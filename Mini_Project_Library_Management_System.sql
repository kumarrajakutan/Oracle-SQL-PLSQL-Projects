-- Library Management System (PL/SQL Project)

-- 1. Create Tables
CREATE TABLE members (
    member_id NUMBER PRIMARY KEY,
    member_name VARCHAR2(100),
    join_date DATE
);

CREATE TABLE books (
    book_id NUMBER PRIMARY KEY,
    book_title VARCHAR2(200),
    author_name VARCHAR2(100),
    quantity NUMBER
);

CREATE TABLE issues (
    issue_id NUMBER PRIMARY KEY,
    member_id NUMBER,
    book_id NUMBER,
    issue_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- 2. Create Sequence for Issues
CREATE SEQUENCE issues_seq START WITH 1 INCREMENT BY 1;

-- 3. Insert Sample Data
INSERT INTO members VALUES (1, 'Alice Johnson', SYSDATE);
INSERT INTO members VALUES (2, 'Bob Smith', SYSDATE);

INSERT INTO books VALUES (101, 'Oracle Database Fundamentals', 'John Doe', 5);
INSERT INTO books VALUES (102, 'PL/SQL Programming', 'Jane Roe', 3);

COMMIT;

-- 4. Procedure to Issue a Book
CREATE OR REPLACE PROCEDURE issue_book(
    p_member_id IN NUMBER,
    p_book_id IN NUMBER
) AS
    v_quantity NUMBER;
BEGIN
    SELECT quantity INTO v_quantity
    FROM books
    WHERE book_id = p_book_id;

    IF v_quantity > 0 THEN
        INSERT INTO issues (issue_id, member_id, book_id, issue_date)
        VALUES (issues_seq.NEXTVAL, p_member_id, p_book_id, SYSDATE);

        UPDATE books
        SET quantity = quantity - 1
        WHERE book_id = p_book_id;

        DBMS_OUTPUT.PUT_LINE('Book issued successfully!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Book not available.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Book ID not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- 5. Trigger to Auto Update Book Quantity After Return
CREATE OR REPLACE TRIGGER after_return_update
AFTER UPDATE OF return_date ON issues
FOR EACH ROW
WHEN (OLD.return_date IS NULL AND NEW.return_date IS NOT NULL)
BEGIN
    UPDATE books
    SET quantity = quantity + 1
    WHERE book_id = :NEW.book_id;
END;
/

-- 6. Example Usage
-- To Issue a Book:
-- EXEC issue_book(1, 101);

-- To Return a Book (update return_date):
-- UPDATE issues SET return_date = SYSDATE WHERE issue_id = 1;
-- COMMIT;
