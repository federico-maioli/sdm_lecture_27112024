# Load and Install Required Libraries -------------------------------------

# Define required packages
required_packages <- c("tidyverse", 'terra')

# Install any missing packages and load them
installed <- required_packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
lapply(required_packages, library, character.only = TRUE)

library(terra)

# load fish data

fish = read_csv('data/fish/fish.csv')

# Load Depth Raster and Extract Values at Grid Points ------------------------------

depth_raster <- terra::rast('data/environment/depth/depth.nc')

# Extract and assign depth values to prediction grid
fish$depth <- abs(terra::extract(depth_raster, fish %>% select(longitude, latitude))$bathymetry_mean)

# Load Present-Day Bottom Temperature Raster and Extract Values --------------------

temp_now_raster <- terra::rast('data/environment/bottom_temperature/present/thetao_baseline_2000_2019_depthmean.nc')[[2]] # Plot present-day temperature raster

# Extract and assign present-day bottom temperature to grid points
fish$bottom_temp <- terra::extract(temp_now_raster, fish %>% select(longitude, latitude))$thetao_mean_2

write_csv(fish,'data/model_input/data.csv')

