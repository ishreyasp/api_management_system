SET SERVEROUTPUT ON;
 
DECLARE 
    user_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO user_exists
    FROM all_users
    WHERE username = 'API_MANAGER';
 
    -- Drop the User if the user already Exists 
    IF user_exists > 0 THEN 
        EXECUTE IMMEDIATE 'DROP USER API_MANAGER CASCADE';
        DBMS_OUTPUT.PUT_LINE('USER API_MANAGER DROPPED');
    END IF;
 
    -- Create the user with a password that contains special characters, enclosed in double quotes
    EXECUTE IMMEDIATE 'CREATE USER API_MANAGER IDENTIFIED BY "dbms#APIMANAGER1@ApiGateway"';
    DBMS_OUTPUT.PUT_LINE('USER API_MANAGER CREATED');
 
    -- Grant Basic connect permission
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO API_MANAGER';    
    -- Grant Read Access to all the tables
    EXECUTE IMMEDIATE 'GRANT SELECT ON SUBSCRIPTION TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON USAGE_TRACKING TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON PRICING_MODEL TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON REQUESTS TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON API TO API_MANAGER';
    EXECUTE IMMEDIATE 'GRANT SELECT ON API_ACCESS TO API_MANAGER';
    -- Grant Full access to API table (can add, modify, deprecate APIs)
    EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON API TO API_MANAGER';
 
    -- Full access to API_ACCESS table (can grant/revoke user access to APIs)
    EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON API_ACCESS TO API_MANAGER';
    -- Grant quota on tablespace (necessary for INSERT operations)
    EXECUTE IMMEDIATE 'ALTER USER API_MANAGER QUOTA 5M ON USERS';
    DBMS_OUTPUT.PUT_LINE('User API_MANAGER created and granted the specified privileges successfully.');
 
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred, try again');
END;
/