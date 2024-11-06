-- View UserAccessRights: Shows which APIs each user has access to and the access status.
CREATE OR REPLACE VIEW user_api_access AS
    SELECT
        users.user_id,
        users.username,
        api.api_id,
        api.api_name,
        api_access.is_active
    FROM
        users users
        JOIN api_access api_access ON users.user_id = api_access.user_id
        JOIN api api ON api.api_id = api_access.api_id
    WHERE
        api_access.is_active = 1;