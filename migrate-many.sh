#!/bin/bash

# Example: ./migrate-many.sh data.txt

data=$1

# Read file specified as an argument line-by-line
while read -r line
do
  # echo "Text read from file: $line"


  # Split line into SVN and GIT urls
  OIFS="$IFS"
  IFS='='
  read -a urls <<< ${line}
  IFS="$OIFS"
  # echo "SVN Urls: ${urls[0]}"
  # echo "GIT Urls: ${urls[1]}"

  # Execute the script to migrate a single repo with the SVN and GIT urls
  ./migrate.sh ${urls[0]} ${urls[1]}
done <$data