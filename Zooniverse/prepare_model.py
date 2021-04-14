### Train a deepforest model from existing classifications
#conda activate Zooniverse

import os
import pandas as pd
from shutil import copyfile
from parse_annotations import run

def get_plotID(x):
    """Get a plotID from filename"""
    basename = os.path.basename(x)
    plotID = "_".join(basename.split("_")[0:2])
    
    return plotID

def get_image_name(x):
    basename = os.path.basename(x)
    image_name = "_".join(basename.split("_")[0:3])
    
    return image_name
    
def copy_image(image_path, basename):
    copyfile("/orange/idtrees-collab/NeonTreeEvaluation/evaluation/RGB/{}.tif".format(image_path), "/orange/ewhite/b.weinstein/NeonTreeEvaluation/hand_annotations/{}.tif".format(basename))
    
## Download shapefiles to directory
files_created = run(download=True, generate=False, savedir="/orange/ewhite/b.weinstein/NeonTreeEvaluation/hand_annotations/")

## Copy images to crops
for x in files_created:
    #check if its in train
    plotID = get_plotID(x)
    benchmark = pd.read_csv("/orange/idtrees-collab/NeonTreeEvaluation/evaluation/RGB/benchmark_annotations.csv")
    
    benchmark["plotID"] = benchmark.image_path.apply(lambda x: "_".join(x.split("_")[0:2]))
    in_test = plotID in benchmark["plotID"].values
    
    if in_test:
        os.remove(x)
    else:
        image_path = get_image_name(x)
        basename = os.path.splitext(os.path.basename(x))[0]
        copy_image(image_path, basename)
