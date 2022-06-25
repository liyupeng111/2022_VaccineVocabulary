Vaccine concepts in the OMOP CDM Vocabulary lack a comprehensive and
consistent hierarchy. In 2021 the vaccine vocabulary working group
manually constructed a high-level vocabulary hierarchy for vaccine
concepts. However, a manually curated hierarchy is difficult to maintain
and scale up with proper quality control considering the large number
concepts in existing vaccine vocabularies such as RxNorm and RxNorm
Extension. An automated approach is needed to facilitate the creation of
a high-quality and practically useful vocabulary hierarchy. We utilized
Formal Concept Analysis (FCA), a computational method for automatically
creating concept hierarchies rooted in the mathematical theory of
lattices, to build a vaccine vocabulary. The required inputs are simply
the vaccine source codes with the vaccine attributes (e.g., indication,
administration route, and dosing). All nodes/concepts,
linkage/hierarchical relationships between nodes and mappings from
source to standard concepts are generated automatically.

The FCA method requires all vaccine source codes along with their
relevant attributes as input. Given a large number of vaccine source
codes in multiple vocabularies (e.g. CVX, NDC, CPT, and ICD Procedure),
we used a subset of CVX, HCPCS, CPT, and ICD Procedure codes with two
vaccine attributes (indication and mechanism of action) for feasibility
demonstration. An example of the input structure is shown below.

    df <- tibble::tribble(
      ~vacc_id, ~d1,          ~d2,       ~d3,      ~m1, 
      40213190, "poliovirus", NA,        NA,       "poliovirus live",
      40213183, "measles",    "mumps",   "rubella", NA,
      40213168, "measles",    "rubella", NA,        NA,
      40213170, "measles",    NA,        NA,        NA)

    df

    ## # A tibble: 4 × 5
    ##    vacc_id d1         d2      d3      m1             
    ##      <dbl> <chr>      <chr>   <chr>   <chr>          
    ## 1 40213190 poliovirus <NA>    <NA>    poliovirus live
    ## 2 40213183 measles    mumps   rubella <NA>           
    ## 3 40213168 measles    rubella <NA>    <NA>           
    ## 4 40213170 measles    <NA>    <NA>    <NA>

First we create a table with all unique combinations of indication and
mechanism of action in the input. Attributes that are not explicitly
encoded in the decomposition of the input source codes are ignored. Two
source codes with the same set of attributes are considered to be the
same vaccine and mapped to the same concept in the new hierarchy. This
table is known as a “formal context” in Formal Concept Analysis
parlance.

    source("src/R/functions.R")
    ctx <- formal_context(df)

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ctx

    ## # A tibble: 7 × 6
    ##      id D_measles D_mumps D_rubella D_poliovirus M_poliovirus_live
    ##   <int> <chr>     <chr>   <chr>     <chr>        <chr>            
    ## 1     1 "X"       ""      ""        ""           ""               
    ## 2     2 "X"       "X"     "X"       ""           ""               
    ## 3     3 "X"       ""      "X"       ""           ""               
    ## 4     4 ""        "X"     ""        ""           ""               
    ## 5     5 ""        ""      ""        "X"          "X"              
    ## 6     6 ""        ""      ""        "X"          ""               
    ## 7     7 ""        ""      "X"       ""           ""

Next we use FCA to create the concept and concept\_relationship tables
that define the hierarchical relationships (i.e. ‘Is a’ relationship).

    tbls <- create_concept_tables(ctx)
    tbls

    ## $concept
    ## # A tibble: 9 × 2
    ##      id concept_name                                                  
    ##   <dbl> <chr>                                                         
    ## 1     0 D_measles; D_mumps; D_rubella; D_poliovirus; M_poliovirus_live
    ## 2     1 D_measles; D_mumps; D_rubella                                 
    ## 3     2 D_poliovirus; M_poliovirus_live                               
    ## 4     3 D_measles; D_rubella                                          
    ## 5     4 D_mumps                                                       
    ## 6     5 D_poliovirus                                                  
    ## 7     6 D_measles                                                     
    ## 8     7 D_rubella                                                     
    ## 9     8 Vaccine                                                       
    ## 
    ## $concept_relationship
    ## # A tibble: 11 × 3
    ##     id_1 relationship  id_2
    ##    <dbl> <chr>        <dbl>
    ##  1     0 Is a             1
    ##  2     0 Is a             2
    ##  3     1 Is a             3
    ##  4     1 Is a             4
    ##  5     2 Is a             5
    ##  6     3 Is a             6
    ##  7     3 Is a             7
    ##  8     4 Is a             8
    ##  9     5 Is a             8
    ## 10     6 Is a             8
    ## 11     7 Is a             8

Finally we generate mappings by matching the attribute list of the
sources to the attribute list of the target concepts. Decomposed source
codes will be mapped to the concept that has the exact same set of
attributes.

    maps_to <- create_maps_to(df, tbls$concept)
    maps_to

    ## # A tibble: 4 × 4
    ##    vacc_id target_concept_id source_attribute_set            target_attribute_s…
    ##      <dbl>             <dbl> <chr>                           <chr>              
    ## 1 40213183                 1 D_measles; D_mumps; D_rubella   D_measles; D_mumps…
    ## 2 40213190                 2 D_poliovirus; M_poliovirus_live D_poliovirus; M_po…
    ## 3 40213168                 3 D_measles; D_rubella            D_measles; D_rubel…
    ## 4 40213170                 6 D_measles                       D_measles

