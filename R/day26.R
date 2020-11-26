# Day 26 - data preprocessing

library(readr)
library(dplyr)
library(tidyr)
library(tmaptools)
library(sf)

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

departures <- df %>% 
  left_join(geocoded_airports, by = c("dep" = "query")) %>% 
  group_by(dep,lat, lon) %>% 
  summarize(Value = sum(Value)) %>% 
  arrange(desc(Value))

write_csv(departures, "departure_flights.csv")
