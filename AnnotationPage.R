#Annotation page UI
library(stringr)

#Available plots to annotate
image_names <- list.files("data/evaluation/RGB/",pattern=".tif")
plotIDs <- str_match(image_names,"(\\w+)_\\d+.tif")[,2]
plotIDs <- plotIDs[!str_detect(plotIDs,"competition")]
field_data <- read.csv("data/filtered_data.csv")
plotIDs <- image_names[plotIDs %in% unique(field_data$plotID)]

AnnotationPage<-function(){
  renderUI({
    fluidPage(
      titlePanel("Annotation Environment"),
      p("The National Ecological Observatory Network collects airborne and forestry data across the United States. Our goal is to turn those surveys into ecological information on individual trees. To do that we must build and validate models of tree crown detection and species classification. This page provides information for the Tree Crown Detection Zooniverse project to assist in ongoing image annotation."),
      sidebarPanel(width=2,
      selectizeInput("annotation_plotID", "plotID", plotIDs, selected = "SJER_052.tif", multiple = FALSE,options = NULL),
      sliderInput("HSI_band_1", "HSI band 1:",
                  min = 0, max = 369,
                  value = 11),
      
      sliderInput("HSI_band_2", "HSI band 2:",
                  min = 0, max = 369,
                  value = 55),
      
      sliderInput("HSI_band_3", "HSI band 3:",
                  min = 0, max = 369,
                  value = 113)),
      
      mainPanel(
      leafletOutput("annotation_hsi",height="700"),
      rglwidgetOutput("annotation_lidar",height='700')
      ))})
}

