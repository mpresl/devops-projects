#!/bin/bash

# Nginx Log Analyzer Script
# Usage: ./nginx-analyzer.sh <log_file>
# Example: ./nginx-analyzer.sh nginx-access.log

# Check if log file is provided
# $# represents the number of command line arguments
# -eq 0 means "equals zero" (no arguments provided)
if [ $# -eq 0 ]; then
    echo "Usage: $0 <log_file>"
    echo "Example: $0 nginx-access.log"
    exit 1  # Exit with error code 1
fi

# Store the first command line argument as the log file path
# $1 refers to the first argument passed to the script
LOG_FILE="$1"

# Check if log file exists
# -f flag tests if the file exists and is a regular file
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found."
    exit 1  # Exit with error code 1
fi

echo "=========================================="
echo "Nginx Log Analysis Report"
echo "=========================================="
echo "Log file: $LOG_FILE"
# wc -l counts the number of lines in the file
# < "$LOG_FILE" redirects the file content to wc command
echo "Total lines: $(wc -l < "$LOG_FILE")"
echo ""

# Function to print section header
# This function takes one parameter ($1) and prints a formatted section header
print_section() {
    echo "------------------------------------------"
    echo "$1"  # Print the section title passed as argument
    echo "------------------------------------------"
}

# Top 5 IP addresses with most requests
print_section "Top 5 IP Addresses (Most Requests)"
# awk '{print $1}' - Extract the first field (IP address) from each line
# sort - Sort the IP addresses alphabetically
# uniq -c - Count unique occurrences and prefix each line with count
# sort -nr - Sort numerically in reverse order (highest count first)
# head -5 - Take only the first 5 lines
# awk '{printf "%-15s %s requests\n", $2, $1}' - Format output:
#   $2 is the IP address (second field after uniq -c)
#   $1 is the count (first field after uniq -c)
#   %-15s means left-align IP address in 15-character field
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 | awk '{printf "%-15s %s requests\n", $2, $1}'

echo ""

# Top 5 most requested paths
print_section "Top 5 Most Requested Paths"
# awk '{print $7}' - Extract the 7th field (request path) from each line
# The nginx combined log format is: IP - - [timestamp] "METHOD /path HTTP/version" status bytes "referer" "user_agent"
# Field 7 is the path part of the request
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 | awk '{printf "%-30s %s requests\n", $2, $1}'

echo ""

# Top 5 response status codes
print_section "Top 5 Response Status Codes"
# awk '{print $9}' - Extract the 9th field (HTTP status code) from each line
# In nginx combined format: IP - - [timestamp] "METHOD /path HTTP/version" status bytes "referer" "user_agent"
# Field 9 is the status code (200, 404, etc.)
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 | awk '{printf "%-10s %s responses\n", $2, $1}'

echo ""

# Top 5 user agents
print_section "Top 5 User Agents"
# Extract user agent (everything after the last quote, but handle cases with no user agent)
# awk -F'"' - Use double quote as field separator
# NF>=4 - Only process lines with at least 4 fields (ensures valid log format)
# {print $6} - Print the 6th field after splitting by quotes
# The format after splitting by quotes: [IP - - [timestamp], METHOD /path HTTP/version, status bytes, referer, user_agent]
# So $6 is the user agent field
awk -F'"' 'NF>=4 {print $6}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 | awk '{printf "%-50s %s requests\n", $2, $1}'

echo ""
echo "=========================================="
echo "Analysis Complete"
echo "=========================================="
