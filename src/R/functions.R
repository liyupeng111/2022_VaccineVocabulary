
#' Create a formal context from decomposed source codes
#' 
#' A 'formal context' is the input to the FCA algorithm. This function requires a 
#' dataframe as input with one row per source code, and the following columns:
#'  d1, d2, ... d{n}, m1, m2, ..., m{n}
#'  
#'  @details  
#'  Attributes are hierarchical: Disease > Mechanism of action.
#'  Each vaccine can have one or more disease attributes. Each disease can have 0 or 1 associated mechanism-of-action 
#'  attribute. A vaccine with no attributes will be mapped to the top level vaccine concept.
#'  Two vaccines with the same set of attributes will be mapped to the same concept.
#'  Each concept/node in the new hierarchy will be uniquely defined by its set of attributes.
#'  
#' @param df A dataframe with columns vacc_id, disease and mechanism attributes d1, d2, ... d{n}, m1, m2, ..., m{n}
#'
#' @return A dataframe representing the formal context derived from the input
#' @export
#'
#' @examples
#' df <- tibble::tribble(
#' ~vacc_id, ~d1,          ~d2,       ~d3,      ~m1, 
#' 40213190, "poliovirus", NA,        NA,       "poliovirus live",
#' 40213183, "measles",    "mumps",   "rubella", NA,
#' 40213168, "measles",    "rubella", NA,        NA,
#' 40213170, "measles",    NA,        NA,        NA)
#' 
#' ctx <- formal_context(df)
formal_context <- function(df) {

  if(!require(dplyr)) stop("The dplyr package must be installed.\nInstall it with `install.packages('dplyr')`")
  
  checkmate::assert_data_frame(df, min.rows = 1)
  
  df <- select(df, vacc_id, matches("^d|^m")) 
  
  if(ncol(df) < 2) stop("The input must be a dataframe with the following column format: vacc_id, d1, d2, ... m1, m2, ...")
  
  # pivot to long format
  df2 <- df %>% 
    tidyr::gather("key", "value", -vacc_id) %>% 
    tidyr::separate("key", into = c("key", "num"), sep = -1) %>% 
    tidyr::spread("key", "value") %>% 
    rename(disease = d, mechanism = m) %>% 
    filter(!(is.na(disease) & is.na(mechanism))) %>% 
    # remove concepts without a disease/indication since at least one disease attribute is required 
    filter(!is.na(disease)) %>% 
    arrange(vacc_id, num)

  ## Create concepts for all single attributes and all combinations of attributes -------
  
  # single mechanism concepts
  mechanism_single <- df2 %>% 
    filter(!is.na(mechanism)) %>% 
    select(disease, mechanism) %>% 
    distinct()

  # single disease concepts
  disease_single <- df2 %>% 
    mutate(mechanism = NA_character_) %>% 
    filter(!is.na(disease)) %>% 
    select(disease, mechanism) %>% 
    distinct()

  # combination mechanism concepts
  mechanism_combos <- df2 %>% 
    filter(!is.na(mechanism)) %>% 
    group_by(vacc_id) %>% 
    summarise(disease = stringr::str_c(disease, collapse = "|"), mechanism = stringr::str_c(mechanism, collapse = "|"), n = n()) %>% 
    ungroup() %>% 
    filter(n > 1) %>% 
    select(disease, mechanism) %>% 
    distinct()

  # combination disease concepts
  disease_combos <- df2 %>% 
    select(vacc_id, disease) %>% 
    distinct() %>% 
    group_by(vacc_id) %>% 
    summarise(disease = stringr::str_c(disease, collapse = "|"), n = n()) %>% 
    ungroup() %>% 
    filter(n > 1) %>% 
    mutate(mechanism = NA_character_) %>% 
    select(disease, mechanism) %>% 
    distinct()

  # combine all expanded concepts into a single dataframe
  expanded <- bind_rows(select(df2, disease, mechanism),
                        mechanism_single, 
                        mechanism_combos,
                        disease_single,
                        disease_combos) %>% 
    distinct() %>% 
    arrange(disease, mechanism) %>% 
    mutate(id = row_number()) %>% 
    select(id, everything())


  # reformat the concepts into a formal context
  ctx <- expanded %>% 
    tidyr::pivot_longer(cols = c(disease, mechanism)) %>% 
    # select(id, value) %>% 
    mutate(value = stringr::str_split(value, "\\|")) %>% 
    tidyr::unnest(cols = "value") %>% 
    mutate(value = stringr::str_trim(value)) %>% 
    mutate(value = stringr::str_replace_all(value, "\\s|-", "_")) %>% 
    mutate(value = stringr::str_remove_all(value, "\\(|\\)|,")) %>% 
    mutate(x = "X") %>% 
    distinct() %>% 
    filter(!is.na(value)) %>% 
    mutate(value = paste0(toupper(stringr::str_sub(name, 1, 1)), "_", value)) %>% 
    select(-name) %>% 
    tidyr::pivot_wider(names_from = "value", values_from = "x", values_fill = "")
  
  ctx
}


