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
  r<-readLAS(path)
    plot(r,size=2)
    rglwidget()
}


annotation_leaflet<-function(plotID, field_data){
  path<-get_data(plotID,"hyperspectral")
  r <- stack(path)
  g<-r[[c(55,117,180)]]
  
  #hotfix, Set crs from rgb, todo hsi needs crs.
  path<-get_data(plotID,"rgb")
  r <- stack(path)
  crs(g)<-crs(r)
  
  path<-get_data(plotID,"chm")
  laz <- raster(path)
  
  pts <- st_as_sf(field_data, coords=c("itcEasting","itcNorthing"))
  st_crs(pts) <- st_crs(r)
  pts<-st_transform(pts,"EPSG:4326")
  
  pts$label <- paste(pts$taxonID, pts$individualID, pts$height, collapse = "<br/>")

  leaflet(data=pts)  %>% addMarkers(popup = ~label) %>% 
    addLayersControl(position = "topleft", baseGroups = c("rgb", "hsi","Canopy Height Model"), options = layersControlOptions(collapsed = F)) %>% 
    addRasterRGB(r, r=1,g=2,b=3, group="rgb",project=F) %>%
    addRasterRGB(g, r=1,g=2,b=3, group="hsi",project=F) %>%
    addRasterImage(laz,group="Canopy Height Model",project=F)
  
  }