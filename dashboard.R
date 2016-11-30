#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")
#setwd("/home/maxromai/Documents/memoire/MOBI-AID")

## app.R ##
library(shiny)
library(shinydashboard)
library(leaflet)
library("RSQLite")

ui <- dashboardPage(
  dashboardHeader(title = "MOBIAID Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
		menuItem("Villo in time", tabName = "villoTime", icon = icon("calendar")),
      menuItem("Informations", tabName = "information", icon = icon("database")),
      menuItem("Source code", icon = icon("file-code-o"), 
               href = "https://github.com/Myxfall/MOBI-AID")
    )
  ),
  ## Body content
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard", 
              box(leafletOutput("plot1", height = 600), height = "100%", width = "100%"),
              fluidPage(
                # ListBox 
                selectInput("listStations", label = h3("Select a station"), 
                            choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), 
                            selected = 1),
                #Prompt select Value
                hr(),
                fluidRow(column(4, verbatimTextOutput("selectStation")))
              )
              
      ),
	  tabItem(tabName = "villoTime",
			  box(leafletOutput("plot2", height = 600), height = "100%", width = "100%")),
      tabItem(tabName = "information", 
              h2("Dashboard informations"))
    )
  )
)

server <- function(input, output, session) {
  #set.seed(122)
  #histdata <- rnorm(500)
  
  con <- dbConnect(SQLite(), dbname="mobilityBike.db")
  query <- "SELECT longitude FROM StaticTable"
  long <- unlist(dbGetQuery(con, query))
  query <- "SELECT latitude FROM StaticTable"
  lat <- unlist(dbGetQuery(con, query))
  query <- "SELECT address FROM StaticTable"
  add <- as.vector(unlist(dbGetQuery(con, query)))

  mat <- matrix(c(long,lat), ncol = 2)
  
  map = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addMarkers(data = mat, popup = add)
  output$plot1 = renderLeaflet(map)

  mapInTime = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13)
  output$plot2 = renderLeaflet(mapInTime)
  
  query <- "SELECT name from StaticTable ORDER BY number"
  namesStation <- dbGetQuery(con, query)
  print(typeof(namesStation))
  
  #link: http://shiny.rstudio.com/reference/shiny/latest/updateSelectInput.html
  updateSelectInput(session, "listStations",
                    choices = namesStation
                    #choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3, "YOYO 4" = 4, "MAISON 5" = 5)
  )
  
  #Output ListBox
  output$selectStation <- renderPrint({ input$listStations })
}

shinyApp(ui, server)
