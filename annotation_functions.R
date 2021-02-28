library(raster)
library(sf)
library(dplyr)
library(leaflet)
library(lidR)
library(leafem)

get_data <- function(plot_name, type) {
  
  #drop file extension
  plot_name <- strsplit(plot_name,"\\.")[[1]][1]
  
  #Check if data has been downloaded
  if (!type %in% c("rgb", "lidar","chm", "hyperspectral", "annotations")) {
    stop(paste("No type option", type, "Available type arguments:'rgb','lidar','chm',hyperspectral','annotations'"))
  }
  
  if (type == "rgb") {
    path <- get_rgb(plot_name)
  }
  if (type == "lidar") {
    path <- get_lidar(plot_name)
  }
  if (type == "hyperspectral") {
    path <- get_hyperspectral(plot_name)
  }
  if (type == "annotations") {
    path <- get_annotations(plot_name)
  }
  if (type=="chm"){
    path<-get_chm(plot_name)
  }
  return(path)
}

get_rgb <- function(plot_name) {
  path <- paste("data/evaluation/RGB/", "/", plot_name, ".tif", sep = "")
  return(path)
}

get_lidar <- function(plot_name) {
  path <- paste("data/evaluation/LiDAR/", "/", plot_name, ".laz", sep = "")
  return(path)
}

get_hyperspectral <- function(plot_name) {
  path <- paste("data/evaluation/Hyperspectral/", "/", plot_name, "_hyperspectral.tif", sep = "")
  return(path)
}

get_chm <- function(plot_name) {
  path <- paste("data/evaluation/CHM/", "/", plot_name, "_CHM.tif", sep = "")
  return(path)
}

get_annotations <- function(plot_name) {
  path <- paste("data/annotations/", "/", plot_name, ".xml", sep = "")
  return(path)
}

annotation_lidar <- function(plotID){
  path <- get_data(plotID,"lidar")
  if(file.exists(path)){
    r<-readLAS(path)
    plot(r,size=2)
    rglwidget()
  } else{
    print(paste("No LiDAR file found at",plotID))
  }
}


annotation_leaflet<-function(plotID, field_data, hsi_layers=c(55,117,180)){
  
  #First group is rgb, then add what data is available
  groups<-c("rgb")
  
  path<-get_data(plotID,"hyperspectral")
  if(file.exists(path)){
    r <- stack(path)
    g<-r[[hsi_layers]]
    
    #hotfix, Set crs from rgb, todo hsi needs crs.
    path<-get_data(plotID,"rgb")
    r <- stack(path)
    crs(g)<-crs(r)
    
    #Add to legend
    use_HSI = TRUE
    groups <- append(groups,"Hyperspectral")
  } else{
    use_HSI = FALSE
  }

  
  path<-get_data(plotID,"chm")
  if(file.exists(path)){
    laz <- raster(path)
    
    pts <- st_as_sf(field_data, coords=c("itcEasting","itcNorthing"))
    st_crs(pts) <- st_crs(r)
    pts<-st_transform(pts,"EPSG:4326")
    
    pts$label <- paste(pts$scientificName, pts$individualID, pts$height, pts$canopyPosition, pts$plantStatus, sep = "<br/>")
    
    pal <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(laz),
                        na.color = "transparent")
    use_CHM=TRUE
    groups <- append(groups,"Canopy Height Model")
  } else{
    use_CHM=FALSE
  }
  
  map <- leaflet(data=pts) %>% 
    addLayersControl(position = "bottomleft", baseGroups =groups, options = layersControlOptions(collapsed = F)) %>% 
    addCircleMarkers(popup = ~label,radius=3,opacity=0.9,color="red") 
 
  if(use_CHM){
    map<-map %>%
      addLegend(pal = pal, values = values(laz),title = "Height", group="Canopy Height Model")  %>%
      addRasterImage(laz,group="Canopy Height Model",project=F, colors = pal) 
  }
  if(use_HSI){
    map<-map %>% addRasterRGB(g, r=1,g=2,b=3, group="Hyperspectral",project=F)
  }
  
  #Add rgb last to be on top
  map <- map %>% addRasterRGB(r, r=1,g=2,b=3, group="rgb",project=F) %>% showGroup("rgb")
  
  return(map)
  }