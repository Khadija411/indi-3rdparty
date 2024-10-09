#!/bin/bash

META_DIR="debian"

# Get the list of drivers from the repository
DRIVERS=$(find . -maxdepth 1 -type d -name "indi*")

# Loop through each driver and extract the version and package name from the changelog file
for DRIVER in $DRIVERS; do
  # Get the driver name
  DRIVER_NAME=$(basename "$DRIVER")

  # Check if the driver has a corresponding changelog file in the metadata directory
  if [ -f "$META_DIR/$DRIVER/changelog" ]; then
    # Extract the version and package name from the changelog file
    PACKAGE_INFO=$(grep -oE "^(.*) \((.*)\)" "$META_DIR/$DRIVER/changelog" | head -1)

    if [ -n "$PACKAGE_INFO" ]; then
      # Extract the version and package name
      VERSION=$(echo "$PACKAGE_INFO" | cut -d'(' -f2 | cut -d')' -f1)
      PACKAGE_NAME=$(echo "$PACKAGE_INFO" | cut -d' ' -f1)

      # Get the last modified date of the changelog file
      DATE=$(git log -1 --format=%ad --date=short -- "$DRIVER")

      # Get the hash of the last commit
      HASH=$(git log -1 --format=%h -- "$DRIVER")

      # Create the package name in the format "version~gitLastModifiedDate.hash"
      PACKAGE_NAME="$PACKAGE_NAME ${VERSION}~${DATE}.${HASH}"

      # Print the package name
      echo "$PACKAGE_NAME"
    else
      echo "No package info found for $DRIVER_NAME"
    fi
  else
    echo "No changelog file found for $DRIVER_NAME"
  fi
done
