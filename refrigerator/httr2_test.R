ncell.lon <- 1
ncell.lat <- 1
database <- "27ETOPO_2022_v1_15s_bed_elev"
    x1 <- -20
    x2 <-  40
    y1 <- 43
    y2 <- 47
    WEB.REQUEST <- paste0("https://gis.ngdc.noaa.gov/arcgis/rest/services/DEM_mosaics/DEM_all/ImageServer/exportImage?bbox=", 
                          x1, ",", y1, ",", x2, ",", y2, "&bboxSR=4326&size=", 
                          ncell.lon, ",", ncell.lat, "&imageSR=4326&format=tiff&pixelType=F32&interpolation=+RSP_NearestNeighbor&compression=LZ77&renderingRule={%22rasterFunction%22:%22none%22}&mosaicRule={%22where%22:%22Name=%", 
                          database, "%27%22}&f=image")
  
    path <- "~/Desktop/tempfile.marmap"
    req <- request(WEB.REQUEST) |> 
      req_progress() |> 
      req_perform(path = path)

    req_retry(max_tries = 5) |> 
      
    download.file(url = WEB.REQUEST, destfile = "tmp.tif", 
                  mode = "wb")
    