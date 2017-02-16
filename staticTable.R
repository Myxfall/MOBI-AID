library("RSQLite")
#Wich one of json library ?
library("rjson")
library("jsonlite")

json_file <- "Bruxelles-Capitale.json"
json_data <- fromJSON(json_file)

con <- dbConnect(SQLite(), dbname="mobilityBike.db")
dbWriteTable(con, "StaticTable", json_data, overwrite=T)

dbDisconnect(con)