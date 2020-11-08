# Day 8: yellow

library(sp)
library(raster)
library(dplyr)
library(leaflet)
library(leafem)
library(htmltools)

hours_of_sunshine <- read.asciigrid("data/sunhours_de.asc") %>% 
  raster() %>% 
  round()
crs(hours_of_sunshine) <- CRS("+init=epsg:31467")

pal <- colorNumeric( c( "#0D2B2A1A", "#E9C72999", "#F5EBC6FF"), 
                     c(min(values(hours_of_sunshine), na.rm = T), max(values(hours_of_sunshine), na.rm = T)),
                     na.color = "transparent")
  leaflet() %>% 
    addProviderTiles(providers$CartoDB.DarkMatter ) %>%
    addRasterImage(hours_of_sunshine, colors =  pal, group = "hours of sunshine", opacity = 0.8) %>% 
    addImageQuery(hours_of_sunshine, layerId = "hours of sunshine") %>% 
    addLegend(pal = pal, values = c(min(values(hours_of_sunshine), na.rm = T), max(values(hours_of_sunshine), na.rm = T))) %>% 
    addControl(html = paste(tags$div(HTML("<a href = '../index.html'>< Back to overview</a>")),
                            tags$h2(HTML("Hours of sunshine in 2019")),
                            tags$div(HTML("Data: <a href= 'https://opendata.dwd.de/climate_environment/CDC/grids_germany/annual/sunshine_duration/'>DWD Climate Data Center (CDC), Jahressumme der Raster der monatlichen Sonnenscheindauer für
Deutschland, Version v1.1.</a>"))),
               position = "bottomleft")
