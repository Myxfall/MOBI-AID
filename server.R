#!/usr/bin/Rscript

## app.R ##
library(shiny)
library(shinydashboard)
library(leaflet)
library("RSQLite")
library(dygraphs)
library(xts)

library("dplyr")
library("ape")
library("rafalib")
library("dendextend")
library("graphics")
library("ggmap")

server <- function(input, output, session) {
  
  con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")
  query <- "SELECT longitude FROM StaticTable ORDER BY number"
  long <- unlist(dbGetQuery(con, query))
  query <- "SELECT latitude FROM StaticTable ORDER BY number"
  lat <- unlist(dbGetQuery(con, query))
  query <- "SELECT name FROM StaticTable ORDER BY number"
  add <- as.vector(unlist(dbGetQuery(con, query)))
  
  mat <- matrix(c(long,lat), ncol = 2)
  
  # ---------- VILLO MAP ----------
  map = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addMarkers(data = mat, popup = add)
  output$plot1 = renderLeaflet(map)
  
  # ---------- VILLO IN TIME ----------
  query <- paste("SELECT stationID, timeStamp, available_bikes FROM dynamicTable ORDER BY stationID")
  timeVilloFrame <- dbGetQuery(con, query)

  query <- paste0("SELECT stationID FROM dynamicTable WHERE stationID = 1")
  station_One <- dbGetQuery(con, query)
  numberOccurrence <- length(station_One[[1]])
  
  updateSliderInput(session, "slider", min = 1, max = numberOccurrence)
  
  # ---------- DYGRAPH PLOT ----------
  query <- "SELECT name from StaticTable ORDER BY number"
  namesStation <- dbGetQuery(con, query)
  
  updateSelectInput(session, "listStations",
                    choices = namesStation
  )
  updateSelectInput(session, "listStations_two",
                    choices = namesStation
  )
  
  if (FALSE) { #Comment section 
  # ---------- CLUSTER DATAS --------
  query <- paste("SELECT number FROM staticTable ORDER BY number")
  ID_MAPPING <- as.vector(unlist(dbGetQuery(con, query)))
  
  # ---------- MAKING A DATAFRAME OF DATAS VECTOR ----------
  tmpDataFrame <- NULL
  for (i in 1:length(ID_MAPPING)) {
    query <- paste("SELECT available_bikes FROM dynamicTable WHERE stationID = ", ID_MAPPING[i])
    stationDatas <- dbGetQuery(con, query)
    
    if (length(stationDatas[[1]]) == 0) {
      stationDatas <- integer(2013)
    }
    
    tmp <- data.frame(id = ID_MAPPING[i], datas = 0)
    tmp$datas[1] = stationDatas
    
    tmpDataFrame <- rbind(tmpDataFrame, tmp)
  }
  
  # ---------- FINAL DATAFRAME ----------
  stationDataFrame <- NULL
  for (i in 1:nrow(tmpDataFrame)) {
    stationDataFrame <- rbind(stationDataFrame, tmpDataFrame[[i, 2]])
  }
  } #End comment
  
  # ---------- Clustering ----------
  #link: https://github.com/joyofdata/hclust-shiny
  colostList <- c("red", "blue", "purple", "yellow", "green", "tan4", "cornsilk3", "aquamarine3")
  observeEvent(input$clusterRun, {
    print(paste("Calculing clusters with", input$clusterDist, "distance and", input$clusterAvg, "agglomerative method"))
    distEucl <- dist(as.matrix(stationDataFrame, method = input$clusterDist))
    hc <- hclust(distEucl, method = input$clusterAvg)
    
    dend <- as.dendrogram(hc)
    #dend <- rotate(dend)
    dend <- color_branches(dend, k = input$clusterNbr)
    dend <- set(dend, "labels_cex", 0.1)

    output$tree <- renderPlot({
      plot(dend)
      
    print("Plotting done...")
    })
    
    # ----- Cluster Mapping -----
    clusterNbr <- input$clusterNbr
    memb <- cutree(hc, k = clusterNbr)
    
    groupList <- vector("list", clusterNbr)
    for (clust in 1:clusterNbr) {
      #Create empty vector
      group <- vector()
      
      #Boucle in memb, making groups by putting good data in right group
      for (i in 1:length(memb)) {
        if (memb[i] == clust) {
          group[length(group)+1] <- i
        }
      }
      groupList[[clust]] <- group
    }
    
    con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")
    query <- "SELECT number, latitude, longitude FROM StaticTable ORDER BY number"
    tm <- dbGetQuery(con, query)
    
    #Create for each group, lat & long vector
    latList <- vector("list", clusterNbr)
    longList <- vector("list", clusterNbr)
    for (clust in 1:clusterNbr) {
      #Empty cluster for on group
      cluster_lat <- vector()
      cluster_long <- vector()
      
      #Get data for one cluster
      for (i in 1:length(groupList[[clust]])) {
        ID <- tm$number[groupList[[clust]][i]]
        long <- tm$longitude[groupList[[clust]][i]]
        lat <- tm$latitude[groupList[[clust]][i]]
        
        cluster_long[i] <- long
        cluster_lat[i] <- lat
      }
      #push in latList & longList
      latList[[clust]] <- cluster_lat
      longList[[clust]] <- cluster_long
    }
    
    mapCluster = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13)
    for (i in 1:clusterNbr) {
      mat <- matrix(c(longList[[i]], latList[[i]]), ncol = 2)
      
      mapCluster = mapCluster %>% addCircleMarkers(data = mat, color = colostList[i], stroke = FALSE, fillOpacity = 0.8)
    }
    output$clusterMap = renderLeaflet(mapCluster)
    
    #mat1 <- matrix(c(longList[[1]], latList[[1]]), ncol = 2)
    #mat2 <- matrix(c(longList[[3]], latList[[3]]), ncol = 2)
    
    #mapCluster = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addCircleMarkers(data = mat1, color = colostList[1])
    #mapCluster = mapCluster %>% addCircleMarkers(data = mat2, color = colostList[2])
    #output$clusterMap = renderLeaflet(mapCluster)
    
    #mat <- matrix(c(long,lat), ncol = 2)
    #mapCluster = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addMarkers(data = mat, popup = add)
    #output$clusterMap = renderLeaflet(mapCluster)
    
  })
  
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
      indexVect <- indexVect + 1
    }
    
    mapInTime = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addCircles(data = mat, radius = bikes, popup = add, color='red')
    output$plot2 = renderLeaflet(mapInTime)
  })
  
  observe({
    dataNameB <- as.character(input$listStations_two)
    
    queryOneB <- paste0("SELECT timeStamp FROM dynamicTable WHERE stationID IN (SELECT number from staticTable WHERE name = '",dataNameB,"')")
    queryTwoB <- paste0("SELECT available_bikes FROM dynamicTable WHERE stationID IN (SELECT number from staticTable WHERE name = '",dataNameB,"')")
    dataTimeB <- dbGetQuery(con, queryOneB)
    dataBikeB <- dbGetQuery(con, queryTwoB)
    
    doubleVectorDateB <- Sys.time()+1:length(dataTimeB[[1]])
    for (i in 1:length(dataTimeB[[1]])) {
      tmpB <-  as.POSIXct(dataTimeB[[1]][i]/1000, origin="1970-01-01")
      doubleVectorDateB[i] <- tmpB
    }
    xtsDataB <- xts(dataBikeB, doubleVectorDateB)
    
    #Constante prediction
    if (input$predictionMethod == 1) {
      lastData <- dataBikeB[[1]][length(dataBikeB[[1]])]
      lastTime <- dataTimeB[[1]][length(dataTimeB[[1]])]
      futurData <- vector()
      futurTime <- vector()
      for (i in 1:25){
        futurData[i] <- lastData
        #Adding data for each hour (epoch time in millisecond, adding 1 hour per data)
        futurTime[i] <- lastTime + ((i-1) * 3600 * 1000)
      }
      doubleVectorDateBB <- Sys.time()+1:25
      for (i in 1:25) {
        tmpBB <-  as.POSIXct(futurTime[i]/1000, origin="1970-01-01")
        doubleVectorDateBB[i] <- tmpBB
      }
      xtsDataBB <- xts(futurData, doubleVectorDateBB)
    }
    #Same prediction
    else if (input$predictionMethod == 2) {
    
    }
    
    a <- cbind(xtsDataB, xtsDataBB)
    #output$futurDygraph <- renderDygraph(dygraph(xtsDataBB) %>% dyRangeSelector() %>% dyOptions(colors = "red"))    
    output$futurDygraph <- renderDygraph(dygraph(a) %>% dyRangeSelector() %>% dyOptions(colors = c("green", "red")))
  })
}
