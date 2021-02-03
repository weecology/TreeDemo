#Zooniverse upload module
import glob
import os
import pandas as pd
from panoptes_client import Panoptes, Project, SubjectSet, Subject
import rasterio
from PIL import Image
import numpy as np


def find_files(path):
    """Search and filter images"""
    field_data = pd.read_csv("../data/neon_vst_data_2021.csv")
    images = {}
    image_paths = glob.glob(os.path.join(path, "*.tif"))
    counter = 1

    #extract site name
    site_name = os.path.basename(path)

    for i in image_paths:
        #Load and get metadata
        d = rasterio.open(i)
        numpy_image = d.read()
        left, bottom, right, top = d.bounds

        #Check if image is all white
        #white_flag = is_white(i)

        #if white_flag:
        #    continue

        #Write as a png
        basename = os.path.splitext(i)[0]
        png_name = "{}.png".format(basename)
        img = Image.open(i)
        img.save(png_name)

        #Create dict
        images[png_name] = {"subject_reference":counter, "bounds":[left,bottom,right,top],"crs":d.crs.to_epsg(),"site":site_name,"resolution":d.res,"filename":png_name}
        counter +=1

    return images

#Create manifests
def create_subject_set(everglades_watch, name="demo"):
    subject_set = SubjectSet()
    subject_set.links.project = everglades_watch
    subject_set.display_name = name
    subject_set.save()

    return subject_set

def upload(subject_set, images, everglades_watch):
    """Assign images to projecti"""
    new_subjects = []

    print("Uploading {} images".format(len(images)))
    for filename, metadata in images.items():
        subject = Subject()

        subject.links.project = everglades_watch
        subject.add_location(filename)

        subject.metadata.update(metadata)

        #Trigger upload
        subject.save()
        new_subjects.append(subject)
    subject_set.add(new_subjects)


def main(path, zooniverse_project):
    """Args:
        path: a .tif to run
    """
    #Create new directory in save_dir
    basename = os.path.splitext(os.path.basename(path))[0]
    dirname = "{}/{}".format(save_dir,basename)

    try:
        os.mkdir(dirname)
    except:
        pass
        #raise ValueError("dirname: {} exists)".format(dirname))

    #Generate metadata
    images = find_files(saved_file)

    #Screen for blanks
    if model:
        screened_images = screen_blanks(images, model)
        print("{} images ready for upload".format(len(screened_images)))
    else:
        screened_images = images

    #Create a new subject set
    subject_set = create_subject_set(name=basename, everglades_watch=everglades_watch)
        
    #Upload
    upload(subject_set, screened_images, everglades_watch)

    return saved_file

if __name__ == "__main__":

    #auth
    everglades_watch = utils.connect()

    #set model
    model = "/orange/ewhite/everglades/Zooniverse/predictions/20201110_161912.h5"

    #Currently debugging with just one site
    paths = ["/orange/ewhite/everglades/WadingBirds2020/6thBridge/6thBridge_03_25_2020.tif"]

    for path in paths:
        print(path)
        saved_file = main(path, everglades_watch, model)

        ##Which files have already been run
        #uploaded = pd.read_csv("uploaded.csv")

        ##Compare names of completed tiles
        #uploaded["basename"] = uploaded.path.apply(lambda x: os.path.basename(x))

        ##Files to process
        #file_pool = glob.glob("/orange/ewhite/everglades/WadingBirds2020/**/*.tif",recursive=True)
        #file_pool_basenames = [os.path.basename(x) for x in file_pool]
        #paths = [file_pool[index] for index, x in enumerate(file_pool_basenames) if not x in uploaded.basename.values]

        #print("Running files:{}".format(paths))
        #for path in paths:
            ##Run .tif
            #try:
                #saved_file = main(path, everglades_watch, model)
                ##Confirm it exists and write to the csv file
                #assert os.path.exists(saved_file)
                #uploaded["path"] = uploaded.path.append(pd.Series({"path":saved_file}),ignore_index=True)
            #except Exception as e:
                #print("{} failed with exception {}".format(path, e))

        #Overwrite uploaded manifest
        #uploaded.to_csv("uploaded.csv",index=False)
