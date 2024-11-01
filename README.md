# sdm_lecture_27112024

Repository for the species distribution models (SDMs) with R.

# How to download this repository

To download this repository to your computer:

1. **Download ZIP**:
   - Click on the green **Code** button near the top right.
   - Select **Download ZIP** from the dropdown menu.

2. **Extract the ZIP file**:
   - Locate the downloaded ZIP file on your computer, then right-click and select **Extract All** (or the equivalent option on your operating system).

3. **Open the folder**:
   - Navigate to the extracted folder to access the files.

You now have a local copy of the repository on your computer!

# What's inside

- `r_vocabulary.html` contains R vocabulary for data manipulation, for those who are not familiar with it.

- `data/` contains all the data for running the analysis.

- `exercise/` contains:
  - the R demonstration `01_hands_on_sdm.html` that I will use to introduce students to SDMs
  - the template `02_fit_my_model_template.R` for students to fit their own models at the end of the lecture

- `data_preparation/` contains the scripts for extracting all the data from the sources and preparing it for analysis.

# Installation instructions

## Install R, RStudio, and necessary libraries

**Note**: It’s very important that you arrive with all the necessary software and R packages installed. If you encounter issues, contact your colleagues, or if you get stuck, email me at [fedma@aqua.dtu.dk](mailto:fedma@aqua.dtu.dk).

### If you don’t have R and RStudio installed

#### Install R
Get the latest version of R from [https://cran.r-project.org/](https://cran.r-project.org/).

#### Install RStudio
RStudio is a visual interface to R. Download the latest version at [https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/).

#### Install R packages
1. Open RStudio.
2. Run the following command to install the necessary packages:


```r
   install.packages(c("tidyverse", "glmmTMB", "sdmTMB",
     "ggeffects", "terra", "sf"),
     dependencies = TRUE)
```

### If you already have R (and RStudio) installed

#### Check your R Version

Run the following command in RStudio to check your R version:

```r
sessionInfo()
```
You need to have a version of R >= 4.3.3.
If necessary, get the latest version at <https://cran.r-project.org/>.

#### Check your RStudio version

In RStudio, go to:
Mac: RStudio -> About RStudio
Windows: Help -> About RStudio
Ensure you have a version of RStudio >= 2024.04.0+735.
You can download the latest version at <https://www.rstudio.com/products/rstudio/download/>.
