library(shiny)
library(mapdeck)
library(sf)
library(dplyr)
library(osmdata)

ui <- bootstrapPage(
  mapdeckOutput(outputId = 'myMap', height = "800px"),
  absolutePanel(
    tags$style(
      HTML('
             #cuisine {background-color: rgba(255,255,255,0.7);;}')),
    top = 10, right = 20, style = "z-index:500; text-align: right;",
    tags$h2("Which cuisine can you eat where in Berlin?"),
    tags$a("Data by OSM via osmdata R package", href="https://cran.r-project.org/web/packages/osmdata/vignettes/osmdata.html"),
    tags$br(),
    tags$a("Map by Deck.gl via mapdeck package", href="https://github.com/SymbolixAU/mapdeck"),
    tags$br(),
    tags$a("< Back to overview", href="../index.html"),
    tags$br(),
    tags$br()),
  absolutePanel(
    top = 200, right = 20, style = "z-index:500; text-align: right;",
    radioButtons("cuisine", "Cuisine:",
                 c("Italian" = "italian",
                   "Turkish & kebab" = "turkish",
                   "German" = "german",
                   "Vietnamese" = "vietnamese",
                   "Indian" = "indian",
                   "Chinese" = "chinese"))
  )
)


server <- function(input, output) {
  
  set_token("MAPBOX_TOKEN")
  
  # get data once and store to file
  
  # restaurants <- opq(bbox = 'berlin germany') %>%
  #   add_osm_feature(key = 'amenity', value = c('fast_food', 'restaurant')) %>% 
  #   osmdata_sf ()
  # 
  # df <- restaurants$osm_points %>% 
  #   dplyr::select("name", "cuisine")
  # df[is.na(df$cuisine), "cuisine"] <- ""
  # df[df$cuisine == "kebab", "cuisine"] <- "turkish"
  # 
  # st_write(df, "data/restaurants.gpkg", append = F)
  
  df <- read_sf("shinyappsio/restaurants.gpkg")
  
  
  output$myMap <- renderMapdeck({
    mapdeck(style = mapdeck_style('light'), 
            zoom = 11, 
            min_zoom = 8, 
            max_zoom = 13,
            location = c(13.4, 52.5))
  })
  
  df_reactive <- reactive({
    if(is.null(input$cuisine)) return(NULL)
    return(
      input$cuisine
    )
  })
  
  observeEvent({input$cuisine}, {
    if(is.null(input$cuisine)) return()
    
    mapdeck_update(map_id = 'myMap') %>%
      add_screengrid(
        data = df[df$cuisine == input$cuisine, ]
        , lat = "lat"
        , lon = "lng"
        , cell_size = 30
        , opacity = 0.3
        , colour_range = colourvalues::colour_values(6:1, palette = "viridis")
        , update_view = F)
  })
  
}

shinyApp(ui, server)