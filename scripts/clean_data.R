# 加载必要的库
library(tidyverse)
library(tidytext)
library(SnowballC)

# 读取 Step 2 生成的 TSV 文件
titles_data <- read_tsv("clean/articles_cleaned.tsv")

# 确保数据包含 Title 和 Year 列
if (!"Title" %in% colnames(titles_data) | !"Year" %in% colnames(titles_data)) {
  stop("Title or Year column is missing in the data")
}

# 对 Title 列进行分词、去除停用词、数字，并进行词干化
processed_titles <- titles_data %>%
  unnest_tokens(word, Title) %>%  # 将 Title 列分词
  filter(!word %in% stop_words$word) %>%  # 去除停用词
  filter(!str_detect(word, "\\d+")) %>%  # 去除数字
  mutate(word = wordStem(word))  # 进行词干化处理

# 保存处理后的数据，包括分词结果和原始年份
write_tsv(processed_titles, "clean/processed_step3.tsv")

print("Step 3 完成：标题已处理，结果保存在 clean/processed_step3.tsv 文件中")

