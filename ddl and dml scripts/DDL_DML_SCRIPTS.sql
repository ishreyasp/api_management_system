
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


-- Creating Usage Tracking Model

DECLARE
    Table_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO Table_exists
    FROM user_tables
    WHERE table_name = 'USAGE_TRACKING';
    
    -- Drop if the table USAGE_TRACKING exists
    IF Table_exists > 0 THEN 
        EXECUTE IMMEDIATE 'DROP TABLE USAGE_TRACKING';
        DBMS_OUTPUT.PUT_LINE('Table USAGE_TRACKING dropped successfully.');
    END IF;
    
    -- Create USAGE_TRACKING Table
    EXECUTE IMMEDIATE 'CREATE TABLE USAGE_TRACKING (
        tracking_id                  NUMBER NOT NULL,
        request_count                INTEGER NOT NULL,
        last_updated                 DATE NOT NULL,
        limit_exceeded               VARCHAR2(25) NOT NULL,
        api_id                       NUMBER,
        users_id                     NUMBER,
        subscription_id              NUMBER NOT NULL,
        CONSTRAINT usage_tracking_pk PRIMARY KEY (tracking_id),
        CONSTRAINT usage_tracking_subscription_fk FOREIGN KEY (subscription_id)
            REFERENCES subscription (subscription_id),
        CONSTRAINT usage_tracking_users_fk FOREIGN KEY (users_id)
            REFERENCES users (user_id)
    )';
    
    DBMS_OUTPUT.PUT_LINE('USAGE_TRACKING table created successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred:');
END;
/


--Insert into Usage Tracking Model
BEGIN
INSERT INTO  USAGE_TRACKING (tracking_id, request_count,last_updated ,limit_exceeded, api_id,users_id, subscription_id)
VALUES (1, 3, SYSDATE, 'YES',1, 1, 1 );
INSERT INTO  USAGE_TRACKING (tracking_id, request_count,last_updated ,limit_exceeded, api_id,users_id, subscription_id)
VALUES (2, 5, SYSDATE, 'NO',2, 2, 2 );
INSERT INTO  USAGE_TRACKING (tracking_id, request_count,last_updated ,limit_exceeded, api_id,users_id, subscription_id)
VALUES (3, 6, SYSDATE, 'YES',3, 3, 3 );
INSERT INTO  USAGE_TRACKING (tracking_id, request_count,last_updated ,limit_exceeded, api_id,users_id, subscription_id)
VALUES (4, 8, SYSDATE, 'NO',4, 4, 4 );
INSERT INTO  USAGE_TRACKING (tracking_id, request_count,last_updated ,limit_exceeded, api_id,users_id, subscription_id)
VALUES (5, 9, SYSDATE, 'YES',5, 5, 5 );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dummy records inserted successfully in Usage_Tracking table.');
END;
/



-- Creating Table Billing

DECLARE
    Table_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO Table_exists
    FROM user_tables
    WHERE table_name = 'BILLING';

 -- Drop if the table USAGE_TRACKING exists
    IF Table_exists > 0 THEN 
        EXECUTE IMMEDIATE 'DROP TABLE BILLING';
        DBMS_OUTPUT.PUT_LINE('Table BILLING dropped successfully.');
    END IF;

-- Create Table Billing
 
EXECUTE IMMEDIATE 'CREATE TABLE billing (
    billing_id                   NUMBER NOT NULL,
    billing_date                 DATE NOT NULL,
    total_amount                 FLOAT(2) NOT NULL,
    subscription_id              NUMBER,
    CONSTRAINT chk_bill_amt CHECK ( total_amount >= 0 ),
    CONSTRAINT billing_pk PRIMARY KEY ( billing_id ),
    CONSTRAINT billing_subscription_fk FOREIGN KEY ( subscription_id )
        REFERENCES subscription ( subscription_id )
)';

    DBMS_OUTPUT.PUT_LINE('BILLING created successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred, try again.');
END;
/

--Inserting data into table Billing
BEGIN

