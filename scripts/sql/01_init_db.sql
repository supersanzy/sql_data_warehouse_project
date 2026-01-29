/*
Script Purpose: 
    This script drops and recreates database schema:
        -- bronze
        -- silver
        -- gold

*/

-- Dropping our schema if it exists
DROP SCHEMA IF EXISTS bronze CASCADE;
DROP SCHEMA IF EXISTS silver CASCADE;
DROP SCHEMA IF EXISTS gold CASCADE;

-- Rereating schema for our layers
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;