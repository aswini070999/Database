# Library Management System

## Project Description
The Library Management System is a database project developed using MySQL. It helps manage books, users, and book issue and return transactions.

## Technologies Used
- MySQL
- SQL
- VS Code

## Database Tables

### 1. Books
Stores book details such as:
- Book ID
- Title
- Author
- Category
- ISBN
- Quantity
- Available Quantity

### 2. Users
Stores library user details such as:
- User ID
- Name
- Email
- Phone
- Address
- Registered Date

### 3. Transactions
Stores book issue and return details such as:
- Transaction ID
- Book ID
- User ID
- Issue Date
- Due Date
- Return Date
- Status

## Relationships
- One book can have multiple transactions.
- One user can have multiple transactions.
- Transactions table uses foreign keys to connect Books and Users.

## Features
- Create and manage books.
- Add and manage users.
- Search for books.
- Issue books.
- Return books.
- Automatically update available book quantity.
- View transaction history.
- Track overdue books.
- Check duplicate records.

## SQL Operations
- CREATE
- INSERT
- SELECT
- UPDATE
- DELETE
- JOIN
- GROUP BY
- Stored Procedure is not used.

## How to Run
1. Open MySQL Workbench.
2. Open `Library_Management_System_Updated.sql`.
3. Select the `LibraryManagement` database.
4. Execute the SQL statements section by section.
5. Check the output using SELECT queries.