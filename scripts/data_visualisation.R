# 加载必要的库
library(tidyverse)

# 读取 Step 3 的处理结果
processed_titles <- read_tsv("clean/processed_step3.tsv")

# 按年份计算每个单词的频率
word_trends <- processed_titles %>%
  count(Year, word, sort = TRUE)

# 挑选前 10 个高频词的趋势
top_words <- word_trends %>%
  group_by(word) %>%
  summarise(total = sum(n)) %>%
  top_n(10, total) %>%
  pull(word)

trend_plot <- word_trends %>%
  filter(word %in% top_words) %>%
  ggplot(aes(x = Year, y = n, color = word, group = word)) +
  geom_line() +
  labs(
    title = "常用词随时间变化的趋势",
    x = "年份",
    y = "频率",
    color = "单词"
  ) +
  theme_minimal()

# 保存图表为 PNG 文件
ggsave("clean/word_trends_over_time.png", trend_plot)

print("Step 4 完成：生成的图表保存为 clean/word_trends_over_time.png")
