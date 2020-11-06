### Day 6: Red

# notable Redpoint ascents according to Wikipedia

library(sf)
library(dplyr)
library(readr)
library(mapview)

Rotpunkt <- read_csv("data/rotpunkt.csv") %>% 
  mutate(climber = paste(climber, " (", Date, ")")) %>% 
  group_by(grade, route, lat, lon) %>% 
  summarize(
    region = first(where),
    climber = paste(climber, collapse = ",<br>")) %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

mapview(Rotpunkt, color = "transparent", col.regions = "red")
