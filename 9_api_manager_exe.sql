ALTER SESSION SET current_schema = app_admin;

SET SERVEROUTPUT ON;

-- Inserting APIs
DECLARE
v_message VARCHAR2(200);
BEGIN
    manage_api_pkg.sp_insert_into_api( 'https://www.weather.com','Provides real-time weather forecasting data',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_api('https://www.payment_authentication.com', 'Handles secure payment processing',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_api('https://www.maps.com', 'Provides mapping and location services',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_api('https://www.authy.com', 'Handles user authentication and authorization',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_api('https://www.northeastern.edu', 'Northeastern University website',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error inserting into api: ' || sqlerrm);
END;
/

-- Updating APIs
DECLARE
v_message VARCHAR2(200);
BEGIN
    manage_api_pkg.sp_update_api( 'https://www.weather.com', 'https://www.weather.in', null, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error updating api: ' || sqlerrm);
END;
/

-- Deleting API
DECLARE
   v_message VARCHAR2(100);
BEGIN
    manage_api_pkg.sp_delete_api('201', v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error deleting api: ' || sqlerrm);
END;
/

-- Inserting pricing models
DECLARE
    v_message VARCHAR2(200);
BEGIN
    manage_api_pkg.sp_insert_into_pricing_model( 'subscription', 99.99 , 20, 200, v_message );
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_pricing_model('pay_per_request', 9.9 , null, 201, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_pricing_model('subscription', 89.99 , 25, 202, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_pricing_model('pay_per_request', 19.99 , null, 203, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    manage_api_pkg.sp_insert_into_pricing_model('pay_per_request', 1.99 , null, 204, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error inserting into pricing model: ' || sqlerrm);
END;
/

-- Updating pricing model
DECLARE
   v_message VARCHAR2(200);
BEGIN
   manage_api_pkg.sp_update_into_pricing_model( 401, 19.99, v_message);
   DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
   
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error updating pricing model: ' || sqlerrm);
END;
/

-- Deleting pricing model
DECLARE
   v_message VARCHAR2(100);
BEGIN
    manage_api_pkg.sp_delete_pricing_model('402', v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error deleting pricing model: ' || sqlerrm);
END;
/

-- Updating API access status
DECLARE
v_message VARCHAR2(200);
BEGIN
    manage_api_pkg.sp_update_api_access( 'john_doe', 200, 'Y', v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
 EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error inserting into api_access: ' || sqlerrm);
END;
/