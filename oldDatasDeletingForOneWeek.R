#!/usr/bin/Rscript
setwd("/home/maxromain/MOBI-AID")

library("dplyr")
library("RSQLite")

#Take the actually epoch timestamp
timestamp <- as.POSIXct( Sys.time() )
#Convert in INTEGER
timestamp <- as.integer( timestamp )
#Substract 604800 sec on the timestamp to have the timeStamp one week ago
timeStampWeekAgo <- ( timestamp - 604800 ) * 1000

#Connect to the dataBase
con <- dbConnect(SQLite(), dbname="mobilityBike_oneWeek.db")

#Create the query of deleting old datas
query <- paste("DELETE FROM dynamicTable WHERE timeStamp < ", timeStampWeekAgo)

#Send Query
dbSendQuery(con, query)

dbDisconnect(con)
