### Day 1: Points

library(sf)
library(dplyr)
library(mapdeck)

mapboxAccessToken <- "TOKEN"

# prepare streets data
blocks <- st_read("data/bloecke.shp") %>%
  st_make_valid() # some blocks are not a valid polygon

xhain <- st_read("data/berlin_bz.geojson") %>%
  filter(name == "Friedrichshain-Kreuzberg")

blocks_in_xhain <- st_intersection(blocks, st_transform(xhain$geometry, 25833)) %>%
  st_combine() %>%
  st_make_valid()

streets_xhain <- st_difference(st_transform(xhain$geometry, 25833), blocks_in_xhain)

#### create cars as points
# amount of cars in XHain 80808
# https://s3.kleine-anfragen.de/ka-prod/be/18/20848.pdf

amount_cars_xhain <- 80808

# this takes about a minute
cars <- st_sample(streets_xhain, size = amount_cars_xhain) %>%
  st_transform(4326) %>%
  st_as_sf()

cars <- cars %>%
  mutate(
    lon = st_coordinates(cars)[, 1],
    lat = st_coordinates(cars)[, 2]
  ) %>%
  st_drop_geometry()

map <- mapdeck(
  style = mapdeck_style("dark"),
  location = c(13.43, 52.51, 14),
  zoom = 12,
  min_zoom = 11,
  max_zoom = 15,
  token = mapboxAccessToken
) %>%
  add_scatterplot(
    data = cars,
    lon = "lon",
    lat = "lat",
    fill_colour = "#FFFFFF",
    stroke_colour = "#FFFFFF",
    radius = 2,
    update_view = F
  ) %>%
  add_title(title = list(
    title = "<b>All 80.808 cars registered in XHain mapped onto the streets</b> <br> <span style='font-size:14px'>Data: <a href= https://fbinter.stadt-berlin.de/fb/index.jsp?loginkey=zoomStart&mapId=ISU5@senstadt&bbox=387452,5818178,395140,5822472'>Geopartal Berlin [Blockkarte 1:5000 (ISU5)]</a> & 
                                        <a href='https://s3.kleine-anfragen.de/ka-prod/be/18/20848.pdf'>kleine Anfragen</a> <br> <a href = '../index.html'>< Back to overview</a> </span>",
    css = "font-size: 18px;"
  ))
