#About page UI
data_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("Link to the data"),
      p("The White Lab at the University of Florida strongly believes in open data. Anyone is welcome to access the source code for model training, download the dataset, or download the compiled model. Efforts to increase the utility of our models are ongoing, do not hesistate to contact us for additional needs or interests."),
      h2("Training Source Code"),
      tags$a(href = "https://github.com/weecology/DeepLidar", "Github Repo"),
      h2("Trained model weights"),
      tags$a(href = "https://github.com/weecology/DeepLidar", "Dropbox link"),
      h2("NEON Tree Benchmark dataset"),
      p("In Progress"),
      tags$a(href = "https://github.com/weecology/NeonTreeEvaluation", "Current Repo")
    )
  })
}