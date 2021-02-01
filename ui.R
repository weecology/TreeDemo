#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
library(shiny)
library(rgl)
library(shinythemes)

#Define thumbnail dir
#Source additional pages

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("readable"),
                  
  #Navbar to each page
  navbarPage("Airborne Tree Detection Demo",
             tabPanel("Explore",uiOutput('explore')),
             tabPanel("Annotate",uiOutput('annotation_page')),
             tabPanel("Upload",uiOutput('upload')),
             tabPanel("NEON Predictions",uiOutput('NEON')),
             tabPanel("Portland Street Trees",uiOutput('street_page')),
             tabPanel("About",uiOutput('about'))
               )))
