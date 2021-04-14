### After running parse_annotations, collect the shapefiles and create a train/ test dataset
#Species dataset

import geopandas as gpd
import pandas as pd
import glob
import numpy as np
from distributed import as_completed
import start_cluster

def load_shapefiles(input_dir, field_data="data/neon_vst_data_2021.csv"):
    fils = glob.glob("{}/*.shp".format(input_dir))
    field_df = pd.read_csv(field_data)
    
    results = []
    for x in fils:
        gdf = gpd.read_file(x)
        gdf = gdf[["xmin","ymin","xmax","ymax","siteID","plotID","individual"]]
        gdf = gdf.rename(columns={"individual":"individualID"})
        
        #lookup individualID
        gdf["label"] = gdf.individualID.apply(lambda x: field_df[field_df.individualID==x].taxonID.unique()[0] if x is not None else x)
        results.append(gdf)
    
    results = pd.concat(results)
    results = results[~results.label.isnull()]
    
    return results  

def sample_plots(shp):
    #split by plot level
    test_plots = shp.plotID.drop_duplicates().sample(frac=0.10)
    
    test = shp[shp.plotID.isin(test_plots)]
    train = shp[~shp.plotID.isin(test_plots)]
    
    test = test.groupby("taxonID").filter(lambda x: x.shape[0] > 5)
    
    train = train[train.taxonID.isin(test.taxonID)]
    test = test[test.taxonID.isin(train.taxonID)]
    
def split_train_test(annotations, client, debug=False):
    """Split shapefile into balanced train and test"""
    
    most_species = 0
    if debug:
        iterations = 1
    else:
        iterations = 500
    
    if client:
        futures = [ ]
        for x in np.arange(iterations):
            future = client.submit(sample_plots, shp=annotations)
            futures.append(future)
        
        for x in as_completed(futures):
            train, test = x.result()
            if len(train.taxonID.unique()) > most_species:
                print(len(train.taxonID.unique()))
                saved_train = train
                saved_test = test
                most_species = len(test.taxonID.unique())            
    else:
        for x in np.arange(iterations):
            train, test = sample_plots(shp=annotations)
            if len(train.taxonID.unique()) > most_species:
                print(len(test.taxonID.unique()))
                saved_train = train
                saved_test = test
                most_species = len(test.taxonID.unique())
    
    train = saved_train
    test = saved_test     
    
    print("There are {} records for {} species for {} sites in filtered train".format(
        train.shape[0],
        len(train.taxonID.unique()),
        len(train.siteID.unique())
    ))
    
    print("There are {} records for {} species for {} sites in test".format(
        test.shape[0],
        len(test.taxonID.unique()),
        len(test.siteID.unique())
    ))
    
    return train, test


def run(input_dir, client, save_dir):
    df = load_shapefiles(input_dir)
    train, test = split_train_test(df, client)
    train.to_csv("{}/train.csv".format(save_dir))
    test.to_csv("{}/test.csv".format(save_dir))
    

if __name__ == "__main__":
    client = start_cluster.start(cpus=20)
    run(input_dir="/orange/idtrees-collab/DeepTreeAttention/data/", savedir="/orange/idtrees-collab/DeepTreeAttention/data/", client=client)
    

    
