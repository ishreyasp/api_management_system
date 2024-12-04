set serveroutput on;

ALTER SESSION SET current_schema=APP_ADMIN;

DECLARE
    v_message VARCHAR2(100);
BEGIN
    api_request_pkg.sp_subscribe_user_to_api('john_doe', 400, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('john_doe', 401, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('john_doe', 404, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('jane_smith', 402, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('jane_smith', 403, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('bob_wilson', 401, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('bob_wilson', 404, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('neelabh_bharwaj', 400, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('neelabh_bharwaj', 402, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('deepthi_nasika', 403, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('deepthi_nasika', 404, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('shreyas_purkar', 402, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('siddharth_dash', 402, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('siddharth_dash', 403, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('mani_khandan', 400, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('naveen_kumar', 400, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('aqeel_ryan', 403, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_subscribe_user_to_api('aqeel_ryan', 404, SYSDATE, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error subscribing to APIs: ' || sqlerrm);
END;
/ 

BEGIN 
    APP_ADMIN.set_user_id(100);
END; 
/ 

SELECT * FROM user_dashboard;

DECLARE
    v_message VARCHAR2(100);
BEGIN
    api_request_pkg.sp_api_request(200, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'john_doe', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'john_doe', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(201, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(201, 'john_doe', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'john_doe', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'john_doe', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);    
    api_request_pkg.sp_api_request(202, 'jane_smith', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'jane_smith', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'jane_smith', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'jane_smith', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'jane_smith', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'jane_smith', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'jane_smith', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'jane_smith', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);    
    api_request_pkg.sp_api_request(203, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'deepthi_nasika', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'deepthi_nasika', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'deepthi_nasika', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'deepthi_nasika', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'deepthi_nasika', 'Sample Request', 'Failure', v_message);    
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'shreyas_purkar', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'shreyas_purkar', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'shreyas_purkar', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'shreyas_purkar', 'Sample Request', 'Success', v_message);   
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'siddharth_dash', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'siddharth_dash', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'siddharth_dash', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'siddharth_dash', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);    
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'neelabh_bharwaj', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'neelabh_bharwaj', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'neelabh_bharwaj', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(202, 'neelabh_bharwaj', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);    
    api_request_pkg.sp_api_request(200, 'mani_khandan', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'mani_khandan', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'mani_khandan', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);     
    api_request_pkg.sp_api_request(200, 'naveen_kumar', 'Sample Request', 'Failure', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(200, 'naveen_kumar', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);    
    api_request_pkg.sp_api_request(203, 'aqeel_ryan', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(203, 'aqeel_ryan', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    api_request_pkg.sp_api_request(204, 'aqeel_ryan', 'Sample Request', 'Success', v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
    
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Failed to request service from APIs: ' || sqlerrm);
END;
/
