#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
source("functions.R")

#additional pages
source("About.R")
source("explore.R")
source("datapage.R")
source("upload.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  #create pages
  output$explore<-explore_page()
  output$about<-about_page()
  output$data_page<-data_page()
  output$upload<-upload_page()
  
  #Field site maps
  output$map <- create_map()
  
  #Show detections?
  output$show_detections <- renderText({ input$show_detections })
  
  #Image gallery
  image_paths<-get_thumbnails(site="TEAK")
  output$imageGrid <- renderGallery(image_paths)
  
  #Default selected image
  #Lidar plot
  current_plot_name<-"TEAK_058"
  output$lidar<-plot_lidar(current_plot_name)
  output$rgb<-plot_rgb(current_plot_name)
  
  #Obserer map click
  observeEvent(input$map_marker_click, {
    p<-input$map_marker_click
    cat("Site selected:",p$id)
    image_paths<-get_thumbnails(site=p$id)
    
    #reset gallery
    output$imageGrid <- renderGallery(image_paths)
  })
  
  #Observer gallery click
  observeEvent(input$clickimg,{
    print(paste("current image is",input$clickimg))
    current_plot_name = str_match(input$clickimg,"(\\w+).")[,2]
 
    #Lidar plot
    output$lidar<-plot_lidar(current_plot_name)
    
    #RGB
    output$rgb<-plot_rgb(current_plot_name)
  })
  
  #Observe file input
  observeEvent(input$uploaded_image, {
    print("Observed upload")
    inFile <- input$uploaded_image
    # if (is.null(inFile)){
    #   return()
    # }
    print(inFile)
    local_path <- file.path("upload", inFile$name)
    file.copy(inFile$datapath, local_path)
    #Load model
    model<-load_environment()
    
    #observe model status change
    output$model_loading <- renderText({ 
      paste("Model Loading:", "Complete")
    })
    
    #predict image
    
    prediction_path<-prediction_wrapper(local_path)
    
    #View prediction
    r<-stack(local_path)
    p<-renderPlot({
      plotRGB(r)
      plot_bbox(prediction_path, extent(r))
    })
    #Assign to shiny object
    output$prediction_plot<-p
  })
  
})


