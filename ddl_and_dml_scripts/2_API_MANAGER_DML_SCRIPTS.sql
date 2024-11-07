-- Insert records for API table
BEGIN 
    INSERT INTO API (API_ID, API_NAME, DESCRIPTION)
    VALUES(1, 'WeatherAPI', 'Provides weather forecasts and historical data');

    INSERT INTO API (API_ID, API_NAME, DESCRIPTION)
    VALUES(2, 'CurrencyConverterAPI', 'Converts currencies in real-time');

    INSERT INTO API (API_ID, API_NAME, DESCRIPTION)
    VALUES(3, 'MapServiceAPI', 'Offers mapping and geolocation services');

    INSERT INTO API (API_ID, API_NAME, DESCRIPTION)
    VALUES(4, 'StockMarketAPI', 'Delivers stock market data and analysis');

    INSERT INTO API (API_ID, API_NAME, DESCRIPTION)
    VALUES(5, 'ECommerceAPI', 'Facilitates e-commerce functionalities like product listing and order management');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Sample data inserted successfully in API table.');

END;
/ 

-- Insert records for API_ACCESS table
BEGIN
    INSERT INTO API_ACCESS(access_id, access_generated, is_active, user_id, api_id)
    VALUES (1, SYSDATE, 1, 1, 1);

    INSERT INTO API_ACCESS(access_id, access_generated, is_active, user_id, api_id)
    VALUES (2, SYSDATE, 1, 2, 2);

    INSERT INTO API_ACCESS(access_id, access_generated, is_active, user_id, api_id)
    VALUES (3, SYSDATE, 1, 3, 3);

    INSERT INTO API_ACCESS(access_id, access_generated, is_active, user_id, api_id)
    VALUES (4, SYSDATE, 1, 4, 4);

    INSERT INTO API_ACCESS(access_id, access_generated, is_active, user_id, api_id)
    VALUES (5, SYSDATE, 1, 5, 5);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Sample data inserted successfully into API_ACCESS table.');

END;
/

-- Insert records for PRICING_MODEL table
BEGIN
   
    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (1, 'pay_per_request', 0.500, 1000, 101);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (2, 'subscription', 15.000, NULL, 102);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (3, 'pay_per_request', 1.250, 500, 103);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (4, 'subscription', 25.000, NULL, 104);

    INSERT INTO PRICING_MODEL (model_id, model_type, rate, request_limit, api_api_id)
    VALUES (5, 'pay_per_request', 0.750, 2000, 105);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dummy records inserted successfully in pricing_model table.');
END;
/