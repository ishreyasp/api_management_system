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
    SELECT
        u."USER_ID",
        u."USERNAME",
        u."FIRST_NAME",
        u."LAST_NAME",
        u."ROLE",
        u."API_TOKEN",
        u."API_TOKEN_STARTDATE",
        u."API_TOKEN_ENDDATE",
        aa.access_id        AS api_access_id,
        aa.access_generated AS access_generated_date,
        aa.is_active        AS access_active_status,
        a.api_id,
        a.api_name,
        a.description       AS api_description,
        r.request_id        AS request_id,
        r.timestamp         AS request_timestamp,
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
        "USERS"        u
        LEFT JOIN api_access     aa ON u."USER_ID" = aa.user_id
        LEFT JOIN api            a ON aa.api_id = a.api_id
        LEFT JOIN requests       r ON u."USER_ID" = r.user_id
                                AND aa.access_id = r.access_id
        LEFT JOIN usage_tracking ut ON u."USER_ID" = ut.users_id
                                       AND a.api_id = ut.api_id
        LEFT JOIN subscription   s ON u."USER_ID" = s.users_id
        LEFT JOIN billing        b ON s.subscription_id = b.subscription_id
    WHERE
        u."USER_ID" = TO_NUMBER(sys_context('user_ctx', 'current_user_id'));