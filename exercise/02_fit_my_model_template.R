
# load the libraries or install them ------------------------------------------------------

packages <- c("tidyverse", "rnaturalearth", "rnaturalearthdata", "sf", "ggeffects", "patchwork")

install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
  library(pkg, character.only = TRUE)
}

# Apply the function
lapply(packages, install_if_missing)

# read the data in  -------------------------------------------------------

# load the input data
data = read_csv('../data/model_input/data.csv') 

# load the grid
grid = read_csv('../data/model_input/grid.csv')