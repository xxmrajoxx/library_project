SELECT * FROM BOOKS
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES
SELECT * FROM ISSUED_STATUS
SELECT * FROM RETURN_STATUS
SELECT * FROM MEMBERS

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

SELECT * FROM BOOKS;

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

--Task 2: Update an Existing Member's Address

SELECT * FROM MEMBERS WHERE member_id = 'C103'
UPDATE MEMBERS
SET member_address ='125 Oak St'
where member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

--unable to delete IS107 in the issued_status table due to the constraint with the return_status table. 
select * from issued_status
where issued_id = 'IS107';

select * from return_status
where issued_id in ('IS107','IS121')

delete from issued_status 
where issued_id = 'IS107';

select * from issued_status where issued_id in ('IS121','IS107');

--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

emp_id = 'E101'

select 
	emp_name,
	issued_book_name,
	emp_id
from employees as e
left join issued_status as iss
on e.emp_id = iss.issued_emp_id
where emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT * FROM BOOKS
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES
SELECT * FROM ISSUED_STATUS --issued_member_id
SELECT * FROM RETURN_STATUS
SELECT * FROM MEMBERS -- member_id

--employees
WITH cte as
(
select 
	issued_emp_id,
	count(issued_id) as number_of_books
from issued_status
group by 1
)
select * from cte
where number_of_books >=2;

--members subquery
select * from
(
select 
	issued_member_id,
	count(issued_id) as number_of_books
from issued_status
group by 1
) as subquery
where number_of_books >=2;

-- HAVING is for aggregated results
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1

--Task 6: Create Summary Tables: 
--Used CTAS to generate new tables based on query results -
--each book and total book_issued_cnt**

SELECT * FROM BOOKS --isbn
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn
SELECT * FROM RETURN_STATUS
SELECT * FROM MEMBERS -- member_id

CREATE TABLE book_issued_cnt as
select 
b.isbn,
b.book_title,
count(iss.issued_id) as issue_count
from books as b
join issued_status as iss
on b.isbn = iss.issued_book_isbn
group by 1,2;

select * from book_issued_cnt;

--Task 7. Retrieve All Books in a Specific Category:
select * from books
where category = 'Classic';

--Task 8: Find Total Rental Income by Category:
select * from issued_status
SELECT * FROM RETURN_STATUS
select * from books -- rental price;

--my way
WITH CTE AS 
(
select 
	category,
	issue_count,
	rental_price,
	rental_price * issue_count as revenue
from books as b
join book_issued_cnt as bic
on bic.isbn = b.isbn
)
SELECT 
	CATEGORY,
	SUM(REVENUE)
	FROM CTE
	group by 1

--tutorial way
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1

--9. List Members Who Registered in the Last 180 Days:
select * from members
where reg_date >= current_date - interval '400 days';


select current_date - interval '10 days'

--List Employees with Their Branch Manager's Name and 
-- their branch details:

select * from branch -- branch_id, manager_id
select * from employees -- branch_id

select 
	emp_name,
	emp_id,
	manager_id,
	position
from branch as b
join employees as e
on b.branch_id = e.branch_id
--where position <> ('Manager')

--joining emp_name and renaming it as manager to find the managers_name
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
  --  b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id;


--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;


--Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM BOOKS --isbn
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn
SELECT * FROM RETURN_STATUS -- return_id
SELECT * FROM MEMBERS -- member_id


