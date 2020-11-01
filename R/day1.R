### Day 1: Points

library(sf)
library(leaflet)
library(dplyr)
library(htmlwidgets)
library(htmltools)

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
cars <- st_sample(streets_xhain,size=amount_cars_xhain) %>% 
  st_transform(4326)

map <- leaflet(cars) %>% 
  addProviderTiles(providers$CartoDB.DarkMatter, options = providerTileOptions(minZoom = 14, maxZoom = 15) ) %>%
  setView(13.43, 52.51, 14) %>% 
  addCircleMarkers(radius = 1, fillColor= "white", color = "transparent") %>% 
  addControl(html = paste(tags$div(HTML("<a href = '../index.html'>< Back to overview</a>")),
    tags$h2(HTML("All 80.808 cars registered in XHain mapped onto the streets.")),
                          tags$div(HTML("Data: <a href= https://fbinter.stadt-berlin.de/fb/index.jsp?loginkey=zoomStart&mapId=ISU5@senstadt&bbox=387452,5818178,395140,5822472'>Geopartal Berlin [Blockkarte 1:5000 (ISU5)]</a> & 
                                        <a href='https://s3.kleine-anfragen.de/ka-prod/be/18/20848.pdf'>kleine Anfragen</a>"))),
             position = "bottomleft")

saveWidget(map, file="day1.html")
