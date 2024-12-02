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
    
    PROCEDURE sp_insert_into_user (
    p_username           IN api_users.username%TYPE,
    p_first_name        IN api_users.first_name%TYPE,
    p_last_name         IN api_users.last_name%TYPE,
    p_role              IN api_users.user_role%TYPE,
    p_api_token         IN api_users.api_token%TYPE,
    p_token_startdate   IN api_users.api_token_startdate%TYPE,
    p_token_enddate     IN api_users.api_token_enddate%TYPE,
    p_message           OUT VARCHAR2
);

    PROCEDURE sp_insert_into_pricing_model (
    p_model_type    IN pricing_model.model_type%TYPE,
    p_rate          IN pricing_model.rate%TYPE,
    p_request_limit IN pricing_model.request_limit%TYPE DEFAULT NULL,
    p_api_id        IN pricing_model.api_id%TYPE,
    p_message       OUT VARCHAR2
);

    PROCEDURE sp_insert_api (
        p_api_name    IN api.name%TYPE,
        p_description IN api.description%TYPE,
        p_status      OUT VARCHAR2,
        p_message     OUT VARCHAR2
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


PROCEDURE sp_insert_into_user (
    p_username           IN api_users.username%TYPE,
    p_first_name        IN api_users.first_name%TYPE,
    p_last_name         IN api_users.last_name%TYPE,
    p_role              IN api_users.user_role%TYPE,
    p_api_token         IN api_users.api_token%TYPE,
    p_token_startdate   IN api_users.api_token_startdate%TYPE,
    p_token_enddate     IN api_users.api_token_enddate%TYPE,
    p_message           OUT VARCHAR2
) AS
    e_invalid_role EXCEPTION;
    e_invalid_dates EXCEPTION;
    e_null_values EXCEPTION;
BEGIN
    -- Initialize output parameters
    p_message := '';

    -- Check for NULL values
    IF p_username IS NULL OR p_first_name IS NULL OR 
       p_last_name IS NULL OR p_role IS NULL OR 
       p_api_token IS NULL OR p_token_startdate IS NULL OR 
       p_token_enddate IS NULL 
    THEN
        RAISE e_null_values;
    END IF;

    -- Validate role
    IF UPPER(p_role) NOT IN ('Student', 'General') THEN
        RAISE e_invalid_role;
    END IF;

    -- Validate token dates
    IF p_token_startdate >= p_token_enddate THEN
        RAISE e_invalid_dates;
    END IF;

    -- Check if username exists using function
    IF user_exists(p_username) THEN
        p_message := 'Username already exists';
        RETURN;
    END IF;

    -- Check if API token exists using function
    IF api_token_exists(p_api_token) THEN
        p_message := 'API token already exists';
        RETURN;
    END IF;

    -- Insert new user (user_id will be generated by sequence default)
    INSERT INTO api_users (
        username,
        first_name,
        last_name,
        user_role,
        api_token,
        api_token_startdate,
        api_token_enddate
    ) VALUES (
        p_username,
        p_first_name,
        p_last_name,
        p_role,
        p_api_token,
        p_token_startdate,
        p_token_enddate
    );

    COMMIT;
    p_message := 'User created successfully';

EXCEPTION
    WHEN e_null_values THEN
        p_message := 'All fields are required';
        ROLLBACK;
    
    WHEN e_invalid_role THEN
        p_message := 'Invalid role. Must be either STUDENT or GENERAL';
        ROLLBACK;
    
    WHEN e_invalid_dates THEN
        p_message := 'Token start date must be before end date';
        ROLLBACK;
    
    WHEN DUP_VAL_ON_INDEX THEN
        p_message := 'Duplicate value found for unique constraint';
        ROLLBACK;
    
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END sp_insert_into_user;

PROCEDURE sp_insert_into_pricing_model (
    p_model_type    IN pricing_model.model_type%TYPE,
    p_rate          IN pricing_model.rate%TYPE,
    p_request_limit IN pricing_model.request_limit%TYPE DEFAULT NULL,
    p_api_id        IN pricing_model.api_id%TYPE,
    p_message       OUT VARCHAR2
) AS
    e_invalid_model_type EXCEPTION;
    e_invalid_rate EXCEPTION;
    e_invalid_limit EXCEPTION;
    e_api_not_found EXCEPTION;
BEGIN
    -- Initialize output
    p_message := '';

    -- Validate required fields
    IF p_model_type IS NULL OR p_api_id IS NULL THEN
        p_message := 'Model type and API ID are required for insert';
        RETURN;
    END IF;

    -- Validate rate
    IF p_rate < 0 THEN
        RAISE e_invalid_rate;
    END IF;

    -- Validate model_type
    IF p_model_type NOT IN ('pay_per_request', 'subscription') THEN
        RAISE e_invalid_model_type;
    END IF;

    -- Check API exists using function
    IF NOT api_exists(p_api_id) THEN
        RAISE e_api_not_found;
    END IF;

    -- Validate request_limit for subscription
    IF p_model_type = 'subscription' AND (p_request_limit IS NULL OR p_request_limit <= 0) THEN
        RAISE e_invalid_limit;
    END IF;

    -- Insert new pricing model
    INSERT INTO pricing_model (
        model_type,
        rate,
        request_limit,
        api_id
    ) VALUES (
        p_model_type,
        p_rate,
        p_request_limit,
        p_api_id
    );

    COMMIT;
    p_message := 'Pricing model created successfully';

EXCEPTION
    WHEN e_invalid_model_type THEN
        p_message := 'Invalid model type. Must be either PAY_PER_REQUEST or SUBSCRIPTION';
        ROLLBACK;
    WHEN e_invalid_rate THEN
        p_message := 'Rate must be greater than or equal to 0';
        ROLLBACK;
    WHEN e_invalid_limit THEN
        p_message := 'Request limit must be greater than 0 for subscription model';
        ROLLBACK;
    WHEN e_api_not_found THEN
        p_message := 'API ID does not exist';
        ROLLBACK;
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END sp_insert_into_pricing_model;

 PROCEDURE sp_insert_api (
    p_api_name    IN api.name%TYPE,
    p_description IN api.description%TYPE,
    p_status      OUT VARCHAR2,
    p_message     OUT VARCHAR2
) AS
    e_null_values EXCEPTION;
    e_api_exists EXCEPTION;
    v_count NUMBER;
BEGIN
    -- Initialize output parameters
    p_message := '';

    -- Check for NULL values
    IF p_api_name IS NULL OR p_description IS NULL THEN
        RAISE e_null_values;
    END IF;

    -- Check if API name already exists
    SELECT COUNT(*)
    INTO v_count
    FROM api
    WHERE UPPER(name) = UPPER(p_api_name);

    IF v_count > 0 THEN
        RAISE e_api_exists;
    END IF;

    -- Insert new API
    INSERT INTO api (
        name,
        description
    ) VALUES (
        p_api_name,
        p_description
    );

    COMMIT;
    p_message := 'API created successfully';

EXCEPTION
    WHEN e_null_values THEN
        p_message := 'API name and description are required';
        ROLLBACK;
    
    WHEN e_api_exists THEN
        p_message := 'API with this name already exists';
        ROLLBACK;
    
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END sp_insert_api;




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



CREATE OR REPLACE PACKAGE update_into_api_management_system_pkg AS

PROCEDURE sp_update_user (
    p_username           IN api_users.username%TYPE,
    p_first_name        IN api_users.first_name%TYPE DEFAULT NULL,
    p_last_name         IN api_users.last_name%TYPE DEFAULT NULL,
    p_api_token         IN api_users.api_token%TYPE DEFAULT NULL,
    p_token_startdate   IN api_users.api_token_startdate%TYPE DEFAULT NULL,
    p_token_enddate     IN api_users.api_token_enddate%TYPE DEFAULT NULL,
    p_message           OUT VARCHAR2
) ;


PROCEDURE sp_update_into_pricing_model (
    p_model_id    IN pricing_model.model_id%TYPE,
    p_rate        IN pricing_model.rate%TYPE,
    p_message     OUT VARCHAR2
);

 PROCEDURE sp_update_api_access_is_active (
    p_username    IN api_users.username%TYPE,
    p_api_id      IN api.api_id%TYPE,
    p_is_active   IN api_access.is_active%TYPE,
    p_message     OUT VARCHAR2
);

END update_into_api_management_system_pkg;
/



CREATE OR REPLACE PACKAGE BODY update_into_api_management_system_pkg AS

PROCEDURE sp_update_user (
    p_username           IN api_users.username%TYPE,
    p_first_name        IN api_users.first_name%TYPE DEFAULT NULL,
    p_last_name         IN api_users.last_name%TYPE DEFAULT NULL,
    p_api_token         IN api_users.api_token%TYPE DEFAULT NULL,
    p_token_startdate   IN api_users.api_token_startdate%TYPE DEFAULT NULL,
    p_token_enddate     IN api_users.api_token_enddate%TYPE DEFAULT NULL,
    p_message           OUT VARCHAR2
) AS
    e_invalid_dates EXCEPTION;
BEGIN
    -- Initialize output parameters
    p_message := '';

    -- Check if user exists
    IF NOT user_exists(p_username) THEN
        p_message := 'User does not exist';
        RETURN;
    END IF;

    -- Validate new token dates if both are provided
    IF p_token_startdate IS NOT NULL AND p_token_enddate IS NOT NULL THEN
        IF p_token_startdate >= p_token_enddate THEN
            RAISE e_invalid_dates;
        END IF;
    END IF;

    -- Check if new API token exists (if provided)
    IF p_api_token IS NOT NULL THEN
        IF api_token_exists(p_api_token) THEN
            p_message := 'API token already exists';
            RETURN;
        END IF;
    END IF;

    -- Update user information
    UPDATE api_users
    SET first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        api_token = COALESCE(p_api_token, api_token),
        api_token_startdate = COALESCE(p_token_startdate, api_token_startdate),
        api_token_enddate = COALESCE(p_token_enddate, api_token_enddate)
    WHERE username = p_username;

    COMMIT;
    p_message := 'User updated successfully';

EXCEPTION
    WHEN e_invalid_dates THEN
        p_message := 'Token start date must be before end date';
        ROLLBACK;
    
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END sp_update_user;


PROCEDURE sp_update_into_pricing_model (
    p_model_id    IN pricing_model.model_id%TYPE,
    p_rate        IN pricing_model.rate%TYPE,
    p_message     OUT VARCHAR2
) AS
    e_invalid_rate EXCEPTION;
    e_model_not_found EXCEPTION;
BEGIN
    -- Initialize output
    p_message := '';

    -- Validate if model_id is provided
    IF p_model_id IS NULL THEN
        p_message := 'Model ID is required for update';
        RETURN;
    END IF;

    -- Validate rate
    IF p_rate < 0 THEN
        RAISE e_invalid_rate;
    END IF;

    -- Check if pricing model exists using function
    IF NOT pricing_model_exists(p_model_id, NULL) THEN
        RAISE e_model_not_found;
    END IF;

    -- Update only the rate
    UPDATE pricing_model
    SET rate = p_rate
    WHERE model_id = p_model_id;

    COMMIT;
    p_message := 'Pricing model rate updated successfully';

EXCEPTION
    WHEN e_invalid_rate THEN
        p_message := 'Rate must be greater than or equal to 0';
        ROLLBACK;
    
    WHEN e_model_not_found THEN
        p_message := 'Pricing model ID does not exist';
        ROLLBACK;
    
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END sp_update_into_pricing_model 
;

PROCEDURE sp_update_api_access_is_active (
    p_username    IN api_users.username%TYPE,
    p_api_id      IN api.api_id%TYPE,
    p_is_active   IN api_access.is_active%TYPE,
    p_message     OUT VARCHAR2
) AS
    v_user_id    api_users.user_id%TYPE;
    v_count      NUMBER;
    e_access_not_found EXCEPTION;
    e_invalid_status EXCEPTION;
    e_api_not_found EXCEPTION;
BEGIN
    -- Initialize output
    p_message := '';

    -- Validate status value
    IF p_is_active NOT IN ('yes', 'no') THEN
        RAISE e_invalid_status;
    END IF;

    -- Check if API exists using function
    IF NOT api_exists(p_api_id) THEN
        RAISE e_api_not_found;
    END IF;

    -- Get user_id from username
    v_user_id := get_user_id(p_username);

    -- Check if access exists for this user-API combination
    SELECT COUNT(*)
    INTO v_count
    FROM api_access
    WHERE user_id = v_user_id
    AND api_id = p_api_id;

    IF v_count = 0 THEN
        RAISE e_access_not_found;
    END IF;

    -- Update is_active status
    UPDATE api_access
    SET is_active = p_is_active
    WHERE user_id = v_user_id
    AND api_id = p_api_id;

    COMMIT;
    p_message := 'API access status updated successfully';

EXCEPTION
    WHEN e_invalid_status THEN
        p_message := 'Invalid status. Must be yes or no';
        ROLLBACK;
    
    WHEN e_api_not_found THEN
        p_message := 'API ID does not exist';
        ROLLBACK;
    
    WHEN e_access_not_found THEN
        p_message := 'API access not found for this user and API combination';
        ROLLBACK;
    
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END sp_update_api_access_is_active;

END update_into_api_management_system_pkg;
/
