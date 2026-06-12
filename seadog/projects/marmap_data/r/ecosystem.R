library(tidyverse)
library(igraph)

# # build dependency edges
# db <- tools::CRAN_package_db()
# edges <- db |>
#   dplyr::select(Package, Imports, Depends, Suggests)
# 
# # parse dependencies
# parse_deps <- function(pkg, field) {
#   if (is.na(field)) return(NULL)
#   str_split(field, ",\\s*")[[1]] |>
#     trimws() |>
#     data.frame(from = pkg, to = _)
# }
# 
# # build network
# edges_long <- pmap_dfr(
#   list(db$Package, db$Imports),
#   parse_deps
# )
# 
# g <- graph_from_data_frame(edges_long)
# 
# #compute network metrics
# centrality <- tibble(
#   pkg = names(degree(g)),
#   degree = degree(g),
#   betweenness = betweenness(g)
#   )

setwd("~/Documents/GitHub/ericpante.github.io/seadog/projects/marmap_data/data/")
#save(db, parse_deps, edges_long, g, centrality, file="ecosystem.rda")

load(file="ecosystem.rda")
mm_centrality <- centrality |>
  filter(pkg == "marmap")

ggplot(centrality, aes(log(1+degree)))+geom_histogram()
ggplot(centrality, aes(log(1+betweenness)))+geom_histogram()

mm_centrality$degree -> mm_degree
mm_centrality$betweenness -> mm_betweenness

round(length(centrality$degree[centrality$degree>mm_degree]) *100 / length(centrality$degree), 1)  -> mm_degree_p
round(length(centrality$betweenness[centrality$betweenness>mm_betweenness]) *100 / length(centrality$betweenness), 1) -> mm_betweenness_p

