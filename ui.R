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
      menuItem("Index", tabName = "index", icon = icon("archive")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Villo in time", tabName = "villoTime", icon = icon("calendar")),
      menuItem("Cluster", tabName = "cluster", icon = icon("database")),
      menuItem("Prediction", tabName = "prediction", icon = icon("area-chart")),
      menuItem("Source code", icon = icon("file-code-o"), 
               href = "https://github.com/Myxfall/MOBI-AID")
    )
  ),
  ## Body content
  dashboardBody(
    tabItems(
      tabItem(tabName = "index",
              h1("Dashboard introduction"),
              h2("Map of villos"),
              p("The first tab is the representation of all stations of \ villo in Brussels. The 340 stations are displayed on an interactive map, allowing the user to see precisely where the stations are located and also has the possibility to click on one of the stations in order to display a popup and thus see its name and number. 'identification."),
              p("Once the name or identity of the station has been retrieved, the user can search for a particular station in the drop-down menu below the map. This pull-down menu allows you to select a station to be analyzed in the graph below. Once done, all data from a week ago until today are displayed on a graph, and allows the user to times the evolution of the number of bikes in the selected station. Similarly, this graphic is interactive and allows the user to zoom in the graph and more easily perceive smaller time intervals."),
              h2("Villo in time"),
              p("This second tab is also an interactive map but this time allows the user to observe the evolution of number of \ villos in time and space. In fact, a cursor gives the possibility to choose a particular instant in the data set, and to display on the map the number of bicycles, represented by the diameter of the circles, at the time chosen. The map shows the number of \ villo per stations for all stations in Brussels. It is then possible to observe, as a function of time, which stations have the most bicycles, and which stations are almost devoid of them."),
              h2("Representation of clustering"),
              p("The third tab is the cluster display shown above. This tab allows you to select the method of representation in the distance matrix, the method of agglomeration of the clustering and the number of cluster to be displayed on the map. When all the options are selected, the execution of the algorithm is launched when the \ emph {run} button is pressed. Once the execution is finished, the cluters are displayed on the map of Brussels as well as on the dendrogram used during the algorithm.
This tool allows a user to observe in real time which stations have similar frequencies of use for a week, and thus allows to analyze the paternes of use of these stations at the precise moment."),
              h2("Prediction"),
              p("The last tab is the tool that allows the visualization of predictive models. In this tab the user has the choice of analyzing a particular station with the same system of selection of a station from a drop-down menu present for the tool of representation of the stations on Brussels. Here an additional choice is proposed, this is the choice of predictive model to be observed. The three models are present, the last naive method, the historical method, and the drift method. Once the method is selected, the last values of the stations are displayed and the predicted values are added.")),
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
              box(plotOutput("tree")), leafletOutput("clusterMap", height = 600, width = 600)
              
      ),
      tabItem(tabName = "prediction", 
              box(fluidPage(
                selectInput("listStations_two", label = h3("Select a station"), 
                            choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), selected = 1),
                radioButtons("predictionMethod", label = h3("Prediction method"), choices = list("Last value" = 1, "Naïve Prediction" = 2, "Drift method" = 3), selected = "1"),
                dygraphOutput("futurDygraph")#, dygraphOutput("erreurQ")
              ), width = 100)
              
      )
    )
  )
)