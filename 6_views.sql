-- View to fetch API details
CREATE OR REPLACE VIEW vw_api AS
    SELECT api_id, 
            name, 
            description
    FROM api
WITH READ ONLY;    

-- View to fetch Pricing Model details
CREATE OR REPLACE VIEW vw_pricing_model AS
SELECT 
    model_id AS "Model ID",
    model_type AS "Model Type",
    rate AS "Rate",
    request_limit AS "Request Limit",
    api_id AS "API ID"
FROM 
    pricing_model
WITH READ ONLY;

-- View to fetch Usage Tracking details
CREATE OR REPLACE VIEW vw_usage_tracking AS
SELECT 
    tracking_id AS "Tracking ID",
    request_count AS "Request Count",
    last_updated AS "Last Updated",
    limit_exceeded AS "Limit Exceeded",
    api_id AS "API ID",
    user_id AS "User ID"
FROM 
    usage_tracking
WITH READ ONLY;

-- View to fetch Requests details
CREATE OR REPLACE VIEW vw_requests AS
SELECT 
    request_id AS "Request ID",
    req_timestamp AS "Request Timestamp",
    response_time AS "Response Time (ms)",
    status AS "Status",
    request_body AS "Request Body",
    response_body AS "Response Body",
    access_id AS "Access ID"
FROM 
    requests
WITH READ ONLY;

-- View to fetch API Access details
CREATE OR REPLACE VIEW vw_api_access AS
SELECT 
    access_id AS "Access ID",
    access_generated AS "Access Generated Date",
    is_active AS "Is Active",
    user_id AS "User ID",
    api_id AS "API ID"
FROM 
    api_access
WITH READ ONLY;

-- View UserAccessRights: Shows which APIs each user has access to and the access status.
CREATE OR REPLACE VIEW user_api_access AS
    SELECT
        api_users.user_id,
        api_users.username,
        api.api_id,
        api.name,
        api_access.is_active
    FROM
             api_users api_users
        JOIN api_access api_access ON api_users.user_id = api_access.user_id
        JOIN api        api ON api.api_id = api_access.api_id
    WHERE
        api_access.is_active = 1;

-- View Billing History: Shows billing history for each user, including subscription details.
CREATE OR REPLACE VIEW billing_history AS
    SELECT
        u.user_id,
        u.username,
        b.billing_id,
        b.billing_date,
        b.total_amount,
        s.subscription_id,
        s.start_date,
        s.end_date,
        s.status,
        s.discount
    FROM
             subscription s
        JOIN billing b ON s.subscription_id = b.subscription_id
        JOIN api_users   u ON s.user_id = u.user_id;
        
-- View ActiveUserSubscriptions: Shows all active subscriptions for each user. 
CREATE OR REPLACE VIEW active_user_subscriptions AS
    SELECT
        api_users.user_id,
        api_users.username,
        subscription.subscription_id,
        subscription.end_date,
        subscription.status
    FROM
             api_users api_users
        JOIN subscription subscription ON api_users.user_id = subscription.user_id
    WHERE
        subscription.status = 'ACTIVE';

-- View APIPerformanceMetrics: Displays average response time and request count for each API.
CREATE OR REPLACE VIEW api_performance_metrics AS
    SELECT
        u.user_id,
        us.username,
        a.api_id,
        a.name,
        u.request_count,
        ROUND(AVG(r.response_time), 2) AS average_response_time
    FROM
             api a
        JOIN usage_tracking u ON a.api_id = u.api_id
        JOIN api_access     aa ON aa.api_id = a.api_id
        JOIN requests       r ON r.access_id = aa.access_id
        JOIN api_users          us ON us.user_id = u.user_id
    GROUP BY
        a.api_id,
        u.request_count,
        u.user_id,
        a.name,
        us.username
    ORDER BY
        1;
      
 -- View API USAGE BY USER: Displays number of request made by each user for each api.
CREATE OR REPLACE VIEW request_count AS
    SELECT
        u.user_id,
        a.api_id,
        u.username,
        a.name,
        ut.request_count
    FROM
             usage_tracking ut
        JOIN api   a ON a.api_id = ut.api_id
        JOIN api_users u ON u.user_id = ut.user_id;

-- Create the Application Context
CREATE OR REPLACE CONTEXT user_ctx USING set_user_id;
/
 
-- Create procedure to set 'USER_ID' in the context
CREATE OR REPLACE PROCEDURE set_user_id (
    p_user_id IN NUMBER
) AS
BEGIN
    dbms_session.set_context('user_ctx', 'current_user_id', TO_CHAR(p_user_id));
END;
/
 
-- View to get user subscription and billing details
CREATE OR REPLACE VIEW user_subscription_billing_view AS
SELECT 
    s.subscription_id,
    s.start_date,
    s.end_date,
    s.status AS subscription_status,
    s.discount,
    b.billing_id,
    b.billing_date,
    b.total_amount
FROM 
    subscription s
    LEFT JOIN billing b ON s.subscription_id = b.subscription_id
WHERE 
    s.user_id = TO_NUMBER(sys_context('user_ctx', 'current_user_id'));