# Load and Install Required Libraries -------------------------------------

# Define and install/load required packages
required_packages <- c("tidyverse", "biooracler")
installed <- required_packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
lapply(required_packages, library, character.only = TRUE)

# Uncomment if biooracler needs to be installed from GitHub
# devtools::install_github("bio-oracle/biooracler") # Requires GitHub credentials

# List available layers to view potential datasets
list_layers() 

# Define parameters for depth data ----------------------------------------

# Retrieve metadata for the depth data (terrain characteristics)
info_layer("terrain_characteristics")

dataset_id <- "terrain_characteristics"
constraints <- list(latitude = latitude, longitude = longitude)
variables <- c("bathymetry_mean")

# Download depth data as a raster file
download_layers(dataset_id, variables, constraints, fmt = "raster", 
                directory = 'data/environment/depth')

# Rename downloaded depth data file
old_name <- "data/environment/depth/6c8f1c2f29d2ac7fc6fe9e90cd1b1cdb.nc"
new_name <- "data/environment/depth/depth.nc"
file.rename(old_name, new_name)

# Define parameters for present-day bottom temperature --------------------

# Retrieve metadata for present-day bottom temperature dataset
info_layer("thetao_baseline_2000_2019_depthmean")

# Set dataset ID and constraints (time period, latitude, longitude)
dataset_id <- "thetao_baseline_2000_2019_depthmean"
time <- c('2001-01-01T00:00:00Z', '2010-01-01T00:00:00Z')
latitude <- c(48, 63)
longitude <- c(-4, 13)
constraints <- list(time = time, latitude = latitude, longitude = longitude)
variables <- c("thetao_mean")  # Specify variable to download

# Download present-day bottom temperature as a raster file
download_layers(dataset_id, variables, constraints, fmt = "raster", 
                directory = 'data/environment/bottom_temperature/present')

# Rename downloaded file for clarity
old_name <- "data/environment/bottom_temperature/present/dd35bff1b8c2b59ef7306deb7c108eed.nc"
new_name <- "data/environment/bottom_temperature/present/thetao_baseline_2000_2019_depthmean.nc"
file.rename(old_name, new_name)

# Define parameters for future climate scenarios --------------------------

# Worst-case scenario (SSP5-8.5) -----------------------------------------
info_layer("thetao_ssp585_2020_2100_depthmean")

dataset_id <- "thetao_ssp585_2020_2100_depthmean"
constraints <- list(latitude = latitude, longitude = longitude)
variables <- c("thetao_mean")

# Download future temperature data for SSP5-8.5 scenario
download_layers(dataset_id, variables, constraints, fmt = "raster", 
                directory = 'data/environment/bottom_temperature/future')

# Rename downloaded SSP5-8.5 scenario file
old_name <- "data/environment/bottom_temperature/future/47ebed8006a03bf4a88debb72d51f3ec.nc"
new_name <- "data/environment/bottom_temperature/future/thetao_ssp585_2020_2100_depthmean.nc"
file.rename(old_name, new_name)

# Best-case scenario (SSP1-1.9) ------------------------------------------
info_layer("thetao_ssp119_2020_2100_depthmean")

dataset_id <- "thetao_ssp119_2020_2100_depthmean"
constraints <- list(latitude = latitude, longitude = longitude)
variables <- c("thetao_mean")

# Download future temperature data for SSP1-1.9 scenario
download_layers(dataset_id, variables, constraints, fmt = "raster", 
                directory = 'data/environment/bottom_temperature/future')

# Rename downloaded SSP1-1.9 scenario file
old_name <- "data/environment/bottom_temperature/future/fbb69341ef46cbd3555e29eed3c2f09d.nc"
new_name <- "data/environment/bottom_temperature/future/thetao_ssp119_2020_2100_depthmean.nc"
file.rename(old_name, new_name)
