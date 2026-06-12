library(jsonlite)
#library(rjson)
library(lubridate)
library(gh)
library(dplyr)
library(tibble)
library(purrr)
library(ggplot2)

###################################################
# github stats
###################################################

owner <- "ericpante"
repo  <- "marmap"

#--------------------------------------------------
# Repository metadata
#--------------------------------------------------

repo_info <- gh(
  "/repos/{owner}/{repo}",
  owner = owner,
  repo = repo
)

#--------------------------------------------------
# Contributors
#--------------------------------------------------

contributors <- gh(
  "/repos/{owner}/{repo}/contributors",
  owner = owner,
  repo = repo,
  .limit = Inf
)

#--------------------------------------------------
# Languages
#--------------------------------------------------

languages <- gh(
  "/repos/{owner}/{repo}/languages",
  owner = owner,
  repo = repo
)

languages_tbl <- enframe(
  unlist(languages),
  name = "language",
  value = "bytes"
) %>%
  mutate(
    pct = round(100 * bytes / sum(bytes), 1)
  ) %>%
  arrange(desc(bytes))

#--------------------------------------------------
# Commits
#--------------------------------------------------

commits <- gh(
  "/repos/{owner}/{repo}/commits",
  owner = owner,
  repo = repo,
  .limit = Inf
)

commit_tbl <- map_dfr(
  commits,
  \(x)
  tibble(
    sha = x$sha,
    author = x$commit$author$name,
    date = as.Date(x$commit$author$date)
  )
)

#--------------------------------------------------
# Summary report
#--------------------------------------------------

summary_tbl <- tibble(
  metric = c(
    "Repository",
    "Description",
    "Created",
    "Last update",
    "Stars",
    "Forks",
    "Watchers",
    "Open issues",
    "Default branch",
    "Contributors",
    "Commits",
    "Main language"
  ),
  value = c(
    repo_info$full_name,
    repo_info$description,
    repo_info$created_at,
    repo_info$updated_at,
    repo_info$stargazers_count,
    repo_info$forks_count,
    repo_info$subscribers_count,
    repo_info$open_issues_count,
    repo_info$default_branch,
    length(contributors),
    nrow(commit_tbl),
    languages_tbl$language[1]
  )
)

###########
summary_tbl
###########


#######################################################
# CLOC lines of code
#######################################################

tmp <- "~/Documents/GitHub/ericpante.github.io/seadog/projects/marmap_data/git"
# 
# # clone repo (no git2r)
# system(sprintf(
#   "git clone https://github.com/ericpante/marmap.git %s",
#   tmp
# ))

system(
  sprintf(
    "cloc %s --json > %s",
    tmp,
    file.path(tmp, "cloc.json")
  )
)

cloc <- jsonlite::fromJSON(
  file.path(tmp, "cloc.json")
)


cloc_tbl <- tibble(
  metric = c("n. of functions", "blank lines", "comment lines", "code lines"),
  
  R = c(
    cloc$R$nFiles,
    cloc$R$blank,
    cloc$R$comment,
    cloc$R$code
  ),
  
  YAML = c(
    cloc$YAML$nFiles,
    cloc$YAML$blank,
    cloc$YAML$comment,
    cloc$YAML$code
  ),
  
  Markdown = c(
    cloc$Markdown$nFiles,
    cloc$Markdown$blank,
    cloc$Markdown$comment,
    cloc$Markdown$code
  ),
  
  SUM = c(
    cloc$SUM$nFiles,
    cloc$SUM$blank,
    cloc$SUM$comment,
    cloc$SUM$code
  )
)
