set serveroutput on;

ALTER SESSION SET current_schema=APP_ADMIN;

DECLARE
    v_message VARCHAR2(100);
BEGIN
    api_request_pkg.sp_api_request(
        p_api_id => 1,             
        p_user_id => 1,            
        p_request_body => 'Sample', 
        p_response_body => 'Sample',
        p_status => 'SUCCESS',
        p_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/