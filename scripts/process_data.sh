#!/bin/bash

# 创建干净数据文件夹
mkdir -p clean

# 定义输出文件路径
output_file="clean/articles_processed.tsv"

# initialize TSV file and 并添加表头
# echo -e "PMID\tYear\tTitle\tAbstract\tMESH" > "$output_file"

# Configuration: Choose fields for processing
use_abstract=true   # Set to true to include abstracts
use_mesh=true       # Set to true to include MESH terms
replace_title_with_abstract=false # Set to true to replace title with abstract

# Initialize the TSV file and add the header
header="PMID\tYear"
header+="\tTitle"
[[ "$use_abstract" == true ]] && header+="\tAbstract"
[[ "$use_mesh" == true ]] && header+="\tMESH"
echo -e "$header" > "$output_file"

# 遍历所有 XML 文件
for file in data/article-*.xml; do
    echo "Processing file: $file"

    # Extract the data
    pmid=$(xmlstarlet sel -t -v "//PMID" "$file" 2>/dev/null | head -1)
    year=$(xmlstarlet sel -t -v "//PubDate/Year" "$file" 2>/dev/null | head -1)
    title=$(xmlstarlet sel -t -v "//ArticleTitle" "$file" 2>/dev/null | sed 's/\[\([^]]*\)\]\.*/\1/' | head -1)
    abstract=$(xmlstarlet sel -t -v "//Abstract/AbstractText" "$file" 2>/dev/null | sed 's/<[^>]*>//g' | head -1)
    mesh=$(xmlstarlet sel -t -m "//MeshHeadingList/MeshHeading/DescriptorName" -v . -o "," "$file" 2>/dev/null | sed 's/,$//' | head -1)




    # Skip articles that do not have a title (or abstract if replacing title)
    if [[ -z "$title" && "$replace_title_with_abstract" != true ]]; then
        echo "Skipping file: $file (missing title and not replacing with abstract)"
        continue
    fi

    # Skip articles where the title is "Not Available"
    if [[ "$title" == "Not Available" && "$replace_title_with_abstract" != true ]]; then
        echo "Skipping file: $file (Title is Not Available)"
        continue
    fi

    # If configured, replace title with abstract
    if [[ "$replace_title_with_abstract" == true && -n "$abstract" ]]; then
        title=$abstract
    fi

    # Replace empty fields with placeholders
    pmid=${pmid:-N/A}
    year=${year:-N/A}
    abstract=${abstract:-N/A}
    mesh=${mesh:-N/A}

    # Prepare row for output
    row="$pmid\t$year\t$title"
    [[ "$use_abstract" == true ]] && row+="\t$abstract"
    [[ "$use_mesh" == true ]] && row+="\t$mesh"

    # Write the results to the TSV file
    echo -e "$row" >> "$output_file"

    # 写入结果到 TSV 文件
    # echo -e "$pmid\t$year\t$title\t$abstract\t$mesh" >> "$output_file"
done

echo "Data preprocessing completed. Results saved in $output_file"