create_concept_tables <- function(ctx) {
  checkmate::assert_data_frame(ctx, min.rows = 1)
  
  reticulate::source_python(file.path("src", "python", "boiler.py"))
  f_in <- tempfile(fileext = ".csv")
  readr::write_csv(ctx, f_in)
  f_out <- tempfile()
  boiler(f_in, f_out)
  concept <- readr::read_csv(paste0(f_out, "concept.csv"), show_col_types = FALSE)
  cr <- readr::read_csv(paste0(f_out, "concept_relationship.csv"), show_col_types = FALSE)

  # # rename top level vaccine  node
  concept <- concept %>%
    mutate(concept_name = ifelse(is.na(concept_name), "Vaccine", concept_name))
  
  # # only include relationships between concepts in the concept table
  cr <- cr %>%
    filter(id_1 %in% concept$id, id_2 %in% concept$id)

  return(list(concept = concept, concept_relationship = cr))
}


create_maps_to <- function(df, concept, warn_unmapped_ids = FALSE) {
  format_attribute <- function(x) {
    x %>%
      stringr::str_trim() %>%
      stringr::str_replace_all("\\s|-", "_") %>%
      stringr::str_remove_all("\\(|\\)|,")
  }
  
  source_code_attributes <- df %>%
    mutate(across(matches("^d|^m"), format_attribute)) %>%
    mutate(across(matches("^d"), ~stringr::str_c("D_", .))) %>%
    mutate(across(matches("^m"), ~stringr::str_c("M_", .))) %>%
    tidyr::unite(col = "attribute_set", sep = "; ", matches("^d|^m"), na.rm = TRUE) %>%
    mutate(attribute_set = stringr::str_split(attribute_set, "; ")) %>%
    select(vacc_id, source_attribute_set = attribute_set) 

  maps_to <- concept %>%
    filter(id > 0) %>%
    mutate(attribute_set = stringr::str_split(concept_name, "; ")) %>%
    select(target_concept_id = id, target_attribute_set = attribute_set) %>%
    # cross join
    dplyr::full_join(source_code_attributes, by = character()) %>%
    mutate(match = purrr::map2_lgl(target_attribute_set, source_attribute_set, setequal)) %>%
    # filter(purrr::map2_lgl(target_attribute_set, source_attribute_set, ~length(.x) == length(.y))) # for debugging
    dplyr::filter(match) %>%
    mutate(source_attribute_set = purrr::map_chr(source_attribute_set, ~stringr::str_c(., collapse = "; "))) %>%
    mutate(target_attribute_set = purrr::map_chr(target_attribute_set, ~stringr::str_c(., collapse = "; "))) %>%
    select(vacc_id, target_concept_id, source_attribute_set, target_attribute_set)

  # each vaccine should be mapped to only one concept
  assertthat::are_equal(nrow(maps_to), n_distinct(maps_to$vacc_id))
  
  mapped_ids <- maps_to$vacc_id
  unmapped_ids <- setdiff(df$vacc_id, mapped_ids)
  
  if (warn_unmapped_ids & length(unmapped_ids) > 0) {
      top_ten <- unmapped_ids[seq(1, min(length(unmapped_ids), 10), by = 1)]
      dots <- if (length(unmapped_ids) > 10) " ..." else ""
      warning(paste(length(unmapped_ids), "ids were not mapped:", paste(top_ten, collapse = ", "), dots))
  } 
  
  maps_to
}


