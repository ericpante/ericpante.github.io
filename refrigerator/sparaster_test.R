bathy_to_spatraster <- function(x, crs = "EPSG:4326") {
  if (!inherits(x, "bathy")) stop("x must be of classe 'bathy' (marmap).")
  if (!requireNamespace("terra", quietly = TRUE)) stop("Package 'terra' required.")
  
  m <- unclass(x)
  if (!is.matrix(m)) m <- as.matrix(m)
  
  lon <- suppressWarnings(as.numeric(rownames(m)))
  lat <- suppressWarnings(as.numeric(colnames(m)))
  
  if (anyNA(lon) || length(lon) != nrow(m)) stop("Longitudes unreadable: the bathy object has non-numerical rownames.")
  if (anyNA(lat) || length(lat) != ncol(m)) stop("Latitudes unreadable: the bathy object has non-numerical colnames.")
  
  dx <- stats::median(abs(diff(lon)))
  dy <- stats::median(abs(diff(lat)))
  if (!is.finite(dx) || dx == 0 || !is.finite(dy) || dy == 0) stop("Invalid grid resolution (dx/dy).")
  
  # Emprise sur les bords des pixels
  xmin <- min(lon) - dx / 2
  xmax <- max(lon) + dx / 2
  ymin <- min(lat) - dy / 2
  ymax <- max(lat) + dy / 2
  
  r <- terra::rast(t(m))
  terra::ext(r) <- terra::ext(xmin, xmax, ymin, ymax)
  terra::crs(r) <- crs
  
  # Orientation
  if (lat[1] < lat[length(lat)]) r <- terra::flip(r, "vertical")
  if (lon[1] > lon[length(lon)]) r <- terra::flip(r, "horizontal")
  
  r
}

library(tidyverse)
library(marmap)
library(terra)
library(tidyterra)

data("hawaii")
rr <- bathy_to_spatraster(hawaii)
rr

ggplot() +
  geom_spatraster(data = rr) +
  geom_spatraster_contour(data = rr, colour = "black", linewidth = 0.2) +
  scale_fill_viridis_c(name = "Altitude/depth (m)") +
  coord_sf(expand = FALSE) +
  theme_minimal()
