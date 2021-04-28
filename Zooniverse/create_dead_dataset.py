### After running parse_annotations, collect the shapefiles and create a train/ test dataset
#Species dataset

import geopandas as gpd
import pandas as pd
import glob
import start_cluster

def load_shapefiles(input_dir, field_data="data/neon_vst_data_2021.csv"):
    fils = glob.glob("{}/*.shp".format(input_dir))
    
    results = []
    for x in fils:
        gdf = gpd.read_file(x)
        gdf = gdf[["xmin","ymin","xmax","ymax","siteID","plotID","individual","Dead","image_name"]]
        gdf = gdf.rename(columns={"individual":"individualID"})
        
        #Dead is '1', None is '0' or NA
        gdf["Dead"] = gdf.Dead.fillna(0)
        gdf["label"] = gdf.Dead.apply(lambda x: "Dead" if x == '1' else "Alive")
        results.append(gdf)
    
    results = pd.concat(results)
    results = results[~results.label.isnull()]
    
    return results  



def validation_split(input_dir, save_dir, client=None, regenerate=False):
    df = load_shapefiles(input_dir)
    train = pd.read_csv("{}/train.csv")
    test = pd.read_csv("{}/test.csv")
    
    df.image
    
def run(input_dir, save_dir, client=None, regenerate=False):
    df = load_shapefiles(input_dir)
    df["image_path"] = df.image_name.apply(lambda x: "{}.tif".format(x))    
    
    if regenerate:
        test_plots = df.plotID.drop_duplicates().sample(frac=0.20, seed=1)
        validation_plots = test_plots.plotID.drop_duplicates().sample(frac=0.5, seed=1)
        
        test = df[df.plotID.isin(test_plots)]
        train = df[~df.plotID.isin(test_plots)]
        validation = df[df.plotID.isin(validation_plots)]
        
    else:
        test = pd.read_csv("{}/dead_test.csv".format(save_dir))
        train = pd.read_csv("{}/dead_train.csv".format(save_dir))
        validation = df[~df.plotID.isin(pd.concat([test,train]).plotID.unique())]

    validation.to_csv("{}/dead_validation.csv".format(save_dir))    
    test.to_csv("{}/dead_test.csv".format(save_dir))
    train.to_csv("{}/dead_train.csv".format(save_dir))
    
    return test

if __name__ == "__main__":
    #client = start_cluster.start(cpus=20)
    #run(input_dir="/orange/idtrees-collab/DeepTreeAttention/data", save_dir="/orange/idtrees-collab/DeepTreeAttention/data", client=None)
    run(save_dir="/Users/benweinstein/Dropbox/Weecology/TreeDetectionZooniverse/",
        input_dir="/Users/benweinstein/Dropbox/Weecology/TreeDetectionZooniverse/",
        regenerate=False)

