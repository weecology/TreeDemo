#About page UI
street_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("Street Tree Prediction"),
      p("Applying DeepForest to Portland Street Trees Dataset. Field collected street trees in blue circles, DeepForest predictions in red rectangles."),
      leafletOutput("street_trees", height=1000)
  )})
}

