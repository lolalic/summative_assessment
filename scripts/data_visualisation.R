# Load required libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(tidytext)
library(topicmodels)
library(stringr)
library(reshape2)

# Load the cleaned data
data <- read.delim("clean/articles_cleaned.tsv", stringsAsFactors = FALSE)

# --- 1. Change in Frequency of Particular Words Over Time ---

# Count word frequency by year
word_freq <- data %>%
  group_by(Year, word) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count))

# Filter words that appear in both years to avoid sparse data
top_words <- word_freq %>%
  group_by(word) %>%
  filter(n_distinct(Year) > 1) %>% # Ensure the word spans more than 1 year
  summarise(total_count = sum(count), .groups = "drop") %>%
  slice_max(total_count, n = 10) %>% # Select top 10 by total count
  pull(word)

# Filter data for top words
filtered_word_freq <- word_freq %>%
  filter(word %in% top_words)

# Plot word frequency trends
word_plot <- ggplot(filtered_word_freq, aes(x = Year, y = count,
                                            color = word, group = word)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Trends in Word Frequency Over Time",
    x = "Year",
    y = "Frequency",
    color = "Word"
  ) +
  theme_minimal()

# Save the plot
ggsave("clean/word_frequency_trends.png", plot = word_plot, width = 8, height = 6)

# --- 2. Changes in the Frequency of MESH Terms Over Time ---

# Tokenize MESH terms
mesh_terms <- data %>%
  filter(!is.na(MESH)) %>%
  mutate(MESH = str_split(MESH, ",")) %>%
  unnest(MESH)

# Count MESH frequency by year
mesh_freq <- mesh_terms %>%
  group_by(Year, MESH) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count))

# Identify top 10 MESH terms by overall frequency
top_mesh <- mesh_freq %>%
  group_by(MESH) %>%
  summarise(total_count = sum(count)) %>%
  top_n(10, total_count) %>%
  pull(MESH)

# Filter data for top MESH terms
filtered_mesh_freq <- mesh_freq %>%
  filter(MESH %in% top_mesh)

# Plot MESH frequency trends
mesh_plot <- ggplot(filtered_mesh_freq, aes(x = Year,
                                      y = count, color = MESH, group = MESH)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Trends in MESH Term Frequency Over Time",
    x = "Year",
    y = "Frequency",
    color = "MESH Term"
  ) +
  theme_minimal()

# Save the plot
ggsave("clean/mesh_term_frequency_trends.png", plot = mesh_plot, width = 8, height = 6)


# --- 3. Topic Modeling Using LDA ---

# Prepare data for LDA (use Abstracts)
lda_data <- data %>%
  filter(!is.na(Abstract)) %>%
  unnest_tokens(word, Abstract) %>%
  anti_join(stop_words, by = "word") %>%
  count(PMID, word, sort = TRUE) %>%
  cast_dtm(PMID, word, n)

# Apply LDA
lda_model <- LDA(lda_data, k = 5, control = list(seed = 123))

# Extract topics and terms
lda_topics <- tidy(lda_model, matrix = "beta")

# Identify top terms for each topic
top_terms <- lda_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  arrange(topic, -beta)

# Print top terms for each topic
print(top_terms)

# Assign topics to documents
lda_documents <- tidy(lda_model, matrix = "gamma") %>%
  mutate(document = as.integer(document)) %>%
  left_join(data, by = c("document" = "PMID")) %>%
  group_by(Year, topic) %>%
  summarise(avg_gamma = mean(gamma), .groups = "drop")

# Plot topic trends over time
topic_plot <- ggplot(lda_documents, aes(x = Year, y = avg_gamma, color = factor(topic), group = topic)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Trends in Topics Over Time",
    x = "Year",
    y = "Average Topic Proportion",
    color = "Topic"
  ) +
  theme_minimal()

# Save the plot
ggsave("clean/topic_trends_over_time.png", plot = topic_plot, width = 8, height = 6)
