# Vancouver Street Tree Planting app by Nicola Rammell

# load libraries 
library(shiny)         # used for shiny web app framework
library(dplyr)         # used for data manipulation
library(tidyr)         # used for data manipulation
library(ggplot2)       # used for plotting 
library(datateachr)    # used to obtain vancouver_trees dataset
library(DT)            # used for dataTableOutput helper functions
library(here)          # used for image file paths
library(shinyWidgets)  # used for customizing sliders

# create trees tibble from vancouver_trees 
trees <- vancouver_trees %>%
  dplyr::mutate(year = lubridate::year(date_planted)) %>%  # create a year column
  tidyr::drop_na(year) %>%                                 # drops 76548 rows with NA 
  tidyr::drop_na(latitude) %>%                             # drops 11318 more rows with NA
  dplyr::rename(genus = genus_name,                        # rename columns
                species = species_name, 
                neighbourhood = neighbourhood_name, 
                id = tree_id) %>%
  dplyr::select(id, genus, species, neighbourhood,        # keep only variables of interest
                latitude, longitude, year)

# user interface 
ui <- fluidPage(
  titlePanel("Vancouver Street Tree Planting"),
  sidebarLayout(                                           # use sidebar layout
    sidebarPanel(
      chooseSliderSkin(skin = c("Square"), color = NULL),  # customize slider appearance
      sliderInput("latitudeInput", "Latitude", 49.2000, 49.2900, c(49.2000, 49.2900)),
      sliderInput("longitudeInput", "Longitude", -123.2, -123.0, c(-123.2, -123.0)),
      uiOutput("genusSelectOutput"),                       # genus filter to specify below
      checkboxInput("filterNeighborhood", "Filter by neighbourhood", FALSE),
      conditionalPanel(                                    # optional neighborhood filter
        condition = "input.filterNeighborhood",
        uiOutput("neighborhoodSelectorOutput"),
      ),
      span("Data source:",                                 # provide dataset reference
           tags$a("City of Vancouver Open Data Portal",
                  href = "https://opendata.vancouver.ca/explore/dataset/street-trees/information/?disjunctive.species_name&disjunctive.common_name&disjunctive.on_street&disjunctive.neighbourhood_name")),
      br(), br(),                                          # breaks for spacing 
      imageOutput("photo1"),                               # place image using imageOutput 
      span("Photo Credit:",                                # provide photo reference 
           tags$a("CBC (2022)", href = "https://www.cbc.ca/news/canada/british-columbia/green-canopy-climate-change-1.6500919")),
      br(), br(),
      imageOutput("photo2"),                               # place image using imageOutput                           
      span("Photo Credit:",                                # provide photo reference 
           tags$a("CBC (2021)", href = "https://www.cbc.ca/news/canada/british-columbia/vancouver-cherry-blossom-japanese-roots-1.5982533")),
      br(), br(),                                          # add my info below
      span("Created by", a(href = "https://github.com/nicolarammell", "Nicola Rammell"), span(" | Code on", a(href = "https://github.com/stat545ubc-2023/shiny-app", "GitHub"))
      ),
    ),
    mainPanel(
      plotOutput("plot"),                                  # put plot on the main page
      br(),                                                # put download buttons below
      downloadButton("download2", "Download Plot"), downloadButton("download1", "Download Table"),
      br(), br(), br(), 
      DT::dataTableOutput("planted")                       # put the table output last
    )
  )
)


# server
server <- function(input, output, session) {
  
  # settings for genus filter   
  output$genusSelectOutput <- renderUI({                   
    selectInput("genusInput", "genus",                      # from trees$genus
                sort(unique(trees$genus)),                  # allow all unique options from df
                multiple = TRUE,                            # allow any number of genera
                selected = c("ACER", "PRUNUS", "FRAXINUS")) # set the defaults
  })
  
  # settings for optional neighbourhood filter
  output$neighborhoodSelectorOutput <- renderUI({           
    selectInput("neighborhoodInput", "neighbourhood",       # from trees$neighbourhood
                sort(unique(trees$neighbourhood)),          # allow all unique options from df
                selected = "HASTINGS-SUNRISE")              # if TRUE, defaults to HASTINGS-SUNRISE
  })
  
  # specify first photo
  output$photo1 <- renderImage({                         
    list(
      src = here::here("www","photo1.png"),                 # give folder and filename
      contentType = "image/png",                            # image type
      width = "100%",                                       # width adjusts to browser
      height = 400                                          # height set to 400
    )
  }, deleteFile = FALSE)
  
  # specify second photo 
  output$photo2 <- renderImage({
    list(
      src = here::here("www", "photo2.png"),                # give folder and filename
      contentType = "image/png",                            # image type
      width = "100%",                                       # width adjusts to browser
      height = 400                                          # height set to 400
    )
  }, deleteFile = FALSE)
  
  # reactive programming for all data handling
  planted <- reactive({
    planted <- trees
    
    if (is.null(input$neighborhoodInput)) {
      return(NULL)
    }
    
    # set genus and neighbourhood filters
    planted <- dplyr::filter(planted, genus %in% input$genusInput)
    if (input$filterNeighborhood) {
      planted <- dplyr::filter(planted, neighbourhood == input$neighborhoodInput)
    }
    
    # set slider filters
    planted <- dplyr::filter(planted, latitude >= input$latitudeInput[1],
                             latitude <= input$latitudeInput[2])
    planted <- dplyr::filter(planted, longitude >= input$longitudeInput[1],
                             longitude <= input$longitudeInput[2])
    
    if(nrow(planted) == 0) {
      return(NULL)
    }
    planted 
  })
  
  # reactive programming for the download plot 
  plotInput <- reactive({
    df <- planted()
    p <-  ggplot(planted(), aes(year, fill = genus)) +
      geom_histogram(colour = "black") +
      theme_classic(20) +
      xlab("Year") +
      ylab("Number of trees planted") +
      scale_fill_brewer(palette = "PiYG")
  })
  
  # reactive programming for the plot to be shown on main page
  output$plot <- renderPlot({
    if (is.null(planted())) {
      return(NULL)
    }
    print(plotInput())
  })
  
  # interactive table to be shown on the main page 
  output$planted <- DT::renderDataTable({
    planted()
  })
  
  # add download table functionality
  output$download1 <- downloadHandler(
    filename = function() {
      "trees-results.csv"
    },
    content = function(con) {
      write.csv(planted(), con)
    }
  )
  
  # add download plot functionality   
  output$download2 <- downloadHandler(
    filename = function() { 
      "plot.png" 
    },
    content = function(file) {
      ggsave(file, plotInput())
    }
  )
}

shinyApp(ui = ui, server = server)