''''
Bounding box post-processing
After neural network predicts a rectangular box, overlay it on the point cloud and assign points for instance based detections
Create a polygon from final tree to use for evaluation
'''
import os
import pyfor
import numpy as np
import geopandas as gp
from shapely import geometry
import pyfor
import xmltodict
import rasterio
import pandas as pd

#Load .laz
def load_lidar(laz_path):
    pc = pyfor.cloud.Cloud(laz_path)
    pc.extension = ".las"
    return pc

def drape_boxes(boxes, pc, bounds=[]):
    '''
    boxes: predictions from retinanet
    pc: Optional point cloud from memory, on the fly generation
    bounds: optional utm bounds to restrict utm box
    '''
    
    #reset user_data column
    pc.data.points.user_data =  np.nan
        
    tree_counter = 1
    for box in boxes:

        #Find utm coordinates
        xmin, xmax, ymin, ymax = find_utm_coords(box = box, pc = pc, bounds=bounds)
        
        #Update points
        pc.data.points.loc[(pc.data.points.x > xmin) & (pc.data.points.x < xmax)  & (pc.data.points.y > ymin)   & (pc.data.points.y < ymax),"user_data"] = tree_counter
        
        #update counter
        tree_counter +=1 
        
    #remove ground points    
    #pc.data.points.loc[pc.data.points.z < 2, "user_data"] = np.nan
    
    return pc    
    
def find_utm_coords(box, pc, rgb_res = 0.1, bounds = []):
    
    """
    Turn cartesian coordinates back to projected utm
    bounds: an optional offset for finding the position of a window within the data
    """
    xmin = box[0]
    ymin = box[1]
    xmax = box[2]
    ymax = box[3]
    
    #add offset if needed
    if len(bounds) > 0:
        tile_xmin, _ , _ , tile_ymax = bounds   
    else:
        tile_xmin = pc.data.points.x.min()
        tile_ymax = pc.data.points.y.max()
        
    window_utm_xmin = xmin * rgb_res + tile_xmin
    window_utm_xmax = xmax * rgb_res + tile_xmin
    window_utm_ymin = tile_ymax - (ymax * rgb_res)
    window_utm_ymax= tile_ymax - (ymin* rgb_res)     
        
    return(window_utm_xmin, window_utm_xmax, window_utm_ymin, window_utm_ymax)
