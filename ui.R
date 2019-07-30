#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(rgl)

#Define thumbnail dir
#Source additional pages

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("yeti"),
  
  #Navbar to each page
  navbarPage("Airborne Tree Detection Demo",
             tabPanel("Explore",uiOutput('explore')),
             tabPanel("Get the Model"),uiOutput('data_page'),
             tabPanel("Upload",uiOutput('upload')),
             tabPanel("About",uiOutput('about'))
  )))
