### prepare the photos database in the form of photo.csv and resize photos
library(progress)
library(magick)

# prepare db
setwd("~/Documents/data/DAUNPAPUA_PHOTOS/stations")
list.files() -> st

STATION = photo = NULL
for (i in st){
  list.files(i, include.dirs = T, pattern="*.JPG", recursive=T) -> list.photos
  paste(i,"/",list.photos,sep="") -> list.photos2
  rep(i,length(list.photos)) -> vec.station
  STATION = c(STATION, vec.station)
  photo = c(photo, list.photos2)
}
data.frame(STATION, photo) -> photo.db
write.table(photo.db, "~/Documents/GitHub/ericpante.github.io/seadog/projects/daunpapua_db/data/photos.csv", row.names = F, col.names = T, sep=",")

# resize images

original.photo <- image_read(photo.db$photo[10])
print(original.photo)
image_write(
  original.photo, 
  path="~/Desktop/test.jpeg", 
  format="jpeg", 
  quality=25
  )

pb <- progress_bar$new(
  format = "  processed :current/:total photos [:bar] :percent",
  total = length(photo.db$photo),
  clear = FALSE,
  width = 60
)
for (i in photo.db$photo){
  original.photo <- image_read(i)
  resized.path = paste("~/Documents/GitHub/ericpante.github.io/seadog/projects/daunpapua_db/photos/",i, sep="")
  if (!dir.exists(dirname(resized.path))) dir.create(dirname(resized.path), recursive = TRUE, showWarnings = FALSE)
  image_write(original.photo, path=resized.path, format="jpeg", quality=25)
  pb$tick()
}


