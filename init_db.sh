#!/bin/bash

# Script Purpose:
    # This shell script connects to your local database and prompt for a password
    # Connects to postgres database to drop data_warehouse if it exists
    # And recreate the data warehouse

# This script when run prompts for password.
# Input your password after making sure that the credentials are the same with yours.

# WARNING: Running this script will drop the entire data_warehouse if it exists.
# All data in the will be permanently deleted. Proceed with caution.

set -e  # stop script on first error

# --------------------------
# Setting Config Files
# --------------------------


DB_NAME="data_warehouse"
CURRENT_DB="postgres"
DB_USER="postgres"
DB_LOCALHOST="localhost"
DB_PORT=5432

# --------------------------
# Create database
# --------------------------

# Drop Database if it exists
psql -h $DB_LOCALHOST -p $DB_PORT -d $CURRENT_DB -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"
echo "Database $DB_NAME dropped"

# Recreating Database
psql -h $DB_LOCALHOST -p $DB_PORT -d $CURRENT_DB -U $DB_USER -c "CREATE DATABASE $DB_NAME;"
echo "$DB_NAME database created successfully"
echo "Database: $DB_NAME is ready!!"