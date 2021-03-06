#!/usr/bin/env bash

tax_names=$1
file_list=$2

## Get the taxid names
awk -F "|" '$4 ~/scientific/ { gsub(/^[ \t]+|[ \t]+$|"'"|'"'/,"",$2); print $1$2}' $tax_names/names.dmp > names_table.dmp

## Get the taxids (unique) for each sample
sample_num=0
while read file
do
    awk '{ print $2 }' $file | sort -gu > `basename ${file%.kron}.taxon`
    (( sample_num++ ))
done < $file_list

## Create a JSON file (goes with the CSV file) for UpSet
cat <<EOF > nf-rnaSeqMetagen.json
{
    "file": "data/nf-rnaSeqMetagen/nf-rnaSeqMetagen.csv",
    "name": "nf-rnaSeqMetagen",
    "header": 0,
    "separator": ",",
    "skip": 0,
    "meta": [
        { "type": "id", "index": 0, "name": "Name" },
        { "type": "string", "index": $(( sample_num + 1 )) }
    ],
    "sets": [
        { "format": "binary", "start": 1, "end": $sample_num } 
    ]
}
EOF

