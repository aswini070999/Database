-- LIBRARY MANAGEMENT SYSTEM
-- Database: MySQL
-- Run this file in MySQL Workbench.

CREATE DATABASE IF NOT EXISTS LibraryManagement;
USE LibraryManagement;

-- =========================================================
-- 1. CREATE TABLES
-- =========================================================

CREATE TABLE IF NOT EXISTS Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100),
    category VARCHAR(50),
    isbn VARCHAR(20) UNIQUE,
    quantity INT NOT NULL DEFAULT 0,
    available_quantity INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    registered_date DATE
);

CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Issued',
    CONSTRAINT fk_transactions_book
        FOREIGN KEY (book_id) REFERENCES Books(book_id),
    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- =========================================================
-- 2. VIEW ALL RECORDS
-- =========================================================

SELECT * FROM Books;
SELECT * FROM Users;
SELECT * FROM Transactions;

-- =========================================================
-- 3. INSERT ONE BOOK / ONE USER
-- Change the values before running. Use a new ISBN/email.
-- Run each INSERT only once.
-- =========================================================

INSERT INTO Books (title, author, category, isbn, quantity, available_quantity)
VALUES ('Java Basics', 'James', 'Programming', '9780000000001', 5, 5);

INSERT INTO Users (name, email, phone, address, registered_date)
VALUES ('Arun', 'arun@example.com', '9876543210', 'Chennai', CURDATE());

-- =========================================================
-- 4. UPDATE BOOK / USER DETAILS
-- =========================================================

UPDATE Books
SET title = 'Core Java', author = 'Updated Author'
WHERE book_id = 1;

UPDATE Users
SET phone = '9999999999', address = 'Vellore'
WHERE user_id = 1;

-- =========================================================
-- 5. DELETE A BOOK / USER
-- A book/user linked to Transactions cannot be deleted until
-- the related transaction records are handled.
-- =========================================================

DELETE FROM Books WHERE book_id = 1;
DELETE FROM Users WHERE user_id = 1;

-- =========================================================
-- 6. SEARCH BOOKS
-- =========================================================

-- Search by title
SELECT * FROM Books
WHERE title LIKE '%Java%';

-- Search by author
SELECT * FROM Books WHERE author LIKE '%Kumar%';

-- Search by category
SELECT * FROM Books WHERE category = 'Programming';

-- Search by book ID
SELECT * FROM Books WHERE book_id = 1;

-- =========================================================
-- 7. AVAILABLE BOOKS
-- =========================================================

SELECT * FROM Books
WHERE available_quantity > 0;

-- =========================================================
-- 8. ISSUE BOOK
-- =========================================================

START TRANSACTION;

UPDATE Books
SET available_quantity = available_quantity - 1
WHERE book_id = 1
  AND available_quantity > 0;

-- Save whether the book quantity was successfully decreased.
SET @book_updated = ROW_COUNT();

-- Create the issue transaction only when the book was available.
INSERT INTO Transactions
    (book_id, user_id, issue_date, due_date, status)
SELECT
    1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Issued'
WHERE @book_updated = 1;

COMMIT;

-- Check the result
SELECT * FROM Books WHERE book_id = 1;
SELECT * FROM Transactions ORDER BY transaction_id DESC;

-- =========================================================
-- 9. RETURN BOOK
-- =========================================================

START TRANSACTION;

UPDATE Transactions
SET status = 'Returned',
    return_date = CURDATE()
WHERE transaction_id = 1
  AND status = 'Issued';

-- Save whether the transaction was successfully returned.
SET @transaction_returned = ROW_COUNT();

-- Increase the matching book's available quantity only once.
UPDATE Books b
JOIN Transactions t ON b.book_id = t.book_id
SET b.available_quantity = b.available_quantity + 1
WHERE t.transaction_id = 1
  AND @transaction_returned = 1;

COMMIT;

-- Check the result
SELECT * FROM Books;
SELECT * FROM Transactions WHERE transaction_id = 1;

-- =========================================================
-- 10. VIEW ISSUED BOOKS WITH USER DETAILS
-- =========================================================

SELECT
    t.transaction_id,
    b.title AS book_title,
    u.name AS user_name,
    t.issue_date,
    t.due_date,
    t.status
FROM Transactions t
JOIN Books b ON t.book_id = b.book_id
JOIN Users u ON t.user_id = u.user_id
WHERE t.status = 'Issued';

-- =========================================================
-- 11. COMPLETE TRANSACTION HISTORY
-- =========================================================

SELECT
    t.transaction_id,
    b.title AS book_title,
    u.name AS user_name,
    t.issue_date,
    t.due_date,
    t.return_date,
    t.status
FROM Transactions t
JOIN Books b ON t.book_id = b.book_id
JOIN Users u ON t.user_id = u.user_id
ORDER BY t.transaction_id DESC;

-- =========================================================
-- 12. USER TRANSACTION HISTORY
-- =========================================================

-- Change 1 to the required user_id.
SELECT
    u.user_id,
    u.name,
    b.title,
    t.issue_date,
    t.due_date,
    t.return_date,
    t.status
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Books b ON t.book_id = b.book_id
WHERE u.user_id = 1
ORDER BY t.issue_date DESC;

-- =========================================================
-- 13. OVERDUE BOOKS
-- =========================================================

SELECT
    t.transaction_id,
    b.title AS book_title,
    u.name AS user_name,
    t.due_date
FROM Transactions t
JOIN Books b ON t.book_id = b.book_id
JOIN Users u ON t.user_id = u.user_id
WHERE t.status = 'Issued'
  AND t.due_date < CURDATE();

-- =========================================================
-- 14. COUNT HOW MANY TIMES EACH BOOK WAS ISSUED
-- =========================================================

SELECT
    b.book_id,
    b.title,
    COUNT(t.transaction_id) AS issue_count
FROM Books b
LEFT JOIN Transactions t ON b.book_id = t.book_id
GROUP BY b.book_id, b.title
ORDER BY issue_count DESC;

-- =========================================================
-- 15. COUNT TRANSACTIONS FOR EACH USER
-- =========================================================

SELECT
    u.user_id,
    u.name,
    COUNT(t.transaction_id) AS total_transactions
FROM Users u
LEFT JOIN Transactions t ON u.user_id = t.user_id
GROUP BY u.user_id, u.name
ORDER BY total_transactions DESC;

-- =========================================================
-- 16. CHECK BOOK QUANTITY
-- =========================================================

SELECT
    book_id,
    title,
    quantity,
    available_quantity,
    (quantity - available_quantity) AS currently_issued
FROM Books;

-- =========================================================
-- END OF LIBRARY MANAGEMENT SYSTEM SQL PROJECT
-- =========================================================
