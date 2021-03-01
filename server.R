#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.

library(shiny)
library(dplyr)
library(leaflet)
library(leafem)

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
  field_data <- read.csv("data/filtered_data.csv")
  #Field site maps
  output$map <- create_map()
  
  #Image gallery
  image_paths<-get_thumbnails(site="TEAK")
  output$imageGrid <- renderGallery(image_paths)
  
  #Default selected image
  #Lidar plot
  current_plot_name<-"TEAK_058_2018"
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
  selected_field_data<-reactive({
    selected_plotID <- str_match(input$annotation_plotID,"(\\w+)_\\d+.tif")[,2]
    print(selected_plotID)
    field_data <- field_data %>% filter(plotID==selected_plotID)
    return(field_data)
  })

  #HSI bands
  hsi_bands <- reactive({
    c(input$HSI_band_1, input$HSI_band_2, input$HSI_band_3)
  })
  
  output$annotation_lidar <-   renderRglwidget(annotation_lidar(input$annotation_plotID))
  output$annotation_hsi <- renderLeaflet(annotation_leaflet(input$annotation_plotID, selected_field_data()))
  
  #Update HSI bands
  observeEvent(ignoreInit =TRUE, hsi_bands(), {
    if(!sum(hsi_bands()==c(11,55,113))==3){
      field_data<-selected_field_data()
      selected_plotID <-  unique(field_data$plotID)
      path<-get_data(selected_plotID,"hyperspectral")
      r <- stack(path)
      g<-r[[hsi_bands()]]
      
      #hotfix, Set crs from rgb, todo hsi needs crs.
      path<-get_data(selected_plotID,"rgb")
      r <- stack(path)
      crs(g)<-crs(r)
      
      leafletProxy("annotation_hsi") %>%
        addRasterRGB(g, r=1,g=2,b=3, group="hsi",project=F)
    } 

  })
  
})


