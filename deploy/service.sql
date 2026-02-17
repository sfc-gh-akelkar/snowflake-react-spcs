-- =============================================================================
-- SPCS Service Creation Script
-- Run this after pushing your Docker images to the Snowflake registry
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE REACT_APP_DB;
USE SCHEMA SPCS;

-- =============================================================================
-- Drop existing service if it exists (for redeployment)
-- =============================================================================
-- DROP SERVICE IF EXISTS REACT_APP_SERVICE;

-- =============================================================================
-- Create the Service
-- This deploys both frontend and backend containers
-- =============================================================================
CREATE SERVICE REACT_APP_SERVICE
    IN COMPUTE POOL REACT_APP_POOL
    FROM SPECIFICATION $$
    spec:
      containers:
        - name: backend
          image: /react_app_db/spcs/react_app_repo/backend:latest
          env:
            SNOWFLAKE_WAREHOUSE: REACT_APP_WH
            SNOWFLAKE_DATABASE: SNOWFLAKE_SAMPLE_DATA
            SNOWFLAKE_SCHEMA: TPCH_SF1
          resources:
            requests:
              cpu: 0.5
              memory: 1Gi
            limits:
              cpu: 1
              memory: 2Gi
        - name: frontend
          image: /react_app_db/spcs/react_app_repo/frontend:latest
          resources:
            requests:
              cpu: 0.25
              memory: 256Mi
            limits:
              cpu: 0.5
              memory: 512Mi
      endpoints:
        - name: frontend
          port: 80
          public: true
    $$
    EXTERNAL_ACCESS_INTEGRATIONS = ()
    QUERY_WAREHOUSE = REACT_APP_WH
    MIN_INSTANCES = 1
    MAX_INSTANCES = 2;

-- =============================================================================
-- Check service status
-- =============================================================================
DESCRIBE SERVICE REACT_APP_SERVICE;
SELECT SYSTEM$GET_SERVICE_STATUS('REACT_APP_SERVICE');

-- =============================================================================
-- Get the service endpoint URL
-- =============================================================================
SHOW ENDPOINTS IN SERVICE REACT_APP_SERVICE;

-- =============================================================================
-- View service logs (for debugging)
-- =============================================================================
-- SELECT SYSTEM$GET_SERVICE_LOGS('REACT_APP_SERVICE', '0', 'backend', 100);
-- SELECT SYSTEM$GET_SERVICE_LOGS('REACT_APP_SERVICE', '0', 'frontend', 100);

-- =============================================================================
-- Useful commands for managing the service
-- =============================================================================
-- Suspend the service (stop running, save costs)
-- ALTER SERVICE REACT_APP_SERVICE SUSPEND;

-- Resume the service
-- ALTER SERVICE REACT_APP_SERVICE RESUME;

-- Scale the service
-- ALTER SERVICE REACT_APP_SERVICE SET MIN_INSTANCES = 2, MAX_INSTANCES = 4;

-- Drop the service (remove completely)
-- DROP SERVICE REACT_APP_SERVICE;
