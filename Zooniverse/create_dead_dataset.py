### After running parse_annotations, collect the shapefiles and create a train/ test dataset
#Species dataset

import geopandas as gpd
import pandas as pd
import glob
import start_cluster

def load_shapefiles(input_dir, field_data="data/neon_vst_data_2021.csv"):
    fils = glob.glob("{}/*.shp".format(input_dir))
    field_df = pd.read_csv(field_data)
    
    results = []
    for x in fils:
        gdf = gpd.read_file(x)
        gdf = gdf[["xmin","ymin","xmax","ymax","siteID","plotID","individual","Dead","image_name"]]
        gdf = gdf.rename(columns={"individual":"individualID"})
        
        #lookup individualID
        gdf["taxonID"] = gdf.individualID.apply(lambda x: field_df[field_df.individualID==x].taxonID.unique()[0] if x is not None else x)
        gdf["label"] = gdf.Dead
        results.append(gdf)
    
    results = pd.concat(results)
    results = results[~results.label.isnull()]
    
    return results  


def run(input_dir, client, save_dir, iterations=1):
    df = load_shapefiles(input_dir)
    
    df["image_path"] = df.image_name.apply(lambda x: "{}.tif".format(x))
    test_plots = df.plotID.drop_duplicates().sample(frac=0.10)
    
    test = df[df.plotID.isin(test_plots)]
    train = df[~df.plotID.isin(test_plots)]
        
    train = train[train.label.isin(test.label)]
    test = test[test.label.isin(train.label)]
    
    #create image path column
    
    
    test.to_csv("{}/dead_test.csv".format(save_dir))
    train.to_csv("{}/dead_train.csv".format(save_dir))
    
    return test

if __name__ == "__main__":
    #client = start_cluster.start(cpus=20)
    run(input_dir="/orange/idtrees-collab/DeepTreeAttention/data", save_dir="/orange/idtrees-collab/DeepTreeAttention/data", client=None)
    

