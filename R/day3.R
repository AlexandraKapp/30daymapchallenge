# Day 3: Polygon
# Voronoi map

library(sf)
library(dplyr)
library(mapview)
library(osmdata)
library(dismo)
library(tmaptools)

berlin <- st_read("data/berlin.geojson")
e <- st_bbox(berlin)

boulder_gyms <- c("Cliffhanger Boulderlounge Berlin", "Basement Boulderstudio Berlin","Ostbloc Berlin","Boulderworkx Berlin", "Boulderklub Berlin",
                  "Bright Side Berlin","Der Kegel Berlin","Südbloc Berlin","Berta Block Berlin","Bouldergarten Berlin")

gyms_geo <- geocode_OSM(boulder_gyms) %>% 
  dplyr::select(query, lat, lon) %>% 
  rbind(c("Boulderworkx Berlin", 52.486775, 13.318185)) %>% 
  rbind(c("Brigth Side Berlin", 52.481917, 13.365807)) %>% 
  rbind(c("Cliffhanger Boulderlounge Berlin", 52.542148, 13.220973))

vor <- voronoi(gyms_geo[c("lon", "lat")], ext = c(e$xmin, e$xmax, e$ymin, e$ymax)) %>% 
  st_as_sf()
st_crs(vor) <- 4326

intersection_with_berlin <- st_intersection(vor, berlin$geometry)
m <- mapview(intersection_with_berlin, legend = F, layer.name = "area", popup = F) + 
  mapview(st_as_sf(gyms_geo, coords = c("lon", "lat"), crs = 4326), legend = F, layer.name = "Boulder gyms", popup = F)

mapshot(m, "day3.html")

  