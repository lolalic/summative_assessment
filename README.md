COVID-19 Publications Analysis Pipeline

This repository contains the code and resources for analyzing trends in COVID-19 research publications, focusing on "long COVID." The pipeline is implemented using Bash, R, SnakeMake, and Conda, and is designed to run on the BlueCrystal HPC environment.

Repository Structure:

.
├── code/                            # Directory for all code files
│   ├── scripts/                     # Scripts for each analysis step
│   │   ├── download_data.sh         # Step 1: Data download
│   │   ├── process_data.sh          # Step 2: Data extraction and cleaning
│   │   ├── clean_data.R             # Step 3: Text preprocessing
│   │   ├── data_visualisation.R     # Step 4: Data visualization
├── raw/                   # Directory for raw data (empty initially)
├── clean/                 # Directory for processed and final output data (empty initially)
├── logs/                  # Directory for log files
├── environment.yml        # Conda environment file for dependency management
├── Snakefile              # Pipeline file orchestrating all steps
└── README.md              # This file


Dependencies:

Dependencies are specified in the environment.yml file. Install them using:

conda env create -f environment.yml
conda activate covid_analysis


Pipeline Overview:

The pipeline consists of four steps:

1.Data Download (scripts/download_data.sh):
Downloads PubMed article metadata and article files related to "long COVID." Saves raw data in the raw/ directory.

2.Data Processing (scripts/process_data.sh):
Extracts metadata (PMID, Year, Title, Abstract, MESH terms) from downloaded XML files. Outputs a TSV file in the clean/ directory.

3.Text Preprocessing (scripts/clean_data.R):
Tokenizes titles, removes stop words, digits, and stems words using the tidytext package. Outputs processed data for analysis.

4.Data Visualization (scripts/data_visualisation.R):
Creates visualizations and saves them as PNG files in the clean/ directory.


Usage Instructions:

1. Clone the Repository