INSERT INTO BILLING (billing_id,  billing_date, total_amount, subscription_id)
VALUES (1, SYSDATE, 1500, 1);
INSERT INTO BILLING (billing_id,  billing_date, total_amount, subscription_id)
VALUES (2, SYSDATE, 1200, 2);
INSERT INTO BILLING (billing_id,  billing_date, total_amount, subscription_id)
VALUES (3, SYSDATE, 2000, 3);
INSERT INTO BILLING (billing_id,  billing_date, total_amount, subscription_id)
VALUES (4, SYSDATE, 2300, 4);
INSERT INTO BILLING (billing_id,  billing_date, total_amount, subscription_id)
VALUES (5, SYSDATE, 2500, 5);

COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dummy records inserted successfully in Billing Model table.');
END;
/


-- Create Subscription Model 

DECLARE
    Table_exists NUMBER;
BEGIN 
    SELECT COUNT(*) INTO Table_exists
    FROM user_tables
    WHERE table_name = 'SUBSCRIPTION';

    -- Drop the table if it already exists
    IF Table_exists > 0 THEN 
        EXECUTE IMMEDIATE 'DROP TABLE SUBSCRIPTION';
        DBMS_OUTPUT.PUT_LINE('Table SUBSCRIPTION dropped successfully.');
    END IF; 

    -- Create the SUBSCRIPTION table
    EXECUTE IMMEDIATE 'CREATE TABLE SUBSCRIPTION (
        subscription_id            NUMBER NOT NULL,
        start_date                 DATE,
        end_date                   DATE,
        status                     VARCHAR2(25) NOT NULL,
        discount                   NUMBER(5, 3) DEFAULT 0.00 NOT NULL,
        users_id                   NUMBER,
        pricing_model_id           NUMBER,
        usage_tracking_id          NUMBER NOT NULL,
        CONSTRAINT chk_sub_date CHECK (start_date < end_date),
        CONSTRAINT subscription_pk PRIMARY KEY (subscription_id),
        CONSTRAINT subscription_pricing_model_fk FOREIGN KEY (pricing_model_id)
            REFERENCES pricing_model (model_id),
        CONSTRAINT subscription_users_fk FOREIGN KEY (users_id)
            REFERENCES users (user_id),
            CONSTRAINT subscription_usage_tracking_fk FOREIGN KEY ( usage_id )
        REFERENCES usage_tracking ( tracking_id );
    )';

    DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION created successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred, try again.');
END;
/


--Inserting data into table Subscription
BEGIN

INSERT INTO SUBSCRIPTION (subscription_id,  start_date, end_date, status, discount, users_id, pricing_model_id  , usage_tracking_id)
VALUES (1, SYSDATE, ADD_MONTHS(SYSDATE , 1), 'ACTIVE' , 0 , 1, 1, 1);
INSERT INTO SUBSCRIPTION (subscription_id,  start_date, end_date, status, discount, users_id ,pricing_model_id  , usage_tracking_id)
VALUES (2, SYSDATE, ADD_MONTHS(SYSDATE , 1), 'ACTIVE' , 20 , 2, 2, 2);
INSERT INTO SUBSCRIPTION (subscription_id,  start_date, end_date, status, discount,users_id,  pricing_model_id ,  usage_tracking_id)
VALUES (3, SYSDATE, ADD_MONTHS(SYSDATE , 1), 'ACTIVE' , 0 , 3, 3, 3);
INSERT INTO SUBSCRIPTION (subscription_id,  start_date, end_date, status, discount,users_id,  pricing_model_id ,  usage_tracking_id)
VALUES (4, SYSDATE, ADD_MONTHS(SYSDATE , 1), 'INACTIVE' , 20 , 4, 4, 4);
INSERT INTO SUBSCRIPTION (subscription_id,  start_date, end_date, status, discount,users_id,  pricing_model_id ,  usage_tracking_id)
VALUES (5, SYSDATE, ADD_MONTHS(SYSDATE , 1), 'INACTIVE' , 0 , 5, 5, 5);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dummy records inserted successfully in Subscription Model table.');
END;
/



