#Annotation page UI
library(stringr)

#Available plots to annotate
plotIDs <- list.files("data/evaluation/RGB/",pattern=".tif")
plotIDs <- plotIDs[!str_detect(plotIDs,"competition")]
field_data <- read.csv("data/filtered_data.csv")
plotIDs <- plotIDs[plotIDs %in% paste(unique(field_data$plotID),"tif",sep=".")]

AnnotationPage<-function(){
  renderUI({
    fluidPage(
      titlePanel("Annotation Environment"),
      p("The National Ecological Observatory Network collects airborne and forestry data across the United States. Our goal is to turn those surveys into ecological information on individual trees. To do that we must build and validate models of tree crown detection and species classification. This page provides information for the Tree Crown Detection Zooniverse project to assist in ongoing image annotation."),
      sidebarPanel(width=2,
      selectizeInput("annotation_plotID", "plotID", plotIDs, selected = "SJER_052.tif", multiple = FALSE,options = NULL),
      # Input: Simple integer interval ----
      sliderInput("HSI_band_1", "HSI band 1:",
                  min = 0, max = 369,
                  value = 11),
      
      # Input: Decimal interval with step value ----
      sliderInput("HSI_band_2", "HSI band 2:",
                  min = 0, max = 369,
                  value = 55),
      
      # Input: Specification of range within an interval ----
      sliderInput("HSI_band_3", "HSI band 3:",
                  min = 0, max = 369,
                  value = 113)),
      
      mainPanel(
      leafletOutput("annotation_hsi",height="700"),
      rglwidgetOutput("annotation_lidar",height='700')
      ))})
}

