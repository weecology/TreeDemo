#About page UI
about_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("About this project"),
      p(style="font-size:25px", "For more information on this project, including details of model training and performance, see",
        a("Weinstein, B. G., Marconi, S., Bohlman, S., Zare, A., & White, E. (2019). Individual tree-crown detection in RGB imagery using semi-supervised deep learning neural networks. Remote Sensing, 11(11), 1309.",href="https://www.mdpi.com/2072-4292/11/11/1309")),
      p(style="font-size:25px", "The goal of this project is to provide RGB tree detection at broad spatial scales. The goal is not to replace traditional ground survey techniques or suggest they can be replaced by automated approaches. While the segmentations are not perfect, they provide scale beyond traditional plot level measures. Whether this fits your scientific question depends on the sensitivity of your data to segmentation results."),
      h2("Contact"),
      p(style = "font-size:25px","benweinstein (at) weecology dot org"),
      h2("Funding"),
      p(style="font-size:25px","This research was supported by the Gordon and Betty Moore Foundation’s Data-Driven Discovery Initiative through grant GBMF4563 to E.P. White. The shiny app was hosted on Microsoft Azure with funding from Microsoft AI4Earth. Special thanks to Dan Morris for his feedback during development.")
    )
  })
}