CREATE OR REPLACE TRIGGER update_usage_tracking
AFTER INSERT ON REQUESTS
FOR EACH ROW
DECLARE
    v_request_limit INTEGER;
    v_request_count INTEGER;
    v_user_id NUMBER;
    v_api_id NUMBER;
BEGIN
    -- Check if the status is 'Failed'. If so, exit the trigger.
    IF :NEW.status = 'Failure' THEN
        RETURN;
    END IF;
    
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

CREATE OR REPLACE TRIGGER TRG_SUBSCRIPTION_API_ACCESS_INSERT
AFTER INSERT ON subscription
FOR EACH ROW
DECLARE
    v_api_id api.api_id%TYPE;
BEGIN
    -- Get the api_id from pricing_model
    SELECT api_id 
    INTO v_api_id
    FROM pricing_model
    WHERE model_id = :NEW.pricing_model_id;
 
    -- Insert record into api_access
    INSERT INTO api_access (
        access_generated,
        is_active,
        user_id,
        api_id
    ) VALUES (
        SYSDATE,
        CASE 
            WHEN :NEW.status = 'Active' THEN 'Y'
            ELSE 'N'
        END,
        :NEW.user_id,
        v_api_id
    );
END;
/

-- Trigger to update api_access.is_active when subscription.status changes
CREATE OR REPLACE TRIGGER TRG_SUBSCRIPTION_API_ACCESS_UPDATE
AFTER UPDATE OF status ON subscription
FOR EACH ROW
DECLARE
    v_api_id api.api_id%TYPE;
BEGIN
    -- Get the api_id from pricing_model
    SELECT api_id 
    INTO v_api_id
    FROM pricing_model
    WHERE model_id = :NEW.pricing_model_id;

    -- Update api_access is_active based on subscription status
    UPDATE api_access
    SET is_active = CASE 
                        WHEN :NEW.status = 'Active' THEN 'Y'
                        ELSE 'N'
                    END
    WHERE user_id = :NEW.user_id
    AND api_id = v_api_id;
END;
/
