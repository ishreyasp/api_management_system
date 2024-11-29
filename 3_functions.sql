-- Check if given user is valid
CREATE OR REPLACE FUNCTION user_exists (
    p_username IN api_users.username%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM api_users
    WHERE username = p_username;

    IF v_count = 0 THEN
        RETURN FALSE;  
    ELSE
        RETURN TRUE;   
    END IF;
END user_exists;
/

-- Get the user id for given username
CREATE OR REPLACE FUNCTION get_user_id (
    p_username IN api_users.username%TYPE
) 
RETURN api_users.user_id%TYPE 
AS
    v_user_id api_users.user_id%TYPE;
BEGIN
    SELECT user_id
    INTO v_user_id
    FROM api_users
    WHERE username = p_username;

    RETURN v_user_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, 'User does not exist.');
END get_user_id;
/

-- Check if api with given api id exists
CREATE OR REPLACE FUNCTION api_exists (
    p_api_id IN api.api_id%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM api
    WHERE api_id = p_api_id;

    IF v_count = 0 THEN
        RETURN FALSE;  
    ELSE
        RETURN TRUE;   
    END IF;
END api_exists;
/

-- Check if pricing model exists
CREATE OR REPLACE FUNCTION pricing_model_exists (
    p_model_id IN pricing_model.model_id%TYPE,
    p_api_id   IN api.api_id%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM pricing_model
    WHERE model_id = p_model_id AND api_id = p_api_id;

    IF v_count = 0 THEN
        RETURN FALSE;  
    ELSE
        RETURN TRUE;   
    END IF;
END pricing_model_exists;
/

-- Calculate the subscription discount for given username 
CREATE OR REPLACE FUNCTION calculate_discount_pct (p_username IN api_users.username%TYPE) 
RETURN NUMBER 
AS
    v_discount  NUMBER(5, 3);
    v_user_role VARCHAR2(10);
BEGIN
    
    SELECT user_role
    INTO v_user_role
    FROM api_users
    WHERE username = p_username;
        
    IF v_user_role = 'Student' THEN
        v_discount := 0.20;
    ELSE 
        v_discount := 0.00;    
    END IF;
    
    RETURN v_discount;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Error calculating discount: ' || SQLERRM);
END calculate_discount_pct;
/

-- Check if the user has an active subscription for the given API
CREATE OR REPLACE FUNCTION is_active_subscription (
    p_user_id    IN api_users.user_id%TYPE,
    p_api_id     IN api.api_id%TYPE,
    p_model_id   IN pricing_model.model_id%TYPE 
) RETURN BOOLEAN
AS
    v_subscription_status subscription.status%TYPE;
    v_count INTEGER;
BEGIN
    -- Check if the user has access to the API through api_access
    SELECT COUNT(*)
    INTO v_count
    FROM api_access
    WHERE api_id = p_api_id
      AND user_id = p_user_id;

    IF v_count = 0 THEN
        RETURN FALSE;  
    END IF;

    -- Now, check if there is an active subscription for the user and API
    BEGIN
        SELECT s.status
        INTO v_subscription_status
        FROM subscription s
        JOIN api_access a ON s.user_id = a.user_id
        WHERE s.user_id = p_user_id
          AND a.api_id = p_api_id
          AND s.pricing_model_id = p_model_id
          AND s.status = 'Active';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;  
    END;

    RETURN TRUE;  
END is_active_subscription;
/
