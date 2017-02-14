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
mat <- matrix(c(0), ncol=2, nrow=2)
mat[1, 1] <- 9
mat

query <- paste("SELECT name FROM staticTable")
stationData <- dbGetQuery(con, query)
stationNumber <- length(stationData[[1]])

stationMatrix <- matrix(c(0), ncol = stationNumber, nrow = stationNumber)

#Recup in order of available_bikes datas
query <- paste("SELECT stationID, available_bikes FROM dynamicTable ORDER BY stationID")
stationData <- dbGetQuery(con, query)

#TODO: Pour faire la matrice on va la faire à coup de requete. afin de faciliter le choix de la station à calculer


#Disconnectt
dbDisconnect(con)
