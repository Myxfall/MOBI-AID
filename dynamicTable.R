#!/usr/bin/Rscript

setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")
source("staticTable.R")

library("RSQLite")

json_file <- "Bruxelles-Capitale.json"
json_data <- fromJSON(json_file)

con <- dbConnect(SQLite(), dbname="mobilityBike.db")
dbSendQuery(con,
            "CREATE TABLE dynamicTable
            (stationID INTEGER,
            status INTEGER,
            bike_stands INTEGER,
            available_bike_stands INTEGER,
            available_bikes INTEGER,
            timeStamp REAL)")

dbDisconnect(con)