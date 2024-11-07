-- View UserAccessRights: Shows which APIs each user has access to and the access status.
CREATE OR REPLACE VIEW user_api_access AS
    SELECT
        users.user_id,
        users.username,
        api.api_id,
        api.api_name,
        api_access.is_active
    FROM
        users users
        JOIN api_access api_access ON users.user_id = api_access.user_id
        JOIN api api ON api.api_id = api_access.api_id
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
        JOIN users   u ON s.users_id = u.user_id;
        
-- View ActiveUserSubscriptions: Shows all active subscriptions for each user. 
CREATE OR REPLACE VIEW active_user_subscriptions AS
    SELECT
        users.user_id,
        users.username,
        subscription.subscription_id,
        subscription.end_date,
        subscription.status
    FROM
             users users
        JOIN subscription subscription ON users.user_id = subscription.users_id
    WHERE
        subscription.status = 'ACTIVE';

-- View APIPerformanceMetrics: Displays average response time and request count for each API.
CREATE OR REPLACE VIEW api_performance_metrics  AS
SELECT
    u.users_id,
    us.username,
    a.api_id,
    a.api_name,
    u.request_count,
    AVG(response_time) AS average_response_time
FROM
         api a
    JOIN usage_tracking u ON a.api_id = u.api_id
    JOIN requests       r ON r.user_id = u.users_id
    JOIN users     us on us.user_id = u.users_id
GROUP BY
    a.api_id, u.request_count, u.users_id, a.api_name, us.username
ORDER BY
    1;
      
 -- View API USAGE BY USER: Displays number of request made by each user for each api.
CREATE OR REPLACE VIEW request_count  AS  
SELECT
    u.user_id,
    a.api_id,
    u.username,
    a.api_name,
    ut.request_count
FROM
         usage_tracking ut
    JOIN api   a ON a.api_id = ut.api_id
    JOIN users u ON u.user_id = ut.users_id;