SELECT * 
FROM ISSUED_STATUS iss
left join return_status rs
on rs.issued_id = iss.issued_id
where rs.return_id is null

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books 
(assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days
overdue. */

SELECT * FROM BOOKS --isbn
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn
SELECT * FROM RETURN_STATUS -- return_id
SELECT * FROM MEMBERS -- member_id

-- left join to capture the books that have not been returned yet

with cte as
(
select 
	ISS.issued_member_id,
	m.member_name,
	b.book_title,
	iss.issued_date,
	r.return_date,
	current_date - iss.issued_date as over_dues_day
	--return_date - issued_date
from issued_status as iss
join
members as m
	on m.member_id = iss.issued_member_id
join 
books as b
	on b.isbn = iss.issued_book_isbn
LEFT join 
return_status as r
	on r.issued_id = iss.issued_id
where r.return_date IS null
)
select 
issued_member_id,
member_name,
book_title,
over_dues_day
from cte
where over_dues_day > 30
order by 1 asc

select * from
(
select 
	ISS.issued_member_id,
	m.member_name,
	b.book_title,
	iss.issued_date,
	r.return_date,
	current_date - iss.issued_date as over_dues_day
	--return_date - issued_date
from issued_status as iss
join
members as m
	on m.member_id = iss.issued_member_id
join 
books as b
	on b.isbn = iss.issued_book_isbn
LEFT join 
return_status as r
	on r.issued_id = iss.issued_id
where r.return_date IS null
) as subquery
where over_dues_day >40;

/*
Task 14: Update Book Status on Return
Write a query to update the status of books 
in the books table to "Yes" when they are returned 
(based on entries in the return_status table).
*/


SELECT * FROM BOOKS where isbn = '978-0-451-52994-2'
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn
SELECT * FROM RETURN_STATUS -- return_id
SELECT * FROM MEMBERS -- member_id


SELECT * FROM BOOKS where isbn = '978-0-451-52994-2'

--Updating a book status to no and checking the issued_status table 
--to see when it was issued
--inserting a row in the return_status
update books
set status = 'no' 
where isbn = '978-0-451-52994-2';

SELECT * FROM ISSUED_STATUS where issued_book_isbn = '978-0-451-52994-2'
select * from return_status WHERE issued_id = 'IS130'

--c106 - has return the book today

select * from return_status
alter table return_status
add book_quality varchar(50)

update return_status
set book_quality = 'Good'

INSERT INTO return_status (return_id, issued_id, return_book_name, return_date, return_book_isbn)
VALUES
('RS125','IS130', NULL, CURRENT_DATE, NULL);

update books
set status = 'yes' 
where isbn = '978-0-451-52994-2';

-- Store Procedures, below is how to write procedure in sql
CREATE OR REPLACE PROCEDURE add_return_records(p_XXXX VARCHAT(XX)))
LANGUAGE plpgsql
AS $$ 
DECLARE -- to declare a variable 

BEGIN
	-- all your logic and code to put in here

END;
$$

