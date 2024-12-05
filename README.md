# API Management System

## Execution Flow
Execute the scripts as mentioned below and connect with the specified roles
   1. SYSDB - 1_app_admin.sql
   2. APP_ADMIN - Scripts (2 - 7), 8, 11
   3. API_MANAGER - Script 9
   4. APP_USER - Script 10

## Project Overview
The API Gateway Management System is a comprehensive solution designed to address the challenges faced by organizations in managing, securing, and monetizing their APIs. The key objectives of this project are:
1.	User Authentication: Implement a secure method for users to authenticate and access the APIs
2.	Billing Mechanism: Develop a billing system that charges users based on their API usage, including both pay-per-request and subscription-based models
3.	Auditing and Logging: Maintain thorough logs of every API request and response, including timestamps, user identity, services accessed, and performance metrics

## Business Rules
The API Gateway Management System is governed by the following business rules:
1.	User Management: 
   - Every user must have a unique user_id.
   - Every user must have a role, which can be either "Student" or "General".
   - Session tokens are validated to ensure users have the necessary permissions to access the API.
2.	API Access: 
   - A user can have access to multiple APIs.
   - Every API request must be validated before the user can make the request.
   - Access to an API must be granted before a user can make requests.
3.	Subscriptions: 
   - A user must have at least one active subscription to access the API.
- Discounts can be applied to subscriptions, with a default discount of 0%.
- Users with the "Student" role receive a 20% discount on their subscriptions.
-	If a subscription is expired, the user cannot access the API.
4.	Pricing Models: 
- Each API will have two pricing models: "Pay-Per-Request" and "Monthly Subscription".
- Users on the pay-per-request model will be charged immediately after each successful API call.
-	Users on the subscription model will be charged at the end of the subscription period.
-	Users will only be charged if the API request is successful.
5.	Requests: 
-	Every API request must be logged.
6.	Billing: 
-	Bills are generated based on subscriptions and usage.
7.	Usage Tracking: 
-	The request count must not exceed the limit defined in the pricing model.
8.	Validations and Constraints: 
-	The username and api_token fields in the USERS table must be unique.
-	The role field in the USERS table must be one of "General" or "Student".
-	The response_time field in the REQUEST table must be greater than or equal to 0.
-	The total_amount field in the BILLING table must be greater than or equal to 0.
-	The end_date of a SUBSCRIPTION must be greater than the start_date.
-	The discount field in the SUBSCRIPTION table has a default value of 0.
-	The model_type field in the PRICING_MODEL table must be either "pay-per-request" or "subscription".
-	The rate and request_limit fields in the PRICING_MODEL table must be greater than 0.
By implementing these business rules, the API Gateway Management System ensures robust user management, secure API access, flexible billing models, comprehensive auditing, and effective usage tracking, addressing the key challenges faced by organizations in managing their APIs.

## Workflow
### Github Link: 
```https://github.com/Deepthi-Nasika/dmdd_api_management_system/tree/main```

Here's the implementation workflow for your API Gateway Management System project:
### Application Administrator (APP_ADMIN)
1.	APP_ADMIN Setup
-	With System Database Administrator (SYSDBA), the initial step is to create APP_ADMIN role who will manage the entire API management system application
-	To create APP_ADMIN from SYSDBA execute 1_app_admin.sql script
2.	Execute DDL & DML Scripts
-	Execute DDL-DML-Scripts for creating tables – USERS, API, API_ACCESS, PRICING_MODEL, REQUESTS, USAGE_TRACKING, SUBSCRIPTION, and BILLING
-	The DML Script will populate the tables with sample data of 5 records in each table
3.	Create Views
-	Execute views.sql script to create views - 
o	ActiveUserSubscriptions – Views all active subscriptions for each user.
o	APIUsageByUser – Displays the number of requests made by each user for each API.
o	BillingHistory – Shows billing history for each user, including subscription details.
o	APIPerformanceMetrics – Displays average response time and request count for each API.
o	UserAccessRights – Shows which APIs each user has access to and the access status.
•	Execute user_dashboard_view.sql script to display user specific views, data related to particular user like API usage with respect to user, number of requests with respect to user
4.	Role Creation – API Manager, Basic User
-	Once APP_ADMIN role is created, the APP_ADMIN’s first task is to create 2 roles – API Manager and Basic User
-	For creating API Manager execute 2_api_manager.sql script
-	For creating Basic User execute 3_basic_user.sql script

### API  Manager Functionality(API_MANAGER)
1.	Validate Permissions
- 	Test App Manager access and permissions by executing select, insert, alter, update statements as API_MANAGER on views and tables to validate the granted permissions
- 	API Manager has access to modify API, API_ACCESS tables and can view other user information like api_usage, request_count, subscribers and etc

### Basic User Functionality (BASIC_USER)
1.	User Specific Views
-	Execute the below script to display data specific to a user:

Script for Accessing the View as a Basic_User
```
-- Set the USER_ID in the session context to view user-specific data 
BEGIN 
APP_ADMIN.set_user_id(1);  -- Replace 1 with the actual USER_ID you want to view
END;
/
-- Query the view to see data for the set USER_ID 

SELECT * FROM APP_ADMIN.user_dashboard;
```


2.	Validate Permissions
-	Test Basic User access and permissions by executing select, insert, alter, update statements as BASIC_USER on views and tables to validate the granted permissions
- Users can create records in requests table with respect to user id, api access key.
This workflow ensures that the API Gateway Management System is set up correctly, with the appropriate user roles and access permissions. The APP_ADMIN user is responsible for the initial setup and ongoing management, while the API_MANAGER and BASIC_USER roles have specific permissions to perform their respective tasks within the system.

## Project Tree
```
dmdd_api_management_system/
├── ddl_and_dml_scripts/
│   └── 1_APP_ADMIN_DDL_DML_SCRIPT.sql
├── users/
│   ├── 1_app_admin.sql
│   ├── 2_api_manager.sql
│   └── 3_basic_user.sql
├── views/
│   ├── user_dashboard_view.sql
│   └── views.sql
└── README.md 
```
