# Day 14: Climate change

library(sf)
library(dplyr)
library(leafpm)
library(mapview)

# https://www.faszination-regenwald.de/info-center/zerstoerung/flaechenverluste/
destroyed_rainforest_area <- 121500000000

# create a square on top of berlin center
bl <- st_read("data/berlin_bz.geojson") %>% 
  st_transform(3035) %>% 
  st_centroid()

ne <- berlin_center$geometry + c(sqrt(destroyed_rainforest_area) / 2, sqrt(destroyed_rainforest_area) / 2)
sw <- berlin_center$geometry - c(sqrt(destroyed_rainforest_area) / 2, sqrt(destroyed_rainforest_area) / 2)
se <- berlin_center$geometry + c(sqrt(destroyed_rainforest_area) / 2, - sqrt(destroyed_rainforest_area) / 2)
nw <- berlin_center$geometry - c(sqrt(destroyed_rainforest_area) / 2, - sqrt(destroyed_rainforest_area) / 2)
rainforest_area <- st_cast(st_combine(c(ne,se,sw,nw)), "POLYGON") %>% 
  st_sf() %>% 
  cbind(label = "destroyed rainforest area 2019: 121.500 km²")

st_crs(rainforest_area) <- 3035

addPmToolbar(
  toolbarOptions = pmToolbarOptions(drawMarker = FALSE,
                                    drawPolygon = FALSE,
                                    drawPolyline = FALSE,
                                    drawRectangle = FALSE,
                                    drawCircle = FALSE,
                                    editMode = FALSE,
                                    cutPolygon = FALSE,
                                    removalMode = FALSE),
  mapview(rainforest_area, color = "transparent", col.regions = "red", alpha.regions = 0.4, popup = F)@map,
  targetGroup = "rainforest_area"
)
