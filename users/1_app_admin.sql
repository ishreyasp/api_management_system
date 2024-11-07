SET SERVEROUTPUT ON;

-- Create APP_ADMIN 
DECLARE
    user_exists NUMBER;
BEGIN
    -- Check if the user exists
    SELECT COUNT(*)
    INTO user_exists
    FROM all_users
    WHERE username = 'APP_ADMIN';

    -- Drop the user if it exists
    IF user_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER APP_ADMIN CASCADE';
        DBMS_OUTPUT.PUT_LINE('User APP_ADMIN dropped successfully.');
    END IF;
    
    -- Create the user with a password that contains special characters, enclosed in double quotes
    EXECUTE IMMEDIATE 'CREATE USER APP_ADMIN IDENTIFIED BY "dbms#Admin1@ApiGateway"';
    -- Grant basic system privileges
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO APP_ADMIN WITH ADMIN OPTION';
    -- Grant object creation privileges
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW, CREATE TABLE, CREATE SEQUENCE, CREATE SYNONYM TO APP_ADMIN';
    -- Grant user management privileges
    EXECUTE IMMEDIATE 'GRANT CREATE USER, ALTER USER, DROP USER TO APP_ADMIN';
    -- Grant unlimited storage quota on the USERS tablespace
    EXECUTE IMMEDIATE 'ALTER USER APP_ADMIN QUOTA 15M ON USERS';
    -- Grant execute privileges on dbms_session
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_SESSION TO APP_ADMIN';
    -- Grant privileges for context management
    EXECUTE IMMEDIATE 'GRANT CREATE ANY CONTEXT TO APP_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO APP_ADMIN';
    DBMS_OUTPUT.PUT_LINE('User APP_ADMIN created and granted the specified privileges successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Something went wrong! Try again.');
END;