SET SERVEROUTPUT ON;

-- Inserting users
DECLARE
    v_message VARCHAR2(200);
BEGIN
    api_management_system_admin_pkg.sp_insert_into_user( 'john_doe', 'John', 'Doe', 'Student', 'API_TOKEN_123', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('jane_smith', 'Jane', 'Smith', 'General', 'API_TOKEN_456', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('bob_wilson', 'Bob', 'Wilson', 'General', 'API_TOKEN_789', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('neelabh_bharwaj', 'neelabh', 'bhardwaj', 'Student', 'API_TOKEN_780', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user( 'deepthi_nasika', 'Deepthi', 'Nasika', 'Student', 'API_TOKEN_454', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('shreyas_purkar', 'Shreyas', 'Purkar', 'General', 'API_TOKEN_653', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('siddharth_dash', 'Siddharth', 'Dash', 'Student', 'API_TOKEN_713', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('mani_khandan', 'Mani', 'Khandan', 'General', 'API_TOKEN_134', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
     api_management_system_admin_pkg.sp_insert_into_user('naveen_kumar', 'Naveen', 'Kumar', 'General', 'API_TOKEN_398', SYSDATE, SYSDATE+30, v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    api_management_system_admin_pkg.sp_insert_into_user('aqeel_ryan', 'Aqeel', 'Ryan', 'Student', 'API_TOKEN_298', SYSDATE, SYSDATE+30, v_message);
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
    api_management_system_admin_pkg.sp_update_api_user_details('john_doe', 'Johnny', 'Doeman', '03-Feb-2025', 'Student', v_message);
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
    api_management_system_admin_pkg.sp_delete_user('jane_smith', v_message);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error deleting api users: ' || sqlerrm);
END;
/

-- Set subscription status to expired
DECLARE
    v_result VARCHAR2(50);
BEGIN
    v_result := update_subscription_status(715);
    DBMS_OUTPUT.PUT_LINE(v_result);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error updating subscription status: ' || sqlerrm);
END;
/