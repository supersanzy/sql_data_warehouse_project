/*
    Script Purpose:
        Calls the stored procedure created for loading transformed data to the silver layer
*/

CALL silver.transform_and_load();