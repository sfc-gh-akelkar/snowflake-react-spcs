-- =============================================================================
-- SPCS Setup Script
-- Run this script to set up the infrastructure for deploying the React app
-- =============================================================================

-- Use a role with appropriate privileges
USE ROLE ACCOUNTADMIN;

-- Create a database for our application (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS REACT_APP_DB;
USE DATABASE REACT_APP_DB;

-- Create a schema for SPCS objects
CREATE SCHEMA IF NOT EXISTS SPCS;
USE SCHEMA SPCS;

-- =============================================================================
-- Create an Image Repository
-- This is where we'll push our Docker images
-- =============================================================================
CREATE IMAGE REPOSITORY IF NOT EXISTS REACT_APP_REPO;

-- Get the repository URL (you'll need this to push images)
SHOW IMAGE REPOSITORIES;

-- =============================================================================
-- Create a Compute Pool
-- This provides the compute resources for running containers
-- =============================================================================
CREATE COMPUTE POOL IF NOT EXISTS REACT_APP_POOL
    MIN_NODES = 1
    MAX_NODES = 2
    INSTANCE_FAMILY = CPU_X64_XS
    AUTO_RESUME = TRUE
    AUTO_SUSPEND_SECS = 300;

-- Check compute pool status
DESCRIBE COMPUTE POOL REACT_APP_POOL;

-- =============================================================================
-- Create a Warehouse (if needed for queries)
-- =============================================================================
CREATE WAREHOUSE IF NOT EXISTS REACT_APP_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

-- =============================================================================
-- Grant necessary permissions
-- =============================================================================
-- Grant usage on the compute pool to the role that will create services
GRANT USAGE ON COMPUTE POOL REACT_APP_POOL TO ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE REACT_APP_WH TO ROLE ACCOUNTADMIN;

-- Grant access to sample data
GRANT USAGE ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE ACCOUNTADMIN;
GRANT USAGE ON SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1 TO ROLE ACCOUNTADMIN;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1 TO ROLE ACCOUNTADMIN;

-- =============================================================================
-- Output the image repository URL
-- =============================================================================
SELECT SYSTEM$REGISTRY_LIST_IMAGES('/REACT_APP_DB/SPCS/REACT_APP_REPO');

-- To get the full repository URL, run:
-- SHOW IMAGE REPOSITORIES LIKE 'REACT_APP_REPO' IN SCHEMA REACT_APP_DB.SPCS;
-- The 'repository_url' column contains the URL to use for docker push
