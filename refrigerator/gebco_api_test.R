install.packages("httr2")
library(httr2)

resp <- request("https://<API-ENDPOINT>/gebco") |>
  req_url_query(
    lon = "3.88",
    lat = "43.61",
    mode = "point"
  ) |>
  req_perform()

json <- resp_body_json(resp)