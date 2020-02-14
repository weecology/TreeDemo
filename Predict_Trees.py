## Prediction of Trees for Shiny app
from deepforest import deepforest
import utilities
import cv2
import matplotlib.pyplot as plt  

class Tree_Model:
    
    def __init__(self, model_path):
        self.model_path = model_path
        
        #read and load models
        self.read_config()
        self.load_model()
    
    def read_config(self):
        self.config = utilities.read_config()
        
    def load_model(self):
        self.model = utilities.read_model(self.model_path, self.config)
        self.model._make_predict_function()
        
    def predict_image(self, image):
        print("Image shape is {}".format(image.shape))
        prediction = utilities.predict_image(model= self.model,raw_image= image)
        
        #return in RGB order
        prediction = prediction[:,:,::-1]
        
        return prediction
      
        