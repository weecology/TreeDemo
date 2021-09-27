#About page UI
NEON_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("NEON Crown Maps"),
      p("The central aim of this project is to provide crown maps for the sites at the National Ecological Observation Network. Once completed, these data will be available for the community. Here we show sample predictions from 15 sites. Zoom in to see millions of individual tree predictions"),
      p("To change sites select from the first dropdown menu on the left"),
      tags$iframe(
        seamless = "seamless", 
        src = "http://weecology.westus.cloudapp.azure.com:8080/ext/visus/viewer.html?", 
        height = 1000, width = 1400
      ),
      #leafletOutput("NEONprediction", height=1000),
      h2("Acknowledgments"),
      p("Thanks to Steve Petruzza at the Univerity of Utah and the OpenVisus framework for their help with large scale web visualization
        (https://github.com/sci-visus/OpenVisus)")
      #plotOutput("HeightDistribution",width = "50%")
  )})
}

