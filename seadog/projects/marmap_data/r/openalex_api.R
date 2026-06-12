library(openalexR)
library(tidyverse)
library(plotly)
library(wordcloud2)

setwd("~/Documents/GitHub/ericpante.github.io/seadog/projects/marmap_data/data")

erics_openalex_api_key="WpMQAtWTG5pXApjl5OPaxS"
options(openalexR.apikey = erics_openalex_api_key)

# openalex ID for marmap paper: https://openalex.org/W2091437452
# marmap_cites<- oa_fetch(
#   entity = "works",
#   cites = "https://openalex.org/W2091437452",
#   verbose = TRUE
# )
# 
# save(marmap_cites,
#     file = "marmap_cites_OpenAlex_API_2026-06-07.rda"
# )

# OpenAlex Stats
load("marmap_cites_OpenAlex_API_2026-06-07.rda")

# remove false positives
marmap_cites <- marmap_cites[!(marmap_cites$publication_year<2010), ]

# number of papers
dim(marmap_cites)[1] -> n.citations

# number of unique authors
all_orcids <- marmap_cites$authorships |>
  map("orcid") |>
  unlist() |>
  na.omit() |>
  unique()
length(all_orcids) -> n.authors

# percent open access
marmap_cites$is_oa -> OA
length(OA[OA==TRUE])*100/length(OA) -> percent.oa

# citations / year
gg.marmap <- ggplot(marmap_cites, 
                    aes(x=publication_year)
                    ) +
              geom_bar(fill="#49788C") +
              labs(x="Publication Year", 
                   y="Number of citations")

# keywords
marmap_keywords <- marmap_cites$keywords |>
  map("display_name") |>
  unlist() |>
  as_tibble() |> 
  count(value)

marmap_keywords %>% wordcloud2()

# key topics

# look at 
# work$primary_topic
# work$topics
# work$concepts

marmap_topics <- unnest(
  marmap_cites,
  topics,
  names_sep = "_primary_topic"
)

topic_counts <- marmap_topics$topics_primary_topicdisplay_name |>
  as_tibble() |> 
  count(value) |>
  arrange(desc(n)) 

ggplot(topic_counts[topic_counts$n>10, ], aes(x=n)) +
  geom_bar()

SIZE=30
topic_counts[topic_counts$n>SIZE, ] -> df
topics <- ggplot(df, aes(x = n, 
                         y = reorder(value, n), 
                         text = paste0(value, "<br>", n)
                         )
                 ) +
  geom_col(fill = "#49788C") +
  labs(
    x = "Number of topic occurrences in openalex",
    y = paste0("Top topics (n>",SIZE,")")
  )

# types of citation citing marmap

marmap_types <- unnest(
  marmap_cites,
  type,
  names_sep = "_type"
)

type_counts <- marmap_types$type |>
  as_tibble() |> 
  count(value) |>
  arrange(desc(n)) 

types <- ggplot(type_counts, aes(x = n, 
                         y = reorder(value, n), 
                         text = paste0(value, "<br>", n)
)
) +
  geom_col(fill = "#49788C") +
  labs(
    x = "Number of occurrences in openalex",
    y = "Publication type"
  )


# types of institutions citing marmap

affiliations <- marmap_cites |>
  select(work_id = id, authorships) |>
  unnest(authorships) |>
  unnest(affiliations, names_sep = "_aff") |>
  filter(!is.na(affiliations_afftype)) |>
  count(affiliations_afftype, sort = TRUE)

aff <- ggplot(affiliations, aes(x = n, 
                                 y = reorder(affiliations_afftype, n), 
                                 text = paste0(affiliations_afftype, "<br>", n)
)
) +
  geom_col(fill = "#49788C") +
  labs(
    x = "Number of occurrences in openalex",
    y = "Affiliation type"
  )

