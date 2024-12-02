SET SERVEROUTPUT ON;

DECLARE
    api_manager_exists NUMBER;
    api_user_exists    NUMBER;
BEGIN

    ------------- Check if Users exists --------------

    -- Check if API_MANAGER already exists
    SELECT
        COUNT(*)
    INTO api_manager_exists
    FROM
        dba_users
    WHERE
        username = 'API_MANAGER';
    
    -- Check if BASIC_USER already exists
    SELECT
        COUNT(*)
    INTO api_user_exists
    FROM
        dba_users
    WHERE
        username = 'BASIC_USER';
    
    ---------- Drop if Users already exists ----------
    
    -- Drop API_MANAGER if already exists
    IF api_manager_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER API_MANAGER CASCADE';
        dbms_output.put_line('USER API_MANAGER DROPPED');
    ELSE
        dbms_output.put_line('USER API_MANAGER DOES NOT EXIST');
    END IF;
    
    -- Drop BASIC_USER if already exists
    IF api_user_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER BASIC_USER CASCADE';
        dbms_output.put_line('USER BASIC_USER DROPPED');
    ELSE
        dbms_output.put_line('USER BASIC_USER DOES NOT EXIST');
    END IF;
        
    --------- Create users & Grant Privileges ---------
    
    -- Create API_MANAGER
    EXECUTE IMMEDIATE 'CREATE USER API_MANAGER IDENTIFIED BY "dbms#ApiManager1@ApiGateway"';
    
    -- Grant basic connect privileges
    EXECUTE IMMEDIATE 'GRANT CONNECT, CREATE SESSION TO API_MANAGER';  
    
    -- Grant execute privileges on procedures

    COMMIT;
    dbms_output.put_line('User API_MANAGER created and granted the specified privileges successfully.');
    
    
    -- Create API_USER
    EXECUTE IMMEDIATE 'CREATE USER BASIC_USER IDENTIFIED BY "dbms#BasicUser1@ApiGateway"';
    
    -- Grant basic connect privileges
    EXECUTE IMMEDIATE 'GRANT CONNECT, CREATE SESSION TO BASIC_USER';  
    
    -- Grant execute privileges on procedures

    COMMIT;
    dbms_output.put_line('User BASIC_USER created and granted the specified privileges successfully.');
END;
/