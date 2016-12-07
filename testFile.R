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
print(timeVilloFrame)

# ----- TEST INDEX -----
print(timeVilloFrame[[1]][3333])
print(timeVilloFrame[[2]][3333])
print(timeVilloFrame[[3]][3333])

# ----- TEST FOR -----
numberOccurrence <- 0
for (i in 1:length(timeVilloFrame[[1]])) {
  if (timeVilloFrame[[1]][i] == 1) {
    numberOccurrence <- numberOccurrence + 1
  }
}
print(numberOccurrence)
#or get a querry, and do a lenght of frame
for (i in seq(1,length(timeVilloFrame[[1]]), numberOccurrence)) {
  print(timeVilloFrame[[1]][i])
}

