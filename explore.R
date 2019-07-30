#Explore page

explore_page<-function(){
  renderUI({
    sidebarLayout(mainPanel = main_panel,sidebarPanel = side_panel)
    })
}

#side panel
side_panel<-sidebarPanel(
  titlePanel("Select a site"),
  leafletOutput("map"),
  h2("Select an image"),
  #custom defined UI function
  uiOutput("imageGrid"),
  tags$script(HTML(
    "$(document).on('click', '.clickimg', function() {",
    "  Shiny.onInputChange('clickimg', $(this).data('value'));",
    "});"))
)

#main panel
main_panel<-mainPanel(
  checkboxInput("show_detections", "Overlay Detections", FALSE,width="200px"),
  splitLayout(rglwidgetOutput("lidar"),plotOutput("rgb")),
  hr(),
  h3("Airborne tree detection promises to unlock information on forests at unprecendented scales. 
    We are developing RGB tree detection models built from semi-supervised deep learning neural networks. Using data from the National Ecological Observation Network, our models can be applied to a wide range of forest conditions. See the about page for more details or get the source code and data.")
)