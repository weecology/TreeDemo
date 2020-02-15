#Preprocessing functions
library(jpeg)
library(tiff)
library(stringr)
library(reticulate)
library(TreeSegmentation)
library(lidR)

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

#Web mercator
