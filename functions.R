#functions
library(dplyr)
library(ggplot2)
library(leaflet)
library(sf)
library(raster)
library(gridExtra)
library(lidR)
library(rgl)
library(stringr)
library(reticulate)

create_map<-function(addRGB=F){
  #basetile
  field_data<-st_read("data/field-sites.csv",options=c("X_POSSIBLE_NAMES=Longitude","Y_POSSIBLE_NAMES=Latitude"))
  
  #Limit to sites we have
  sites_in_folder<-list.files("data/evaluation/RGB/",full.names = F)
  sites_in_folder<-unique(str_match(sites_in_folder,"(\\w+)_")[,2])
  
  field_data<-field_data %>% filter(Site.ID %in% sites_in_folder)
  m <- leaflet(field_data) %>% addTiles() %>% addMarkers(~Longitude,~Latitude,popup=~Site.ID,layerId = ~Site.ID)
  
  if(addRGB){
    public_token = "https://api.mapbox.com/styles/v1/bweinstein/ck6nzcbj60rqk1inr3jre92g2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYndlaW5zdGVpbiIsImEiOiJ2THJ4dWRNIn0.5Pius_0u0NxydUzkY9pkWA"
    m <- m %>% addTiles(urlTemplate=public_token, options=tileOptions(maxZoom = 21))
  }
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

#Render gallery
renderGallery<-function(image_paths){
  
  #shuffle and show top 8 images
  image_paths<-sample(image_paths)
  selected_images<-image_paths[1:8]
  renderUI({
    fluidRow(
      lapply(selected_images, function(img) {
        column(3,offset = 0.25, 
               tags$img(src=img, class="clickimg", 'data-value'=img,width="100%")
        )
      })
    )
  })
}

#plot corresponding lidar
plot_lidar<-function(current_plot_name){

  #Infer path from name
  path_to_tile<-paste("data/evaluation/LiDAR/",current_plot_name,".laz",sep="")
  
  #does it exist?
  if(!file.exists(path_to_tile)){
    paste(path_to_tile,"does not exist")
    return(NULL)
  }
  
  #Read tile
  print(getwd())
  tryCatch(r<-readLAS(path_to_tile),error = function(e) stop(e,paste("Missing File",path_to_tile)))

  #drop non-predicted points
  g<-lasfilter(r,!label==0)
  
  if(nrow(g@data)==0){
    return(NULL)
  }
  #Plot widget
  renderRglwidget({
    try(rgl.close())
    plot(g,size=3,color="label",colorPalette=sample(rainbow(length(unique(g$label)))))
    rglwidget()
  })
}

plot_rgb<-function(current_plot_name,overlay_detections=TRUE){
  #Infer site
  site_dir<-str_match(current_plot_name,"(\\w+)_")[,2]
  
  #Infer path from name
  path_to_tile<-paste("data/evaluation/RGB/",current_plot_name,".tif",sep="")
  
  #read raster
  r<-stack(path_to_tile)
  
  s<-renderPlot({
    plotRGB(r)
    #Overlay detections?
    if(overlay_detections){
      path_to_csv<-paste("data/evaluation/RGB/",current_plot_name,".csv",sep="")
      #Grab extent
      e<-extent(r)
      plot_bbox(path_to_csv,raster_extent =e)
    }
  })
  return(s)
}

#plot bounding boxes
bbox_wrap <- function(xmin,xmax,ymin,ymax) {
  st_as_sfc(st_bbox(extent(xmin,xmax,ymin,ymax)))
}
    
plot_bbox<-function(path_to_csv,raster_extent){
  df<-read.csv(path_to_csv)
  
  #Convert image coords to utm
  df$utm_xmin = df$xmin * 0.1 + raster_extent@xmin
  df$utm_xmax = df$xmax * 0.1 + raster_extent@xmin
  
  #R and Python coord flip, numpy origin is topleft
  df$utm_ymin = raster_extent@ymax - df$ymax * 0.1
  df$utm_ymax = raster_extent@ymax - df$ymin * 0.1
  
  if(nrow(df)==0){
    return(NULL)
  }
  
  utm_coords<-df %>% dplyr::select(utm_xmin,utm_xmax,utm_ymin,utm_ymax)
  boxes<-apply(utm_coords, 1,function(x) {bbox_wrap(x['utm_xmin'],x['utm_xmax'],x['utm_ymin'],x['utm_ymax'])})
  boxes<-do.call(c,boxes)
  plot(boxes,add=T,lwd=2)
}

#image prediction
predict_image<-function(local_path){
  print(paste("Working dir is ",getwd()))
  use_condaenv("TreeDemo",required=TRUE)
  source_python("utilities.py")
  save_path<-prediction_wrapper(local_path)
  return(save_path)
}

#Neon prediction
neon_prediction<-function(leaflet_proxy, predictions){
  #Set view
  neon_map <- leaflet_proxy %>% addPolylines(data=predictions,color="red",weight=2)
  return(neon_map)
}

#Tree density raster
# tree_density<-function(leaflet_proxy,current_site){
#   available_tif<-list.files("data/NEON/rasters/",pattern="tif",full.names = T)
#   site_tif <- available_tif[str_detect(available_tif,current_site)]
#   site_tif<-raster(site_tif)
#   leaflet_proxy %>% addRasterImage(site_tif,opacity = 0.2,colors="Blues")
# }

load_predictions<-function(site_name="OSBS"){
  available_shp<-list.files("data/NEON/",pattern=".shp",full.names = T)
  site_shp <- available_shp[str_detect(available_shp,site_name)]
  predictions<-read_sf(site_shp)
  predictions<-st_transform(predictions,"+proj=longlat +datum=WGS84 +no_defs")
  return(predictions)
  }

height_distribution <- function(predictions, current_site){
  p<-ggplot(predictions) + geom_histogram(aes(x=height)) + labs(x="Height (m)") + ggtitle(paste(current_site," n=",nrow(predictions),sep=""))
  return(renderPlot(p))
}

#Street tree prediction
street_prediction<-function(){
  
  #Ground truth
  trees<-read_sf("data/StreetTrees/test_trees.shp")
  trees<-st_transform(trees,"+proj=longlat +datum=WGS84 +no_defs")
  
  predictions<-read_sf("data/StreetTrees/trained_model.shp")
  predictions<-st_transform(predictions,"+proj=longlat +datum=WGS84 +no_defs")
  
  #Predictions
  public_token = "https://api.mapbox.com/styles/v1/bweinstein/ck6nxanpr05it1jt829blfqz8/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYndlaW5zdGVpbiIsImEiOiJ2THJ4dWRNIn0.5Pius_0u0NxydUzkY9pkWA"
  tree_extent=extent(trees)
  
  #Set view
  x_location <- mean(c(as.numeric(tree_extent@xmax),as.numeric(tree_extent@xmin)))
  y_location <- mean(c(as.numeric(tree_extent@ymax),as.numeric(tree_extent@ymin)))
  
  street_map <- leaflet() %>%
    addTiles(urlTemplate=public_token, options=tileOptions(maxZoom = 21)) %>% addCircles(data=trees,radius = 1) %>% 
    setView(zoom=19,lng=x_location,lat=y_location) %>% fitBounds(as.numeric(tree_extent@xmin),as.numeric(tree_extent@ymin),
              as.numeric(tree_extent@xmax),as.numeric(tree_extent@ymax)) %>%
    addPolylines(data=predictions,color="red",weight=2)
    return(renderLeaflet(street_map))
}

