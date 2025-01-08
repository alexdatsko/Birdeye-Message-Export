#!/bin/bash


########################################################
# Birdeye-Message-Export.sh
# Alex Datsko - MME Consulting Inc.
#   v0.1 1-8-25 - Initial POC
#
# Can only extract 100 messages at a time it looks like.
# ALSO be careful some files may be incomplete due to rate limiting!
# found that you can only pull max messages of 10k at a time it looks like so, I broke the year extract function into 4 sections for now, quarterly, as this did not surpass 10k messages.
#
# started with this:
#   curl -X POST -H "Content-Type: application/json" https://api.birdeye.com/resources/v1/messenger/export -d '{"businessNumber":"ayy","apikey":"ayyy","startDate":"10/31/2018","endDate":"01/01/2020","size": "10","excludeCampaignMessages": 1}' -sk | jq


# API endpoint and parameters
API_KEY="replaceme"
BUSINESS_NUMBER="alsoreplacethis"

START_YEAR=2018
END_YEAR=2025

SIZE=100  # Adjust this value if needed, this looks like the max we can pull at once

API_URL="https://api.birdeye.com/resources/v1/messenger/export"


# Function to fetch data for a specific year (split into 3 month sections.. 10000 is max cap it seems)
# Q1
fetch_year_data() {
    local year=$1
    local start_date="01/01/${year}"
    local end_date="03/31/${year}"
    local offset=0
    local output_file="${year}.json"
    local has_more="true"

    echo "Fetching data for year $year..."
    while [[ "$has_more" == "true" ]]; do
        response=$(curl -s -X POST -H "Content-Type: application/json" \
            "$API_URL" \
            -d '{
                "businessNumber": "'$BUSINESS_NUMBER'",
                "apikey": "'$API_KEY'",
                "startDate": "'$start_date'",
                "endDate": "'$end_date'",
                "size": "'$SIZE'",
                "offset": "'$offset'",
                "excludeCampaignMessages": 1
            }')

        if ! echo "$response" | jq . > /dev/null 2>&1; then
            echo "Error fetching data for year $year at offset $offset. Exiting..."
            exit 1
        fi

        echo "$response" | jq . >> "$output_file"

        has_more=$(echo "$response" | jq '.hasMore')
        echo "start_date: $start_date end_date: $end_date offset: $offset , has_more: $has_more"
        if [[ $has_more -ne "true" ]]; then
          echo "$response" | tail -n 1
          has_more=false
        fi
        offset=$((offset + SIZE))
    done

# Q2
    local start_date="04/01/${year}"
    local end_date="06/31/${year}"
    local offset=0
    local has_more="true"

    while [[ "$has_more" == "true" ]]; do
        response=$(curl -s -X POST -H "Content-Type: application/json" \
            "$API_URL" \
            -d '{
                "businessNumber": "'$BUSINESS_NUMBER'",
                "apikey": "'$API_KEY'",
                "startDate": "'$start_date'",
                "endDate": "'$end_date'",
                "size": "'$SIZE'",
                "offset": "'$offset'",
                "excludeCampaignMessages": 1
            }')

        if ! echo "$response" | jq . > /dev/null 2>&1; then
            echo "Error fetching data for year $year at offset $offset. Exiting..."
            exit 1
        fi

        echo "$response" | jq . >> "$output_file"

        has_more=$(echo "$response" | jq '.hasMore')
        echo "start_date: $start_date end_date: $end_date offset: $offset , has_more: $has_more"
        if [[ $has_more -ne "true" ]]; then
          echo "$response" | tail -n 1
          has_more=false
        fi
        offset=$((offset + SIZE))
    done


#### Q3- 2nd half of year...

    local start_date="07/01/${year}"
    local end_date="09/31/${year}"
    local offset=0
    local has_more="true"

    while [[ "$has_more" == "true" ]]; do
        response=$(curl -s -X POST -H "Content-Type: application/json" \
            "$API_URL" \
            -d '{
                "businessNumber": "'$BUSINESS_NUMBER'",
                "apikey": "'$API_KEY'",
                "startDate": "'$start_date'",
                "endDate": "'$end_date'",
                "size": "'$SIZE'",
                "offset": "'$offset'",
                "excludeCampaignMessages": 1
            }')

        if ! echo "$response" | jq . > /dev/null 2>&1; then
            echo "Error fetching data for year $year at offset $offset. Exiting..."
            exit 1
        fi

        echo "$response" | jq . >> "$output_file"

        has_more=$(echo "$response" | jq '.hasMore')
        echo "start_date: $start_date end_date: $end_date offset: $offset , has_more: $has_more"
        if [[ $has_more -ne "true" ]]; then
          has_more=false
        fi
        offset=$((offset + SIZE))
    done

# Q4
    local start_date="10/01/${year}"
    local end_date="12/31/${year}"
    local offset=0
    local has_more="true"

    while [[ "$has_more" == "true" ]]; do
        response=$(curl -s -X POST -H "Content-Type: application/json" \
            "$API_URL" \
            -d '{
                "businessNumber": "'$BUSINESS_NUMBER'",
                "apikey": "'$API_KEY'",
                "startDate": "'$start_date'",
                "endDate": "'$end_date'",
                "size": "'$SIZE'",
                "offset": "'$offset'",
                "excludeCampaignMessages": 1
            }')

        if ! echo "$response" | jq . > /dev/null 2>&1; then
            echo "Error fetching data for year $year at offset $offset. Exiting..."
            exit 1
        fi

        echo "$response" | jq . >> "$output_file"

        has_more=$(echo "$response" | jq '.hasMore')
        echo "start_date: $start_date end_date: $end_date offset: $offset , has_more: $has_more"
        if [[ $has_more -ne "true" ]]; then
          has_more=false
        fi
        offset=$((offset + SIZE))
    done


    echo "Data for year $year saved to $output_file."
}

# Loop through the years
for year in $(seq $START_YEAR $END_YEAR); do
    fetch_year_data $year
done

