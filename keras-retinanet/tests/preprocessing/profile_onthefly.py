#Profiling the on the fly generator
from keras_retinanet.preprocessing import onthefly
import numpy as np
import yaml
import os
import pandas as pd

import cProfile
import pstats
import time
import glob

pr = cProfile.Profile()
pr.enable()

#Helper function for testing
def load_data(data_dir):
    '''
    data_dir: path to .csv files. Optionall can be a path to a specific .csv file.
    nsamples: Number of total samples, "all" will yield full dataset
    '''
    
    if(os.path.splitext(data_dir)[-1]==".csv"):
        data=pd.read_csv(data_dir,index_col=0)
    else:
        #Gather data
        data_paths=glob.glob(data_dir+"/*.csv")
        dataframes = (pd.read_csv(f,index_col=0) for f in data_paths)
        data = pd.concat(dataframes, ignore_index=False)
    
    data=data[data.xmin!=data.xmax]    

    return(data)

with open("/Users/ben/Documents/DeepForest/_config_debug.yml", 'r') as f:
    config = yaml.load(f)    

config["plot_image"]= True
config["shuffle_training"]=True

#Set seed
np.random.seed(2)

#Load data
data=load_data(data_dir="/Users/ben/Documents/DeepForest/" + config['training_csvs'])
    
#Write training and evaluation data to file for annotations
data.to_csv("/Users/ben/Documents/DeepForest/data/training/detection.csv")

training_generator=onthefly.OnTheFlyGenerator(csv_data_file="/Users/ben/Documents/DeepForest/data/training/detection.csv",
                                              group_method="none",shuffle_groups=False,
                                              config=config,base_dir="/Users/ben/Documents/DeepForest/" + config["rgb_tile_dir"],shuffle_tiles=config["shuffle_training"])

for x in np.arange(10):
    start=time.time()
    training_generator.next()
    end=time.time()
    delta=end-start
    print("Time elapsed %f" %(delta))

stats = pstats.Stats(pr)
stats.strip_dirs()
stats.sort_stats('cumulative', 'calls')
stats.print_stats(30)
stats.sort_stats('time', 'calls')
stats.print_stats(10)
    
pr.disable()