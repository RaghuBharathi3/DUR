# 00_install_packages.R - Bootstrap script to ensure all required CRAN packages are installed
# This script can be sourced independently if you need to (re)install packages.

# Load the helper function from global.R (assumes the working directory is the project root)
source(file.path(getwd(), "global.R"))

# Run the installer
install_missing_packages()

message("Package installation completed.")
