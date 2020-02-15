import glob
import os
import Lidar
import laspy
import pandas as pd
        
def write_label(point_cloud, path):
    
    #Create a dummy laspy object
    inFile = laspy.file.File("test.laz", header=point_cloud.data.header, mode="w")    
    for dim in point_cloud.data.points:
        setattr(inFile, dim, point_cloud.data.points[dim])
    
    #Create second laspy object
    outFile1 = laspy.file.File(path, mode = "w",header = inFile.header)

    #Create label column is it doesn't exist
    try:
        len(inFile.label)
        print("File has {} labels".format(len(inFile.label)))
    except:
        # copy fields if label doesn't exist        
        outFile1.define_new_dimension(
            name="label",
            data_type=5,
            description = "Integer Tree Label"
         )
    
    for dimension in inFile.point_format:
        dat = inFile.reader.get_dimension(dimension.name)
        outFile1.writer.set_dimension(dimension.name, dat)
        
    outFile1.label = point_cloud.data.points.user_data
    outFile1.close()
    
#Training tiles    
def run(csv_path, laz_path):
    """predictions_csv: path to csv holding bbox predictions
    """
    #Load data
    df = pd.read_csv(csv_path,index_col=0)
    point_cloud = Lidar.load_lidar(laz_path)

    #Drape RGB bounding boxes over the point cloud
    point_cloud = Lidar.drape_boxes(df.values, point_cloud)
        
    #Write Laz with label info
    write_label(point_cloud, laz_path)

def drape_wrapper():
    prediction_csvs = glob.glob("data/evaluation/RGB/*.csv")
    LiDAR_dir = "data/evaluation/LiDAR/"
    for f in prediction_csvs:
        print(f)
        
        #Construct filename
        plot_name = os.path.splitext(os.path.basename(f))[0]
        laz_path = os.path.join(LiDAR_dir,plot_name)
        laz_path =  "{}.laz".format(laz_path)
        
        if os.path.exists(laz_path):
            run(csv_path = f, laz_path= laz_path)
        else:
            print("{} does not exist".format(laz_path))

if __name__=="__main__":
    drape_wrapper()
