# Day 11: 3D

  
library(mapdeck)
library(raster)
library(slippymath)
library(sf)

token <- "TOKEN"
set_token(token)

# https://docs.mapbox.com/help/troubleshooting/access-elevation-data/
elevation <- paste0("https://api.mapbox.com/v4/mapbox.terrain-rgb/5/16/11@2x.pngraw?access_token=", token)
texture <- paste0("https://api.mapbox.com/v4/mapbox.satellite/5/16/11@2x.jpg90?access_token=", token)


# get the bounding box of the desired tile in the alpes
bbox_for_tile <- st_bbox(st_point(c(10.8, 46.8)))
tile <- bbox_to_tile_grid(bbox_for_tile, zoom = 5)
bbox_tile <- tile_grid_bboxes(tile)
bbox_tile <- bbox_tile[[1]]

p1<- st_point(c(bbox_tile[1], bbox_tile[2])) %>% 
  st_sfc(crs = 3857) %>% 
  st_transform(4326)
p2 <- st_point(c(bbox_tile[3], bbox_tile[4])) %>% 
  st_sfc(crs = 3857) %>% 
  st_transform(4326)

bounds <- c(st_coordinates(p1), st_coordinates(p2))

mapdeck(pitch = 70, zoom = 6, location = c(6, 47), style = mapdeck_style("satellite")) %>%
  add_terrain(
    , elevation_data = elevation
    , elevation_decoder = c(65536,256,1, -100000)
    , texture = texture
    , bounds = bounds
    , max_error = 1
    , update_view = F
  )

mapview::mapview(p1) + p2