set serveroutput on;

ALTER SESSION SET current_schema=APP_ADMIN;

SELECT * FROM api;

SELECT * FROM pricing_model;

DECLARE
    v_message VARCHAR2(100);
BEGIN
    api_request_pkg.sp_subscribe_user_to_api('john_doe', 201, 401, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/ 

DECLARE
    v_message VARCHAR2(100);
BEGIN
    api_request_pkg.sp_api_request(
        p_api_id => 201,             
        p_username => 'john_doe',            
        p_request_body => 'Sample Request', 
        p_status => 'SUCCESS',
        p_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/

BEGIN 
    APP_ADMIN.set_user_id(100);
END; 
/ 

SELECT * FROM user_dashboard;
