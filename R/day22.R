# Day 22: Movement

# data: https://www.vbb.de/unsere-themen/vbbdigital/api-entwicklerinfos/datensaetze

library(tidytransit)
library(dplyr)
library(mapdeck)
library(sf)

set_token("TOKEN")
# ubahn
# route_name, start_time, end_time, linestring
gtfs <- read_gtfs("data/vbb_gtfs.zip")

# get all service_ids for mondays
all_mondays <- gtfs$calendar %>% 
  filter(monday == 1) %>% 
  pull(service_id)

# select trips that are U-Bahn on mondays
selected_trips <- gtfs$routes %>% 
  filter(route_type == "400") %>% # only use U-Bahn
  left_join(gtfs$trips, by = "route_id") %>% 
  filter(service_id %in% all_mondays) # only take trips on mondays

# get linestrings for routes
selected_shapes <- gtfs$shapes %>% 
  filter(shape_id %in% unique(selected_trips$shape_id) )
shapes <- shapes_as_sf(selected_shapes)

# df for ubahn with linestring, start and end time
ubahn <- selected_trips %>% 
  left_join (gtfs$stop_times, by = "trip_id") %>%
  arrange(trip_id, stop_sequence) %>% 
  select(trip_id, route_id, shape_id, route_short_name, departure_time) %>% 
  group_by(trip_id, route_id, route_short_name, shape_id) %>% 
  summarise(starttime = first(departure_time),
            endtime = last(departure_time)) %>% 
  left_join(shapes, by = "shape_id") %>% 
  st_as_sf() %>% 
  mutate(start_timestamp =  as.numeric(as.POSIXct(starttime, format="%H:%M:%S"))) %>% 
  mutate(end_timestamp =  as.numeric(as.POSIXct(endtime, format="%H:%M:%S"))) %>% 
  filter(!is.na(start_timestamp)) %>% 
  filter(!is.na(end_timestamp)) # for simlicity dates greater than 24h are ignored

get_zm <- function (start, end, geom) {
  coords <- st_coordinates(geom)
  m <- seq(start, end, (end-start) / nrow(coords))
  line_matrix <- (coords[,c("X","Y")] %>% cbind(Z = 200) %>% cbind(M = m))
  return (st_sf(st_sfc(st_linestring(x = line_matrix, dim = "XYZM")), crs = 4326))
}

# add time to linestring with M parameter
dt <- data.table::data.table(ubahn)
dt[, geometry := get_zm(start_timestamp, end_timestamp, geometry), by=1:nrow(dt)]
ubahn_zm <- st_as_sf(dt, dim = "XYZM")

mapdeck(
  location = c(13.41, 52.51)
  , zoom = 11
  , style = mapdeck_style("dark")
) %>%
  add_trips(
    data = ubahn_zm
    , start_time = ubahn_zm$start_timestamp %>% min()    
    , end_time = ubahn_zm$end_timestamp %>% max()
    , animation_speed = 80
    , trail_length = 100
    , stroke_colour = "#B0E2FF"
    , stroke_width = 10
  )
