#!/usr/bin/Rscript


## app.R ##
library(shiny)
library(shinydashboard)
library(leaflet)
library("RSQLite")
library(dygraphs)
library(xts)

ui <- dashboardPage(
  dashboardHeader(title = "MOBIAID Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Villo in time", tabName = "villoTime", icon = icon("calendar")),
      menuItem("Cluster", tabName = "cluster", icon = icon("database")),
      menuItem("Source code", icon = icon("file-code-o"), 
               href = "https://github.com/Myxfall/MOBI-AID")
    )
  ),
  ## Body content
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard", 
              box(leafletOutput("plot1", height = 600), height = "100%", width = "100%"),
              box(fluidPage(
                # ListBox 
                selectInput("listStations", label = h3("Select a station"), 
                            choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), 
                            selected = 1),
                #Prompt select Value
                dygraphOutput("dygraph")
              ), width = 100)
              
      ),
      tabItem(tabName = "villoTime",
              box(leafletOutput("plot2", height = 600), height = "100%", width = "100%"),
              box(fluidPage(
                sliderInput("slider", label = h3("Select Time"), min = 1, max = 100, value = 1)
              ),width = 100)
      ),
      tabItem(tabName = "cluster", 
              box(
                fluidPage(
                  radioButtons("clusterDist", label = h3("Distance method"), choices = list("Euclidean" = "euclidean", "Maximum" = "maximum", "Manhattan" = "manhattan", "Canberra" = "canberra", "Binary" = "binary", "Minkowski" = "minkowski"), selected = "euclidean")
                )
              ),
              box(
                fluidPage(
                  radioButtons("clusterAvg", label = h3("Agglomeration method"), choices = list("complete" = "complete", "average" = "average", "ward.D" = "ward.D", "ward.D2" = "ward.D2", "single" = "single", "mcquitty" = "mcquitty", "median" = "median", "centroid" = "centroid"), selected = "complete")
                )
              ),
              box(
                fluidPage(numericInput("clusterNbr", label = h3("Number of cluster"), value = 5))
              ), actionButton("clusterRun", "Run"),
              box(plotOutput("tree"))
              
      )
    )
  )
)