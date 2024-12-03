SET SERVEROUTPUT ON;

-- Drop all foreign key constraints
DECLARE
    sql_statement VARCHAR2(4000);
BEGIN
    FOR c IN (
        SELECT
            table_name,
            constraint_name
        FROM
            user_constraints
        WHERE
            constraint_type = 'R' -- Foreign Key
    ) LOOP
        BEGIN
            sql_statement := 'ALTER TABLE '
                             || c.table_name
                             || ' DROP CONSTRAINT '
                             || c.constraint_name;
            EXECUTE IMMEDIATE sql_statement;
            dbms_output.put_line('Dropped constraint '
                                 || c.constraint_name
                                 || ' from table '
                                 || c.table_name);
<<<<<<< HEAD

=======
>>>>>>> 4bd53756ba0e5056f22d73c209145bb148daa4b0
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line('Failed to drop constraint '
                                     || c.constraint_name
                                     || ': '
                                     || sqlerrm);
        END;
    END LOOP;
END;
/

-- Drop all tables
BEGIN
    FOR t IN (
        SELECT
            table_name
        FROM
            user_tables
        WHERE
            table_name IN ( 'API_USERS', 'API', 'API_ACCESS', 'PRICING_MODEL', 'REQUESTS',
                            'USAGE_TRACKING', 'SUBSCRIPTION', 'BILLING' )
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE '
                              || t.table_name
                              || ' CASCADE CONSTRAINTS';
            dbms_output.put_line('Dropped table: ' || t.table_name);
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line('Failed to drop table '
                                     || t.table_name
                                     || ': '
                                     || sqlerrm);
        END;
    END LOOP;
END;
/

-- Drop all user-defined sequences
BEGIN
    FOR s IN (
        SELECT
            sequence_name
        FROM
            user_sequences
        WHERE
            sequence_name NOT LIKE 'ISEQ$$%'
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
            dbms_output.put_line('Dropped sequence: ' || s.sequence_name);
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line('Failed to drop sequence: '
                                     || s.sequence_name
                                     || ': '
                                     || sqlerrm);
        END;
    END LOOP;
END;
/

BEGIN
    dbms_output.put_line('All constraints, tables, and sequences dropped successfully.');
END;
/

-- Create sequence for API_USERS table
CREATE SEQUENCE api_users_seq START WITH 100 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Create API_USERS table
CREATE TABLE api_users (
    user_id             NUMBER(9) DEFAULT api_users_seq.NEXTVAL NOT NULL,
    username            VARCHAR2(25) NOT NULL,
    first_name          VARCHAR2(50) NOT NULL,
    last_name           VARCHAR2(50) NOT NULL,
    user_role           VARCHAR2(10) NOT NULL,
    created_at          DATE DEFAULT sysdate NOT NULL,
    api_token           VARCHAR2(20) NOT NULL,
    api_token_startdate DATE NOT NULL,
    api_token_enddate   DATE NOT NULL,
    CONSTRAINT users_pk PRIMARY KEY ( user_id ),
    CONSTRAINT users_chk_api_token_dates CHECK ( api_token_startdate < api_token_enddate ),
    CONSTRAINT users_username_un UNIQUE ( username ),
    CONSTRAINT users_api_token_un UNIQUE ( api_token ),
    CONSTRAINT users_chk_role CHECK ( user_role IN ( 'General', 'Student' ) )
);

-- Create sequence for API table
CREATE SEQUENCE api_seq START WITH 200 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Create API table
CREATE TABLE api(
    api_id      NUMBER(9) DEFAULT api_seq.NEXTVAL NOT NULL,
    name        VARCHAR2(50) NOT NULL,
    description VARCHAR2(100),
    CONSTRAINT api_pk PRIMARY KEY ( api_id )
);

-- Create sequence for API_ACCESS table
CREATE SEQUENCE api_access_seq START WITH 300 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Create API_ACCESS table
CREATE TABLE api_access (
    access_id        NUMBER(9) DEFAULT api_access_seq.NEXTVAL NOT NULL,
    access_generated DATE DEFAULT sysdate NOT NULL,
    is_active        CHAR(1) NOT NULL,
    user_id          NUMBER(9) NOT NULL,
    api_id           NUMBER(9) NOT NULL,
    CONSTRAINT api_access_pk PRIMARY KEY ( access_id ),
    CONSTRAINT api_access_chk_is_active CHECK ( is_active IN ('Y', 'N') )
);

-- Create sequence for PRICING_MODEL table
CREATE SEQUENCE pricing_model_seq START WITH 400 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Create PRICING_MODEL table
CREATE TABLE pricing_model (
    model_id      NUMBER(9) DEFAULT pricing_model_seq.NEXTVAL NOT NULL,
    model_type    VARCHAR2(20) NOT NULL,
    rate          NUMBER(5, 3) NOT NULL,
    request_limit NUMBER(4),
    api_id        NUMBER(9),
    CONSTRAINT pricing_model_pk PRIMARY KEY ( model_id ),
    CONSTRAINT pricing_model_chk_type CHECK ( model_type IN ( 'pay_per_request', 'subscription' ) ),
    CONSTRAINT pricing_model_chk_limit CHECK ( request_limit > 0 ),
    CONSTRAINT pricing_model_chk_rate CHECK ( rate > 0 )
);

-- Create sequence for REQUESTS table    
CREATE SEQUENCE requests_seq START WITH 500 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Create REQUESTS table
CREATE TABLE requests (
    request_id    NUMBER(9) DEFAULT requests_seq.NEXTVAL NOT NULL,
    req_timestamp DATE DEFAULT sysdate NOT NULL,
    response_time NUMBER(5, 2),
    status        VARCHAR2(10) NOT NULL,
    request_body  VARCHAR2(20) NOT NULL,
    response_body VARCHAR2(20) NOT NULL,
    access_id     NUMBER(9) NOT NULL,
    CONSTRAINT requests_pk PRIMARY KEY ( request_id ),
    CONSTRAINT requests_chk_response_time CHECK ( response_time >= 0 ),
    CONSTRAINT requests_chk_status CHECK ( status IN ('Success', 'Failure') )
);

-- Create sequence for USAGE_TRACKING table
CREATE SEQUENCE usage_tracking_seq START WITH 600 INCREMENT BY 1 NOMAXVALUE NOCYCLE;

-- Creating USAGE_TRACKING table
CREATE TABLE usage_tracking (
    tracking_id    NUMBER(9) DEFAULT usage_tracking_seq.NEXTVAL NOT NULL,
    request_count  NUMBER(4) NOT NULL,
    last_updated   DATE DEFAULT sysdate NOT NULL,
    limit_exceeded CHAR(1) NOT NULL,
    api_id         NUMBER(9) NOT NULL,
    user_id        NUMBER(9) NOT NULL,
    CONSTRAINT usage_tracking_pk PRIMARY KEY ( tracking_id ),
    CONSTRAINT usage_tracking_chk_limit_exceeded CHECK ( limit_exceeded IN ('Y', 'N') )
);

-- Create sequence for SUBSCRIPTION table
CREATE SEQUENCE subscription_seq START WITH 700 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Create SUBSCRIPTION table
CREATE TABLE subscription (
    subscription_id   NUMBER(9) DEFAULT subscription_seq.NEXTVAL NOT NULL,
    start_date        DATE DEFAULT sysdate NOT NULL,
    end_date          DATE,
    status            VARCHAR2(10) NOT NULL,
    discount          NUMBER(5, 3) DEFAULT 0.00 NOT NULL,
    user_id           NUMBER(9) NOT NULL,
    pricing_model_id  NUMBER(9) NOT NULL,
    usage_tracking_id NUMBER(9) NOT NULL,
    CONSTRAINT subscription_pk PRIMARY KEY ( subscription_id ),
    CONSTRAINT subscription_chk_sub_date CHECK ( start_date < end_date ),
    CONSTRAINT subscription_chk_status CHECK ( status IN ('Active', 'Expired') )
);

-- Create sequence for BILLING table
CREATE SEQUENCE billing_seq START WITH 800 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
    
-- Creating BILLING table
CREATE TABLE billing (
    billing_id      NUMBER(9) DEFAULT billing_seq.NEXTVAL NOT NULL,
    billing_date    DATE DEFAULT sysdate NOT NULL,
    total_amount    FLOAT(2) NOT NULL,
    subscription_id NUMBER(9) NOT NULL,
    CONSTRAINT billing_pk PRIMARY KEY ( billing_id ),
    CONSTRAINT billing_chk_total_amount CHECK ( total_amount >= 0 )
);

ALTER TABLE api_access
    ADD CONSTRAINT api_access_api_fk FOREIGN KEY ( api_id )
        REFERENCES api ( api_id )
        ON DELETE CASCADE;

ALTER TABLE api_access
    ADD CONSTRAINT api_access_users_fk FOREIGN KEY ( user_id )
        REFERENCES api_users ( user_id )
        ON DELETE CASCADE;
        
ALTER TABLE pricing_model
    ADD CONSTRAINT pricing_model_api_fk FOREIGN KEY ( api_id )
        REFERENCES api ( api_id )
        ON DELETE CASCADE;  
       
ALTER TABLE requests
    ADD CONSTRAINT requests_access_fk FOREIGN KEY ( access_id )
        REFERENCES api_access ( access_id )
        ON DELETE CASCADE;
        
ALTER TABLE usage_tracking
    ADD CONSTRAINT usage_tracking_api_fk FOREIGN KEY ( api_id )
        REFERENCES api ( api_id )
        ON DELETE SET NULL;

ALTER TABLE usage_tracking
    ADD CONSTRAINT usage_tracking_users_fk FOREIGN KEY ( user_id )
        REFERENCES api_users ( user_id )
        ON DELETE SET NULL;   
        
ALTER TABLE subscription
    ADD CONSTRAINT subscription_pricing_model_fk FOREIGN KEY ( pricing_model_id )
        REFERENCES pricing_model ( model_id )
        ON DELETE SET NULL;

ALTER TABLE subscription
    ADD CONSTRAINT subscription_usage_tracking_fk FOREIGN KEY ( usage_tracking_id )
        REFERENCES usage_tracking ( tracking_id )
        ON DELETE SET NULL;

ALTER TABLE subscription
    ADD CONSTRAINT subscription_users_fk FOREIGN KEY ( user_id )
        REFERENCES api_users ( user_id )
        ON DELETE SET NULL;        
    
ALTER TABLE billing
    ADD CONSTRAINT billing_subscription_fk FOREIGN KEY ( subscription_id )
        REFERENCES subscription ( subscription_id )
        ON DELETE SET NULL;    
        
BEGIN
    dbms_output.put_line('All tables created successfully');
END;
/

COMMIT;        
