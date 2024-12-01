rule all:
    input:
        # Final outputs including all visualizations
        "clean/topic_trends_over_time.png",
        "clean/word_frequency_trends.png",
        "clean/mesh_term_frequency_trends.png"

rule download_data:
    output:
        "raw/pmids.xml",  # XML file containing article IDs
        directory("raw/")  # Directory for all downloaded articles
    script:
        "scripts/download_data.sh"  # Script to download data from PubMed

rule process_data:
    input:
        directory("raw/")  # Input directory containing raw XML article files
    output:
        "clean/articles_processed.tsv"  # Output processed TSV file with relevant fields
    script:
        "scripts/process_data.sh"  # Script for data extraction and cleaning

rule clean_data:
    input:
        "clean/articles_processed.tsv"  # Input processed TSV file
    output:
        "clean/articles_cleaned.tsv"  # Output cleaned and tokenized data
    script:
        "scripts/clean_data.R"  # Script to clean, tokenize, and preprocess text

rule data_visualisation:
    input:
        "clean/articles_cleaned.tsv"  # Input cleaned and tokenized data
    output:
        # Multiple outputs for different visualizations
        "clean/word_frequency_trends.png",  # Word frequency trends plot
        "clean/mesh_term_frequency_trends.png",  # MESH term frequency trends plot
        "clean/topic_trends_over_time.png"  # Topic trends over time plot
    script:
        "scripts/data_visualisation.R"  # Script for generating visualizations
