
SET SERVEROUTPUT ON;

-- Create USERS table
DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'USERS';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE "USERS"';
        DBMS_OUTPUT.PUT_LINE('Table USERS dropped successfully.');
    END IF;

    -- Create the table 
    EXECUTE IMMEDIATE 'CREATE TABLE "USERS" (
        "USER_ID" NUMBER NOT NULL,
        "USERNAME" VARCHAR2(25) NOT NULL,
        "FIRST_NAME" VARCHAR2(255) NOT NULL,
        "LAST_NAME" VARCHAR2(255) NOT NULL,
        "ROLE" VARCHAR2(25) NOT NULL,
        "CREATED_AT" DATE DEFAULT SYSDATE,
        "API_TOKEN" VARCHAR2(20) NOT NULL,
        "API_TOKEN_STARTDATE" DATE NOT NULL,
        "API_TOKEN_ENDDATE" DATE NOT NULL,
        CONSTRAINT "users_PK" PRIMARY KEY ("USER_ID"),
        CONSTRAINT "chk_api_token_dates" CHECK ("API_TOKEN_STARTDATE" < "API_TOKEN_ENDDATE"),
        CONSTRAINT "users_username_UN" UNIQUE ("USERNAME"),
        CONSTRAINT "users_api_token_UN" UNIQUE ("API_TOKEN"),
        CONSTRAINT "chk_role" CHECK ("ROLE" IN (''General'', ''Student''))
    )';
    DBMS_OUTPUT.PUT_LINE('Table USERS created successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred, try again.');
        
END;
/

-- Insert records for USERS table
BEGIN
    INSERT INTO USERS (USER_ID, USERNAME, FIRST_NAME, LAST_NAME, ROLE, CREATED_AT, API_TOKEN, API_TOKEN_STARTDATE, API_TOKEN_ENDDATE)
    VALUES (1, 'john_doe', 'John', 'Doe', 'General', SYSDATE, 'token123', DATE '2024-01-01', DATE '2024-12-31');

    INSERT INTO USERS (USER_ID, USERNAME, FIRST_NAME, LAST_NAME, ROLE, CREATED_AT, API_TOKEN, API_TOKEN_STARTDATE, API_TOKEN_ENDDATE)
    VALUES (2, 'jane_smith', 'Jane', 'Smith', 'Student', SYSDATE, 'token456', DATE '2024-02-01', DATE '2024-11-30');

    INSERT INTO USERS (USER_ID, USERNAME, FIRST_NAME, LAST_NAME, ROLE, CREATED_AT, API_TOKEN, API_TOKEN_STARTDATE, API_TOKEN_ENDDATE)
    VALUES (3, 'michael_brown', 'Michael', 'Brown', 'General', SYSDATE, 'token789', DATE '2024-03-01', DATE '2024-10-31');
    
    INSERT INTO "USERS" ("USER_ID", "USERNAME", "FIRST_NAME", "LAST_NAME", "ROLE", "CREATED_AT", "API_TOKEN", "API_TOKEN_STARTDATE", "API_TOKEN_ENDDATE")
    VALUES (4, 'cjones', 'Carol', 'Jones', 'Student', SYSDATE, 'TOKEN44556', TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-09-30', 'YYYY-MM-DD'));

    INSERT INTO "USERS" ("USER_ID", "USERNAME", "FIRST_NAME", "LAST_NAME", "ROLE", "CREATED_AT", "API_TOKEN", "API_TOKEN_STARTDATE", "API_TOKEN_ENDDATE")
    VALUES (5, 'dlee', 'David', 'Lee', 'General', SYSDATE, 'TOKEN78901', TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-08-31', 'YYYY-MM-DD'));

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dummy records inserted successfully in users table.');
END;
/

-- Create PRICING_MODEL table
DECLARE
    table_exists NUMBER;
BEGIN
    -- Check if the table exists
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'PRICING_MODEL';

    -- If the table exists, drop it
    IF table_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE PRICING_MODEL';
        DBMS_OUTPUT.PUT_LINE('Table PRICING_MODEL dropped successfully.');
    END IF;

    -- Create the table 
    EXECUTE IMMEDIATE 'CREATE TABLE PRICING_MODEL ( 
        model_id      NUMBER NOT NULL,
        model_type    VARCHAR2(255) NOT NULL,
        rate          NUMBER(5, 3) NOT NULL,
        request_limit INTEGER,
        api_api_id    NUMBER,
        CONSTRAINT chk_modeltype CHECK ( model_type IN ( ''pay_per_request'', ''subscription'' ) ),
        CONSTRAINT limit_constraint CHECK ( request_limit > 0 ),
        CONSTRAINT rate_constraint CHECK ( rate >= 0 ),
        CONSTRAINT pricing_model_pk PRIMARY KEY ( model_id )
    )';
    DBMS_OUTPUT.PUT_LINE('Table PRICING_MODEL created successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred, try again.');
        
END;
/

-- Insert records for PRICING_MODEL table
BEGIN
    
    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (1, 'pay_per_request', 0.500, 1000, 101);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (2, 'subscription', 15.000, NULL, 102);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (3, 'pay_per_request', 1.250, 500, 103);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (4, 'subscription', 25.000, NULL, 104);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (5, 'pay_per_request', 0.750, 2000, 105);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dummy records inserted successfully in pricing_model table.');
END;
/