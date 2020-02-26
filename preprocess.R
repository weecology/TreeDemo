#Preprocessing functions
library(jpeg)
library(tiff)
library(stringr)
library(reticulate)
library(lidR)
library(raster)
library(sf)

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
    predictions <- sf::read_sf(available_shp[x])
    print(available_shp[x])
    print(projection(predictions))
    predictions<-st_transform(predictions,crs=3857)
    prediction_list[[x]]<-predictions[,c("label","height")]
  }
  
  all_predictions<-do.call(rbind, prediction_list)
  write_sf(all_predictions,"data/NEON/allpredictions.shp",driver="ESRI SHAPEFILE")
}

project_shp()

predictions_WREF <- sf::read_sf("data/NEON/2019_WREF_3_582000_5073000_image.shp")
predictions_WREF<-predictions_WREF[,c("label","height")]
predictions_WREF<-st_transform(predictions_WREF,crs=3857)

predictions_ABBY <- sf::read_sf("data/NEON/2018_ABBY_2_557000_5065000_image.shp")
predictions_ABBY<-predictions_ABBY[,c("label","height")]
predictions_ABBY<-st_transform(predictions_ABBY,crs=3857)


predictions_OSBS <- sf::read_sf("data/NEON/2018_OSBS_4_400000_3285000_image.shp")
predictions_OSBS<-predictions_OSBS[,c("label","height")]
predictions_OSBS<-st_transform(predictions_OSBS,crs=3857)

utm_10m<-rbind(predictions_WREF,predictions_ABBY,predictions_OSBS)
#utm_10m<-st_transform(utm_10m,crs=3857)
write_sf(utm_10m,"data/NEON/utm10_crossOSBS.shp",driver="ESRI SHAPEFILE")

mapview(utm_10m)


#Project and merge mapbox tiles
available_tif<-list.files("/Users/ben/Dropbox/Weecology/mapbox",pattern=".tif",full.names = T)

#Project to web mercator and merge
r<-raster::stack(available_tif[1])
f<-raster::stack(available_tif[2])
proj_f<-projectRaster(f,crs="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs")
d<-merge(proj_r,proj_f)

for(path in available_tif[2:length(available_tif)]){
  
}


  