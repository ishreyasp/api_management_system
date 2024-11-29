SET SERVEROUTPUT ON;

-- Create APP_ADMIN 
DECLARE
    v_user_exists    NUMBER;
    v_user_connected NUMBER;
BEGIN
    -- Check if the user exists
    SELECT COUNT(*)
    INTO v_user_exists
    FROM all_users
    WHERE username = 'APP_ADMIN';
    
    -- Check if the user is already connected
    SELECT COUNT(*)
    INTO v_user_connected
    FROM v$session
    WHERE username = 'APP_ADMIN';

    -- Drop the user if it exists and not connected
    IF v_user_exists > 0 THEN
        IF v_user_connected = 0 THEN
            EXECUTE IMMEDIATE 'DROP USER APP_ADMIN CASCADE';
            dbms_output.put_line('User APP_ADMIN dropped successfully.');
        ELSE
            dbms_output.put_line('User APP_ADMIN is already connected. Cannot drop user.');
            RETURN;
        END IF;
    ELSE
        dbms_output.put_line('User APP_ADMIN does not exist.');
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
    -- Grant privileges for procedure management
    EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO APP_ADMIN';
    -- Grant privileges for trigger management
    EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO APP_ADMIN';
    dbms_output.put_line('User APP_ADMIN created and granted the specified privileges successfully.');
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Something went wrong! Try again.');
END;