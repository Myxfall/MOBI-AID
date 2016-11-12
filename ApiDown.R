#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")

library("dplyr")
library("ggplot2")
library(ggmap)

UrlDecaux <- function(decaux,key) {
  if (grepl('\\?',decaux, perl = TRUE)) {
    delim <- '&'
  }
  else {
    delim <- '?'
  }
  sprintf("https://api.jcdecaux.com/vls/v1/%s%sapiKey=%s",decaux,delim,key)
}

GetJsonDecaux <- function(decaux, key = DecauxKey) {
  jsonlite::fromJSON(UrlDecaux(decaux,key), flatten = TRUE)
}

#Import and modif data
DecauxKey <- "65550c9a6efe8fe39f92aebe672943aaa36ec7eb"

Contracts <- GetJsonDecaux("contracts")

DecauxContractName <- filter(Contracts, commercial_name == "villo")[["name"]]
Stations <- GetJsonDecaux(sprintf("stations?contract=%s",DecauxContractName))

Stations <- mutate(Stations, status = factor(status, level=c("CLOSED","OPEN")))
Stations <- mutate(Stations, contract_name = factor(contract_name))
Stations <- mutate(Stations, date = as.POSIXct(last_update/1000, origin = "1970-01-01"))
StationsDate <- max(Stations[,'date'])
summary(Stations)

#Affichage Graph
qplot(data = Stations, bike_stands)
qplot(data = Stations, available_bike_stands)
qplot(data = Stations, date)

#Relations
qplot(data = Stations, bike_stands, available_bikes)

qplot(data = Stations, bike_stands, available_bikes + available_bike_stands, color = status, geom = "jitter")

#
ggplot(data = Stations, aes(x = available_bikes/bike_stands)) +
  geom_histogram()
ggplot(data = Stations, aes(x = available_bikes/bike_stands)) +
  geom_density()

ggplot(data = Stations, aes(x = available_bikes/bike_stands)) +
  geom_density() + facet_grid(~ bonus)

location.lat.max <- max(Stations[["position.lat"]])
location.lat.min <- min(Stations[["position.lat"]])
location.lat.width <- location.lat.max-location.lat.min
location.lng.max <- max(Stations[["position.lng"]])
location.lng.min <- min(Stations[["position.lng"]])
location.lng.width <- location.lng.max-location.lng.min
location.box <- c(location.lat.min-.05*location.lat.width,
                  location.lat.max+.05*location.lat.width,
                  location.lng.min-.05*location.lng.width,
                  location.lng.max+.05*location.lng.width)
names(location.box) <- c("bottom", "top", "left", "right")

map.Decaux.raw <- get_map(location.box, source = "osm", 
                          maptype = "roadmap")
#ggmap(map.Decaux.raw)
map.Decaux <- ggmap(map.Decaux.raw, extent = "device")

map.Decaux + geom_point(data = Stations, 
                        aes(x = position.lng, y = position.lat))

map.avail <- map.Decaux + geom_point(data = Stations, 
                                     aes(x = position.lng, y = position.lat, 
                                         col = available_bikes/bike_stands, 
                                         size = bike_stands),
                                     alpha = .85) + 
  scale_size(range = c(.5,3), name = "Bike stands", trans = "sqrt") +
  scale_color_gradient(limits = c(0,1), name = "Bike availability") +
  ggtitle("Bike availability") +
  theme(plot.title = element_text(size = 20))
map.avail