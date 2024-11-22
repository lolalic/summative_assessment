#!/bin/bash

# 创建干净数据文件夹
mkdir -p clean

# 定义输出文件路径
output_file="clean/articles_cleaned.tsv"

# 初始化 TSV 文件并添加表头
echo -e "PMID\tYear\tTitle\tAbstract\tMESH" > "$output_file"

# 遍历所有 XML 文件
for file in raw/article-*.xml; do
    echo "Processing file: $file"  # 调试信息

    # 提取数据
    pmid=$(xmlstarlet sel -t -v "//PMID" "$file" 2>/dev/null | head -1)
    year=$(xmlstarlet sel -t -v "//PubDate/Year" "$file" 2>/dev/null | head -1)
    title=$(xmlstarlet sel -t -v "//ArticleTitle" "$file" 2>/dev/null | sed 's/\[\([^]]*\)\]\.*/\1/' | head -1)
    abstract=$(xmlstarlet sel -t -v "//Abstract/AbstractText" "$file" 2>/dev/null | sed 's/<[^>]*>//g' | head -1)
    mesh=$(xmlstarlet sel -t -m "//MeshHeadingList/MeshHeading/DescriptorName" -v . -o "," "$file" 2>/dev/null | sed 's/,$//' | head -1)

    # 跳过无标题的记录
    if [[ -z "$title" ]]; then
        echo "Skipping file: $file (missing essential data)"
        continue
    fi
    
  

    # 判断标题内容是否为 "Not Available"
    if [[ "$title" == "Not Available" ]]; then
        echo "Skipping file: $file (Title is Not Available)"
        continue
    fi


    # 替换空字段为占位符
    pmid=${pmid:-N/A}
    year=${year:-N/A}
    abstract=${abstract:-N/A}
    mesh=${mesh:-N/A}

    # 写入结果到 TSV 文件
    echo -e "$pmid\t$year\t$title\t$abstract\t$mesh" >> "$output_file"
done

echo "数据预处理完成，结果保存在 $output_file"
