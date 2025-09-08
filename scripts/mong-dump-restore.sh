#!/bin/bash

# Check for required commands
if ! command -v mongodump &> /dev/null || ! command -v mongorestore &> /dev/null; then
  echo "Error: mongodump and mongorestore must be installed and accessible."
  exit 1
fi

# Parse arguments
SOURCE_URI=""
DEST_URI=""
ZIP_PATH="mongo_dump.zip"
TEMP_DIR="/tmp/mongo-dump"

while [[ $# -gt 0 ]]; do
  case $1 in
    --source-uri)
      SOURCE_URI="$2"
      shift 2
      ;;
    --destination-uri)
      DEST_URI="$2"
      shift 2
      ;;
    --zip-path)
      ZIP_PATH="$2"
      shift 2
      ;;
    --temp-dir)
      TEMP_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate arguments
if [[ -z "$SOURCE_URI" || -z "$DEST_URI" ]]; then
  echo "Error: Both --source-uri and --destination-uri must be provided."
  exit 1
fi

DUMP_DIR="$TEMP_DIR/dump"

# Ensure the temporary directory exists
mkdir -p "$TEMP_DIR"

# Step 1: Dump the source database
echo "Starting database dump..."
mongodump --uri="$SOURCE_URI" --out="$DUMP_DIR"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to dump the source database."
  exit 1
fi
echo "Database dump completed."

# # Step 2: Create a ZIP archive of the dump
# echo "Creating ZIP archive..."
# zip -r "$ZIP_PATH" "$DUMP_DIR" > /dev/null
# if [[ $? -ne 0 ]]; then
#   echo "Error: Failed to create ZIP archive."
#   exit 1
# fi
# echo "ZIP archive created at: $ZIP_PATH"
#
# # Step 3: Restore the database from the ZIP archive
# echo "Extracting ZIP archive..."
# unzip -q "$ZIP_PATH" -d "$TEMP_DIR"
# if [[ $? -ne 0 ]]; then
#   echo "Error: Failed to extract ZIP archive."
#   exit 1
# fi
# echo "ZIP archive extracted."

echo "Starting database restore..."
mongorestore --uri="$DEST_URI" "$DUMP_DIR"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to restore the database."
  exit 1
fi
echo "Database restore completed."

# Cleanup temporary files
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
if [[ $? -ne 0 ]]; then
  echo "Warning: Failed to clean up temporary files."
else
  echo "Cleanup completed."
fi

exit 0

