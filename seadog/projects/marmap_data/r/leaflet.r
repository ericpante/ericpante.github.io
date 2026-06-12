# maps of authors citing marmap
# This code is run AFTER openalex_api.R, which loads the data 
library(tidyverse)
library(httr2)
library(sf)
library(leaflet)
library(rnaturalearth)
library(viridis)
##############################################################################

get_doi_metadata = function(DOI){
  # URL-encode the DOI
  doi_encoded <- URLencode(paste0("https://doi.org/", DOI), reserved = TRUE)
  url <- paste0("https://api.openalex.org/works/",doi_encoded)
  # query openalex
  work <- request(url) |>
    req_error(is_error = function(work) FALSE) |>
    req_perform()
  type <- resp_headers(work)[["content-type"]]
  if (is.null(type) || !grepl("json", type)) {
    return(NULL)
  }
  return(resp_body_json(work))
}

get_countries = function(WORK){
  countries <- unique(unlist(
    lapply(WORK$authorships, function(auth) {
      sapply(auth$institutions, function(inst) inst$country_code)
    })
  ))
  return(countries)
}

##############################################################################


# mm_countries = NULL
# for (doi in marmap_cites$doi){
#   get_doi_metadata(doi) -> mt
#   get_countries(mt) -> cnt
#   mm_countries = c(mm_countries, cnt)
# }
setwd("~/Documents/GitHub/ericpante.github.io/seadog/projects/marmap_data/data/")
# save(mm_countries, file="countries.rda")

load("countries.rda")

country_counts <- tibble(iso_a2_eh = mm_countries) %>%
  count(iso_a2_eh, name = "n")

sf_countries <- ne_countries(scale = "medium", returnclass = "sf")

polygons <- sf_countries %>%
  filter(iso_a2_eh %in% unique(mm_countries)) %>%
  left_join(country_counts, by = "iso_a2_eh") %>%
  mutate(n = ifelse(is.na(n), 0, n))

