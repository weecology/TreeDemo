#Zooniverse upload module
import glob
import os
import pandas as pd
from panoptes_client import Panoptes, Project, SubjectSet, Subject
import rasterio
from PIL import Image
import numpy as np
from datetime import datetime

def preprocess_field_data():
    field = pd.read_csv("../data/raw/neon_vst_data_2021.csv")
    field = field[~field.elevation.isnull()]
    field = field[~field.growthForm.isin(["liana","small shrub"])]
    field = field[~field.growthForm.isnull()]
    field = field[~field.plantStatus.isnull()]        
    field = field[field.plantStatus.str.contains("Live")]    
    field = field[~(field.canopyPosition.isin(["Full shade", "Mostly shaded"]))]
    field = field[(field.height > 3) | (field.height.isnull())]
    field = field[field.stemDiameter > 10]
    field = field[~field.taxonID.isin(["BETUL", "FRAXI", "HALES", "PICEA", "PINUS", "QUERC", "ULMUS", "2PLANT"])]
    field = field[~(field.eventID.str.contains("2014"))]
    with_heights = field[~field.height.isnull()]
    with_heights = with_heights.loc[with_heights.groupby('individualID')['height'].idxmax()]
    
    missing_heights = field[field.height.isnull()]
    missing_heights = missing_heights[~missing_heights.individualID.isin(with_heights.individualID)]
    missing_heights = missing_heights.groupby("individualID").apply(lambda x: x.sort_values(["eventID"],ascending=False).head(1)).reset_index(drop=True)
  
    field = pd.concat([with_heights,missing_heights])
    
    return field


def find_plots(image_dir, RGB_dir):
    """Search and filter images"""
    field_data = preprocess_field_data()
    unique_plots = field_data.plotID.unique()
    
    image_paths = glob.glob(os.path.join(RGB_dir, "*.tif"))
    selected_plots = [x for x in image_paths if os.path.splitext(os.path.basename(x))[0] in unique_plots]
    
    images = {}
    counter = 1

    for i in image_paths:
        #Load and get metadata
        d = rasterio.open(i)
        numpy_image = d.read()
        left, bottom, right, top = d.bounds

        #Write as a png
        basename = os.path.splitext(i)[0]
        png_name = "{}.png".format(basename)
        img = Image.open(i)
        img.save(png_name)

        #Create dict
        images[png_name] = {"subject_reference":counter, "bounds":[left,bottom,right,top],"crs":d.crs.to_epsg(),"site":site_name,"plotID",:plotID, "eventID":eventID,"filename":png_name}
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
    """Assign images to projecti"""
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
    #Create new directory in save_dir

    #Generate metadata
    images = find_plots(RGB_dir, saved_file)

    #Create a new subject set
    subject_set = create_subject_set(name=datetime.datetime(), zooniverse_project=zooniverse_project)
        
    #Upload
    upload(subject_set, images, zooniverse_project)

    return saved_file

if __name__ == "__main__":

    #auth
    zooniverse_project = utils.connect()

    #Currently debugging with just one site
    paths = ["/orange/ewhite/everglades/WadingBirds2020/6thBridge/6thBridge_03_25_2020.tif"]

    for path in paths:
        saved_file = main(path, zooniverse_project)