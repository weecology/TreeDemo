#Parse annotatons from Zooniverse to create a pandas dataframe suitable for further analysis
import pandas as pd
import geopandas as gpd
from panoptes_client import Panoptes
from shapely.geometry import box, Point
import json
import numpy as np
import os

#Utils
from panoptes_client import Panoptes, Project

def connect():
    Panoptes.connect(username='bw4sz', password='D!2utNBno8;b')
    project = Project.find(14950)
    return project

def download_data(zooniverse_project, min_version, generate=False):
    #see https://panoptes-python-client.readthedocs.io/en/v1.1/panoptes_client.html#module-panoptes_client.classification
    classification_export = zooniverse_project.get_export('classifications', generate=generate)
    rows = []
    for row in classification_export.csv_dictreader():
        rows.append(row)    
    
    df = pd.DataFrame(rows)
    df["workflow_version"] = df.workflow_version.astype(float)
    df  = df[df.workflow_version > min_version]  
    
    return df

def download_subject_data(zooniverse_project, savedir, generate=False):
    #see https://panoptes-python-client.readthedocs.io/en/v1.1/panoptes_client.html#module-panoptes_client.classification
    classification_export = zooniverse_project.get_export('subjects', generate=generate)
    rows = []
    for row in classification_export.csv_dictreader():
        rows.append(row)    
    
    df = pd.DataFrame(rows)    
    fname = "{}/TreeCrownDetection.csv".format(savedir)
    
    #Overwrite subject set
    df.to_csv(fname)
    
    return df

def load_classifications(classifications_file, min_version= 30.36):
    """Load classifications from Zooniverse
    classifications_file: path to .csv
    """
    df = pd.read_csv(classifications_file)
    df  = df[df.workflow_version > min_version]  
    return df
    
def parse_additional_response(x):
    annotation_dict = json.loads(x)[0]
    response = annotation_dict["value"]
    return response

def parse_crowns(x):
    x_coord = x["x"]
    if x_coord < 0:
        x_coord = 0
    
    y_coord = x["y"]
    
    if y_coord < 0:
        y_coord = 0
    
    annotations = pd.DataFrame({"xmin":[x_coord], "xmax":[x_coord + x["width"]],"ymin":[y_coord],"ymax":[y_coord + x["height"]]})
    
    #If any annotations are slightly off screen, round
    return annotations

def parse_field_points(x):
    annotations = pd.DataFrame({"x":[x["x"]], "y":[x["y"]], "individualID":[x["details"][0]["value"]]})
    return annotations

def parse_dead_points(x):
    annotations = pd.DataFrame({"x":[x["x"]], "y":[x["y"]]})
    
    return annotations

def parse_data(x):
    """Parse crown location task"""
    #Extract and parse json
    annotation_dict = json.loads(x)[0]
    
    boxes = annotation_dict["value"]
    
    if len(boxes) == 0:
        return None
    
    #For each frame get the crown location
    crowns_list = []
    field_points_list = []
    dead_trees_list = []
    for x in boxes:
        if x["tool"] == 0:
            crowns = parse_crowns(x)
            if crowns["xmin"].values[0] < 0:
                raise ValueError("invalid box")
            crowns["geometry"] = crowns.apply(lambda x: box(x["xmin"], x["ymin"], x["xmax"], x["ymax"]),axis=1)
            crowns = (crowns)            
            crowns_list.append(crowns)        
        if x["tool"] == 1:
            field_points = parse_field_points(x)
            field_points["geometry"] = field_points.apply(lambda x: Point(x["x"], x["y"]),axis=1)
            field_points_list.append(field_points)
        if x["tool"] == 2:
            dead_trees = parse_dead_points(x)
            dead_trees["geometry"] = dead_trees.apply(lambda x: Point(x["x"], x["y"]),axis=1)            
            dead_trees_list.append(dead_trees)            

    #merge if there are any additional points
    crowns_df = gpd.GeoDataFrame(pd.concat(crowns_list))
     
    if len(field_points_list) > 0:  
        field_points_df = gpd.GeoDataFrame(pd.concat(field_points_list))
        crowns_df = gpd.sjoin(crowns_df,field_points_df,how="left")
        crowns_df = crowns_df.drop(columns=["index_right","x","y"])

    if len(dead_trees_list) > 0:
        dead_trees_df = gpd.GeoDataFrame(pd.concat(dead_trees_list))
        dead_trees_df["Dead"] = True    
        crowns_df = gpd.sjoin(crowns_df,dead_trees_df,how="left")
        
        crowns_df = crowns_df.drop(columns=["index_right","x","y"])
        crowns_df["Dead"] = crowns_df.Dead.fillna(False)   
    
    #spatial join
    return crowns_df

     
