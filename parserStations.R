#!/usr/bin/Rscript
setwd("/home/maxromain/MOBI-AID")

library("dplyr")
library("RSQLite")

UrlDecaux <- function(decaux,key) {
  if (grepl('\\?',decaux, perl = TRUE)) {
    delim <- '&'
  }
  else {
    delim <- '?'
  }
  url(sprintf("https://api.jcdecaux.com/vls/v1/%s%sapiKey=%s",decaux,delim,key))
}

GetJsonDecaux <- function(decaux, key = DecauxKey) {
  jsonlite::fromJSON(UrlDecaux(decaux,key), flatten = TRUE)
}

#Import and modif data
DecauxKey <- "65550c9a6efe8fe39f92aebe672943aaa36ec7eb"

#Recuperation of API datas
Contracts <- GetJsonDecaux("contracts")
DecauxContractName <- filter(Contracts, commercial_name == "villo")[["name"]]
Stations <- GetJsonDecaux(sprintf("stations?contract=%s",DecauxContractName))
print(Stations)

#Size of API list
sizeAPI <- length(Stations[[1]])

con <- dbConnect(SQLite(), dbname="mobilityBike.db")

if(FALSE){
for (i in 1:sizeAPI) {
  #print(Stations[[2]][i])
  ID <- Stations[[1]][i]
  if (Stations[[6]][i] == "OPEN") {
    status <- 1
  }
  else {
    status <- 0
  }
  bikeStands <- Stations[[8]][i]
  availableBikeStands <- Stations[[9]][i]
  availableBikes <- Stations[[10]][i]
  lastUpdate <- Stations[[11]][i]
  
  print("NEW ELEMENT")
  print(ID)
  print(status)
  print(bikeStands)
  print(availableBikeStands)
  print(availableBikes)
  print(lastUpdate)
  
  dbSendQuery(con,
              "INSERT INTO dynamicTable
              (stationID, status, bike_stands, available_bike_stands, available_bikes, timeStamp)
              VALUES (ID, status, bikeStands, availableBikeStands, availableBikes, lastUpate)")
  
}}

for (i in 1:sizeAPI) {
  if (Stations[[6]][i] == "OPEN") {
    Stations[[6]][i] <- 1
  }
  else {
    Stations[[6]][i] <- 0
  }
}

#Write on the data base
auteurs <- data.frame(stationID=c(Stations[[1]]), 
                      status=c(Stations[[6]]), 
                      bike_stands=c(Stations[[8]]),
                      available_bike_stands=c(Stations[[9]]),
                      available_bikes=c(Stations[[10]]),
                      timeStamp=c(Stations[[11]]))

dbWriteTable(con, "dynamicTable", auteurs, append = T)

dbDisconnect(con)