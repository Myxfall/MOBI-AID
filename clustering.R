#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI_New/MOBI-AID")

library("dplyr")
library("RSQLite")
library("ape")
library("rafalib")
library("pvclust")
library("dendextend")

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

if (FALSE){
distEucl <- dist(as.matrix(stationDataFrame))
hc <- hclust(distEucl)

dend <- as.dendrogram(hc)
dend <- rotate(dend, 1:150)
dend <- color_branches(dend, k=20)
dend <- set(dend, "labels_cex", 0.1)
plot(dend)
}

#plot(as.dendrogram(hc), hang = -1, cex = 0.3, xlab = "Cluster", horiz = TRUE)
#plot(as.phylo(hc), type = "fan", cex = 0.3)
#plot(hc,cex=0.5)
#myplclust(hc, cex=0.5)

result <- parPvclust(cl=NULL, stationDataFrame, nboot = 100)
plot(result)


