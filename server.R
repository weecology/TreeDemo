#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.

library(shiny)
library(dplyr)
source("functions.R")

options(shiny.sanitize.errors = FALSE)

#additional pages
source("About.R")
source("explore.R")
source("upload.R")
source("NEONPage.R")
source("StreetTreesPage.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  #create pages
  output$explore<-explore_page()
  output$about<-about_page()
  output$upload<-upload_page()
  output$NEON<-NEON_page()
  output$street_page<-street_page()
  
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
    # if (is.null(inFile)){
    #   return()
    # }
    print(inFile)
    local_path <- file.path("upload", inFile$name)
    file.copy(inFile$datapath, local_path)
    
    #Load model and predict
    save_path<-predict_image(local_path)
    
    #View prediction
    p<-renderImage({
      list(src=save_path)
    })
    
    #Assign to shiny object
    output$prediction_plot<-p
  })
  
  ### NEON Predictions ###
  #Top map
  output$NEONprediction<-create_map(addRGB = T)
  
  #Zoom to site
  observeEvent(input$NEONprediction_marker_click, {
    p<-input$NEONprediction_marker_click
    leafletProxy("NEONprediction") %>% setView(p$lng,p$lat,zoom=15)
  })
  
  mapzoom <-  reactive({
    if(is.null(input$NEONprediction_zoom)){
      return(4)
    } else{
      return(input$NEONprediction_zoom)
    }
  })
  
  mapsite <-  reactive({
    if(is.null(input$NEONprediction_marker_click)){
      return("OSBS")
    } else{
      return(input$NEONprediction_marker_click$id)
    }
  })
  
  observe({
    current_zoom <- mapzoom()
    current_site <- mapsite()
   if(current_zoom > 18){
      neon_prediction(leaflet_proxy = leafletProxy("NEONprediction"), current_site)
    } else{
      print(paste("Current site is:",current_site,"Current zoom is:",current_zoom))
    }
  })
  

  

    
  output$street_trees<-street_prediction()
})


