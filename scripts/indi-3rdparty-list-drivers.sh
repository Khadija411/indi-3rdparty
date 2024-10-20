#!/bin/bash

META_DIR="debian"
REPO_URL="https://github.com/indilib/indi-3rdparty.git"
REQUIRED_BINARIES=("git" "basename" "find" "dpkg")
output_file="package_list.txt"

# Check if all required binaries are available
for BINARY in "${REQUIRED_BINARIES[@]}"; do
  if ! command -v "$BINARY" &> /dev/null; then
    echo "Error: $BINARY is not installed. Please install the package that provides this binary or add to PATH "
    exit 1
  fi
done

# Clone the repository if it doesn't exist
if [ ! -d "indi-3rdparty" ]; then
  if ! git clone "$REPO_URL"; then
    echo "Error cloning repository: $REPO_URL" >> error.log
    exit 1
  fi
else
  # Change into the repository directory
  cd "indi-3rdparty"
fi

if [ -f "$output_file" ]; then
  rm -rf $output_file
fi

# Check if it's a git directory
if git rev-parse --is-inside-work-tree; then
 if ! git pull; then
   echo "Error pulling repository: $REPO_URL" >> error.log
   exit 1
 fi
else
 echo "This is not a Git repository." >> error.log
 exit 1
fi

# Get the list of drivers from the repository
DRIVERS=$(find . -maxdepth 1 \( -type d -name "lib*" -o -type d -name "indi*" \))

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

      # Get the last modified date of the driver
      DATE=$(git log -1 --format=%ad --date=format:%Y%m%d -- "$DRIVER")

      # Get the hash of the last commit
      HASH=$(git log -1 --format=%h -- "$DRIVER")

      # Create the package name in the format "version~gitLastModifiedDate.hash"
      PACKAGE_NAME="$PACKAGE_NAME ${VERSION}~git${DATE}.${HASH}"

      # Print the package name
      echo "$PACKAGE_NAME" >> $file
    else
      echo "No package info found for $DRIVER_NAME"
    fi
  else
    echo "No changelog file found for $DRIVER_NAME"
  fi
done
