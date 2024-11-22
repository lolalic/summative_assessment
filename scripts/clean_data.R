library(xml2)
library(tidyverse)

# extract all XML file
files <- list.files("raw", pattern = ".xml", full.names = TRUE)

# extract title and year
data <- map_dfr(files, function(file) {
  xml <- read_xml(file)
  pmid <- xml_find_first(xml, ".//PMID") %>% xml_text()
  year <- xml_find_first(xml, ".//PubDate//Year") %>% xml_text()
  title <- xml_find_first(xml, ".//ArticleTitle") %>% xml_text()

  # clean up the title
  title <- gsub("<.*?>", "", title)  # remove XML tags
  tibble(PMID = pmid, Year = year, Title = title)
})

# save as TSV file
write_tsv(data, "articles.tsv")
