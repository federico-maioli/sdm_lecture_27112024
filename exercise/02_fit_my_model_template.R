# load the libraries or install them ---------------------------------------

packages <- c("tidyverse", "rnaturalearth", "rnaturalearthdata", "sf", "ggeffects", "patchwork")

install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
  library(pkg, character.only = TRUE)
}

# remember to open the .Rproj file to avoid directory issues

# apply the function to load or install packages
lapply(packages, install_if_missing)

# read the data in  -------------------------------------------------------

# load the input data
data <- read_csv('./data/model_input/data.csv') 

# log transform biomass
data$log_density <- log(data$kg_km2 + 1) 

# load the grid
grid <- read_csv('./data/model_input/grid.csv')

# extract coastline data for plotting later
map_data <- rnaturalearth::ne_countries(scale = "large",
                                        returnclass = "sf",
                                        continent = "europe")

# crop the map to the north sea area
north_sea <- suppressWarnings(suppressMessages(st_crop(
  map_data, c(
    xmin = -7,
    ymin = 49,
    xmax = 13,
    ymax = 63
  )
)))

# explore species list
species <- unique(data$species)
species

# select your species
my_species <- '' # choose your species

# filter data for the selected species
my_data <- data |> filter(species == my_species)

# map the raw presence-absence data
ggplot(data = my_data, aes(longitude, latitude, color = as.factor(present))) + 
  geom_point(size = 0.5) + 
  geom_sf(data = north_sea, inherit.aes = FALSE) + 
  theme_light() + 
  xlim(-6, 12) + 
  ylim(50, 62) +
  ylab('Latitude') + 
  xlab('Longitude') + 
  scale_color_manual(
    name = my_species,
    values = c("0" = "red", "1" = "blue"),
    labels = c("0" = "Absent", "1" = "Present")
  )

# map the biomass (log density) data
ggplot(data = my_data, aes(longitude, latitude, color = log_density)) + 
  geom_point(size = 0.5) + 
  geom_sf(data = north_sea, inherit.aes = FALSE) + 
  theme_light() + 
  xlim(-6, 12) + 
  ylim(50, 62) +
  ylab('Latitude') + 
  xlab('Longitude') + 
  scale_color_viridis_c(paste0(my_species, ' log(density)'))

# presence-absence or biomass? your choice!

# model examples:
# my_SDM_biomass <- lm(log_density ~ 1 + bottom_temp, data = my_data)
# my_SDM_presence <- glm(present ~ 1 + bottom_temp, data = my_data, family = binomial(link = "logit"))

# remember these functions:
# ggeffects::predict_response() for partial effects
# plot(partial_effect, ci_style = "dash") to visualize the effects
# summary() for coefficient estimates
# what is the interpretation of the slope?

# predict on current conditions, e.g.:
# grid$log_density_now <- predict(my_SDM, grid |> mutate(bottom_temp = bottom_temp_now))
# for presence-absence models, use type = 'response' in predict()

# predict on future conditions:
# grid$log_density_future <- predict(my_SDM, grid |> mutate(bottom_temp = bottom_temp_2100_ssp585))
# remember you also have bottom_temp_2100_ssp119

# have fun exploring the plots and making cool visualizations! :)