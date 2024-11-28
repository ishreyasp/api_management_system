CREATE OR REPLACE TRIGGER update_usage_tracking
AFTER INSERT ON REQUESTS
FOR EACH ROW
DECLARE
    v_request_limit INTEGER;
    v_request_count INTEGER;
    v_user_id NUMBER;
    v_api_id NUMBER;
BEGIN
    -- Retrieve the request limit for the API associated with the access_id
    SELECT pm.request_limit
    INTO v_request_limit
    FROM API_ACCESS aa
    JOIN PRICING_MODEL pm ON aa.api_id = pm.api_id
    WHERE aa.access_id = :NEW.access_id;
    
    -- Retrieve the user_id and api_id from API_ACCESS for the new access_id
    SELECT user_id, api_id 
    INTO v_user_id, v_api_id
    FROM API_ACCESS 
    WHERE access_id = :NEW.access_id;

    -- Increment the request count and check if the limit is exceeded in one UPDATE statement
    UPDATE USAGE_TRACKING
    SET request_count = request_count + 1,
        last_updated = SYSDATE,
        limit_exceeded = CASE
                            WHEN request_count + 1 >= v_request_limit THEN 'Y'
                            ELSE 'N'
                         END
    WHERE user_id = v_user_id
      AND api_id = v_api_id
    RETURNING request_count INTO v_request_count;

END;
/