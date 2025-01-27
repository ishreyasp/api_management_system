SET SERVEROUTPUT ON;

DECLARE
    v_api_manager_count NUMBER;
    v_api_user_count    NUMBER;
BEGIN
    -- Check if user API_MANAGER already exists
    SELECT COUNT(1)
    INTO v_api_manager_count
    FROM all_users
    WHERE username = 'API_MANAGER';
    
    -- Check if user APP_USER already exists
    SELECT COUNT(*)
    INTO v_api_user_count
    FROM all_users
    WHERE username = 'APP_USER';
    
    -- Drop API_MANAGER if already exists
    IF v_api_manager_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER API_MANAGER CASCADE';
        dbms_output.put_line('USER API_MANAGER DROPPED');
    ELSE
        dbms_output.put_line('USER API_MANAGER DOES NOT EXIST');
    END IF;
    
    -- Drop APP_USER if already exists
    IF v_api_user_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER APP_USER CASCADE';
        dbms_output.put_line('USER APP_USER DROPPED');
    ELSE
        dbms_output.put_line('USER APP_USER DOES NOT EXIST');
    END IF;
    
   -- Create the user with a password that contains special characters, enclosed in double quotes
    EXECUTE IMMEDIATE 'CREATE USER API_MANAGER IDENTIFIED BY "dbms#APIMANAGER1@ApiGateway"';
    -- Grant Basic connect permission
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO API_MANAGER';    
    -- Grant Read Access to all the tables
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_usage_tracking TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_pricing_model TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_requests TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_api TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_api_access TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON api_performance_metrics TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON request_count TO API_MANAGER';
    -- Grant Full access to Package insert_into_api_and_api_access_pkg
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON manage_api_pkg TO API_MANAGER';
    -- Grant quota on tablespace
    EXECUTE IMMEDIATE 'ALTER USER API_MANAGER QUOTA 5M ON USERS';
    
    COMMIT;
    dbms_output.put_line('User API_MANAGER created and granted the specified privileges successfully.');
    
    -- Create the user with a password that contains special characters, enclosed in double quotes
    EXECUTE IMMEDIATE 'CREATE USER APP_USER IDENTIFIED BY "dbms#AppUser1@ApiGateway"';
    -- Grant Basic connect permission
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO APP_USER';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON set_user_id TO APP_USER';
    -- Grant Read Access to all specific tables
    EXECUTE IMMEDIATE 'GRANT SELECT ON user_subscription_billing_view TO APP_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_api TO APP_USER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON vw_pricing_model TO APP_USER';
    -- Grant execute privileges on procedures
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON api_request_pkg TO APP_USER';  
    -- Grant quota on tablespace 
    EXECUTE IMMEDIATE 'ALTER USER APP_USER QUOTA 5M ON REQUESTS'; 

    COMMIT;
    dbms_output.put_line('User APP_USER created and granted the specified privileges successfully.');
    
 EXCEPTION
   WHEN OTHERS THEN
         dbms_output.put_line('An error occurred while creating users, try again');
END;
/