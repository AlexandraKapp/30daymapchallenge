### Day 2: Lines


library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(flowmapblue)
library(tmaptools)
library(sf)

mapboxAccessToken <- "TOKEN"

# Data: https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=avia_par_de&lang=en
df <- read_csv("data/avia_par_de/avia_par_de_1_Data.csv") %>% 
  filter(Value != ":") %>% 
  filter(TRA_MEAS == "Passengers on board (departures)") %>% 
  separate(AIRP_PR, into =c("dep", "arr"), sep = " - ", extra = "merge") %>% 
  mutate(Value = as.integer(gsub(" ", "", Value, fixed = TRUE)))

# all departure airports
all_airports <- df %>% 
  select(dep) %>% 
  pull() %>% 
  unique()

# get coordinates of airports
geocoded_airports <- geocode_OSM(all_airports) %>% 
  select(query, lat, lon)

# check if geocoding worked
geocoded_airports %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
  mapview::mapview()

# fix coords of Franfurt Main manually
geocoded_airports[geocoded_airports$query == "FRANKFURT/MAIN airport", "lat"] = 50.036186
geocoded_airports[geocoded_airports$query == "FRANKFURT/MAIN airport", "lon"] = 8.558073

# bring in format for flowmaps blue
geocoded_airports["id"] <- seq(1:nrow(geocoded_airports))
geocoded_airports <- rename(geocoded_airports, name = "query")

flows <- df %>% 
  filter(arr %in% all_airports) %>%  #  only inner german flights
  left_join(geocoded_airports, by = c("dep" = "name")) %>% 
  left_join(geocoded_airports, by = c("arr" = "name"), suffix = c("_dep", "_arr")) %>% 
  select("id_arr", "id_dep", "Value") %>% 
  rename(origin = id_arr, 
         dest = id_dep,
         count = Value)

  
flowmapblue(geocoded_airports, flows, mapboxAccessToken, clustering=TRUE, darkMode=TRUE, animation=TRUE)
