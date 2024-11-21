
#!/bin/bash

mkdir -p raw

# Step 1: Download an XML file containing article IDs
echo "Downloading article IDs..."
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22long%20covid%22&retmax=10000" > raw/pmids.xml

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Error downloading article IDs. Exiting..."
    exit 1
fi

# Step 2: Extract article ID
echo "Extracting article IDs..."
pmids=$(xmllint --xpath "//IdList/Id/text()" raw/pmids.xml)

if [ -z "$pmids" ]; then
    echo "No PMIDs found. Exiting..."
    exit 1
fi

# Step 3: Download data for each article
echo "Downloading articles..."
for pmid in $pmids; do
    echo "Downloading article with PMID: $pmid"
    curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$pmid" > raw/article-$pmid.xml
    if [ $? -ne 0 ]; then
        echo "Error downloading article with PMID: $pmid"
        continue
    fi
    sleep 1 # Pause for 1 second to avoid overloading the server
done

echo "All downloads completed!"

