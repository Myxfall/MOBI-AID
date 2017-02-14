#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")

library("dplyr")
library("RSQLite")

con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")

query <- paste("SELECT number FROM staticTable ORDER BY number")
ID_MAPPING <- as.vector(unlist(dbGetQuery(con, query)))

for (i in 1:length(ID_MAPPING)) {
  query <- paste("SELECT available_bikes FROM dynamicTable WHERE stationID = ", ID_MAPPING[i])
  data <- as.vector(unlist(dbGetQuery(con, query)))
  
  if (length(data) < 2013) {
    print(length(data))
    print(ID_MAPPING[i])
  }
}
