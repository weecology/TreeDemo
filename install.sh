#install shiny script
sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install nginx
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev

#git
sudo apt-get install git

#gdal
sudo apt install -y libudunits2-0 libudunits2-dev
sudo apt install -y libgdal-dev
sudo apt-get install -y libtiff5-dev
sudo apt-get install libxt-dev


sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev
sudo su - -c "R -e \"install.packages(c('tidyverse','lidR','raster','stringr'))\""
#nice to break them up to see errors a bit better
sudo su - -c "R -e \"install.packages(c('shiny'))\""
sudo su - -c "R -e \"install.packages(c('leaflet'))\""
sudo su - -c "R -e \"install.packages(c('raster'))\""
sudo su - -c "R -e \"install.packages(c('sf'))\""
sudo su - -c "R -e \"install.packages(c('shinythemes'))\""

#rgl
sudo apt-get install -y xorg libx11-dev libglu1-mesa-dev libatlas-base-dev gfortran libblas-dev  libblas-dev liblapack-dev python-autopep8
sudo apt install -y libftgl2 libcgal-dev libglu1-mesa-dev libglu1-mesa-dev libx11-dev libfreetype6-dev
sudo apt-get install -y libcgal-dev libglu1-mesa-dev libglu1-mesa-dev

sudo su - -c "R -e \"install.packages(c('digest','xtable','rgl'))\""

#lidR dependency
sudo su - -c "R -e \"install.packages(c('Cairo'))\""
sudo su - -c "R -e \"install.packages(c('imager'))\""

sudo apt-get install -y libgdal-dev libgeos++-dev libudunits2-dev libproj-dev libx11-dev libgl-dev libglu-dev libfreetype6-dev libv8-3.14-dev libcairo2-dev
sudo su - -c "R -e \"install.packages(c('lidR'))\""

sudo su - -c "R -e \"install.packages(c('reticulate'))\""

sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
sudo gdebi shiny-server-1.5.9.923-amd64.deb

#Instructions
#nano into nginx and set locations
#location /shiny/ {
#  proxy_pass http://127.0.0.1:3838/;
#}

#location /rstudio/ {
#  proxy_pass http://127.0.0.1:8787/;
#}

#Python install
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p ~/miniconda

#download TreeDemo data
cd ~/TreeDemo

#install conda env
#reset thumbnails see preprocces.R


#nice to know restart sudo systemctl restart shiny-server
