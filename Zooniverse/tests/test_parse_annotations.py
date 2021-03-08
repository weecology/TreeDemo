#test parse annotations
import os
import glob
import parse_annotations
import pytest


@pytest.fixture()
def project():
    project = parse_annotations.connect()
    
    return project
    
def test_connect():
    parse_annotations.connect()
    
def test_download_data(project):
    df = parse_annotations.download_data(zooniverse_project=project, min_version=30.36)
    assert not df.empty
    
def test_parse_trees(project):
    df = parse_annotations.download_data(zooniverse_project=project, min_version=30.36)
    results = parse_annotations.parse_trees(df)
    assert all([x in results.columns for x in ["xmin","xmax","ymin","ymax","image_name","plotID","year"]])
    assert not results.empty 
    
    
def test_run(project, tmpdir):
    parse_annotations.run(min_version=30.36, debug=False, download=True, savedir=tmpdir)
    os.path.exists("{}/parsed_annotations.csv".format(tmpdir))
    os.path.exists("{}/TreeCrownDetection.csv".format(tmpdir))
    shps = glob.glob("{}/*.shp".format(tmpdir))
    
    #Debug five images
    assert len(shp) == 5
    