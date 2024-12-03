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


-- Trigger for generating billing for Subscription model
CREATE OR REPLACE TRIGGER generate_subscription_billing
AFTER UPDATE OF status ON subscription
FOR EACH ROW
WHEN (NEW.status = 'Expired')
DECLARE
    v_username          api_users.username%TYPE;
    v_api_id            api.api_id%TYPE;
BEGIN
    -- Generate billing for expired subscription
    -- Retrieve the API id associated with the subscription_id
    SELECT pm.api_id
    INTO v_api_id
    FROM pricing_model pm
    JOIN subscription s ON s.model_id = pm.model_id
    WHERE s.subscription_id = NEW.subscription_id;

    -- Retrieve the username associated with the subscription_id
    SELECT u.username
    INTO v_username
    FROM subscription s
    JOIN api_users u ON s.user_id = u.user_id
    WHERE s.subscription_id = NEW.subscription_id;

    billing_pkg.generate_billing(
        p_subscription_id => :NEW.subscription_id,
        v_username,
        v_api_id
    );
END;
/

-- Trigger for generating billing for Pay Per Use model
CREATE OR REPLACE TRIGGER update_billing
AFTER INSERT ON REQUESTS
FOR EACH ROW
DECLARE
    v_request_limit INTEGER;
    v_request_count INTEGER;
    v_user_id NUMBER;
    v_api_id NUMBER;
    v_username          api_users.username%TYPE;
    v_api_id            api.api_id%TYPE;
BEGIN
    -- Retrieve the API id associated with the subscription_id
    SELECT pm.api_id
    INTO v_api_id
    FROM pricing_model pm
    JOIN subscription s ON s.model_id = pm.model_id
    WHERE s.subscription_id = NEW.subscription_id;

    -- Retrieve the username associated with the subscription_id
    SELECT u.username
    INTO v_username
    FROM subscription s
    JOIN api_users u ON s.user_id = u.user_id
    WHERE s.subscription_id = NEW.subscription_id;

    billing_pkg.generate_billing(
        p_subscription_id => :NEW.subscription_id,
        v_username,
        v_api_id
    );
END;
/

