#!/usr/bin/Rscript
setwd("/Users/user/Documents/3eme/MOBI-AID/MOBI-AID/")

## app.R ##
library(shiny)
library(shinydashboard)
library(leaflet)
library("RSQLite")

ui <- dashboardPage(
  dashboardHeader(title = "MOBIAID Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Informations", tabName = "information", icon = icon("database")),
      menuItem("Source code", icon = icon("file-code-o"), 
               href = "https://github.com/Myxfall/MOBI-AID")
    )
  ),
  ## Body content
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard", 
              box(leafletOutput("plot1", height = 550), height = "100%", width = "100%")),
      tabItem(tabName = "information", 
              h2("Dashboard informations"))
    )
  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  con <- dbConnect(SQLite(), dbname="mobilityBike.db")
  query <- "SELECT longitude FROM StaticTable"
  long <- unlist(dbGetQuery(con, query))
  query <- "SELECT latitude FROM StaticTable"
  lat <- unlist(dbGetQuery(con, query))
  query <- "SELECT address FROM StaticTable"
  add <- as.vector(unlist(dbGetQuery(con, query)))
  print(typeof(add))
  
  mat <- matrix(c(long,lat), ncol = 2)
  try <- c("BONJOUR", "ALLO", "STANDARD")
  #Forming the matrix of station's positions
  a <- c(4.334831,4.352776,4.346942)
  b <- c(50.89752,50.85192,50.84563)
  c <- matrix(c(a,b), ncol = 2)
  
  map = leaflet() %>% addTiles() %>% setView(4.350382, 50.847436, zoom = 13) %>% addMarkers(data = mat, popup = add)
  output$plot1 = renderLeaflet(map)
}

shinyApp(ui, server)