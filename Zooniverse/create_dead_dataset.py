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


def run(input_dir, save_dir, iterations=1, client=None):
    df = load_shapefiles(input_dir)
    
    df["image_path"] = df.image_name.apply(lambda x: "{}.tif".format(x))
    test_plots = df.plotID.drop_duplicates().sample(frac=0.10)
    
    test = df[df.plotID.isin(test_plots)]
    train = df[~df.plotID.isin(test_plots)]
        
    train = train[train.label.isin(test.label)]
    test = test[test.label.isin(train.label)]
    
    #reduce imbalance in dataset
    train_dead_labels = train[train.label=="Dead"]
    train_alive_labels = train[train.label=="Alive"]
    
    #Just from the same images
    #train_alive_labels[train_alive_labels.image_name.isin(train_dead_labels.image_name)]
    
    balanced_train = pd.concat([train_dead_labels, train_alive_labels.sample(n=train_dead_labels.shape[0]*2)])

    test.to_csv("{}/dead_test.csv".format(save_dir))
    balanced_train.to_csv("{}/dead_train.csv".format(save_dir))
    
    return test

if __name__ == "__main__":
    #client = start_cluster.start(cpus=20)
    run(input_dir="/orange/idtrees-collab/DeepTreeAttention/data", save_dir="/orange/idtrees-collab/DeepTreeAttention/data", client=None)
    #run(save_dir="/Users/benweinstein/Dropbox/Weecology/TreeDetectionZooniverse/", input_dir="/Users/benweinstein/Dropbox/Weecology/TreeDetectionZooniverse/")

