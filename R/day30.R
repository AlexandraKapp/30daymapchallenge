# Day 30: a map

# create an own mapbox style and display

library(mapboxapi)
library(leaflet)
library(dplyr)

mapboxAccessToken <- "TOKEN"

leaflet() %>%
  addMapboxTiles(
    access_token = mapboxAccessToken,
    style_id = "ckg5e0r7f3jh119k89aw2m64c",
                 username = "lxndrkpp") %>%
  setView(lng = 9.99,
          lat = 53.5,
          zoom = 11)
