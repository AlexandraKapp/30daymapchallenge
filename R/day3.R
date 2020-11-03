# Day 3: Polygon
# Voronoi map

library(sf)
library(dplyr)
library(mapview)
library(osmdata)
library(dismo)
library(tmaptools)

berlin <- st_read("data/berlin.geojson")

# use CRS 3035 for mapping
berlin <- st_transform(berlin, 3035)
e <- st_bbox(berlin)

boulder_gyms <- c("Cliffhanger Boulderlounge Berlin", "Basement Boulderstudio Berlin","Ostbloc Berlin","Boulderworkx Berlin", "Boulderklub Berlin",
                  "Bright Side Berlin","Der Kegel Berlin","Südbloc Berlin","Berta Block Berlin","Bouldergarten Berlin")

# gecode gyms and manually fix the ones that are not found
gyms_geo <- geocode_OSM(boulder_gyms) %>% 
  dplyr::select(query, lat, lon) %>% 
  rbind(c("Boulderworkx Berlin", 52.486775, 13.318185)) %>% 
  rbind(c("Brigth Side Berlin", 52.481917, 13.365807)) %>% 
  rbind(c("Cliffhanger Boulderlounge Berlin", 52.542148, 13.220973))

gyms_geo <- st_as_sf(gyms_geo, coords = c("lon", "lat"), crs = 4326) %>% st_transform(3035)
gyms_coords <- st_coordinates(gyms_geo)
gyms_geo$lon <- gyms_coords[, 1]
gyms_geo$lat <- gyms_coords[, 2]

# create voronoi map
vor <- voronoi(st_drop_geometry(gyms_geo[c("lon", "lat")]), ext = c(e$xmin, e$xmax, e$ymin, e$ymax)) %>% 
  st_as_sf() %>% 
  cbind(gyms_geo$query)
st_crs(vor) <- 3035
intersection_with_berlin <- st_intersection(vor, berlin$geometry) %>% dplyr::select(gyms_geo.query)

# convert back to CRS 4326 for mapping
intersection_with_berlin <- st_transform(intersection_with_berlin, 4326)
gyms_geo <- st_transform(gyms_geo, 4326)

m <- mapview(intersection_with_berlin, legend = F, layer.name = "area", popup = F ) + 
  mapview(dplyr::select(gyms_geo, -lon, -lat), legend = F, layer.name = "Boulder gyms", popup = F)

mapshot(m, "html/day3.html")
