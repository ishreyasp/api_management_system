SET SERVEROUTPUT ON;

DECLARE
    v_message VARCHAR2(200);
BEGIN
    insert_into_api_management_system_pkg.sp_insert_into_user( 'john_doe','John','Doe','Student','API_TOKEN_123',SYSDATE,SYSDATE + 30,v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_user('jane_smith', 'Jane', 'Smith', 'General', 'API_TOKEN_456', SYSDATE,SYSDATE + 30,v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_user('bob_wilson', 'Bob', 'Wilson', 'Student', 'API_TOKEN_789', SYSDATE,SYSDATE + 30,v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
   insert_into_api_management_system_pkg.sp_insert_into_user('neelabh_bharwaj', 'neelabh', 'bhardwaj', 'Student', 'API_TOKEN_780', SYSDATE,SYSDATE + 30,v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error inserting into api_users: ' || sqlerrm);
END;
/


DECLARE
   v_message VARCHAR2(200);
BEGIN
-- Update John Doe's details
update_into_api_management_system_pkg.sp_update_user('john_doe','Johnny', 'Doeman','NEW_TOKEN_123',SYSDATE,SYSDATE + 60, v_message);
   DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error updating api_users: ' || sqlerrm);
END;
/

--Only API_MANAGER CAN INSERT THE VALUES INTO API 





DECLARE
    v_message VARCHAR2(200);
BEGIN
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model( 'subscription', 99.9 , 4, 204, v_message );
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('pay_per_request', 0.1 , 5, 205, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('subscription', 99.9 , 5, 206, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
   insert_into_api_management_system_pkg.sp_insert_into_pricing_model('pay_per_request', 0.1 , 5, 207, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
     EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error inserting into api: ' || sqlerrm);
END;
/


DECLARE
   v_message VARCHAR2(200);
BEGIN
   -- Update rate for pricing model ID 1
   update_into_api_management_system_pkg.sp_update_into_pricing_model( 416, 8.99, v_message);
   DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
 EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error inserting into api: ' || sqlerrm);
END;
/