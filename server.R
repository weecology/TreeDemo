#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.

library(shiny)
library(dplyr)
source("functions.R")
source("annotation_functions.R")

options(shiny.sanitize.errors = FALSE)

#additional pages
source("About.R")
source("explore.R")
source("upload.R")
source("NEONPage.R")
source("StreetTreesPage.R")
source("AnnotationPage.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  #create pages
  output$explore<-explore_page()
  output$about<-about_page()
  output$upload<-upload_page()
  output$NEON<-NEON_page()
  output$street_page<-street_page()
  output$annotation_page<-AnnotationPage()
  ### Explore ###
  
  #Field site maps
  output$map <- create_map()
  
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
  
  ### Upload ###
  
  #Observe file input
  observeEvent(input$uploaded_image, {
    print("Observed upload")
    inFile <- input$uploaded_image
    
    print(inFile)
    local_path <- file.path("upload", inFile$name)
    file.copy(inFile$datapath, local_path)
    
    #Load model and predict
    save_path<-predict_image(local_path)
    
    print(save_path)
    
    #View prediction
    output$prediction_plot<-renderImage({
      list(src=save_path,alt="Alternate text",height=600,width=600)
    },deleteFile = FALSE)
  })
  
  output$street_trees<-street_prediction()
  
  ##Annotation page
  reactive(input$annotation_plotID,{
    output$annotation_rgb <- annotation_plot(output$annotation_plotID)
    output$annotation_lidar <- annotation_lidar(output$annotation_plotID)
    output$annotation_chm <- annotation_chm(output$annotation_plotID)
    output$annotation_HSI <- annotation_hsi(output$annotation_plotID)
  })
  
  

  
})


