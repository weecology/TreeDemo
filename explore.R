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
  h2("Tree Predictions"),
  splitLayout(plotOutput("rgb",height = "600"),rglwidgetOutput("lidar")),
  hr(),
  p(style = "font-size:25px","Airborne tree detection can unlock information on forests at unprecendented scales. 
    We are developing RGB tree detection models using semi-supervised deep learning neural networks using data from the National Ecological Observation Network. See the about page for more details or get the source code and data.")
)
