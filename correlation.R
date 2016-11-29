#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")

library("RSQLite")
library("ggplot2")

con <- dbConnect(SQLite(), dbname="mobilityBike.db")

corrBetweenStations <- function(station_One, station_two) {
  query_one <- paste("SELECT * FROM dynamicTable WHERE stationID = ", station_One)
  query_two <- paste("SELECT * FROM dynamicTable WHERE stationID = ", station_two)
  
  dataStationOne <- dbGetQuery(con, query_one)
  dataStationTwo <- dbGetQuery(con, query_two)
  print(dataStationOne)
  print(dataStationTwo)
  
  print(qplot(data = dataStationOne, timeStamp, available_bikes, color=status))
  #print(ggplot(data = dataStationOne, aes(y = available_bikes)) +geom_density())
  
  #cor(dataStationOne, dataStationTwo)
  
  xrange <- range(dataStationOne$timeStamp)
  yrange <- range(dataStationOne$available_bikes)
  
  #plot(xrange, yrange, type="n", xlab="Time", ylab="Available Bikes")
  #lines(dataStationOne$timeStamp, dataStationOne$available_bikes, lwd=1.5)   
}

corrBetweenStations(1,2)