The result can be visualized using ggraph. Nodes are uniquely identified
by their set of attributes. Disease/indication level nodes begin with
“D\_” and mechanism level nodes begin with “M\_”.

    ggplot_hierachy(tbls$concept, tbls$concept_relationship)

    ## Loading required package: ggraph

    ## Loading required package: ggplot2

![](readme_files/figure-markdown_strict/unnamed-chunk-5-1.png)

For larger graphs we can use use plotly display node labels only when
the cursor is hovering over a node.

    plotly_hierachy(tbls$concept, tbls$concept_relationship, title = "Example Vaccine Hierarchy")

    ## 
    ## Attaching package: 'tidygraph'

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## 
    ## Attaching package: 'plotly'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     last_plot

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## The following object is masked from 'package:graphics':
    ## 
    ##     layout

    ## 
    ## Attaching package: 'igraph'

    ## The following object is masked from 'package:plotly':
    ## 
    ##     groups

    ## The following object is masked from 'package:tidygraph':
    ## 
    ##     groups

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     as_data_frame, groups, union

    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum

    ## The following object is masked from 'package:base':
    ## 
    ##     union

<div id="htmlwidget-9265e0e700e8001efbd0" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-9265e0e700e8001efbd0">{"x":{"visdat":{"c8ab6f51364b":["function () ","plotlyVisDat"]},"cur_data":"c8ab6f51364b","attrs":{"c8ab6f51364b":{"x":{},"y":{},"mode":"markers","text":["D_measles; D_mumps; D_rubella","M_poliovirus_live","D_measles; D_rubella","D_mumps","D_poliovirus","D_measles","D_rubella","Vaccine"],"hoverinfo":"text","marker":{"color":["#34b4eb","#eb3434","#34b4eb","#34b4eb","#34b4eb","#34b4eb","#34b4eb","#34b4eb"]},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"Example Vaccine Hierarchy","shapes":[{"type":"line","line":{"color":"#030303","width":0.3},"x0":10.5007665076543,"y0":13.3684116217837,"x1":9.22475772774,"y1":12.8527061339669},{"type":"line","line":{"color":"#030303","width":0.3},"x0":9.729565392555,"y0":11.5522739738152,"x1":9.22475772774,"y1":12.8527061339669},{"type":"line","line":{"color":"#030303","width":0.3},"x0":12.2646082475363,"y0":9.69519909063449,"x1":13.0081478306501,"y1":8.48555274301838},{"type":"line","line":{"color":"#030303","width":0.3},"x0":10.9030209006687,"y0":12.350796455866,"x1":10.5007665076543,"y1":13.3684116217837},{"type":"line","line":{"color":"#030303","width":0.3},"x0":11.7544096319607,"y0":12.7385117319387,"x1":10.5007665076543,"y1":13.3684116217837},{"type":"line","line":{"color":"#030303","width":0.3},"x0":11.3262923874643,"y0":11.2325018659476,"x1":9.729565392555,"y1":11.5522739738152},{"type":"line","line":{"color":"#030303","width":0.3},"x0":11.3262923874643,"y0":11.2325018659476,"x1":12.2646082475363,"y1":9.69519909063449},{"type":"line","line":{"color":"#030303","width":0.3},"x0":11.3262923874643,"y0":11.2325018659476,"x1":10.9030209006687,"y1":12.350796455866},{"type":"line","line":{"color":"#030303","width":0.3},"x0":11.3262923874643,"y0":11.2325018659476,"x1":11.7544096319607,"y1":12.7385117319387}],"xaxis":{"domain":[0,1],"automargin":true,"title":"","showgrid":false,"showticklabels":false,"zeroline":false},"yaxis":{"domain":[0,1],"automargin":true,"title":"","showgrid":false,"showticklabels":false,"zeroline":false},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[9.22475772774,13.0081478306501,10.5007665076543,9.729565392555,12.2646082475363,10.9030209006687,11.7544096319607,11.3262923874643],"y":[12.8527061339669,8.48555274301838,13.3684116217837,11.5522739738152,9.69519909063449,12.350796455866,12.7385117319387,11.2325018659476],"mode":"markers","text":["D_measles; D_mumps; D_rubella","M_poliovirus_live","D_measles; D_rubella","D_mumps","D_poliovirus","D_measles","D_rubella","Vaccine"],"hoverinfo":["text","text","text","text","text","text","text","text"],"marker":{"color":["#34b4eb","#eb3434","#34b4eb","#34b4eb","#34b4eb","#34b4eb","#34b4eb","#34b4eb"],"line":{"color":"rgba(31,119,180,1)"}},"type":"scatter","error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"line":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>

## Additional resources

A complete description of the algorithm using all vaccine source codes
evaluated to date is available in “extras/Algorithm\_walkthrough.Rmd”

A SQL script that attemps to automatically extract the decomposed
attributes from vaccine source codes is available in the
“extras/Decomposition” folder.

The full output that has been generated using this approach to date is
available in the “output” folder.
