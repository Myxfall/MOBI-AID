#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI_New/MOBI-AID")

library("dplyr")
library("RSQLite")
library("ape")
library("rafalib")
library("pvclust")
library("dendextend")
library("graphics")
library("ggmap")


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

group1 <- vector()
group2 <- vector()
group3 <- vector()
group4 <- vector()
group5 <- vector()

for (i in 1:length(memb)) {
  #Separing in clusters
  if (memb[i] == 1) {
    group1[length(group1)+1] <- i
  }
  else if (memb[i] == 2) {
    group2[length(group2)+1] <- i
  }
  else if (memb[i] == 3) {
    group3[length(group3)+1] <- i
  }
  else if (memb[i] == 4) {
    group4[length(group4)+1] <- i
  }
  else if (memb[i] == 5) {
    group5[length(group5)+1] <- i
  }
}

con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")
query <- "SELECT number, latitude, longitude FROM StaticTable ORDER BY number"
tm <- dbGetQuery(con, query)

#TODO: bug ici, il prend à la suite, et non la bonne station
# --------- CLUSTER 1 ---------
cluster1_long <- vector()
cluster1_lat <- vector()
for (i in 1:length(group1)) {
  ID <- tm$number[group1[i]]
  long <- tm$longitude[group1[i]]
  lat <- tm$latitude[group1[i]]
  
  cluster1_long[i] <- long
  cluster1_lat[i] <- lat
}

# --------- CLUSTER 2 ---------
cluster2_long <- vector()
cluster2_lat <- vector()
for (i in 1:length(group2)) {
  ID <- tm$number[group2[i]]
  long <- tm$longitude[group2[i]]
  lat <- tm$latitude[group2[i]]
  
  cluster2_long[i] <- long
  cluster2_lat[i] <- lat
}


map <- get_map(location = 'Brussels', zoom = 12)
cluster1Pos <- data.frame(lon = cluster1_long, lat = cluster1_lat)
cluster2Pos <- data.frame(lon = cluster2_long, lat = cluster2_lat)
ggmap(map) + geom_point(data = cluster1Pos, aes(x = cluster1Pos$lon, y = cluster1Pos$lat, size = 1), alpha = 1, color = "red") + geom_point(data = cluster2Pos, aes(x = cluster2Pos$lon, y = cluster2Pos$lat, size = 1), alpha = 1, color = "blue")

# URL GGMAP:
#1: https://github.com/dkahle/ggmap
#2: http://www.comeetie.fr/partage/ehess/
