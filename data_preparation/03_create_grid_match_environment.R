# Load and Install Required Packages -----------------------------------------------

# Define required packages
required_packages <- c("tidyverse", "sf", "terra", "patchwork")

# Install any missing packages and load all required packages
installed <- required_packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
lapply(required_packages, library, character.only = TRUE)

# Load Fish Data -------------------------------------------------------------------

# Import fish data from CSV file
fish <- read_csv('data/fish/fish.csv')

# Define a Function to Round Down Coordinates --------------------------------------

# Function to round down coordinates to the nearest specified base (0.05)
round_down_even <- function(x, base = 0.05) {
  base * floor(x / base)
}

# Set the cell width for grid creation
cell_width <- 0.05

# Create Prediction Grid Based on Fish Data Coordinates ----------------------------

# Generate a grid using rounded-down longitude and latitude from the fish data
pred_grid <- expand.grid(
  longitude = seq(round_down_even(min(fish$longitude)), max(fish$longitude), cell_width),
  latitude = seq(round_down_even(min(fish$latitude)), max(fish$latitude), cell_width)
)

# Filter Grid Points Too Far from Observations -------------------------------------

# Exclude points that are too far from actual fish observations
source('script/extra_functions/exclude_too_far.R')
index <- exclude_too_far(pred_grid$longitude, pred_grid$latitude, fish$longitude, fish$latitude, 0.3)
pred_grid <- pred_grid[!index, ]

# Plot the Prediction Grid Points --------------------------------------------------

ggplot(pred_grid, aes(longitude, latitude)) + geom_point()

# Load Coastline Data --------------------------------------------------------------

# Load large-scale coastline data as an `sf` object
coastline <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf")

# Remove Grid Points Located on Land -----------------------------------------------

# Convert prediction grid to spatial format with appropriate coordinate reference system (CRS)
sf_grid <- st_as_sf(pred_grid, coords = c('longitude', 'latitude'), crs = 4326)

# Identify points located on land using spatial intersection with the coastline data
sf_use_s2(FALSE)
on_land <- st_intersects(sf_grid, coastline, sparse = FALSE)
pred_grid <- pred_grid[!apply(on_land, 1, any), ]

# Visualize Prediction Grid with Coastline Overlay ----------------------------------

ggplot(data = coastline) +
  geom_sf() +  
  geom_point(data = pred_grid, aes(x = longitude, y = latitude), inherit.aes = FALSE) +
  xlim(min(pred_grid$longitude), max(pred_grid$longitude)) +
  ylim(min(pred_grid$latitude), max(pred_grid$latitude))

# Load Environmental Covariates ----------------------------------------------------

# Load Depth Raster and Extract Values at Grid Points ------------------------------

depth_raster <- terra::rast('data/environment/depth/depth.nc')
terra::plot(depth_raster)  # Plot depth raster to inspect

# Extract and assign depth values to prediction grid
pred_grid$depth <- abs(terra::extract(depth_raster, pred_grid %>% select(longitude, latitude))$bathymetry_mean)

# Load Present-Day Bottom Temperature Raster and Extract Values --------------------

temp_now_raster <- terra::rast('data/environment/bottom_temperature/present/thetao_baseline_2000_2019_depthmean.nc')[[2]]
terra::plot(temp_now_raster)  # Plot present-day temperature raster

# Extract and assign present-day bottom temperature to grid points
pred_grid$bottom_temp_now <- terra::extract(temp_now_raster, pred_grid %>% select(longitude, latitude))$thetao_mean_2

# Load Future Bottom Temperature Raster SSP 1-1.9 year 2100 and Extract Values -------------------------

temp_future_raster_ssp119 <- terra::rast('data/environment/bottom_temperature/future/thetao_ssp119_2020_2100_depthmean.nc')[[8]]
terra::plot(temp_future_raster_ssp119)  # Plot future temperature raster

# Extract and assign future bottom temperature (SSP5-8.5, 2100) to grid points
pred_grid$bottom_temp_2100_ssp119 <- terra::extract(temp_future_raster_ssp119, pred_grid %>% select(longitude, latitude))$thetao_mean_8

# Load Future Bottom Temperature Raster SSP 5-8.5 year 2100 and Extract Values -------------------------

temp_future_raster_ssp585 <- terra::rast('data/environment/bottom_temperature/future/thetao_ssp585_2020_2100_depthmean.nc')[[8]]
terra::plot(temp_future_raster_ssp585)  # Plot future temperature raster

# Extract and assign future bottom temperature (SSP5-8.5, 2100) to grid points
pred_grid$bottom_temp_2100_ssp585 <- terra::extract(temp_future_raster_ssp585, pred_grid %>% select(longitude, latitude))$thetao_mean_8

# Remove Rows with Missing Values --------------------------------------------------

# Remove rows with any NA values to ensure complete data for analysis
pred_grid <- pred_grid %>% na.omit()

# Compare Present and Future Temperatures on a Map ----------------------------------

# Plot current bottom temperature
p1 <- ggplot(data = coastline) +
  geom_sf() +  
  geom_raster(data = pred_grid %>% mutate(bottom_temp = bottom_temp_now), 
              aes(x = longitude, y = latitude, fill = bottom_temp), inherit.aes = FALSE) +
  xlim(min(pred_grid$longitude), max(pred_grid$longitude)) +
  ylim(min(pred_grid$latitude), max(pred_grid$latitude)) + ggtitle('Now')

# Plot future bottom temperature (SSP1-1.9 scenario)
p2 <- ggplot(data = coastline) +
  geom_sf() +  
  geom_raster(data = pred_grid %>% mutate(bottom_temp = bottom_temp_2100_ssp119), 
              aes(x = longitude, y = latitude, fill = bottom_temp), inherit.aes = FALSE) +
  xlim(min(pred_grid$longitude), max(pred_grid$longitude)) +
  ylim(min(pred_grid$latitude), max(pred_grid$latitude)) + ggtitle('2100 SSP 1-1.9')

# Plot future bottom temperature (SSP5-8.5 scenario)
p3 <- ggplot(data = coastline) +
  geom_sf() +  
  geom_raster(data = pred_grid %>% mutate(bottom_temp = bottom_temp_2100_ssp585), 
              aes(x = longitude, y = latitude, fill = bottom_temp), inherit.aes = FALSE) +
  xlim(min(pred_grid$longitude), max(pred_grid$longitude)) +
  ylim(min(pred_grid$latitude), max(pred_grid$latitude)) + ggtitle('2100 SSP 5-8.5')

# Combine plots
p1 + p2 + p3 + plot_layout(guides = 'collect') & 
  scale_fill_continuous(limits = range(c(pred_grid$bottom_temp_now,pred_grid$bottom_temp_2100_ssp119, pred_grid$bottom_temp_2100_ssp585)), 
                        low = "#FFCCCC", high = "#990000") & 
  theme_minimal() & theme(legend.position="bottom", legend.box = "horizontal")

# Save the grid!
write_csv(pred_grid,'data/model_input/grid.csv')
