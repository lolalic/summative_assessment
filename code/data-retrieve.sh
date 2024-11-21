
#!/bin/bash

# Step 1: 下载包含文章 ID 的 XML 文件
echo "Downloading article IDs..."
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22long%20covid%22&retmax=10000" > ../data/pmids.xml

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "Error downloading article IDs. Exiting..."
    exit 1
fi

# Step 2: 提取文章 ID
echo "Extracting article IDs..."
pmids=$(xmllint --xpath "//IdList/Id/text()" ../data/pmids.xml)

if [ -z "$pmids" ]; then
    echo "No PMIDs found. Exiting..."
    exit 1
fi

# Step 3: 下载每篇文章的数据
echo "Downloading articles..."
for pmid in $pmids; do
    echo "Downloading article with PMID: $pmid"
    curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$pmid" > ../data/article-$pmid.xml
    if [ $? -ne 0 ]; then
        echo "Error downloading article with PMID: $pmid"
        continue
    fi
    sleep 1 # 暂停 1 秒以避免服务器过载
done

echo "All downloads completed!"
