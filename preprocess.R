#Preprocessing functions
library(jpeg)
library(tiff)
library(stringr)
library(reticulate)
library(lidR)
library(raster)

#Reader all tif images and make small jpeg thumbnails
create_thumbnails<-function(){
  #load thumbnails
  #find all tifs
  all_tifs<-list.files("data/evaluation/RGB/",recursive = T,pattern=".tif",full.names = T)
  for(x in all_tifs){
    print(x)
    img <- readTIFF(x, native=TRUE)
    plot_name = str_match(x,"(\\w+).tif")[,2]
    new_path = paste("www/",plot_name,".jpeg",sep="") 
    writeJPEG(img, target = new_path, quality = 1)
  }
}

create_thumbnails()

#Predict RGB for all images
predict_images<-function(){
  use_condaenv("TreeDemo",required=TRUE)
  source_python("utilities.py")
  predict_all_images()
}

predict_images()

#Drape lidar images
drape_cloud<-function(){
  use_condaenv("TreeDemo",required=TRUE)
  source_python("create_lidar_annotations.py")
  drape_wrapper()
}

drape_cloud()

#project into longlat

project_shp<-function(){
  available_shp<-list.files("data/NEON/",pattern=".shp",full.names = T)
  prediction_list<-list()
  for(x in 1:length(available_shp)){
    predictions <- read_sf(available_shp[x])
    predictions<-st_transform(predictions,crs=3857)
    prediction_list[[x]]<-predictions[,c("label","height")]
  }
  
  all_predictions<-do.call(rbind, prediction_list)
  write_sf(all_predictions,"data/NEON/allpredictions.shp",driver="ESRI SHAPEFILE")
}

project_shp()

#Project and merge mapbox tiles
available_tif<-list.files("/Users/ben/Dropbox/Weecology/mapbox",pattern=".tif",full.names = T)

#Project to web mercator and merge
r<-raster::stack(available_tif[1])
f<-raster::stack(available_tif[2])
proj_f<-projectRaster(f,crs="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs")
d<-merge(proj_r,proj_f)

for(path in available_tif[2:length(available_tif)]){
  
}

for(x in 1:1000){
  plot(all_predictions[sample(nrow(all_predictions),1),])
  Sys.sleep(2)
}
  