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


main_panel<-mainPanel(
  h2("DeepForest Tree Predictions"),
  p("Rotate the point cloud to see predictions in 3D."),
  splitLayout(plotOutput("rgb",height = "600"),rglwidgetOutput("lidar")),
  hr(),
  p(style = "font-size:25px","Airborne tree detection can unlock information on forests at unprecendented scales. 
    We are developing an RGB tree detection framework called DeepForest that uses semi-supervised deep learning neural networks to predict tree crowns in imagery. DeepForest was trained ondata from the National Ecological Observation Network"),
  h2("DeepForest Model"),
  tags$a(href = "https://deepforest.readthedocs.io/en/latest/", "Python Package"),
  h2("NEON Tree Benchmark dataset"),
  tags$a(href = "https://github.com/weecology/NeonTreeEvaluation", "Current Repo"),
  p("The Weecology Lab at the University of Florida strongly believes in open data. All are welcome to access the source code for model training, download the dataset, or predicted new images using the compiled model. Efforts to increase the utility of our models are ongoing, do not hesistate to contact us for additional needs or interests.")
)

