SET SERVEROUTPUT ON;

-- Create APP_ADMIN 
DECLARE
    user_exists    NUMBER;
    user_connected NUMBER;
BEGIN
    -- Check if the user exists
    SELECT
        COUNT(*)
    INTO user_exists
    FROM
        all_users
    WHERE
        username = 'APP_ADMIN';
    
    -- Check if the user is connected
    SELECT
        COUNT(*)
    INTO user_connected
    FROM
        v$session
    WHERE
        username = 'APP_ADMIN';

    -- Drop the user if it exists and not connected
    IF user_exists > 0 THEN
        IF user_connected = 0 THEN
            EXECUTE IMMEDIATE 'DROP USER APP_ADMIN CASCADE';
            dbms_output.put_line('User APP_ADMIN dropped successfully.');
        ELSE
            dbms_output.put_line('User APP_ADMIN is already connected, Cannot drop user');
            RETURN;
        END IF;
    ELSE
        dbms_output.put_line('User APP_ADMIN does not exist.');
    END IF;
    
    -- Create the user with a password that contains special characters, enclosed in double quotes
    EXECUTE IMMEDIATE 'CREATE USER APP_ADMIN IDENTIFIED BY "dbms#Admin1@ApiGateway"';
    
    -- Grant Privileges
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, CREATE TABLE, CREATE VIEW, CREATE USER, CREATE SESSION, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER, CREATE ANY CONTEXT, ALTER USER, DROP USER TO APP_ADMIN WITH ADMIN OPTION'
    ;
    
    -- Grant execute privileges on dbms_session
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_SESSION TO APP_ADMIN';
    
    -- Grant select privileges on dba_users
    EXECUTE IMMEDIATE 'GRANT SELECT ON dba_users TO APP_ADMIN';

    -- Grant quota on the USERS tablespace
    EXECUTE IMMEDIATE 'ALTER USER APP_ADMIN QUOTA 15M ON DATA';
    dbms_output.put_line('User APP_ADMIN created and granted the specified privileges successfully.');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error: ' || sqlerrm);
        COMMIT;
END;
/