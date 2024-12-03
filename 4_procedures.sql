-- Insert Packages
CREATE OR REPLACE PACKAGE insert_into_api_management_system_pkg AS
    PROCEDURE sp_subscribe_user_to_api (
        p_username            IN api_users.username%TYPE,
        p_api_id              IN api.api_id%TYPE,
        p_pricing_model_id    IN pricing_model.model_id%TYPE,
        p_start_date          IN subscription.start_date%TYPE,
        p_end_date            IN subscription.end_date%TYPE,
        p_message             OUT VARCHAR2
    );
    
END insert_into_api_management_system_pkg;
/

CREATE OR REPLACE PACKAGE BODY insert_into_api_management_system_pkg AS

    PROCEDURE sp_subscribe_user_to_api (
        p_username            IN api_users.username%TYPE,
        p_api_id              IN api.api_id%TYPE,
        p_pricing_model_id    IN pricing_model.model_id%TYPE,
        p_start_date          IN subscription.start_date%TYPE,
        p_end_date            IN subscription.end_date%TYPE,
        p_message             OUT VARCHAR2
    )
    AS
    -- Variable declarations
    v_usage_tracking_id usage_tracking.tracking_id%TYPE;
    v_subscription_id   subscription.subscription_id%TYPE;
    v_user_role         api_users.user_role%TYPe;
    v_user_id           api_users.user_id%TYPE;
    v_discount          subscription.discount%TYPE;
    v_count             NUMBER;
    
    -- Custom exceptions
    e_user_not_found            EXCEPTION;
    e_api_not_found             EXCEPTION;
    e_pricing_model_not_found   EXCEPTION;
    BEGIN
        -- Ensure that the user exists and is valid
       IF NOT user_exists(p_username) THEN
            RAISE e_user_not_found;
        END IF;
        
        -- Get user id
        v_user_id := get_user_id(p_username);
        
        -- Ensure that the API exists and is valid
        IF NOT api_exists(p_api_id) THEN
            RAISE e_api_not_found;
        END IF;

        -- Ensure that the pricing model exists and is valid
        IF NOT pricing_model_exists(p_pricing_model_id, p_api_id) THEN
            RAISE e_pricing_model_not_found;
        END IF;
    
        -- Insert into Usage_Tracking table to create a tracking record for the user
        INSERT INTO usage_tracking (
            request_count, 
            last_updated, 
            limit_exceeded, 
            api_id, 
            user_id
        ) VALUES (
            0, 
            SYSDATE, 
            'N', 
            p_api_id, 
            v_user_id
        )
        RETURNING tracking_id INTO v_usage_tracking_id;
        
        -- If user role is Student then offer 20% discount
        v_discount := calculate_discount_pct(p_username);

        -- Insert into Subscription table
        INSERT INTO subscription (
            start_date, 
            end_date, 
            status, 
            discount, 
            user_id, 
            pricing_model_id, 
            usage_tracking_id
        ) VALUES (
            p_start_date, 
            p_end_date, 
            'Active', 
            v_discount, 
            v_user_id,  
            p_pricing_model_id, 
            v_usage_tracking_id
        )
        RETURNING subscription_id INTO v_subscription_id;

        -- Commit the transaction
        COMMIT;
        
        p_message := 'Subscription added successfully.';
        
    EXCEPTION
        WHEN e_user_not_found THEN
            p_message := 'User does not exist.';
            ROLLBACK;
            
        WHEN e_api_not_found THEN
            p_message := 'API does not exist.';
            ROLLBACK;
            
        WHEN e_pricing_model_not_found THEN
            p_message := 'Pricing model for the API does not exist.';
            ROLLBACK;
            
        WHEN NO_DATA_FOUND THEN
            p_message := 'API access or user record not found.';
            ROLLBACK;

        WHEN OTHERS THEN
            p_message := 'An unexpected error occurred.';
            ROLLBACK;
    END sp_subscribe_user_to_api;

END insert_into_api_management_system_pkg;     
/

CREATE OR REPLACE PACKAGE api_request_pkg AS  
    PROCEDURE sp_api_request (
        p_api_id        IN api.api_id%TYPE,
        p_username      IN api_users.username%TYPE,
        p_request_body  IN requests.request_body%TYPE,
        p_status        IN requests.status%TYPE,
        p_message       OUT VARCHAR2
    );

END api_request_pkg;
/

