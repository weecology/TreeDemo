# Tree Classification Demo

A Shiny app deployed on Microsoft Azure to demonstrate the current DeepForest model.

See our python package: https://deepforest.readthedocs.io/


## Parse Zooniverse Annotations

Zooniverse/ folder contains utilities for downloading annotations. They should be run in the following order

1. parse_annotations downloads each annotation and saves a .shp
2. prepare_model copies the data to a single directory.
3. create_dead_dataset.py creates a train test split for dead/alive trees

## Citation

Weinstein, B. G., Marconi, S., Bohlman, S. A., Zare, A., & White, E. P. (2020). Cross-site learning in deep learning RGB tree crown detection. Ecological Informatics, 101061.

For install of this repo see install.sh
