#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <log_directory>"
    echo "  <log_directory> - Directory containing log files to archive"
    echo ""
    echo "Example: $0 /var/log"
    echo "Example: $0 ./logs"
    exit 1
}

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No directory specified"
    usage
fi

# Check if the provided argument is a valid directory
if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a valid directory"
    usage
fi

# Store the log directory
LOG_DIR="$1"

# Create a new directory to store the compressed logs
mkdir -p compressed_logs

# Generate timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")

# Define archive name with timestamp
archive_name="logs_archive_$timestamp.tar.gz"

# Check if there are any .log files in the specified directory
log_count=$(find "$LOG_DIR" -maxdepth 1 -name "*.log" | wc -l)

if [ $log_count -eq 0 ]; then
    echo "Warning: No .log files found in directory '$LOG_DIR'"
    echo "Available files in directory:"
    ls -la "$LOG_DIR"
    exit 1
fi

# Compress all .log files in the specified directory into a tar.gz archive
echo "Archiving $log_count log files from directory: $LOG_DIR"
tar -czf "compressed_logs/$archive_name" -C "$LOG_DIR" $(find "$LOG_DIR" -maxdepth 1 -name "*.log" -printf "%f ")

# Check if the archive was created successfully
if [ $? -eq 0 ]; then
    # Log the date and time of the archive creation
    echo "Archive $archive_name created on $(date)" >> compressed_logs/archive_log.txt
    
    echo "Log files have been compressed into $archive_name and stored in the 'compressed_logs' directory."
    echo "Archive size: $(du -h "compressed_logs/$archive_name" | cut -f1)"
else
    echo "Error: Failed to create archive"
    exit 1
fi
