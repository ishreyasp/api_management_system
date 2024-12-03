CREATE OR REPLACE TRIGGER update_usage_tracking_and_billing
AFTER INSERT ON REQUESTS
FOR EACH ROW
DECLARE
    v_request_limit     pricing_model.request_limit%TYPE;
    v_request_count     usage_tracking.request_count%TYPE;
    v_user_id           api_users.user_id%TYPE;
    v_api_id            api.api_id%TYPE;
    v_pricing_model     pricing_model.model_type%TYPE;
    v_rate              pricing_model.rate%TYPE;
    v_subscription_id  subscription.subscription_id%TYPE;
    v_discount         subscription.discount%TYPE;
    v_tracking_id      subscription.usage_tracking_id%TYPE;
    v_billing_id       billing.billing_id%TYPE;
    v_total_amount     billing.total_amount%TYPE;
    v_message          VARCHAR2(4000);
BEGIN
    -- Check if the status is 'Failed'. If so, exit the trigger.
    IF :NEW.status = 'Failure' THEN
        RETURN;
    END IF;
    
    -- Retrieve the request limit, subscription-id, usage_tracking_id, rate, model_type for the API, Pricing model associated with the access_id
    SELECT pm.request_limit, s.subscription_id, s.discount, s.usage_tracking_id, pm.api_id, pm.model_type, pm.rate
    INTO v_request_limit, v_subscription_id, v_discount, v_tracking_id, v_api_id, v_pricing_model, v_rate
    FROM API_ACCESS aa
    JOIN subscription s ON aa.user_id = s.user_id
    JOIN PRICING_MODEL pm ON s.pricing_model_id = pm.model_id
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

    -- Retrieve request_count from usage_tracking
    SELECT request_count
    INTO v_request_count
    FROM usage_tracking
    WHERE tracking_id = v_tracking_id;
    
    -- Update the total amount in existing record
    SELECT billing_id, total_amount
    INTO v_billing_id, v_total_amount
    FROM billing 
    WHERE subscription_id = v_subscription_id;
    
    v_total_amount := v_rate * v_request_count;
    v_total_amount := v_total_amount - (v_total_amount * v_discount);

    IF v_pricing_model = 'pay_per_request' THEN
        UPDATE billing
        SET total_amount = ROUND(v_total_amount,2),
            billing_date = SYSDATE
        WHERE subscription_id = v_subscription_id;
    END IF;

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
    v_username         api_users.username%TYPE;
    v_api_id           api.api_id%TYPE;
    v_discount         subscription.discount%TYPE;
    v_tracking_id      subscription.usage_tracking_id%TYPE;
    v_message          VARCHAR2(4000);
    v_pricing_model    pricing_model.model_type%TYPE;
    v_rate             pricing_model.rate%TYPE;
    v_request_limit    pricing_model.request_limit%TYPE;
    v_billing_id       billing.billing_id%TYPE;
    v_total_amount     billing.total_amount%TYPE;
    v_request_count    usage_tracking.request_count%TYPE;
BEGIN
    -- Retrieve the API ID, model type, rate, request limit, and discount for the subscription
    SELECT pm.api_id, pm.model_type, pm.rate, pm.request_limit, NVL(:NEW.discount, 0)
    INTO v_api_id, v_pricing_model, v_rate, v_request_limit, v_discount
    FROM pricing_model pm
    WHERE pm.model_id = :NEW.pricing_model_id;

    -- Retrieve request_count from usage_tracking
    SELECT request_count
    INTO v_request_count
    FROM usage_tracking
    WHERE tracking_id = :NEW.usage_tracking_id;

    -- Calculate the total amount for subscription billing
    v_total_amount := v_rate * v_request_limit;
    v_total_amount := v_total_amount - (v_total_amount * v_discount);

    -- Update the total amount in the billing table if the subscription already exists
    UPDATE billing
    SET total_amount = ROUND(v_total_amount, 2),
        billing_date = SYSDATE
    WHERE subscription_id = :NEW.subscription_id;

END;
/
