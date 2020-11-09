# 9: Monochrome

## finding the main streets of a city: 
# do random 500 x 500 routes and plot thickness of overlapping lines

library(sf)
library(dplyr)

library(osrm)
library(stplanr)

library(leaflet)
library(htmltools)

# get 500 random routings

berlin <- st_read("data/berlin_bz.geojson")

start_points <- st_sample(berlin,size=500) %>% st_as_sf
end_points <- st_sample(berlin,size=500) %>% st_as_sf

# the routing takes a few minutes
routes <- route(from = start_points, 
                to = end_points, 
                route_fun = osrmRoute,
                returnclass = "sf")

routes["count"] <- 1

overlapping_segments <- overline(routes, attrib = "count")

leaflet(overlapping_segments) %>% 
  addProviderTiles(providers$CartoDB.DarkMatter) %>%
  addPolylines(weight = overlapping_segments$count / 4, color = "white") %>% 
  addControl(html = paste(tags$div(HTML("<a href = '../index.html'>< Back to overview</a>")),
                          tags$h2(HTML("The life lines of Berlin")),
                          tags$div(HTML("What are the major streets in Berlin? Routing of 500 random points to 500 random points reveals the most commonly used streets.")),
                          tags$div(HTML("Thanks to the <a href= 'https://github.com/ropensci/stplanr'>stplanr Package</a>!"))),
             position = "bottomleft")
