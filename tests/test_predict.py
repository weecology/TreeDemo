#test image prediction for debugging
from utilities import *
import matplotlib.pyplot as plt
import cv2
import pandas as pd

def test_predict():
    config = read_config()        
    model = read_model(config["model_path"], config) 
    image = predict_image(image_path="/Users/ben/Downloads/gettyimages-908-47-640x640.jpg",model=model,return_plot=True)
    
    plt.imshow(image[:,:,::-1])
    plt.show()

#test_predict()
raw_image = cv2.imread("/Users/ben/Downloads/gettyimages-908-47-640x640.jpg")
print("raw image shape".format(raw_image.shape))
csv_path = prediction_wrapper(image_path="/Users/ben/Downloads/gettyimages-908-47-640x640.jpg")
boxes = pd.read_csv(csv_path)
print(boxes)