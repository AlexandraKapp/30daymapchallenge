# Day 4: Hexagon

library(sf)
library(dplyr)
library(osmdata)
library(mapdeck)

mapboxAccessToken <- "TOKEN"

# Data: https://unfallatlas.statistikportal.de/_opendata2020.html
# Unfallatlas | Statistische Ämter des Bundes und der Länder
accidents <- st_read("/data/Unfallorte2019/Unfallorte2019_LinRef.shp") %>% 
  st_zm()
stuttgart <-   opq(bbox = 'stuttgart germany') %>%
   add_osm_feature(key = 'de:amtlicher_gemeindeschluessel', value = '08111000') %>% 
   osmdata_sf ()
stuttgart <- stuttgart$osm_multipolygons$geometry

accidents_stuttgart_index <- st_intersects(accidents, st_transform(stuttgart, 25832), sparse = F) # st_intersects is faster than st_intersection

accidents_stuttgart <- accidents[accidents_stuttgart_index, ] %>% st_transform(4326)
coords <- st_coordinates(accidents_stuttgart)
accidents_stuttgart["lng"] <- coords[,1]
accidents_stuttgart["lat"] <- coords[,2]

mapdeck( style = mapdeck_style("streets"), token = mapboxAccessToken, pitch = 10) %>%
  add_hexagon(
    data = accidents_stuttgart
    , lat = "lat"
    , lon = "lng"
    , layer_id = "hex_layer"
    , radius = 100
    , elevation_scale = 2
    , colour_range = colourvalues::colour_values(6:1, alpha = 200)
    , legend = T
  )%>%
  add_title(title = list(
    title = "<b>Accidents in Stuttgart</b> <br> <span style='font-size:10px'>Data: <a href=https://unfallatlas.statistikportal.de/_opendata2020.html>Unfallatlas Statistische Aemter</a>
    <br> <a href = '../index.html'>< Back to overview</a> </span>",
    css = "font-size: 14px;"
  ))
