#About page UI
plotIDs = list.files("data/evaluation/RGB/",pattern=".tif")

AnnotationPage<-function(){
  renderUI({
    fluidPage(
      titlePanel("Annotation Environment"),
      p("The National Ecological Observatory Network collects airborne and forestry data across the United States. Our goal is to turn those surveys into ecological information on individual trees.To do that we must build and validate model of tree detection and classification. This page provides supplamental information for the Tree Crown Detection Zooniverse project"),
      selectizeInput("annotation_plotID", "plotID", plotIDs, selected = "SJER_052.tif", multiple = FALSE,options = NULL),
      leafletOutput("annotation_hsi",height="800"),
      rglwidgetOutput("annotation_lidar",height='500')
      )})
}

