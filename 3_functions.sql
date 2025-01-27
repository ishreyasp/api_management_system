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

-- Function to check if user is already subscribed to an API 
CREATE OR REPLACE FUNCTION is_subscription_exists (
    p_user_id IN subscription.user_id%TYPE,
    p_pricing_model_id IN subscription.pricing_model_id%TYPE
) RETURN BOOLEAN
AS
    v_count NUMBER;
BEGIN
    -- Count the records matching the user_id and pricing_model_id
    SELECT COUNT(*)
    INTO v_count
    FROM subscription
    WHERE user_id = p_user_id AND pricing_model_id = p_pricing_model_id;

    -- Return TRUE if a matching subscription exists, FALSE otherwise
    RETURN v_count > 0;
END is_subscription_exists;
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
            SUM(CASE WHEN r.status = 'Success' THEN 1 ELSE 0 END) AS success_requests,
            SUM(CASE WHEN r.status = 'Failure' THEN 1 ELSE 0 END) AS failed_requests,
            SUM(CASE WHEN r.status = 'Success' THEN 1 END) * pm.rate AS total_revenue_generated,
            SUM(CASE WHEN r.status = 'Failure' THEN 1 END) * pm.rate AS total_revenue_loss
        FROM 
            api a
        JOIN 
            api_access ac ON a.api_id = ac.api_id
        JOIN 
            pricing_model pm ON a.api_id = pm.api_id
        JOIN 
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

-- Function to check if subscription exists
CREATE OR REPLACE FUNCTION subscription_exists (
    p_subscription_id IN subscription.subscription_id%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM subscription
    WHERE subscription_id = p_subscription_id;

    IF v_count = 0 THEN
        RETURN FALSE;  
    ELSE
        RETURN TRUE;   
    END IF;
END subscription_exists;
/

-- Function to check if subscription exists
CREATE OR REPLACE FUNCTION billingid_exists (
    p_subscription_id IN billing.subscription_id%TYPE
) 
RETURN BOOLEAN 
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM billing
    WHERE subscription_id = p_subscription_id;

    IF v_count = 0 THEN
        RETURN FALSE;  
    ELSE
        RETURN TRUE;   
    END IF;
END billingid_exists;
/

-- Function to calculate API contribution
CREATE OR REPLACE FUNCTION get_api_revenue_contribution
RETURN SYS_REFCURSOR
AS
    api_revenue_cursor SYS_REFCURSOR;
BEGIN
    OPEN api_revenue_cursor FOR
    SELECT 
        a.name AS "API Name",
        pm.model_type AS "Pricing Model",
        SUM(b.total_amount) AS "Total Revenue"
    FROM 
        billing b
    JOIN subscription s ON b.subscription_id = s.subscription_id
    JOIN pricing_model pm ON s.pricing_model_id = pm.model_id
    JOIN api a ON pm.api_id = a.api_id
    GROUP BY 
        a.name, pm.model_type
    ORDER BY 
        "Total Revenue" DESC;
    
    RETURN api_revenue_cursor;
END get_api_revenue_contribution;
/

-- Function to display users with highest billing
CREATE OR REPLACE FUNCTION get_top_paying_users
RETURN SYS_REFCURSOR
AS
    top_users_cursor SYS_REFCURSOR;
BEGIN
    OPEN top_users_cursor FOR
    SELECT 
        u.username AS "Username",
        SUM(b.total_amount) AS "Total Amount Paid",
        COUNT(b.billing_id) AS "Number of Billings"
    FROM 
        billing b
    JOIN subscription s ON b.subscription_id = s.subscription_id
    JOIN api_users u ON s.user_id = u.user_id
    GROUP BY 
        u.username
    ORDER BY 
        "Total Amount Paid" DESC
    FETCH FIRST 10 ROWS ONLY;
    
    RETURN top_users_cursor;
END get_top_paying_users;
/

-- Functio to get API cccess audit report
CREATE OR REPLACE FUNCTION get_api_access_audit_report
RETURN SYS_REFCURSOR
AS
   v_report_cursor SYS_REFCURSOR;
BEGIN
   OPEN v_report_cursor FOR
       SELECT 
           u.username,
           u.user_role,
           a.name AS api_name,
           ac.access_generated,
           ac.is_active,
           ut.request_count,
           ut.last_updated,
           ut.limit_exceeded,
           (SELECT COUNT(request_id) 
            FROM requests r 
            WHERE r.access_id = ac.access_id) as total_requests
       FROM api_users u
       JOIN api_access ac ON u.user_id = ac.user_id
       JOIN api a ON ac.api_id = a.api_id
       LEFT JOIN usage_tracking ut ON (u.user_id = ut.user_id AND a.api_id = ut.api_id)
       ORDER BY 
           u.user_role,
           u.username,
           ac.access_generated DESC;

   RETURN v_report_cursor;
END;
/

-- Function to get all users token expiry date report
CREATE OR REPLACE FUNCTION get_user_dates_report
RETURN SYS_REFCURSOR
AS
   v_report_cursor SYS_REFCURSOR;
BEGIN
   OPEN v_report_cursor FOR
       SELECT 
           u.username,
           u.user_role,
           u.api_token,
           u.api_token_startdate,
           u.api_token_enddate,
           a.name AS api_name,
           ac.access_generated,
           ac.is_active,
           CASE 
               WHEN SYSDATE > u.api_token_enddate THEN 'Expired'
               WHEN SYSDATE BETWEEN u.api_token_startdate AND u.api_token_enddate THEN 'Valid'
               WHEN SYSDATE < u.api_token_startdate THEN 'Not Yet Active'
           END as token_status,
           TRUNC(u.api_token_enddate - SYSDATE) as days_until_token_expiry
       FROM api_users u
       LEFT JOIN api_access ac ON u.user_id = ac.user_id
       LEFT JOIN api a ON ac.api_id = a.api_id
       ORDER BY 
           u.username,
           ac.access_generated DESC;

   RETURN v_report_cursor;
END;
/