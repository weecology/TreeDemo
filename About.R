#About page UI
about_page<-function(){
  print("making page")
  renderUI({
    fluidPage(
      titlePanel("About this project"),
      h1("Ben Weinstein"),
      p("I am a researcher in the White Lab at the University of Florida. I study ecology, evolution and the use of computer vision for biological monitoring"),
      h2("Contact"),
      p("benweinstein (at) weecology dot org")
    )
  })
}