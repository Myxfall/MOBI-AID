#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI_New/MOBI-AID")

library("dplyr")
library("RSQLite")
library("ape")
library("rafalib")
library("pvclust")
library("dendextend")
library("graphics")

#Connection to database
con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")

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

distEucl <- dist(as.matrix(stationDataFrame))
hc <- hclust(distEucl)

# Vector of cluster
memb <- cutree(hc , k = 5)
