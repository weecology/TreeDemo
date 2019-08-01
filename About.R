#About page UI
about_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("About this project"),
      p(style="font-size:25px", "For more information on this project, including details of model training and performance, see",
        a("Weinstein, B. G., Marconi, S., Bohlman, S., Zare, A., & White, E. (2019). Individual tree-crown detection in RGB imagery using semi-supervised deep learning neural networks. Remote Sensing, 11(11), 1309.",href="https://www.mdpi.com/2072-4292/11/11/1309")),
      h1("Ben Weinstein"),
      img(src="ben-weinstein.jpg",height="300px"),
      p(style = "font-size:25px","I am a researcher in the White Lab at the University of Florida. I study ecology, evolution and the use of computer vision for biological monitoring."),
      p(style = "font-size:25px","This project is ongoing and we are working to improve predictions, combine multidata sources and create reproducible workflows. Are you a machine learning researcher who needs data? Are you a forester interested in trying out the model? Contact Us!"),
      h2("Contact"),
      p(style = "font-size:25px","benweinstein (at) weecology dot org"),
      h2("Funding"),
      p(style="font-size:25px","This work was funded by a Moore-Sloan Data Science Grant to Ethan White (). The shiny app was hosted on Microsoft Azure with funding from Microsoft AI4Earth. Special thanks to Dan Morris for his feedback during development.")
    )
  })
}