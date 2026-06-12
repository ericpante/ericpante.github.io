# get community statistics from stackoverflow api

# API KEY
"rl_pJZ41E9oy1XsEabzQmUjiRMuK"
# usethis::edit_r_environ()

library(httr2)
library(dplyr)

library(httr)
library(dplyr)

get_stack_metrics <- function(keyword) {
  
  api_key <- Sys.getenv("STACK_API_KEY")
  
  page <- 1
  has_more <- TRUE
  all_items <- list()
  
  while(has_more) {
    
    r <- GET(
      "https://api.stackexchange.com/2.3/search/advanced",
      query = list(
        q = keyword,
        site = "stackoverflow",
        pagesize = 100,
        page = page,
        key = api_key
      ),
      httr::user_agent("R package marmap impact analysis (pante.eric@gmail.com)")
    )
    
    res <- content(r, "parsed", simplifyVector = TRUE)
    
    if(length(res$items) > 0)
      all_items[[length(all_items)+1]] <- res$items
    
    has_more <- isTRUE(res$has_more)
    page <- page + 1
  }
  
  df.marmap <- bind_rows(all_items)

  n_questions = nrow(df.marmap)
  n_answers = sum(df.marmap$answer_count)
  total_views = sum(df.marmap$view_count)
  median_views = median(df.marmap$view_count)
  answered_rate = mean(df.marmap$is_answered)
  avg_score = mean(df.marmap$score)
  
  return(c(keyword,
           n_questions,
           n_answers,
           total_views,
           answered_rate,
           avg_score
           ))  
  # tibble(
  #   keyword = keyword,
  #   n_questions = nrow(df.marmap),
  #   n_answers = sum(df.marmap$answer_count),
  #   total_views = sum(df.marmap$view_count),
  #   median_views = median(df.marmap$view_count),
  #   answered_rate = mean(df.marmap$is_answered),
  #   avg_score = mean(df.marmap$score)
  # )
}

# stats for marmap itself
get_stack_metrics("marmap") -> res.marmap

# remove functions matching other packages
list.files("~/Documents/GitHub/ericpante.github.io/seadog/projects/marmap_data/git/R/")[-c(32,38,3)] -> functions
sub(".R","", functions) -> function.names
res=NULL
for (i in function.names){
  res = rbind(res, get_stack_metrics(i))
}

# formating the results
rbind(res,res.marmap) -> all.res
as_tibble(all.res) -> tibble.all.res
colnames(tibble.all.res) <- c(
                              "keyword",
                              "n_questions",
                              "n_answers",
                              "total_views",
                              "answered_rate",
                              "avg_score"
                            )
