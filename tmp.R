#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")

library("dplyr")
library("RSQLite")

#Connect to database
con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")

# ---------- EUCLEDIEN DISTANCE TEST -----------
query <- paste("SELECT available_bikes FROM dynamicTable WHERE stationID = 5")
station_one <- as.vector(unlist(dbGetQuery(con, query)))

query <- paste("SELECT available_bikes FROM dynamicTable WHERE stationID = 1")
station_two <- as.vector(unlist(dbGetQuery(con, query)))

distance <- dist(rbind(station_one, station_one))
#ditance <- dist(rbind(station_one, station_two))

# ----------------------------------------------
# ---------- CONSTRUCTION MATRIX TEST ----------
if (FALSE) {
query <- paste("SELECT name FROM staticTable")
stationData <- dbGetQuery(con, query)
stationNumber <- length(stationData[[1]])

stationMatrix <- matrix(c(0), ncol = stationNumber, nrow = stationNumber)

query <- paste("SELECT number FROM staticTable ORDER BY number")
stationIDList <- dbGetQuery(con, query)

for (i in 1:length(stationIDList[[1]])) {
  #print(stationIDList[i])
  for (j in i:length(stationIDList[[1]])) {
    queryOne <- paste0("SELECT available_bikes FROM dynamicTable WHERE stationID = ", stationIDList[[1]][i])
    stationOneBikes <- as.vector(unlist(dbGetQuery(con, queryOne)))
    queryTwo <- paste0("SELECT available_bikes FROM dynamicTable WHERE stationID = ", stationIDList[[1]][j])
    stationTwoBikes <- as.vector(unlist(dbGetQuery(con, queryTwo)))
    
    euclDist <- dist(rbind(stationOneBikes, stationTwoBikes))
    
    stationMatrix[i, j] <- euclDist
  }
}
}
#TODO: Pour faire la matrice on va la faire à coup de requete. afin de faciliter le choix de la station à calculer

# ---------- METHOD WITHOUT QUERY ---------- 
query <- paste("SELECT number FROM staticTable ORDER BY number")
ID_MAPPING <- as.vector(unlist(dbGetQuery(con, query)))

dataList <- vector("list", length(ID_MAPPING))
for (i in 1:length(ID_MAPPING)) {
  query <- paste("SELECT available_bikes FROM dynamicTable where stationID = ", ID_MAPPING[i], "")
  dt <- as.vector(unlist(dbGetQuery(con, query)))
  dataList[[i]] <- dt
}

print(dataList[[120]])
print(dataList[[108]])

stationDatasMatrix <- matrix(c(0), nrow = 340, ncol = 340)
stationDatasMatrix[340, 340] <- 999
for (i in 1:length(ID_MAPPING)) {
  for (j in i:length(ID_MAPPING)) {
    if (length(dataList[[i]]) == 0) {
      euclDist <- 999
    }
    if (length(dataList[[j]]) == 0) {
      euclDist <- 999
    }
    else if (length(dataList[[i]]) != 0 & length(dataList[j]) != 0) {
      euclDist <- dist(rbind(dataList[[i]], dataList[[j]]))
    }
    print(euclDist)
    stationDatasMatrix[j, i] <- euclDist

  }
}

#Disconnect
dbDisconnect(con)
