#Preprocessing functions
library(jpeg)
library(tiff)
library(stringr)

#Reader all tif images and make small jpeg thumbnails
create_thumbnails<-function(){
  #find all tifs
  all_tifs<-list.files("data",recursive = T,pattern=".tif",full.names = T)
  for(x in all_tifs){
    img <- readTIFF(x, native=TRUE)
    plot_name = str_match(x,"(\\w+).tif")[,2]
    new_path = paste("data/","thumbnails/",plot_name,".jpeg",sep="") 
    writeJPEG(img, target = new_path, quality = 1)
  }
}

create_thumbnails()

