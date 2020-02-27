#About page UI
NEON_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("NEON Crown Maps"),
      p("The central aim of this project is to provide crown maps for the sites at the National Ecological Observation Network. Once completed, these data will be available for the community. Here we show sample predictions from 15 sites."),
      p("Please allow 10-15 seconds for the browser to load on selection, as the tiles are very large and contain tens of thousands of trees. The image may turn gray during selection, please be patient."),
      actionButton("return","Return to full extent"),
      leafletOutput("NEONprediction", height=1000),
      h2("Tree Height Distribution"),
      plotOutput("HeightDistribution",width = "50%")
  )})
}