ggplot_hierachy <- function(concept, concept_relationship) {
  if (!require(ggraph)) stop("ggraph is required. Install it with `install.packages('ggraph')`")
  
  # create graph data structure
  nodes <- concept %>% 
    filter(id != 0) %>%  # remove the terminal node of the graph
    mutate(name = concept_name) %>% 
    select(name) %>% 
    mutate(display_name = ifelse(stringr::str_detect(name, "M_"), stringr::str_remove_all(name, "D_\\w+;"), name)) %>% 
    mutate(display_name = stringr::str_trim(display_name)) %>% 
    mutate(node_type = ifelse(stringr::str_detect(name, "M_"), "mechanism", "disease")) 
  
  edges <- concept_relationship %>% 
    mutate(from = id_2, to = id_1) %>% 
    select(from, to) %>% 
    # remove edges from the terminal node
    filter(from > 0, to > 0)
  
  tidygraph::tbl_graph(nodes, edges) %>%
    ggraph('fr') + 
    geom_edge_link(arrow = arrow(angle = 20, length = unit(0.15, "inches"), ends = "last", type = "open")) +
    geom_node_point() + 
    coord_fixed() +
    ggraph::geom_node_text(aes(label = display_name), repel = T, force = 200) +
    ggplot2::theme(panel.background = element_rect(fill = 'white', color = 'white'))
}

plotly_hierachy <- function(concept, concept_relationship, title = "") {
  library(tidygraph)
  library(plotly)
  library(igraph)
  library(igraphdata)
  library(dplyr)
  library(stringr)
  
  # create graph data structure
  nodes <- concept %>% 
    filter(id != 0) %>%  # remove the terminal node of the graph
    mutate(name = concept_name) %>% 
    select(name) %>% 
    mutate(display_name = ifelse(str_detect(name, "M_"), str_remove_all(name, "D_\\w+;"), name)) %>% 
    mutate(display_name = str_trim(display_name)) %>% 
    mutate(node_type = ifelse(str_detect(name, "M_"), "mechanism", "disease")) %>% 
    mutate(color = ifelse(node_type == "mechanism", "#eb3434", "#34b4eb")) # mechanisms are red, diseases are blue.
  
  edges <- concept_relationship %>% 
    mutate(from = id_2, to = id_1) %>% 
    select(from, to) %>% 
    # remove edges from the terminal node
    filter(from > 0, to > 0)
  
  G <- tbl_graph(nodes, edges)
  L <- layout.auto(G)
  
  nm <- G %>% 
    activate(nodes) %>% 
    pull(display_name)
  
  # Blue #34b4eb = disease level concepts
  # Red #eb3434 = mechanism level concepts
  colors <- G %>% activate(nodes) %>% pull(color)
  
  # Create Vertices and Edges
  vs <- V(G)
  es <- as.data.frame(get.edgelist(G))
  
  Nv <- length(vs)
  Ne <- length(es[1]$V1)
  
  # Create Nodes
  Xn <- L[,1]
  Yn <- L[,2]
  
  names(Xn) <- G %>% activate(nodes) %>% pull(name)
  names(Yn) <- G %>% activate(nodes) %>% pull(name)
  
  # network <- plot_ly(x = ~Xn, y = ~Yn, mode = "markers", text = vs$label, hoverinfo = "text")
  network <- plot_ly(x = ~Xn, y = ~Yn, type = "scatter", mode = "markers", text = nm, hoverinfo = "text", marker = list(color = colors))
  
  # Creates Edges
  edge_shapes <- list()
  for(i in 1:Ne) {
    v0 <- es[i,]$V1
    v1 <- es[i,]$V2
    
    edge_shape = list(
      type = "line",
      line = list(color = "#030303", width = 0.3),
      x0 = Xn[v0],
      y0 = Yn[v0],
      x1 = Xn[v1],
      y1 = Yn[v1]
    )
    
    edge_shapes[[i]] <- edge_shape
  }
  
  # Create Network
  axis <- list(title = "", showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE)
  
  fig <- layout(
    network,
    title = title,
    shapes = edge_shapes,
    xaxis = axis,
    yaxis = axis
  )
  fig
}
