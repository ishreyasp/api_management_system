-- Insert records for REQUESTS table
BEGIN
    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (1, SYSDATE, 1.234, 'Success', 'Request data 1', 'Response data 1', 1, 1);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (2, SYSDATE, 2.345, 'Failure', 'Request data 2', 'Response data 2', 2, 2);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (3, SYSDATE, 0.987, 'Success', 'Request data 3', 'Response data 3', 3, 3);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (4, SYSDATE, 1.234, 'Success', 'Request data 4', 'Response data 4', 4, 4);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (5, SYSDATE, 3.456, 'Failure', 'Request data 5', 'Response data 5', 5, 5);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (6, SYSDATE, 1.987, 'Success', 'Request data 6', 'Response data 6', 1, 1);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (7, SYSDATE, 2.678, 'Success', 'Request data 7', 'Response data 7', 2, 2);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (8, SYSDATE, 1.123, 'Failure', 'Request data 8', 'Response data 8', 3, 3);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (9, SYSDATE, 0.876, 'Success', 'Request data 9', 'Response data 9', 4, 4);

    INSERT INTO REQUESTS (request_id, timestamp, response_time, status, request_body, response_body, user_id, access_id)
    VALUES (10, SYSDATE, 4.567, 'Failure', 'Request data 10', 'Response data 10', 5, 5);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('10 records inserted successfully into REQUESTS table.');
END;
/