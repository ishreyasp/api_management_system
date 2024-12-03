-- Function to check if given user is valid
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

-- Function to get the user id for given username
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

-- Function to check if api with given api id exists
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

-- Function to check if pricing model exists
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

-- Function to check if pricing model exists for pricing_model table
CREATE OR REPLACE FUNCTION is_pricing_model_available (
    p_model_id IN pricing_model.model_id%TYPE,
    p_api_id   IN api.api_id%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    -- If api_id is provided, check both
    IF p_api_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM pricing_model
        WHERE model_id = p_model_id 
        AND api_id = p_api_id;
    ELSE
        -- If api_id is NULL, check only model_id
        SELECT COUNT(*)
        INTO v_count
        FROM pricing_model
        WHERE model_id = p_model_id;
    END IF;

    RETURN v_count > 0;
END is_pricing_model_available;
/

-- Function to calculate the subscription discount for given username 
CREATE OR REPLACE FUNCTION calculate_discount_pct (
    p_username IN api_users.username%TYPE) 
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

-- Function to check if the user has an active subscription for the given API
CREATE OR REPLACE FUNCTION is_active_subscription (
    p_user_id    IN api_users.user_id%TYPE,
    p_api_id     IN api.api_id%TYPE,
    p_model_id   IN pricing_model.model_id%TYPE 
) RETURN BOOLEAN
AS
    v_subscription_status subscription.status%TYPE;
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM api_access
    WHERE api_id = p_api_id
      AND user_id = p_user_id;

    IF v_count = 0 THEN
        RETURN FALSE;  
    END IF;

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

-- Function to generate random text
CREATE OR REPLACE FUNCTION generate_random_text(
    p_length IN NUMBER
) RETURN VARCHAR2 
AS
    v_random_text VARCHAR2(4000);
    v_characters  CONSTANT VARCHAR2(62) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    v_characters_length CONSTANT NUMBER := LENGTH(v_characters);
    v_index NUMBER;
BEGIN
    v_random_text := '';
    FOR i IN 1..p_length LOOP
        v_index := ROUND(DBMS_RANDOM.VALUE(1, v_characters_length));
        v_random_text := v_random_text || SUBSTR(v_characters, v_index, 1);
    END LOOP;
    RETURN v_random_text;
    
END generate_random_text;
/

-- Function to get user engagement report
CREATE OR REPLACE FUNCTION get_user_engagement_report
RETURN SYS_REFCURSOR
AS
    user_report SYS_REFCURSOR;
BEGIN
    OPEN user_report FOR
        WITH user_activity AS (
            SELECT 
                u.username,
                COUNT(r.request_id) AS total_requests,
                MAX(r.req_timestamp) AS last_request_date,
                CASE 
                    WHEN MAX(r.req_timestamp) < SYSDATE - 90 THEN 'Inactive'
                    ELSE 'Active'
                END AS user_status
            FROM 
                api_users u
            JOIN 
                api_access ac ON u.user_id = ac.user_id
            JOIN 
                requests r ON ac.access_id = r.access_id
            GROUP BY 
                u.username
        ),
        user_segments AS (
            SELECT 
                username,
                total_requests,
                user_status,
                NTILE(3) OVER (ORDER BY total_requests DESC) AS engagement_tier_rank
            FROM 
                user_activity
        )
        SELECT 
            username AS "Username",
            user_status AS "Status",
            CASE 
                WHEN engagement_tier_rank = 1 THEN 'High Engagement'
                WHEN engagement_tier_rank = 2 THEN 'Medium Engagement'
                ELSE 'Low Engagement'
            END AS "Engagement Tier",
            total_requests AS "Total Requests"
        FROM 
            user_segments
        ORDER BY 
            engagement_tier_rank, total_requests DESC;

    RETURN user_report;
END get_user_engagement_report;
/

-- Function to get API revenue data
CREATE OR REPLACE FUNCTION get_api_revenue_data
RETURN SYS_REFCURSOR
AS
    revenue_cursor SYS_REFCURSOR;
BEGIN
    OPEN revenue_cursor FOR
    WITH revenue_data AS (
        SELECT 
            a.name AS api_name,
            pm.model_type AS pricing_model,
            COUNT(r.request_id) AS total_requests,
            SUM(CASE WHEN r.status = 'SUCCESS' THEN 1 ELSE 0 END) AS success_requests,
            SUM(CASE WHEN r.status = 'FAILED' THEN 1 ELSE 0 END) AS failed_requests,
            COUNT(CASE WHEN r.status = 'SUCCESS' THEN 1 END) * pm.rate AS total_revenue_generated,
            COUNT(CASE WHEN r.status = 'FAILED' THEN 1 END) * pm.rate AS total_revenue_loss
        FROM 
            api a
        JOIN 
            api_access ac ON a.api_id = ac.api_id
        JOIN 
            subscription s ON ac.user_id = s.user_id
        JOIN 
            pricing_model pm ON s.pricing_model_id = pm.model_id
        LEFT JOIN 
            requests r ON ac.access_id = r.access_id
        GROUP BY 
            a.name, pm.model_type, pm.rate
    )
    SELECT 
        api_name AS "API Name",
        pricing_model AS "Pricing Model",
        success_requests AS "Successful Requests",
        failed_requests AS "Failed Requests",
        total_revenue_generated AS "Revenue Generated",
        total_revenue_loss AS "Revenue Lost"
    FROM 
        revenue_data
    ORDER BY 
        total_requests DESC;

    RETURN revenue_cursor;
END get_api_revenue_data;
/

-- Function to get API response time
CREATE OR REPLACE FUNCTION get_api_response_time_report
RETURN SYS_REFCURSOR
AS
    response_time_cursor SYS_REFCURSOR;
BEGIN
    OPEN response_time_cursor FOR
    SELECT  
        a.name AS "API Name",
        TO_CHAR(r.req_timestamp, 'YYYY-MM') AS "Month",
        ROUND(AVG(r.response_time), 2) AS "Average Response Time (s)",
        MIN(r.response_time) AS "Minimum Response Time (s)",
        MAX(r.response_time) AS "Maximum Response Time (s)"
    FROM 
        requests r
    JOIN 
        api_access ac ON r.access_id = ac.access_id
    JOIN 
        api a ON ac.api_id = a.api_id
    GROUP BY 
        a.name, TO_CHAR(r.req_timestamp, 'YYYY-MM')
    ORDER BY 
        "Month", "Average Response Time (s)" DESC;

    RETURN response_time_cursor;
END get_api_response_time_report;
/

-- Function to update the subscription status to expired for given subscription id 
CREATE OR REPLACE FUNCTION update_subscription_status (
    p_subscription_id IN NUMBER
) RETURN VARCHAR2
AS
    v_result VARCHAR2(50);
BEGIN
    -- Update the status field to 'Expired'
    UPDATE subscription
    SET status = 'Expired'
    WHERE subscription_id = p_subscription_id;

    -- Check if the update affected any rows
    IF SQL%ROWCOUNT > 0 THEN
        v_result := 'Subscription status updated to Expired.';
    ELSE
        v_result := 'No subscription found with the given ID.';
    END IF;

    -- Commit the changes
    COMMIT;

    -- Return the result
    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        RETURN 'An error occurred: ' || SQLERRM;
END update_subscription_status;
/

--Function to check if api_token already exsists
CREATE OR REPLACE FUNCTION api_token_exists (
    p_api_token IN api_users.api_token%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM api_users
    WHERE api_token = p_api_token;
 
    IF v_count = 0 THEN
        RETURN FALSE;  
    ELSE
        RETURN TRUE;   
    END IF;
END api_token_exists;
/
