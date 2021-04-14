#test create dataset
import create_species_dataset

def test_load_shapefile():
    df = create_species_dataset.load_shapefiles("data")
    assert all([x in df.columns for x in ["xmin","ymin","xmax","ymax","label"]])
    
def test_run(tmpdir):
    train, test = create_species_dataset.run(input_dir="data", client=None, save_dir=tmpdir, iterations=3)
    
    assert not train.empty
    assert not test.empty
    assert all([x in train.columns for x in ["xmin","ymin","xmax","ymax","label"]])
    assert all([x in test.columns for x in ["xmin","ymin","xmax","ymax","label"]])
    assert train[train.plotID.isin(test.plotID)].empty