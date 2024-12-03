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

--Only API_MANAGER CAN INSERT THE VALUES INTO API 





DECLARE
    v_message VARCHAR2(200);
BEGIN
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model( 'Weather API','Provides real-time weather forecasting data',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('Payment Gateway API', 'Handles secure payment processing',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_management_system_pkg.sp_insert_into_pricing_model('Maps API', 'Provides mapping and location services',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
   insert_into_api_management_system_pkg.sp_insert_into_pricing_model('Auth API', 'Handles user authentication and authorization',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
     EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error inserting into api: ' || sqlerrm);
END;
/

