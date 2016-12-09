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
      menuItem("Informations", tabName = "information", icon = icon("database")),
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
      tabItem(tabName = "information", 
              h2("Dashboard informations"))
    )
  )
)