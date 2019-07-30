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
  p("Explanation Text")
)