CREATE OR REPLACE PROCEDURE add_return_recordss(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(255);
    v_book_name VARCHAR(255);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn, -- FROM THE ISSUED_STATUS
        issued_book_name
        INTO
        v_isbn, --DECALRE THE VARIABLE TYPE
        v_book_name --DECALRE THE VARIABLE TYPE
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn; -- FIND THE ISBN TO UPDATE THE BOOKS TABLE

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;

SELECT * FROM BOOKS

END;
$$

CALL add_return_recordss('RS138', 'IS135');

-- the function name
--the return_id will be input by an employee
--p is the one of the parameters 


--TESTING FUNCTIONS add_return_records 
-- below is the test
SELECT * FROM BOOKS WHERE ISBN = '978-0-307-58837-1';
SELECT * FROM ISSUED_STATUS WHERE ISSUED_ID = 'IS135';
SELECT * FROM RETURN_STATUS WHERE ISSUED_ID = 'IS135';

ISSUED_ID = IS135
ISBN = 978-0-307-58837-1



/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/

SELECT * FROM BOOKS --isbn & rental price
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES -- emp_id & branch_Id
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn and issued_emp_id
SELECT * FROM RETURN_STATUS -- return_id
SELECT * FROM MEMBERS -- member_id

CREATE TABLE branch_reports
AS
select 
	b.branch_id,
	count(iss.issued_id) as number_of_books_issued,
	count(rs.return_id) as number_of_books_returned,
	sum(bk.rental_price) as total_revnue
from issued_status as iss
left join return_status as rs
on rs.issued_id = iss.issued_id
join employees as e
on e.emp_id = iss.issued_emp_id
join branch as b
on b.branch_id = e.branch_id
join books as bk
on bk.isbn = iss.issued_book_isbn
group by 1;

SELECT * FROM branch_reports;



/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a 
new table active_members containing members who have 
issued at least one book in the last 12 months.
*/


SELECT * FROM MEMBERS --member_id
SELECT * FROM ISSUED_STATUS --issued_member_id

CREATE TABLE active_members
as
SELECT * FROM MEMBERS
WHERE Member_id in
					(select 
						distinct issued_member_id
					from issued_status
					WHERE issued_date > (CURRENT_DATE - INTERVAL '12 MONTH')
					);

SELECT * FROM active_members;


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have 
processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/

SELECT * FROM BOOKS --isbn & rental price
SELECT * FROM BRANCH
SELECT * FROM EMPLOYEES -- emp_id & branch_Id
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn and issued_emp_id
SELECT * FROM RETURN_STATUS -- return_id
SELECT * FROM MEMBERS -- member_id

SELECT * FROM EMPLOYEES 

SELECT 
	e.emp_name,
	b.branch_id,
	count(iss.issued_id) as number_of_books_processed,
	dense_rank() over(order by count(iss.issued_id) desc)
FROM ISSUED_STATUS as iss
join employees as e
on e.emp_id = iss.issued_emp_id
join branch as b
on b.branch_id = e.branch_id
group by 1,2

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued
books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've 
issued damaged books.
*/

update RETURN_STATUS 
set book_quality = 'damaged'
where return_id in ('RS107','RS108','RS109','RS111','RS112','RS118','RS125','RS116');

SELECT * FROM MEMBERS -- member_id
SELECT * FROM RETURN_STATUS -- return_id
SELECT * FROM ISSUED_STATUS --issued_member_id, --issued_book_isbn and issued_emp_id

select 
	issued_book_name,
	member_name,
	count(iss.issued_id) as number_of_issues,
	count(return_id) as returns
from issued_status as iss
join members as m
on m.member_id = iss.issued_member_id
left join return_status as rs
on rs.issued_id = iss.issued_id 
where book_quality = 'damaged'
group by 1,2

/*
Task 19: Stored Procedure Objective:
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in
the library based on its issuance. The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, 
and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book 
is currently not available.
*/


CREATE OR REPLACE PROCEDURE add_return_records(p_XXXX VARCHAT(XX)))
LANGUAGE plpgsql
AS $$ 
DECLARE -- to declare a variable 

BEGIN
	-- all your logic and code to put in here

END;
$$

SELECT * FROM BOOKS;
SELECT *  FROM ISSUED_STATUS

create or replace PROCEDURE issue_book(
p_issued_id varchar(255),
p_issued_member_id varchar(255), 
p_issued_book_isbn varchar(255),
p_issued_emp_id varchar(255)
)

LANGUAGE plpgsql
AS $$
DECLARE
-- ALL THE VARIABLES
	v_status varchar(255);

BEGIN
-- ALL THE CODE
	--CHECKING IF THE BOOK IS AVAILABLE 'YES'
	SELECT
		status
		INTO
		v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
			SET STATUS = 'No'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book records added sucessfully for book isbn: %', p_issued_book_isbn;

	ELSE 
		RAISE NOTICE 'Sorry to inform you the book you have requested is unavaiable book_isbn: %', p_issued_book_isbn;
	END IF;


END;
$$


CALL issue_book('IS151', 'C108', '978-0-553-29698-2', 'E104')

CALL issue_book('IS152', 'C108', '978-0-375-41398-8', 'E104')

--978-0-553-29698-2 YES
--978-0-375-41398-8 NO
SELECT * FROM ISSUED_STATUS
SELECT * FROM BOOKS WHERE isbn = '978-0-553-29698-2'
SELECT * FROM BOOKS WHERE isbn = '978-0-375-41398-8'


