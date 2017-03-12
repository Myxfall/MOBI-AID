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
# plot(hc)

# ---------- dynamic method --------
# Ask number cluster
clusterNbr <- 5
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

if (FALSE) {
#---------- Static method ---------
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

# --------- CLUSTER 3 ---------
cluster3_long <- vector()
cluster3_lat <- vector()
for (i in 1:length(group3)) {
  ID <- tm$number[group3[i]]
  long <- tm$longitude[group3[i]]
  lat <- tm$latitude[group3[i]]
  
  cluster3_long[i] <- long
  cluster3_lat[i] <- lat
}

# --------- CLUSTER 4 ---------
cluster4_long <- vector()
cluster4_lat <- vector()
for (i in 1:length(group4)) {
  ID <- tm$number[group4[i]]
  long <- tm$longitude[group4[i]]
  lat <- tm$latitude[group4[i]]
  
  cluster4_long[i] <- long
  cluster4_lat[i] <- lat
}

# --------- CLUSTER 5 ---------
cluster5_long <- vector()
cluster5_lat <- vector()
for (i in 1:length(group5)) {
  ID <- tm$number[group5[i]]
  long <- tm$longitude[group5[i]]
  lat <- tm$latitude[group5[i]]
  
  cluster5_long[i] <- long
  cluster5_lat[i] <- lat
}


map <- get_map(location = 'Brussels', zoom = 12)
cluster1Pos <- data.frame(lon = cluster1_long, lat = cluster1_lat)
cluster2Pos <- data.frame(lon = cluster2_long, lat = cluster2_lat)
cluster3Pos <- data.frame(lon = cluster3_long, lat = cluster3_lat)
cluster4Pos <- data.frame(lon = cluster4_long, lat = cluster4_lat)
cluster5Pos <- data.frame(lon = cluster5_long, lat = cluster5_lat)
ggmap(map) + geom_point(data = cluster1Pos, aes(x = cluster1Pos$lon, y = cluster1Pos$lat, size = 1), alpha = 1, color = "red") + 
  geom_point(data = cluster2Pos, aes(x = cluster2Pos$lon, y = cluster2Pos$lat, size = 1), alpha = 1, color = "blue") +
  geom_point(data = cluster3Pos, aes(x = cluster3Pos$lon, y = cluster3Pos$lat, size = 1), alpha = 1, color = "green") +
  geom_point(data = cluster4Pos, aes(x = cluster4Pos$lon, y = cluster4Pos$lat, size = 1), alpha = 1, color = "yellow") +
  geom_point(data = cluster5Pos, aes(x = cluster5Pos$lon, y = cluster5Pos$lat, size = 1), alpha = 1, color = "purple")
}

map <- get_map(location = 'Brussels', zoom = 12)
# URL GGMAP:
#1: https://github.com/dkahle/ggmap
#2: http://www.comeetie.fr/partage/ehess/
