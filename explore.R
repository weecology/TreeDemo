#Explore page

explore_page<-function(){
  renderUI({
    mainPanel(
      checkboxInput("show_detections", "Overlay Detections", FALSE,width="200px"),
      splitLayout(rglwidgetOutput("lidar"),plotOutput("rgb")),
      hr(),
      h2("Select an image to predict"),
      #custom defined UI function
      uiOutput("imageGrid"),
      tags$script(HTML(
        "$(document).on('click', '.clickimg', function() {",
        "  Shiny.onInputChange('clickimg', $(this).data('value'));",
        "});")),
      hr(),
      titlePanel("Select a site to view tree detection results"),
      leafletOutput("map")
    )})
}
