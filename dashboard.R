#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")
#setwd("/home/maxromai/Documents/memoire/MOBI-AID")

## app.R ##
library(shiny)
library(shinydashboard)
library(leaflet)
library("RSQLite")
library(dygraphs)
library(xts)

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
              box(fluidPage(
                # ListBox 
                selectInput("listStations", label = h3("Select a station"), 
                            choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), 
                            selected = 1),
                #Prompt select Value
                dygraphOutput("dygraph")
              ), width = 100)
              
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

  #link: http://shiny.rstudio.com/reference/shiny/latest/updateSelectInput.html
  updateSelectInput(session, "listStations",
                    choices = namesStation
                    #choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3, "YOYO 4" = 4, "MAISON 5" = 5)
  )
  
  #Query Select station select distinct * from dynamicTable where timeStamp in (select max(timeStamp) from dynamicTable where stationID = (
  #select number from staticTable where name = "211 - METRO CERIA"))
  data <- dbGetQuery(con, "SELECT timeStamp, available_bikes from dynamicTable where stationID = 3")

  #output$value <- renderText(input$listStations)
  observe({
    #dataSave <- isolate(input$listStations)
    dataName <- as.character(input$listStations)

    query <- paste0("SELECT timeStamp, available_bikes FROM dynamicTable WHERE stationID IN (SELECT number from staticTable WHERE name = '",dataName,"')")
    data_two <- dbGetQuery(con, query)
    
    queryOne <- "SELECT timeStamp from dynamicTable where stationID = 3"
    queryTwo <- "SELECT available_bikes from dynamicTable where stationID = 3"
    dataTime <- dbGetQuery(con, queryOne)
    dataBike <- dbGetQuery(con, queryTwo)
    
    #Transformation epoch timeStamp to date object
    #Need to divide by 1000, because epoch is in milisecond
    #dateTry <- dataTime[[1]][500]
    #dateOne <- as.Date(as.POSIXct(dateTry/1000, origin="1970-01-01"))
    #print(dateOne)
    
    vector <- character()
    #vector <- c()
    for (i in 1:length(dataTime[[1]])) {
      #dataTime[[1]][i] <- as.Date(as.POSIXct(dataTime[[1]][i]/1000, origin="1970-01-01"))
      #print(dataTime[[1]][i])
      
      #dateTry <- dataTime[[1]][i]
      #dateOne <- as.Date(as.POSIXct(dateTry/1000, origin="1970-01-01"))
      #vector[i] <- as.character(dateOne)
      #print(vector[i])
    } 
    #tryvector <- as.xts(as.POSIXlt(dataTime))
    #dataBoth <- cbind(vector, dataBike)

    #Output ListBox
    output$dygraph <- renderDygraph(dygraph(data_two) %>% dyRangeSelector())
  })
  

}

shinyApp(ui, server)
