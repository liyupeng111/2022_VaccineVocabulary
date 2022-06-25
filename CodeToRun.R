# Map inputs (decomposed source codes) to outputs (concept, concept_relationship, maps_to tables)

source("src/R/functions.R")

df <- readr::read_tsv("input/decomposed_source_codes.tsv")

ctx <- formal_context(df)

tbls <- create_concept_tables(ctx)

maps_to <- create_maps_to(df, tbls$concept)


readr::write_csv(tbls$concept, "output/concept.csv")
readr::write_csv(tbls$concept_relationship, "output/concept_relationship.csv")
readr::write_csv(maps_to, "output/maps_to.csv")