def parse_subject_data(x):
    """Parse image metadata"""
    annotation_dict = json.loads(x)
    assert len(annotation_dict.keys()) == 1
    
    for key in annotation_dict:
        data = annotation_dict[key]  
        try:
            image_name = os.path.splitext(os.path.basename(data["filename"]))[0]
        except:
            image_name = os.path.splitext(os.path.basename(data["Filename"]))[0]
        siteID = image_name.split("_")[0]
        plotID = "_".join(image_name.split("_")[0:2])         
        event = int(image_name.split("_")[2])
        try:
            utm_left, utm_bottom, utm_right, utm_top = data["bounds"]
        except:
            return None
        resolution = 0.1
        crs = data["crs"]
        
        bounds = pd.DataFrame({"subject_ids":[key], "image_name":image_name, "siteID":[siteID],"plotID":plotID,"year":event,
                               "image_utm_left": [utm_left], "image_utm_bottom":[utm_bottom],"image_utm_right":[utm_right],"image_utm_top":[utm_top],"resolution":resolution,"crs":crs})
    
    return bounds

def parse_trees(df):
    #remove empty annotations
    results = [ ]
    for index, row in df.iterrows(): 
        #Extract annotations for each image
        crowns = parse_data(row.annotations)
        
        if crowns is None:
            continue

        #Extract subject data
        metadata = parse_subject_data(row.subject_data)
        
        if metadata is None:
            continue
                
        #Assign metadata columns
        crowns["classification_id"] = row["classification_id"]
        crowns["user_name"] = row["user_name"]
        crowns["created_at"] = row["created_at"]
        
        for col_name in metadata:
            crowns[col_name] = metadata[col_name].values[0]
        results.append(crowns)
    
    results = gpd.GeoDataFrame(pd.concat(results))
    
    return results

def project_box(df):
    """Convert boxes into utm coordinates for a single utm"""
    df["box_utm_left"] = df.image_utm_left + (df.resolution * df.xmin)
    df["box_utm_bottom"] = df.image_utm_top - (df.resolution * df.ymin)
    df["box_utm_right"] = df.image_utm_left + (df.resolution * df.xmax)
    df["box_utm_top"] = df.image_utm_top - (df.resolution * df.ymax)
    
    #Create geopandas
    geoms = [box(left, bottom, right, top) for left, bottom, right, top in zip(df.box_utm_left, df.box_utm_bottom, df.box_utm_right, df.box_utm_top)]
    gdf = gpd.GeoDataFrame(df, geometry=geoms)
    
    #set CRS
    if len(df["crs"].unique())>1:
        raise ValueError("More than one crs in the dataframe {}".format(df.crs.unique()))
    
    gdf.crs = "epsg:{}".format(df["crs"].unique()[0])
    
    return gdf
    

def run(classifications_file=None, savedir=".", download=False, generate=False,min_version=30.36, debug=False):
    
    #Authenticate
    if download:
        zooniverse_project = connect()    
        df = download_data(zooniverse_project, min_version, generate=generate)
        
        #add subject data to dir
        download_subject_data(zooniverse_project, savedir=savedir)

    else:
        #Read file from zooniverse download
        df = load_classifications(classifications_file, min_version=min_version)        
    
    #if debug for testing, just sample 5 rows    
    if debug:
        df = df[df.subject_ids.isin(df.subject_ids[0:4])]        
    
    #Parse JSON and filter
    df = parse_trees(df)
    
    #Write parsed data
    df.to_csv("{}/{}.csv".format(savedir, "parsed_annotations"),index=True)
    
    files_created = []
    for name, group in df.groupby("classification_id"):
        print()
        projected_box = project_box(group)
        fname = "{}/{}_{}.shp".format(savedir,projected_box.image_name.unique()[0],name)
        print(fname)
        projected_box.to_file(fname)
        files_created.append(fname)
    
    return files_created

if __name__ == "__main__":
    #Download from Zooniverse and parse
    run(min_version=30.36, debug=False, generate=False, download=True, savedir="/orange/idtrees-collab/DeepTreeAttention/data")
