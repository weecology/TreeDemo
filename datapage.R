#About page UI
data_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("Link to the data"),
      p("The White Lab at the University of Florida strongly believes in open data. All are welcome to access the source code for model training, download the dataset, or predicted new images using the compiled model. Efforts to increase the utility of our models are ongoing, do not hesistate to contact us for additional needs or interests."),
      h2("DeepForest Model"),
      tags$a(href = "https://deepforest.readthedocs.io/en/latest/", "Python Package"),
      h2("NEON Tree Benchmark dataset"),
      p("In Progress"),
      tags$a(href = "https://github.com/weecology/NeonTreeEvaluation", "Current Repo")
    )
  })
}