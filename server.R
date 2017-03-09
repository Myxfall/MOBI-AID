#!/usr/bin/Rscript

## app.R ##
library(shiny)
library(shinydashboard)
library(leaflet)
library("RSQLite")
library(dygraphs)
library(xts)

server <- function(input, output, session) {
  
  con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")
  query <- "SELECT longitude FROM StaticTable ORDER BY number"
  long <- unlist(dbGetQuery(con, query))
  query <- "SELECT latitude FROM StaticTable ORDER BY number"
  lat <- unlist(dbGetQuery(con, query))
  query <- "SELECT name FROM StaticTable ORDER BY number"
  add <- as.vector(unlist(dbGetQuery(con, query)))
  
  mat <- matrix(c(long,lat), ncol = 2)
  
  map = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addMarkers(data = mat, popup = add)
  output$plot1 = renderLeaflet(map)
  
  # ---------- VILLO IN TIME ----------
  query <- paste("SELECT stationID, timeStamp, available_bikes FROM dynamicTable ORDER BY stationID")
  timeVilloFrame <- dbGetQuery(con, query)
  print(timeVilloFrame)
  
  query <- paste0("SELECT stationID FROM dynamicTable WHERE stationID = 1")
  station_One <- dbGetQuery(con, query)
  numberOccurrence <- length(station_One[[1]])
  
  updateSliderInput(session, "slider", min = 1, max = numberOccurrence)
  
  # ---------- DYGRAPH PLOT ----------
  query <- "SELECT name from StaticTable ORDER BY number"
  namesStation <- dbGetQuery(con, query)
  
  #link: http://shiny.rstudio.com/reference/shiny/latest/updateSelectInput.html
  updateSelectInput(session, "listStations",
                    choices = namesStation
                    #choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3, "YOYO 4" = 4, "MAISON 5" = 5)
  )
  
  observe({
    dataName <- as.character(input$listStations)
    
    queryOne <- paste0("SELECT timeStamp FROM dynamicTable WHERE stationID IN (SELECT number from staticTable WHERE name = '",dataName,"')")
    queryTwo <- paste0("SELECT available_bikes FROM dynamicTable WHERE stationID IN (SELECT number from staticTable WHERE name = '",dataName,"')")
    dataTime <- dbGetQuery(con, queryOne)
    dataBike <- dbGetQuery(con, queryTwo)
    
    #Transformation epoch timeStamp to date object
    #Need to divide by 1000, because epoch is in milisecond
    
    # ---------- CONVERSION TO XTS ----------
    doubleVectorDate <- Sys.time()+1:length(dataTime[[1]])
    for (i in 1:length(dataTime[[1]])) {
      tmp <-  as.POSIXct(dataTime[[1]][i]/1000, origin="1970-01-01")
      doubleVectorDate[i] <- tmp
    }
    xtsData <- xts(dataBike, doubleVectorDate)
    
    #Output ListBox
    output$dygraph <- renderDygraph(dygraph(xtsData) %>% dyRangeSelector())
    
    # ---------- SLIDER TIME ----------
    #Modifier algorithme:  parcours jusquau nbr séléectionner.  passe à false, chercher station suivante et recommencer
    selectedTime <- as.numeric(input$slider)
    #Getting the informations of the selected timeStamp
    selectedTimeStamp <- 1
    bikes <- c()
    indexVect <- 1
    for (i in seq(selectedTime,length(timeVilloFrame[[1]]), numberOccurrence)) {
      #Multiple value for better vizualisation
      bikes[indexVect] <- timeVilloFrame[[3]][i] * 5
      print(bikes[indexVect])
      indexVect <- indexVect + 1
    }
    
    mapInTime = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addCircles(data = mat, radius = bikes, popup = add, color='red')
    output$plot2 = renderLeaflet(mapInTime)    
  })
}
