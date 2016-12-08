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

con <- dbConnect(SQLite(), dbname="mobilityBike.db")
query <- paste("SELECT stationID, timeStamp, available_bikes FROM dynamicTable ORDER BY stationID")
timeVilloFrame <- dbGetQuery(con, query)

# ----- TEST INDEX -----
print(timeVilloFrame[[1]][3333])
print(timeVilloFrame[[2]][3333])
print(timeVilloFrame[[3]][3333])

# ----- NUMBER OF STATION OCURRENCE -----
query <- paste0("SELECT stationID FROM dynamicTable WHERE stationID = 1")
station_One <- dbGetQuery(con, query)
numberOccurrence <- length(station_One[[1]])
print(numberOccurrence)

# ----- FOR BY -----
selectedTimeStamp <- 1
bikes <- c()

indexVect <- 1
for (i in seq(1,length(timeVilloFrame[[1]]), numberOccurrence)) {
  bikes[indexVect] <- timeVilloFrame[[3]][i]
  print(bikes[indexVect])
  indexVect <- indexVect + 1
}
print(bikes)

