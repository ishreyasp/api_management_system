SET SERVEROUTPUT ON;

-- Inserting users
DECLARE
    v_message VARCHAR2(200);
BEGIN
    insert_into_api_management_system_pkg.sp_insert_into_user( 'john_doe', 'John', 'Doe', 'Student', 'API_TOKEN_123', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_user('jane_smith', 'Jane', 'Smith', 'General', 'API_TOKEN_456', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_user('bob_wilson', 'Bob', 'Wilson', 'General', 'API_TOKEN_789', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_user('neelabh_bharwaj', 'neelabh', 'bhardwaj', 'Student', 'API_TOKEN_780', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error inserting into api users: ' || sqlerrm);
END;
/

-- Updating user
DECLARE
   v_message VARCHAR2(200);
BEGIN
    update_into_api_management_system_pkg.sp_update_api_user_details('john_doe', 'Johnny', 'Doeman', null, null, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error updating api users: ' || sqlerrm);
END;
/

-- Deleting user
DECLARE
   v_message VARCHAR2(100);
BEGIN
    delete_from_api_management_system_pkg.sp_delete_user('john_doe', v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error deleting api users: ' || sqlerrm);
END;
/

-- Inserting pricing models
DECLARE
    v_message VARCHAR2(200);
BEGIN
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model( 'subscription', 99.9 , 4, 200, v_message );
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('pay_per_request', 0.1 , null, 201, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('subscription', 99.9 , 5, 202, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('pay_per_request', 0.1 , null, 203, v_message);
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
   update_into_api_management_system_pkg.sp_update_into_pricing_model( 400, 8.99, v_message);
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
    manage_api_pkg.sp_delete_pricing_model('400', v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error deleting pricing model: ' || sqlerrm);
END;
/

-- Set subscription status to expired
DECLARE
    v_result VARCHAR2(50);
BEGIN
    v_result := update_subscription_status(703);
    DBMS_OUTPUT.PUT_LINE(v_result);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error updating subscription status: ' || sqlerrm);
END;
/