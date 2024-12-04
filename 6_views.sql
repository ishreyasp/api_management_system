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
        AVG(r.response_time) AS average_response_time
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
    p_user_id NUMBER
) AS
BEGIN
    dbms_session.set_context('user_ctx', 'current_user_id', p_user_id);
END;
/

-- Create user_dashboard view
CREATE OR REPLACE VIEW user_dashboard AS
WITH filtered_subscriptions AS (
    SELECT
        s.subscription_id,
        s.user_id,
        s.start_date,
        s.end_date,
        s.status,
        s.discount,
        s.usage_tracking_id,
        s.pricing_model_id
    FROM subscription s
    WHERE EXISTS (
        SELECT 1
        FROM pricing_model pm
        WHERE pm.api_id = s.pricing_model_id
          AND pm.model_id = s.pricing_model_id
    )
)
SELECT
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    u.user_role,
    u.api_token,
    u.api_token_startdate,
    u.api_token_enddate,
    aa.access_id        AS api_access_id,
    aa.access_generated AS access_generated_date,
    aa.is_active        AS access_active_status,
    a.api_id,
    a.name,
    a.description       AS api_description,
    r.request_id        AS request_id,
    r.req_timestamp     AS request_timestamp,
    r.response_time     AS response_time,
    r.status            AS request_status,
    r.request_body      AS request_body,
    r.response_body     AS response_body,
    ut.tracking_id      AS usage_tracking_id,
    ut.request_count    AS total_requests,
    ut.last_updated     AS last_usage_update,
    ut.limit_exceeded   AS usage_limit_exceeded,
    s.subscription_id   AS subscription_id,
    s.start_date        AS subscription_start_date,
    s.end_date          AS subscription_end_date,
    s.status            AS subscription_status,
    s.discount          AS subscription_discount,
    b.billing_id        AS billing_id,
    b.billing_date      AS billing_date,
    b.total_amount      AS total_bill_amount
FROM
    api_users u
    LEFT JOIN api_access aa ON u.user_id = aa.user_id
    LEFT JOIN api a ON aa.api_id = a.api_id
    LEFT JOIN requests r ON aa.access_id = r.access_id
    LEFT JOIN filtered_subscriptions s ON u.user_id = s.user_id
    LEFT JOIN usage_tracking ut ON s.usage_tracking_id = ut.tracking_id
    LEFT JOIN billing b ON s.subscription_id = b.subscription_id
WHERE
    u.user_id = TO_NUMBER(sys_context('user_ctx', 'current_user_id'));