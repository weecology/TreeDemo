#Zooniverse upload module
import glob
import os
import pandas as pd
from panoptes_client import Panoptes, Project, SubjectSet, Subject
import rasterio
from PIL import Image
import numpy as np
from datetime import datetime

def connect():
    #TODO hash this password.    
    Panoptes.connect(username='bw4sz', password='D!2utNBno8;b')
    tree_detection = Project.find(14950)
    return tree_detection

def find_plots(RGB_dir, save_dir):
    """Search and filter images"""
    field_data = pd.read_csv("../data/filtered_data.csv")
    unique_plots = field_data.plotID.unique()
    
    image_paths = glob.glob(os.path.join(RGB_dir, "*.tif"))
    selected_plots = [x for x in image_paths if "_".join(os.path.splitext(os.path.basename(x))[0].split("_")[:-1]) in unique_plots]
    
    #Prioritize plots not already annotated
    already_annotated = glob.glob("../data/annotations/*.xml")
    already_annotated =  [os.path.splitext(os.path.basename(x))[0] for x in already_annotated]
    to_be_annotated = [x for x in selected_plots if not os.path.splitext(os.path.basename(x))[0] in already_annotated]
    
    #not part of demo training upload
    demo_upload = ["TEAK_045_2019","KONZ_024_2020","UKFS_004_2020","STEI_004_2020","ABBY_070_2019","HARV_002_2019","HARV_005_2019","WREF_080_2018","BART_006_2019"]
    to_be_annotated = [x for x in to_be_annotated if not os.path.splitext(os.path.basename(x))[0] in demo_upload]
    
    #index = np.random.choice(len(to_be_annotated),10)
    #to_be_annotated = np.array(to_be_annotated)[index]
    
    # remove 
    images = {}
    counter = 1

    for i in to_be_annotated:
        #Load and get metadata
        d = rasterio.open(i)
        numpy_image = d.read()
        left, bottom, right, top = d.bounds

        #Write as a png
        basename = os.path.splitext(i)[0]
        png_name = "{}.png".format(basename)
        img = Image.open(i)
        img.save(png_name)
        
        plotID = os.path.splitext(os.path.basename(i))[0]

        #Create dict
        images[png_name] = {"subject_reference":counter, "bounds":[left,bottom,right,top],"crs":d.crs.to_epsg(),"plotID":plotID,"filename":png_name}
        counter +=1

    return images

#Create manifests
def create_subject_set(zooniverse_project, name="demo"):
    subject_set = SubjectSet()
    subject_set.links.project = zooniverse_project
    subject_set.display_name = name
    subject_set.save()

    return subject_set

def upload(subject_set, images, zooniverse_project):
    """Assign images to project"""
    new_subjects = []

    print("Uploading {} images".format(len(images)))
    for filename, metadata in images.items():
        subject = Subject()

        subject.links.project = zooniverse_project
        subject.add_location(filename)

        subject.metadata.update(metadata)

        #Trigger upload
        subject.save()
        new_subjects.append(subject)
    subject_set.add(new_subjects)


def main(zooniverse_project, RGB_dir, save_dir):
    """Args:
        path: a .tif to run
    """

    #Generate metadata
    images = find_plots(RGB_dir,save_dir)

    #Create a new subject set
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")    
    subject_set = create_subject_set(name=timestamp, zooniverse_project=zooniverse_project)
        
    #Upload
    upload(subject_set, images, zooniverse_project)

if __name__ == "__main__":

    #auth
    zooniverse_project = connect()
    
    main(zooniverse_project, RGB_dir="/Users/benweinstein/Documents/NeonTreeEvaluation/evaluation/RGB/", save_dir="temp/")
