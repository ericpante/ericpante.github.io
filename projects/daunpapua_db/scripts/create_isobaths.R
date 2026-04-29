# Generate bathymetric contour lines for the Quarto/Leaflet app.
# Run this script once before rendering the website. It creates:
#   data/isobaths.geojson
# which is then loaded by scripts/app.js.

library(marmap)
library(sf)

# EDIT THIS PATH to your local GEBCO NetCDF file
gebco_nc <- "~/sdrive/DAUNPAPUA/plannification_2024/16_seadog/GEBCO_28_Apr_2026_3333a9345578/gebco_2026_n-7.0_s-12.0_w145.0_e154.0.nc"

# Output expected by the JavaScript app
out_geojson <- "data/isobaths.geojson"

# Choose contour depths here. Negative values are depths below sea level.
levels <- -seq(100, 1000, by = 50)

bathy <- readGEBCO.bathy(gebco_nc)

# Convert marmap bathymetry object to x/y/z for contourLines()
xyz <- as.xyz(bathy)

x <- sort(unique(xyz$V1))  # longitude
y <- sort(unique(xyz$V2))  # latitude
z <- matrix(xyz$V3, nrow = length(x), ncol = length(y))

iso <- contourLines(
  x = x,
  y = y,
  z = z[, ncol(z):1],
  levels = levels
)

iso_sf <- st_sf(
  level = sapply(iso, `[[`, "level"),
  geometry = st_sfc(
    lapply(iso, function(line) {
      st_linestring(cbind(line$x, line$y))
    }),
    crs = 4326
  )
)

dir.create(dirname(out_geojson), showWarnings = FALSE, recursive = TRUE)
st_write(iso_sf, out_geojson, driver = "GeoJSON", delete_dsn = TRUE)

message("Wrote ", out_geojson)

