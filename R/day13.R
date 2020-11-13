# Day 13 Raster
# Get WMS layer into leaflet

library(httr)
library(dplyr)
library(raster)
library(leaflet)
library(htmltools)

# get correct parameters for query by using getCapabilities (with this URL)
# https://fbinter.stadt-berlin.de/fb/wms/senstadt/wmsk_07_05_14verkehr_gesDEN2016?request=getCapabilities&service=WMS

url_wms <- "https://fbinter.stadt-berlin.de/fb/wms/senstadt/wmsk_07_05_14verkehr_gesDEN2016"
url <- httr::parse_url(url_wms)

url$query <- list(version = "1.1.1",
                  request = "GetMap",
                  SRS = "EPSG:4258",
                  bbox = "13.08,52.33,13.77,52.69",
                  width = 800,
                  height = 600,
                  layers = 2, # get "Name" of layer from getCapabilities
                  styles = "default",
                  format = "image/png")

request <- httr::build_url(url)

r <- raster::stack(request)
extent(r) <- c(13.08,13.77,52.33,52.69)
crs(r) <- CRS("+init=EPSG:4258")

leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  leafem::addRasterRGB(r, r= 1, g=2, b=3, opacity = 0.7) %>% 
  addControl(html = paste(tags$div(HTML("<a href = '../index.html'>< Back to overview</a>")),
                          tags$h3(HTML("Noise in Berlin")),
                          tags$div(HTML("Data: <a href=
                                        'https://fbinter.stadt-berlin.de/fb/index.jsp?loginkey=zoomStart&mapId=wmsk_07_05_14verkehr_gesDEN2016@senstadt&bbox=13,52,13,52'>
                                        Geodatenportal Berlin: Strat. Lärmkarte Gesamtlärmindex L_DEN (Tag-Abend-Nacht) Raster 2017 (Umweltatlas)</a>"))),
             position = "bottomleft")
             