#About page UI
NEON_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("NEON Crown Maps"),
      p("The central aim of this project is to provide crown maps for the sites at the National Ecological Observation Network. Once completed, these data will be available for the community. Here we show sample predictions from OSBS and TEAK sites."),
      p("Please allow 10-15 seconds for the browser to load, as the tiles are very large and contain tens of thousands of trees. Once loaded, move the map to engage the RGB tiles."),
      selectInput(inputId = "NEON_site",label="NEON Site",
                  choices=c("Longleaf Pine, Florida (OSBS)",
                            "Sierra Nevadas, California (TEAK)",
                            "Everglades Wetland, Florida (DSNY)",
                            "Pacific Northwest, Washington (WREF)",
                            "Mid-atlantic Decidious, Maryland (SERC)",
                            "Great Plains, North Dakota (NOGP)",
                            "Southern Bottomlands, Alabama (TALL)",
                            "Southwest Desert, Arizona (SRER)",
                            "Prarie, Kansas (KONZ)",
                            "Logged Conifer, Washington (ABBY)",
                            "Southern Grassland, Texas (CLBJ)")),
      leafletOutput("NEON_prediction", height=1000)
  )})
}

