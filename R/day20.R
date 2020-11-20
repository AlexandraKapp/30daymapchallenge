# Day 20: Population
# Data: Amt für Statistik Berlin-Brandenburg Binnenwanderungen sind die Zu- und Fortzüge innerhalb der Regionaleinheiten einer Region (2013)

library(shiny)
library(shinyjs)
library(leaflet)
library(sf)
library(dplyr)
library(readr)

bw <- read_csv("shinyappsio/binnenwanderung.csv")
outline <- read_sf("shinyappsio/berlin_bz.geojson")
bw$geometry <- outline$geometry[match(bw$ID, outline$cartodb_id)]
bw <- st_as_sf(bw) %>% st_transform(4326)

ui <- bootstrapPage(
  useShinyjs(),
  tags$head(tags$style(
    HTML('#title_text {background-color: rgba(255,255,255,0.85);;}'))),
  tags$style(type = "text/css", "html, body {width:100%;height:100%; font-family: Oswald, sans-serif;}"),
    leafletOutput("map", height = "100%"),
  absolutePanel(
    top = 35, right = 20, style = "z-index:500; text-align: right;",
    tags$div(id = "title_text",
      tags$h2("How many people move within Berlin from where to where?"),
      tags$h3("Once in Berlin, more people move from the center further out."),
      tags$b("Click on a district to see where the people are coming from that move to this district.")
    )
  ),
  absolutePanel(
    top = 40, left = 20, style = "z-index:500; text-align: right;",
    actionButton("back_button", "< Back to overview")
  ),
  absolutePanel(
    bottom = 15, left = 20, style = "z-index:500; text-align: right;",
    tags$p(HTML('<a href = "https://www.statistik-berlin-brandenburg.de/webapi/opendatabase?id=WBBEb13">Amt für Statistik Berlin-Brandenburg Binnenwanderungen sind die Zu- und Fortzüge innerhalb der Regionaleinheiten einer Region (2013)</a>'))
  )
)


server <- function(input, output, session) {
  
  # initially disable radio button
  shinyjs::disable("back_button")
  
  # plotting
  min <- min(bw$diff, na.rm = T)
  max <- max(bw$diff)
  magma <- colorNumeric("magma", na.color = "transparent", domain =  c(min:max), reverse = T) 

    output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addPolygons(layerId = ~ origin, data = bw, 
                  fillColor = ~magma(diff), 
                  fillOpacity = 0.8,
                  color = "white",
                  group = "bezirke") %>% 
        addLegend(layerId = "legend", pal = magma, values = c(min:max), position = "bottomright", title = "Movements within Berlin")
      
  })
  
  observeEvent(input$map_shape_click, {

    click <- input$map_shape_click
    
    bw[c("origin", click$id)]
    
    magma <- colorNumeric("magma", na.color = "transparent", domain =  c(100:5000), reverse = T) 
    
    leafletProxy("map") %>%
      addPolygons(layerId = ~ origin, data = bw, fillColor = ~magma(bw[[click$id]]), 
                  fillOpacity = 0.8,
                  color = "black") %>% 
    addLegend(layerId = "legend", pal = magma, values = c(100:5000), position = "bottomright", title = "People moving to selected district")

    enable("back_button")

  }, ignoreInit = T)

  observeEvent(input$back_button, {
    leafletProxy("map") %>% 
      addPolygons(layerId = ~ origin, data = bw, 
                  fillColor = ~magma(diff), 
                  fillOpacity = 0.8,
                  color = "white", popup = ~origin, group = "bezirke") %>% 
      addLegend(layerId = "legend", pal = magma, values = c(min: max),  position = "bottomright")
    
    disable("back_button")
    
  }, ignoreInit = T)

}

shinyApp(ui, server)
