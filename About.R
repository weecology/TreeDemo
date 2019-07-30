#About page UI
about_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("About this project"),
      h1("Ben Weinstein"),
      img(src="ben-weinstein.jpg",height="100px"),
      p("I am a researcher in the White Lab at the University of Florida. I study ecology, evolution and the use of computer vision for biological monitoring."),
      p("This project is ongoing and we are working to improve predictions, combine multidata sources and create reproducible workflows. Are you a machine learning researcher who needs data? Are you a forester interested in trying out the model? Contact Us!"),
      h2("Contact"),
      p("benweinstein (at) weecology dot org")
    )
  })
}