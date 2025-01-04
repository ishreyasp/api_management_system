# API Gateway Management System

## Project Overview
The API Management System is designed to implement a secure and efficient user hierarchy with role-based access control. The system manages various aspects of API operations including user access, subscriptions, billing, and usage tracking. All components are organized in a GitHub repository that contains essential scripts for database creation, user management, and view implementations.

## ER Diagram
![ER_Diagram](https://github.com/user-attachments/assets/1a0bb3ba-5001-413a-bf11-5fd8a2fb537f)

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

By implementing these business rules, the API Gateway Management System ensures robust user management, secure API access, flexible billing models, comprehensive auditing, and effective usage tracking, addressing organizations' key challenges in managing their APIs.

## Roles and Permissions
1. APP_ADMIN:
- Full access to all schemas and tables
- Can perform CRUD (Create, Read, Update, Delete) operations on all tables
- Specific capabilities:
   - Manage users: Add, modify, or delete entries in the 'users' table
   - Manage APIs: Full control over the 'api' table
   - Manage pricing models: Can modify the 'pricing_model' table
   - View and modify all subscriptions, usage tracking, and billing information
   - Full access to logs and requests data
   
2. API_MANAGER:
- Limited administrative access
- Specific capabilities:
   - Manage APIs: Can add, modify, or deprecate APIs in the 'api' table
   - Manage API access: Can modify the 'api_access' table to grant or revoke user access to specific APIs
   - View usage tracking: Read access to the 'usage_tracking' table
   - Cannot directly modify user accounts or billing information
   - Can view logs and request data but cannot modify them
     
3. APP_USER:
- Limited access, primarily to their data
- Specific capabilities:
   - View own user information: Read-only access to their entry in the 'users' table
   - View subscribed APIs: Read-only access to 'api' entries they're subscribed to
   - View own API access: Read-only access to their entries in the 'api_access' table
   - View own usage: Read-only access to their data in the 'usage_tracking' table
   - View own requests: Read-only access to their entries in the 'request' table
   - View own subscription and billing information: Read-only access to their data in 'subscription' and 'billing' tables
   - Cannot access or modify other users' data or system-wide settings
     
## How to use
Execute the SQL files in Oracle SQL Developer sequentially, starting with the lowest number indicated in the file prefix.
Use the following credentials to connect to the database:
- Log in as system DBA. Run file 1.
- Log in as APP_ADMIN with password dbms#Admin1@ApiGateway. Run files 2 to 8 and 11.
- Log in as API_MANAGER with password dbms#APIMANAGER1@ApiGateway to execute file 9.
- Log in as APP_USER with password dbms#AppUser1@ApiGateway to execute file 10.
