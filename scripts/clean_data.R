# libraries
library(tidyverse)
library(tidytext)
library(SnowballC)

# Read the TSV file generated in Step 2
titles_data <- read_tsv("clean/articles_processed.tsv")

# Ensure the data contains the Title and Year columns
if (!"Title" %in% colnames(titles_data) | !"Year" %in% colnames(titles_data)) {
  stop("Title or Year column is missing in the data")
}

# # Tokenize the Title column, remove stop words, numbers, and apply stemming
processed_titles <- titles_data %>%
  unnest_tokens(word, Title) %>%  # Tokenize the Title column
  filter(!word %in% stop_words$word) %>%  # Remove stop words
  filter(!str_detect(word, "\\d+")) %>%  # Remove numbers
  mutate(word = wordStem(word))  # Apply stemming

# Save the processed data, including tokenized results and original year
write_tsv(processed_titles, "clean/articles_cleaned.tsv")

print("Step 3 completed: Titles have been processed, and the results are saved in clean/articles_cleaned.tsv")


