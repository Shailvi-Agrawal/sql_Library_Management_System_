Use library_db_project2;
 
select* from books;
select* from members;
select* from employee;
select* from returns_status;
select* from issued_status;
select* from branch;

-- Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select* from books;

-- Update an Existing Member's Address

update members
set member_address = '125 Oak St'
where member_id= 'C103';

-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from Issued_Status 
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status 
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id, count(*) as count 
from issued_status 
group by issued_emp_id 
having count(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_issued_cnt as 
select b.isbn, b.book_title, count(i.issued_id) as total_issued from books b 
join issued_status i 
on b.isbn = i.issued_book_isbn
group by b.isbn, book_title;

select * from book_issued_cnt;

-- Task 7. Retrieve All Books in a Specific Category:

select* from books
where category= 'Children';

SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

select category, c*d as rental_income from(
 SELECT 
    b.category,
    SUM(b.rental_price) c ,
    COUNT(*) d
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
) t;

-- tast 9- List Members Who Registered in the Last 180 Days:

select * from members where 
reg_date >= current_date() - 180;

-- task 10 List Employees with Their Branch Manager's Name and their branch details:

select e1. emp_name, e2.emp_name from employee e1
join branch b on 
e1.branch_id = b.branch_id
join employee e2 on
b.manager_id = e2.emp_id
;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

create table expensive_books as 
select * from books 
where rental_price > 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned

select i.issued_book_name from returns_status r 
right join issued_status i on 
r.issued_id = i.issued_id
where r.return_id is null;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.


SELECT 
    m.member_id,
    m.member_name,
    ist.issued_book_name,
    ist.issued_date, 
   datediff( current_date() , ist.issued_date)  as overdue_days
FROM
    members m
        JOIN
    issued_status ist ON m.member_id = ist.issued_member_id
        LEFT JOIN
    returns_status rt ON ist.issued_id = rt.issued_id
WHERE
    rt.return_id IS NULL
    and 
    datediff( current_date() , ist.issued_date) > 30
    order by 1;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.

create table Performance_report as 
SELECT br.branch_id, br.manager_id,  count(ist.issued_id) as t_issued , count(rt.return_id) as t_returned , sum(rental_price) as T_income
from issued_status ist
join  employee e 
 ON ist.issued_emp_id = e.emp_id
 join branch br on 
br.branch_id = e.branch_id
left join returns_status rt on 
ist.issued_id = rt.issued_id 
join books b on 
b.isbn = ist.issued_book_isbn
group by 1, 2;


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

select m.member_id, count(ist.issued_id) active_member from members m join
issued_status ist
on ist.issued_member_id = m.member_id
group by 1 having count(ist.issued_id) >=1;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

Select * from employee;

select e.emp_name, br.branch_id, count(i.issued_id) as total 
 from issued_status i join employee e on 
 i.issued_emp_id = e.emp_id
 join branch br on br.manager_id = e.emp_id
 group by 1 , 2
 order by count(issued_id) desc limit 3;
 
 
