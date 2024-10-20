#!/bin/bash

# Get the list of installed Debian packages
INSTALLED_PACKAGES=$(dpkg -l | awk '/^ii/ {print $2}')

# Loop through each installed package
for PACKAGE in $INSTALLED_PACKAGES; do
  # Check if the package is related to indi drivers
  if [[ "$PACKAGE" == *"libindi"* ]]; then

    # Get the Debian version of the package
    DEB_VERSION=$(dpkg -s "$PACKAGE" | awk '/Version:/ {print $2}')

    # Get the git hash of the package
    GIT_HASH=$(apt-get changelog "$PACKAGE" | grep -Eo 'commit [0-9a-f]{7,}' | head -1 | cut -d' ' -f2)

    # Print the package name with Debian version and git hash
    echo "$PACKAGE $DEB_VERSION~git$GIT_HASH"
  fi
  
done