CREATE OR REPLACE PACKAGE BODY api_request_pkg AS

    PROCEDURE sp_api_request (
        p_api_id        IN api.api_id%TYPE,
        p_username      IN api_users.username%TYPE,
        p_request_body  IN requests.request_body%TYPE,
        p_status        IN requests.status%TYPE,
        p_message       OUT VARCHAR2
    )
    AS
    -- Variable declarations
    v_user_id               api_users.user_id%TYPE;
    v_access_id             api_access.access_id%TYPE;
    v_is_active             api_access.is_active%TYPE;
    v_token_enddate         api_users.api_token_enddate%TYPE;
    v_response_time         requests.response_time%TYPE;
    v_is_limit_exceeded     usage_tracking.limit_exceeded%TYPE;
    v_response_body         requests.response_body%TYPE;

    -- Custom exceptions
    e_token_expired           EXCEPTION;
    e_no_api_access           EXCEPTION;
    e_request_limit_exceeded  EXCEPTION;
    e_user_not_found          EXCEPTION;
    e_api_not_found           EXCEPTION;
    
    BEGIN
    
        -- Ensure that the user exists and is valid
        IF NOT user_exists(p_username) THEN
            RAISE e_user_not_found;
        END IF;
        
        -- Get user id
        v_user_id := get_user_id(p_username);
        
        -- Ensure that the API exists and is valid
        IF NOT api_exists(p_api_id) THEN
            RAISE e_api_not_found;
        END IF;
        
        -- Fetch access_id, is_active and api_token_enddate
        SELECT a.access_id, a.is_active, u.api_token_enddate
        INTO v_access_id, v_is_active, v_token_enddate
        FROM api_access a
        JOIN api_users u ON u.user_id = v_user_id
        WHERE a.api_id = p_api_id
        AND a.user_id = v_user_id;
       
        -- Check if the API token has expired
        IF v_token_enddate < SYSDATE THEN
            RAISE e_token_expired;
        END IF;
        
        -- Check if the API access is active
        IF v_is_active = 'N' THEN
            RAISE e_no_api_access;
        END IF;
        
        -- Fetch limit_exceeded from usage_tracking table
        BEGIN
            SELECT limit_exceeded
            INTO v_is_limit_exceeded
            FROM usage_tracking
            WHERE api_id = p_api_id
            AND user_id = v_user_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_is_limit_exceeded := 'N'; 
        END;
        
        -- Check if request limit is exceeded
        IF UPPER(v_is_limit_exceeded) = 'Y' THEN
            RAISE e_request_limit_exceeded;
        END IF;

        -- Generate a random response time between 0.1 and 1 second
        v_response_time := ROUND(DBMS_RANDOM.VALUE(0.1, 1), 2);
        
        -- Generate random response body
        v_response_body := generate_random_text(20);

        -- Insert a record into the requests table and return the request_id
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
            v_response_body,
            v_access_id
        )
        RETURNING request_id INTO p_message;  

        -- Commit the transaction
        COMMIT;
    
        p_message := 'API request successful. Request ID: ' || p_message;

    EXCEPTION
        WHEN e_user_not_found THEN
            p_message := 'User does not exist.';
            ROLLBACK;
            
        WHEN e_api_not_found THEN
            p_message := 'API does not exist.';
            ROLLBACK;
            
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
            p_message := 'An unexpected error occurred: ' || SQLERRM;
            ROLLBACK;
            
    END sp_api_request;

END api_request_pkg;
/

CREATE OR REPLACE PROCEDURE sp_update_api_user_details (
    p_username          IN api_users.username%TYPE,
    p_first_name        IN api_users.first_name%TYPE DEFAULT NULL,
    p_last_name         IN api_users.last_name%TYPE DEFAULT NULL,
    p_api_token_enddate IN api_users.api_token_enddate%TYPE DEFAULT NULL,
    p_user_role         IN api_users.user_role%TYPE DEFAULT NULL,
    p_message           OUT VARCHAR2
)
AS
    -- Custom exceptions
    e_invalid_role           EXCEPTION;
    e_user_not_found         EXCEPTION;
BEGIN
    
    -- Ensure that the user exists and is valid
    IF NOT user_exists(p_username) THEN
           RAISE e_user_not_found;
    END IF;
        
    -- Validate input for role
    IF p_user_role IS NOT NULL AND p_user_role NOT IN ('General', 'Student') THEN
        RAISE e_invalid_role;
    END IF;

    -- Update the api_users table
    UPDATE api_users
    SET 
        first_name = NVL(p_first_name, first_name),
        last_name = NVL(p_last_name, last_name),
        api_token_enddate = NVL(p_api_token_enddate, api_token_enddate),
        user_role = NVL(p_user_role, user_role)
    WHERE 
        username = p_username;

    -- Commit the transaction
    COMMIT;
    
    p_message := 'User: ' || p_username || ' updated successfully successfully.';
    
    EXCEPTION
        WHEN e_user_not_found THEN
            p_message := 'User does not exist.';
            ROLLBACK;
            
        WHEN e_invalid_role THEN
            p_message := 'Invalid user role. Allowed roles are General or Student';
            ROLLBACK; 
END sp_update_api_user_details;
/
