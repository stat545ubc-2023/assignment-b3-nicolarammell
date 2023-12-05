# Vancouver Street Tree Planting app by Nicola Rammell - version 2

# load libraries 
library(shiny)         # used for shiny web app framework
library(dplyr)         # used for data manipulation
library(tidyr)         # used for data manipulation
library(ggplot2)       # used for plotting 
library(datateachr)    # used to obtain vancouver_trees dataset
library(DT)            # used for dataTableOutput helper functions
library(here)          # used for image file paths
library(shinyWidgets)  # used for customizing sliders
library(colourpicker)  # used for customizing colours
library(shinythemes)   # used for adding a theme

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
  theme = shinytheme("flatly"),                            # apply overall theme to app
  titlePanel("Vancouver Street Tree Planting"),            # app title
  sidebarLayout(                                           # use sidebar layout
    sidebarPanel(
      chooseSliderSkin(skin = c("Sharp"), color = NULL),  # customize slider appearance
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
           tags$a("CBC", href = "https://www.cbc.ca/news/canada/photos/spring-blossoms-scroller-1.6442639")),
      br(), br(),                                          # add my info below
      span("Created by", a(href = "https://github.com/nicolarammell", "Nicola Rammell"), span(" | Code on", a(href = "https://github.com/stat545ubc-2023/shiny-app", "GitHub"))
      ),
    ),
    mainPanel(
      tabsetPanel(                                         # use three tabs in main panel
        tabPanel("Home",                                   # name the Home tab
                 br(),         
                 "Welcome to the Vancouver Street Tree Planting app! 
                 This app allows you to explore trees planted in Vancouver, BC city streets from 1989 - 2019.", 
                 br(), br(), 
                 "To explore trees by neighborhood, try the \"Filter by neighborhood\" option. To refine your 
                 search geographically, try using the Latitude/Longitude sliders. If you are interested in 
                 finding trees belonging to specific genera, click on the \"genus\" box to add any number of 
                 tree genera using the drop down menu!", 
                 br(), br(), 
                 "As you customize your inputs, your customized plot and table will update in their respective 
                 tabs. If you would like to download your plot or table, simply use the \"Download\" bottons to 
                 generate your own copy.", 
                 br(), br(), 
                 "Happy exploring!"),
        tabPanel("Plot",                                   # name the Plot tab
                 br(),                                     # add colour picker
                 colourInput("col", "Select outline colour", "#AF37D4", closeOnClick = TRUE), 
                 plotOutput("plot"),                       # add plot to main panel
                 br(),                 
                 downloadButton("download2", "Download Plot")),
        tabPanel("Table",                                  # name the Table tab
                 br(), 
                 DT::dataTableOutput("planted"), br(),     # add table to main panel
                 downloadButton("download1", "Download Table"))
      )
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
                selected = c("PRUNUS"))                     # set the defaults
  })
  
  # settings for optional neighbourhood filter
  output$neighborhoodSelectorOutput <- renderUI({           
    selectInput("neighborhoodInput", "neighbourhood",       # from trees$neighbourhood
                sort(unique(trees$neighbourhood)),          # allow all unique options from df
                selected = "HASTINGS-SUNRISE")              # if TRUE, defaults to HASTINGS-SUNRISE
  })
  
  # specify photo
  output$photo1 <- renderImage({                         
    list(
      src = here::here("www", "photo1.png"),                # give folder and filename
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
    p <-  ggplot(planted(), aes(year, fill = genus)) +
      geom_histogram(colour = input$col) +
      theme_classic(20) +
      xlab("Year") +
      ylab("Number of trees")  +
      scale_fill_brewer(palette = "Greens")
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