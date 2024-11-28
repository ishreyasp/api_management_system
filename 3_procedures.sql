-- Insert Packages
CREATE OR REPLACE PACKAGE api_request_pkg AS  
    PROCEDURE sp_api_request (
        p_api_id        IN api.api_id%TYPE,
        p_user_id       IN api_users.user_id%TYPE,
        p_request_body  IN requests.request_body%TYPE,
        p_response_body IN requests.response_body%TYPE,
        p_status        IN requests.status%TYPE,
        p_message       OUT VARCHAR2
    );

END api_request_pkg;
/

CREATE OR REPLACE PACKAGE BODY api_request_pkg AS

    PROCEDURE sp_api_request (
        p_api_id        IN api.api_id%TYPE,
        p_user_id       IN api_users.user_id%TYPE,
        p_request_body  IN requests.request_body%TYPE,
        p_response_body IN requests.response_body%TYPE,
        p_status        IN requests.status%TYPE,
        p_message       OUT VARCHAR2
    )
    AS
    -- Variable declarations
    v_access_id          api_access.access_id%TYPE;
    v_is_active          api_access.is_active%TYPE;
    v_token_enddate      api_users.api_token_enddate%TYPE;
    v_response_time      requests.response_time%TYPE;
    v_is_limit_exceeded  usage_tracking.limit_exceeded%TYPE;

    -- Custom exceptions
    e_token_expired           EXCEPTION;
    e_no_api_access           EXCEPTION;
    e_request_limit_exceeded  EXCEPTION;
    
    BEGIN
        -- Fetch access_id and is_active from api_access table
        SELECT access_id, is_active
        INTO v_access_id, v_is_active
        FROM api_access
        WHERE api_id = p_api_id
            AND user_id = p_user_id;
        
        -- Fetch limit_exceeded from usage_tracking table
        BEGIN
            SELECT limit_exceeded
            INTO v_is_limit_exceeded
            FROM usage_tracking
            WHERE api_id = p_api_id
                AND user_id = p_user_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_is_limit_exceeded := 'N';
        END;

        -- Fetch api_token_enddate from users table
        SELECT api_token_enddate
        INTO v_token_enddate
        FROM api_users
        WHERE user_id = p_user_id;

        -- Check if the API token has expired
        IF v_token_enddate < SYSDATE THEN
            RAISE e_token_expired;
        END IF;

        -- Check if the API access is active
        IF v_is_active = 'N' THEN
            RAISE e_no_api_access;
        END IF;

        -- Check if request limit is exceeded
        IF UPPER(v_is_limit_exceeded) = 'Y' THEN
            RAISE e_request_limit_exceeded;
        END IF;

        -- Generate a random response time between 0.1 and 1 second
        v_response_time := ROUND(DBMS_RANDOM.VALUE(0.1, 1), 2);

        -- Insert a record into the requests table
        INSERT INTO requests (
            response_time,
            status,
            request_body,
            response_body,
            access_id
        ) VALUES (
            v_response_time,
            p_status,
            p_request_body,
            p_response_body,
            v_access_id
        );

        -- Commit the transaction
        COMMIT;
    
        p_message := 'API request successful.';

    EXCEPTION
        WHEN e_token_expired THEN
            p_message := 'API access denied: Token has expired.';
            ROLLBACK;

        WHEN e_no_api_access THEN
            p_message := 'API access denied: Access is inactive.';
            ROLLBACK;

        WHEN e_request_limit_exceeded THEN
            p_message := 'API access denied: API request limit reached.';
            ROLLBACK;

        WHEN NO_DATA_FOUND THEN
            p_message := 'API access or user record not found.';
            ROLLBACK;

        WHEN OTHERS THEN
            p_message := 'An unexpected error occurred.';
            ROLLBACK;
    END sp_api_request;
    
END api_request_pkg;
/