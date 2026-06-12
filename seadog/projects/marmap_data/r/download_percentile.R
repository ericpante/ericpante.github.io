# download percentile stats

library(cranlogs)
library(dplyr)
library(purrr)

# list of CRAN packages
tools::CRAN_package_db() -> all_pkgs
pkgs <- all_pkgs[,1]

# download stats
downloads <- map_dfr(pkgs, \(p) {
  data.frame(
    package = p,
    downloads = cran_downloads(p, when = "last-day")$count
  )
})

marmap_dl <- downloads %>%
  filter(package == "marmap") %>%
  pull(downloads)

downloads <- downloads %>%
  mutate(
    percentile = percent_rank(downloads) * 100
  )

downloads %>%
  filter(package == "marmap")

marmap_percentile <- mean(downloads$downloads <= marmap_dl) * 100
marmap_percentile

library(ggplot2)

ggplot(downloads, aes(x = downloads)) +
  geom_histogram(bins = 20) +
  geom_vline(xintercept = marmap_dl, color = "red") +
  theme_minimal()