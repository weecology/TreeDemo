#upload page
#About page UI
upload_page<-function(){
  renderUI({
    fluidPage(
      titlePanel("Upload an Image"),
      p("The tree detection model has been trained on 40m by 40m images from fixed-wing aircraft. Performance will be likely be best at these spatial scales. We recommend cropping a small portion of an image to upload for testing purposes."), 
        p("Please note for the purposes of this demo, prediction takes 5 - 10 seconds depending on upload time. Actual run times are much faster after loading the model once."),
      fluidRow( 
        fileInput("uploaded_image", "Upload an Image", accept = c('image/png', 'image/jpeg',"image/tiff"))
      ),
      textOutput("model_loading"),
      plotOutput("prediction_plot",height="700px")
    )
  })
}