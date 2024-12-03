ALTER SESSION SET current_schema = app_admin;

SET SERVEROUTPUT ON;
DECLARE
v_message VARCHAR2(200);
BEGIN
    insert_into_api_and_api_access_pkg.sp_insert_api( 'Weather API','Provides real-time weather forecasting data',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    insert_into_api_and_api_access_pkg.sp_insert_api('Payment Gateway API', 'Handles secure payment processing',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
   insert_into_api_and_api_access_pkg.sp_insert_api('Maps API', 'Provides mapping and location services',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
  insert_into_api_and_api_access_pkg.sp_insert_api('Auth API', 'Handles user authentication and authorization',v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error inserting into api: ' || sqlerrm);
END;
/

