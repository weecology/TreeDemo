#About page UI
NEON_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("NEON Crown Maps"),
      p("The central aim of this project is to provide crown maps for the sites at the National Ecological Observation Network. Once completed, these data will be available for the community. Here we show sample predictions from 15 sites."),
      p("Please allow 10-15 seconds for the browser to load on selection, as the tiles are very large and contain tens of thousands of trees."),
      selectInput(inputId = "NEON_site",label="NEON Site",
                  choices=c("Longleaf Pine, Florida (OSBS)",
                            "Sierra Nevadas, California (TEAK)",
                            "Everglades Wetland, Florida (DSNY)",
                            "Pacific Northwest, Washington (WREF)",
                            "Mid-atlantic Decidious, Maryland (SERC)",
                            "Great Plains, North Dakota (NOGP)",
                            "Northeast Decidious, New Hampshire (BART)",
                            "Southern Conifers, Alabama (DELA)",
                            "Southern Bottomlands, Alabama (TALL)",
                            "Southwest Desert, Arizona (SRER)",
                            "Prarie, Kansas (KONZ)",
                            "Riparian Wetland, Alaska (BONA)",
                            "Logged Conifer, Washington (ABBY)",
                            "Southern Grassland, Texas (CLBJ)")),
      leafletOutput("NEON_prediction", height=1000),
      plotOutput("HeightDistribution",width = "50%")
  )})
}

