API Management System Documentation
Project Overview

The API Management System is designed to implement a secure and efficient user hierarchy with role-based access control. The system manages various aspects of API operations including user access, subscriptions, billing, and usage tracking. All components are organized in a GitHub repository that contains essential scripts for database creation, user management, and view implementations.

Repository Organization
The project maintains a clean and organized structure on GitHub with three primary directories:


1.	DDL and DML Scripts Directory
a.	Contains all database object creation scripts
b.	Includes data population scripts for initial setup
c.	Establishes the foundational database schema

2.    Users Directory
a.	Houses scripts for different user role creations
b.	Contains permission and privilege management scripts
c.	Defines the security hierarchy of the system

3.    Views Directory
a.	Contains all view definitions for different user roles
b.	Implements role-specific data access controls
c.	Manages data visibility based on user permissions



IMPLEMENTATION WORKFLOW

Initial Setup by System Database Administrator (SYSDBA)
The implementation begins with the SYSDBA, who has the highest level of database privileges. Their primary responsibility is to create the APP_ADMIN user, who will then manage the entire API management system. This critical first step establishes the foundation for all subsequent operations.

Application Administrator (APP_ADMIN) Setup Phase
Once created by SYSDBA, APP_ADMIN takes on the role of primary system administrator. The APP_ADMIN's first task is to execute all DDL and DML scripts to create and populate the database tables. This includes setting up tables for users, APIs, subscriptions, billing, and usage tracking. After establishing the database structure, APP_ADMIN creates necessary views that will serve different user roles.




User Role Creation and Permission Management
After setting up the database structure and views, APP_ADMIN proceeds to create two types of users:

1.	API Manager Creation The API Manager role is created with specific permissions focused on API management and monitoring. This role has elevated privileges for API-related operations but restricted access to user and billing information.

2.	Basic User Creation Basic Users are created with limited permissions, primarily focused on accessing their own data and performing basic API operations. Their access is strictly controlled through specialized views and permission sets.


Execution Sequence
The project must be executed in a specific sequence to ensure proper functionality:

1.	Begin with SYSDBA creating the APP_ADMIN user

Path: dmdd_api_management_system/ users/ 1_app_admin.sql


2.	APP_ADMIN executes database creation scripts

Path: dmdd_api_management_system/ ddl_and_dml_scripts/ 1_APP_ADMIN_DDL_DML_SCRIPTS.sql



3.	APP_ADMIN creates views 

Path: dmdd_api_management_system/ views/ views.sql



4 . APP_ADMIN creates Views for Basic_User

Path: dmdd_api_management_system/ views/ user_dashboard_view.sql



5. APP_ADMIN creates and configures API Manager

 Path: dmdd_api_management_system/users/ 2_api_manager.sql




6.APP_ADMIN creates and configures Basic Users

       Path: dmdd_api_management_system/users/ 3_basic_user.sql

7.	Test API Manager access and permissions by running queries  as API_MANAGER on  views and tables that API_Manager has access to, to validate the Granted Permissions.



8.	Test Basic User access and permissions by running queries as Basic_User on  views and tables that Basic_User  has access to , to validate the Granted Permissions.


Script for Accessing the View as a Basic_User


-- Set the USER_ID in the session context to view user-specific data 

BEGIN 
APP_ADMIN.set_user_id(1);  -- Replace 1 with the actual USER_ID you want to view 

END/;

 -- Query the view to see data for the set USER_ID 

SELECT * FROM APP_ADMIN.user_dashboard;


























BUSINESS RULES
1.	User Management: 

o Every user has a unique username 
o Every user must have a role 
o User roles must be one of: "Student" or "General" 
o Session tokens are validated for a user to have permission to access the API 

2.	APIAccess:

o A user can have access to multiple APIs
o Every API must be validated to make an API request
o Access to an API must be granted before a user can make requests 

3.	Subscriptions:

o A user should have at least one active subscription
o Discounts can be applied to subscriptions, with a default of 0 o Student role gets a discount of 20%
o If a subscription is expired user cannot access the API 

4.	Pricing: 

o Each API will have both the Pricing model ‘Pay-Per-Request’ and ‘Monthly Subscription’ 
o Users on the pay-per-request model will be charged immediately after each successful API call 
o Users on the subscription model will be charged at the end of the subscription period 
o The user will be charged only if the API request is successful 



5.	Requests: 

o Every API request must be logged 


6.	Billing: 

o Bills are generated based on subscriptions and usage 

7.	UsageTracking:
 
o The request count must not exceed the limit defined in the pricing model 

