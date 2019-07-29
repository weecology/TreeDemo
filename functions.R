#functions
library(dplyr)
library(ggplot2)
library(leaflet)
library(sf)
library(raster)
library(RStoolbox)
library(gridExtra)
library(lidR)
library(rgl)
library(stringr)


create_map<-function(){
  #basetile
  field_data<-st_read("data/field-sites.csv",options=c("X_POSSIBLE_NAMES=Longitude","Y_POSSIBLE_NAMES=Latitude"))
  
  #Limit to sites we have
  sites_in_folder<-list.dirs("data/",full.names = F)
  field_data<-field_data %>% filter(Site.ID %in% sites_in_folder)
  m <- leaflet(field_data) %>% addTiles() %>% addMarkers(~Longitude,~Latitude,popup=~Site.ID,layerId = ~Site.ID)
  return(renderLeaflet(m))
}

#define runApp(
get_thumbnails<-function(site="All"){
  #Find thumbnails
  image_paths<-list.files("www",pattern=".jpeg")
  
  #optional filter
  if(!site=="All"){
    image_paths=image_paths[str_detect(image_paths,site)]
  } 
  return(image_paths)
}

  #plot corresponding lidar
  plot_lidar<-function(current_plot_name){
    #Infer site
    site_dir<-str_match(current_plot_name,"(\\w+)_")[,2]
    
    #Infer path from name
    path_to_tile<-paste("data/",site_dir,"/",current_plot_name,".laz",sep="")
    
    #Read tile
    print(getwd())
    tryCatch(r<-readLAS(path_to_tile),error = function(e) stop(e,paste("Missing File",path_to_tile)))

    #Plot widget
    renderRglwidget({
      try(rgl.close())
      plot(r,size=3)
      rglwidget()
    }, outputArgs = list(width = "auto", height = "200px"))
  }

plot_rgb<-function(current_plot_name){
  #Infer site
  site_dir<-str_match(current_plot_name,"(\\w+)_")[,2]
  
  #Infer path from name
  path_to_tile<-paste("data/",site_dir,"/",current_plot_name,".tif",sep="")
  
  #read raster
  r<-stack(path_to_tile)
  
  s<-renderPlot({
    plotRGB(r)
  })
  return(s)
}

#Render gallery
renderGallery<-function(image_paths){
  
  #shuffle and show top 9 images
  image_paths<-sample(image_paths)
  selected_images<-image_paths[1:9]
  renderUI({
  fluidRow(
    lapply(selected_images, function(img) {
      column(2,offset = 0.5, 
             tags$img(src=img, class="clickimg", 'data-value'=img, height="200px",width="auto")
      )
    })
  )
})
}
