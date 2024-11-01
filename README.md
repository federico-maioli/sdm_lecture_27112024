# sdm_lecture_27112024
Repo for the species distribution models (SDMs) with R

# How to Download this Repository

To download this repository to your computer:

1. **Download ZIP**:
   - Click on the green **Code** button near the top right.
   - Select **Download ZIP** from the dropdown menu.

2. **Extract the ZIP File**:
   - Locate the downloaded ZIP file on your computer, then right-click and select **Extract All** (or the equivalent option on your operating system).

3. **Open the Folder**:
   - Navigate to the extracted folder to access the files.

You now have a local copy of the repository on your computer!

# What's inside
`r_vocabulary.html` contains some R vocabulary for data manipulation for those who are not familiar with it.

`data/` conatains all the data for running the analysis.

`exercise/` contains:
- the R demonstration `01_hands_on_sdm.html` that I will use to introduce students to SDMs
- the template students will use at the end of the lecture for fitting their own model `02_fit_my_model_template.R`

`data_preparation/` contains the scripts for extracting all the data from the sources and prepare them.

# Installation Instructions

## Install R, RStudio, and Necessary Libraries

**Note**: It’s very important that you arrive with all the necessary software and R packages installed. If you encounter issues, contact your colleagues, or if you get stuck, email me at [fedma@aqua.dtu.dk](mailto:fedma@aqua.dtu.dk).

### If You Don’t Have R and RStudio Installed

#### Install R
Get the latest version of R from [https://cran.r-project.org/](https://cran.r-project.org/).

#### Install RStudio
RStudio is a visual interface to R. Download the latest version at [https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/).

#### Install R Packages
1. Open RStudio.
2. Run the following command to install the necessary packages:

```r
   install.packages(c("tidyverse", "glmmTMB", "sdmTMB",
     "ggeffects", "terra", "sf"),
     dependencies = TRUE)
```

### If You Already Have R (and RStudio) Installed

#### Check Your R Version

Run the following command in RStudio to check your R version:

```r
sessionInfo()
```
You need to have a version of R >= 4.3.3.
If necessary, get the latest version at <https://cran.r-project.org/>.

#### Check Your RStudio Version

In RStudio, go to:
Mac: RStudio -> About RStudio
Windows: Help -> About RStudio
Ensure you have a version of RStudio >= 2024.04.0+735.
You can download the latest version at <https://www.rstudio.com/products/rstudio/download/>.
