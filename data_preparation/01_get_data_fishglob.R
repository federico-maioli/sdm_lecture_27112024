# Load and Install Required Libraries -------------------------------------

# Define required packages
required_packages <- c("tidyverse")

# Install any missing packages and load them
installed <- required_packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
lapply(required_packages, library, character.only = TRUE)


# Load FishGlob Data ------------------------------------------------------

# URL for the FishGlob dataset (raw file)
fishglob_url <- "https://github.com/AquaAuma/FishGlob_data/raw/main/outputs/Compiled_data/FishGlob_public_std_clean.RData"

# Load data from URL
load(url(fishglob_url)) # May take some time

# Filter for North-Sea IBTS surveys between 2000-2020 to match environmental covariates
filtered_data <- data %>%
  filter(survey == 'NS-IBTS', year %in% 2010:2020)


# Quality Check: Set Pelagic Species Weight to Zero -----------------------

# List of pelagic families to exclude from analysis
pelagic_families <- c(
  "Clupeidae", "Osmeridae", "Exocoetidae", "Atherinidae", "Engraulidae",
  "Hemiramphidae", "Inermiidae", "Belonidae", "Scomberesocidae", "Echeneidae",
  "Carangidae", "Bramidae", "Scombridae", "Centrolophidae", "Istiophoridae", "Ammodytidae"
)

# Set `wgt_cpua` to 0 for pelagic families
filtered_data <- filtered_data %>%
  mutate(wgt_cpua = ifelse(family %in% pelagic_families, 0, wgt_cpua))


# Calculate Species Presence for Selection --------------------------------

# Define occurrence threshold for species
occurrence_threshold <- 30 

# Calculate total hauls per year
haul_summary <- filtered_data %>%
  group_by(year) %>%
  summarize(total_hauls = n_distinct(haul_id), .groups = "drop")

# Calculate species occurrence and percentage presence across hauls
species_presence_summary <- filtered_data %>%
  group_by(accepted_name, haul_id, year) %>%
  summarize(total_weight = sum(wgt_cpua, na.rm = TRUE), .groups = "drop") %>%
  mutate(occurrence = ifelse(total_weight > 0, 1, 0)) %>%
  group_by(year, accepted_name) %>%
  summarize(hauls_with_species = sum(occurrence, na.rm = TRUE), .groups = "drop") %>%
  left_join(haul_summary, by = "year") %>%
  mutate(presence_percent = hauls_with_species / total_hauls * 100) %>%
  group_by(accepted_name) %>%
  summarize(mean_presence = mean(presence_percent, na.rm = TRUE), .groups = "drop") %>%
  filter(mean_presence >= occurrence_threshold)

# Filter for valid species names (genus and species)
selected_species <- species_presence_summary %>%
  filter(grepl("^\\w+ \\w+$", accepted_name))


# Expand Data for All Hauls and Selected Species --------------------------

# Create a dataframe with all haul-species combinations
expanded_data <- expand.grid(
  haul_id = unique(filtered_data$haul_id),
  accepted_name = unique(selected_species$accepted_name)
) %>%
  left_join(distinct(filtered_data, haul_id, survey))


# Extract Haul Information ------------------------------------------------

# Extract distinct haul details
haul_data <- filtered_data %>%
  select(
    survey, source, timestamp, haul_id, country, sub_area, continent,
    stat_rec, station, stratum, year, month, day, quarter, latitude,
    longitude, haul_dur, area_swept, gear, sbt, sst, depth
  ) %>%
  distinct()


# Filter Expanded Data for Selected Species -------------------------------

# Keep only rows with selected species in the expanded data
expanded_data <- expanded_data %>%
  semi_join(selected_species, by = "accepted_name")


# Merge Haul and Species Data ---------------------------------------------

# Combine expanded data with haul details
expanded_data <- expanded_data %>%
  left_join(haul_data, by = "haul_id")

# Extract species weights and join with expanded data
species_weight_data <- filtered_data %>%
  select(accepted_name, wgt_cpua, wgt, haul_id) %>%
  semi_join(selected_species, by = "accepted_name")

# Merge to create the complete dataset, filling missing weights with 0
complete_data <- expanded_data %>%
  left_join(species_weight_data, by = c("haul_id", "accepted_name")) %>%
  replace_na(list(wgt_cpua = 0, wgt = 0))


# Handle Duplicates and Aggregate Data ------------------------------------

# Identify and summarize duplicate rows by key columns
group_by_columns <- c(
  "source", "timestamp", "haul_id", "country", "sub_area", 
  "continent", "stat_rec", "station", "stratum", "year", "month", "day",
  "quarter", "latitude", "longitude", "haul_dur", "area_swept", "gear", 
  "sbt", "sst", "depth", "accepted_name"
)

# Aggregate `wgt_cpua` and `wgt` by key columns to handle duplicates
complete_data <- complete_data %>%
  group_by(across(all_of(group_by_columns))) %>%
  summarize(
    wgt_cpua = sum(wgt_cpua, na.rm = TRUE),
    wgt = sum(wgt, na.rm = TRUE),
    .groups = "drop"
  )


# Select and Rename Relevant Columns --------------------------------------

# Keep only the columns needed for analysis
final_data <- complete_data %>%
  select(haul_id, year, latitude, longitude, accepted_name, wgt_cpua) %>%
  rename(
    species = accepted_name,
    kg_km2 = wgt_cpua
  )

# Add presence-absence column
final_data <- final_data %>%
  mutate(present = ifelse(kg_km2 > 0, 1, 0))

# Clean species names
final_data <- final_data %>% mutate(species = str_replace_all(species, " ", "_"))


# Write the Dataset -------------------------------------------------------

write_csv(final_data,'data/fish/fish.csv')

