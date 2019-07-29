#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source("functions.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  #create pages
  output$explore<-explore_page(output)
  
  #Field site maps
  output$map <- create_map()
  
  #Show detections?
  output$show_detections <- renderText({ input$show_detections })
  
  #Image gallery
  image_paths<-get_thumbnails(site="MLBS")
  output$imageGrid <- renderGallery(image_paths)
  
  #Obserer map click
  observeEvent(input$map_marker_click, {
    p<-input$map_marker_click
    cat("Site selected:",p$id)
    image_paths<-get_thumbnails(site=p$id)
    #reset gallery
    output$imageGrid <- renderGallery(image_paths)
  })
  
  #Top plots
  current_plot_name<-"WOOD_012"
  
  #Lidar plot
  output$lidar<-plot_lidar(current_plot_name)
  
  #RGB
  output$rgb<-rendertif(current_plot_name)
})
