---------------------------------------------------------------------
-- Exam Ref 70-761 Querying Data with Transact-SQL
-- Chapter 1 - Manage Data with Transact-SQL
-- Skill 1.1: Create Transact-SQL SELECT queries
-- © Itzik Ben-Gan
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Practice SQL environment and Sample databases
---------------------------------------------------------------------

-- Database server:
-- The code samples in this book can be executed in SQL Server 2016 Service Pack 1 (SP1) or later
-- and Azure SQL Database.
-- If you prefer to work with a local instance, SQL Server Developer
-- Edition is free if you sign up for the free Visual Studio Dev
-- Essentials program: https://myprodscussu1.app.vssubscriptions.visualstudio.com/Downloads?q=SQL%20Server%20Developer
-- In the installation's Feature Selection step, you need to choose only the Database Engine Services feature.

-- SQL Server Management Studio:
-- Download and install SQL Server Management Studio from here: https://msdn.microsoft.com/en-us/library/mt238290.aspx

-- Sample database:
-- This book uses the TSQLV4 sample database.
-- It is supported in both SQL Server 2016 and Azure SQL Database.
-- Download and install TSQLV4 from here: http://tsql.solidq.com/SampleDatabases/TSQLV4.zip

---------------------------------------------------------------------
-- Further reading
---------------------------------------------------------------------

-- If you are looking for further reading for more practice and 
-- more advanced topics beyond this book, see:
-- TSQL Fundamentals, 3rd Edition for more practice of fundamentals: https://www.microsoftpressstore.com/store/t-sql-fundamentals-9781509302000
-- T-SQL Querying for more advanced querying and query tuning: https://www.microsoftpressstore.com/store/t-sql-querying-9780735685048?w_ptgrevartcl=T-SQL+Querying_2193978
-- Itzik Ben-Gan's column in SQL Server Pro: http://sqlmag.com/author/itzik-ben-gan

---------------------------------------------------------------------
-- Understanding the Foundations of T-SQL
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Using T-SQL in a Relational Way
---------------------------------------------------------------------

USE TSQLV4;
GO
--Even when the table doesn’t allow duplicate rows, a query against the table can still return duplicate rows in its result
SELECT country
FROM HR.Employees;
GO
--In fact, T-SQL is based more on multiset theory than on set theory. A multiset (also known as a bag or a superset) in many respects is similar to a set, but can have duplicates. T-SQL provides you with a DISTINCT clause to remove duplicates
SELECT DISTINCT country
FROM HR.Employees;
GO
--No relevance to the order of the elements
--When this query was run on one system, it returned the following output, which looks like it is sorted by the column lastname
SELECT empid, lastname
FROM HR.Employees;
GO

SELECT lastname
FROM HR.Employees;
GO

SELECT empid
FROM HR.Employees;
GO
--Even if the rows were returned in a different order, the result would have still been considered correct.
SELECT empid, lastname
FROM HR.Employees
ORDER BY empid;
GO

--T-SQL allows referring to ordinal positions of columns from the result in the ORDER BY clause
SELECT empid, lastname
FROM HR.Employees
ORDER BY 1;
GO

--T-SQL has another deviation from the relational model in that it allows defining result columns based on an expression without assigning a name to the target column.
SELECT empid, firstname + ' ' + lastname
FROM HR.Employees;
GO

--But according to the relational model, all attributes must have names. In order for the query to be relational, you need to assign an alias to the target attribute. You can do so by using the AS clause
SELECT empid, firstname + ' ' + lastname AS fullname
FROM HR.Employees;
GO
---------------------------------------------------------------------
-- Logical Query Processing
---------------------------------------------------------------------

---------------------------------------------------------------------
-- T-SQL as a Declarative English-Like Language
---------------------------------------------------------------------

SELECT shipperid, phone, companyname
FROM Sales.Shippers;
GO
---------------------------------------------------------------------
-- Logical Query Processing Phases
---------------------------------------------------------------------
--1. Evaluate the FROM clause
--2. Filter rows based on the WHERE clause
--3. Group rows based on the GROUP BY clause
--4. Filter groups based on the HAVING clause
--5. Process the SELECT clause
--6. Handle presentation ordering

SELECT country, YEAR(hiredate) AS yearhired, COUNT(*) AS numemployees
FROM HR.Employees
WHERE hiredate >= '20140101'
GROUP BY country, YEAR(hiredate)
HAVING COUNT(*) > 1
ORDER BY country, yearhired DESC;
GO
-- fails
SELECT country, YEAR(hiredate) AS yearhired
FROM HR.Employees
WHERE yearhired >= 2014;
GO

-- fails
SELECT empid, country, YEAR(hiredate) AS yearhired, yearhired - 1 AS prevyear
FROM HR.Employees;
GO
---------------------------------------------------------------------
-- Getting started with the SELECT statement
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The FROM clause
---------------------------------------------------------------------
--It's the clause where you indicate the tables that you want to query.
--It's the clause where you can apply table operators like joins to input tables.
--Basic example
SELECT empid, firstname, lastname, country
FROM HR.Employees;
GO

-- assigning a table alias
SELECT E.empid, firstname, lastname, country
FROM HR.Employees AS E;
GO
---------------------------------------------------------------------
-- The SELECT clause
---------------------------------------------------------------------
--It evaluates expressions that define the attributes in the query's result, assigning them with aliases if needed.
--Using a DISTINCT clause, you can eliminate duplicate rows in the result if needed.

-- projection of a subset of the source attributes
SELECT empid, firstname, lastname
FROM HR.Employees;
GO

-- bug due to missing comma
SELECT empid, firstname lastname
FROM HR.Employees;
GO

-- aliasing for renaming
SELECT empid AS employeeid, firstname, lastname
FROM HR.Employees;
GO

-- expression without an alias
SELECT empid, firstname + N' ' + lastname
FROM HR.Employees;
GO

-- aliasing expressions
SELECT empid, firstname + N' ' + lastname AS fullname
FROM HR.Employees;
GO

-- removing duplicates with DISTINCT
SELECT DISTINCT country, region, city
FROM HR.Employees;
GO 

-- SELECT without FROM
SELECT 10 AS col1, 'ABC' AS col2;
GO

---------------------------------------------------------------------
-- Filtering data with predicates
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Predicates and three-valued-logic
---------------------------------------------------------------------

-- content of Employees table
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees;
GO

--the literal 'USA' is preceded with the letter N as a prefix, that's to denote a Unicode character string literal, because the
--country column is of the data type NVARCHAR. Had the country column been of a regular character string data type, such as --VARCHAR, the literal should have been just 'USA'.

-- employees from the United States
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA';
GO

-- employees from Washington State
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region = N'WA';
GO

-- employees that are not from Washington State
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region <> N'WA';
GO

-- handling NULLs incorrectly
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region <> N'WA'
   OR region = NULL;
GO

-- employees that are not from Washington State, resolving the NULL problem
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region <> N'WA'
   OR region IS NULL;
GO
---------------------------------------------------------------------
-- Filtering character data
---------------------------------------------------------------------

-- regular character string
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = 'Davis';
GO

-- Unicode character string
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'Davis';
GO

-- employees whose last name starts with the letter D.
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';
GO

---------------------------------------------------------------------
-- Filtering date and time data
---------------------------------------------------------------------

-- language-dependent literal
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '02/12/16';
GO

-- language-neutral literal
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '20160212';
GO

-- create table Sales.Orders2
DROP TABLE IF EXISTS Sales.Orders2;
GO

SELECT orderid, CAST(orderdate AS DATETIME) AS orderdate, empid, custid
INTO Sales.Orders2 
FROM Sales.Orders;
GO
--In practice, though, the precision of DATETIME is three and a third milliseconds. Because 999 is not a multiplication of this precision, the value is rounded up to the next millisecond, which happens to be the midnight of the next day. To make matters worse, when people want to store only a date in a DATETIME type, they store the date with midnight in the time, so besides returning orders placed in April 2016, this query also returns all orders placed in May 1, 2016.

-- filtering a range, the unrecommended way
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders2
WHERE orderdate BETWEEN '20160401' AND '20160430 23:59:59.999';
GO

-- filtering a range, the recommended way
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders2
WHERE orderdate >= '20160401' AND orderdate < '20160501';
GO
---------------------------------------------------------------------
-- Sorting data
---------------------------------------------------------------------

-- query with no ORDER BY doesn't guarantee presentation ordering
SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA';
GO

-- simple ORDER BY example
SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city;
GO

-- use descending order
SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city DESC;
GO

-- order by multiple columns
SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city, empid;
GO

-- order by ordinals (bad practice)
SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY 4, 1;
GO

-- change SELECT list but forget to change ordinals in ORDER BY
SELECT empid, city, firstname, lastname, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY 4, 1;
GO

-- order by elements not in SELECT
SELECT empid, city
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY birthdate;
GO

-- when DISTINCT specified, can only order by elements in SELECT

-- following fails
SELECT DISTINCT city
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY birthdate;
GO

-- following succeeds
SELECT DISTINCT city
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city;
GO

-- can refer to column aliases asigned in SELECT
SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY birthmonth;
GO

-- NULLs sort first
SELECT orderid, shippeddate
FROM Sales.Orders
WHERE custid = 20
ORDER BY shippeddate;
GO

---------------------------------------------------------------------
-- Filtering data with TOP and OFFSET-FETCH
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Filtering Data with TOP
---------------------------------------------------------------------

-- return the three most recent orders
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- can use percent
SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- can use expression, like parameter or variable, as input
DECLARE @n AS BIGINT = 5;

SELECT TOP (@n) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- no ORDER BY, ordering is arbitrary
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders;
GO

-- be explicit about arbitrary ordering
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL);
GO

-- non-deterministic ordering even with ORDER BY since ordering isn't unique
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- return all ties
SELECT TOP (3) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- break ties
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;
GO

---------------------------------------------------------------------
-- Filtering Data with OFFSET-FETCH
---------------------------------------------------------------------

-- skip 50 rows, fetch next 25 rows
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;
GO 

-- fetch first 25 rows
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 25 ROWS ONLY;
GO

-- skip 50 rows, return all the rest
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS;
GO

-- ORDER BY is mandatory; return some 3 rows
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL)
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;
GO

-- can use expressions as input
DECLARE @pagesize AS BIGINT = 25, @pagenum AS BIGINT = 3;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

-- For more on TOP and OFFSET-FETCH, including optimization, see
-- T-SQL Querying book's sample chapter: Chapter 5 - TOP and OFFSET-FETCH
-- You can find the online version of this chapter here: https://www.microsoftpressstore.com/articles/article.aspx?p=2314819
-- You can download the PDF version of this chapter here: https://ptgmedia.pearsoncmg.com/images/9780735685048/samplepages/9780735685048.pdf
-- This chapter uses the sample database TSQLV3 which you can download here: http://tsql.solidq.com/SampleDatabases/TSQLV3.zip

---------------------------------------------------------------------
-- Combining sets with set operators
---------------------------------------------------------------------

---------------------------------------------------------------------
-- UNION and UNION ALL
---------------------------------------------------------------------

-- locations that are employee locations or customer locations or both
SELECT country, region, city
FROM HR.Employees
UNION
SELECT country, region, city
FROM Sales.Customers;
GO

-- with UNION ALL duplicates are not discarded
SELECT country, region, city
FROM HR.Employees
UNION ALL
SELECT country, region, city
FROM Sales.Customers;
GO

---------------------------------------------------------------------
-- INTERSECT
---------------------------------------------------------------------

-- locations that are both employee and customer locations
SELECT country, region, city
FROM HR.Employees
INTERSECT
SELECT country, region, city
FROM Sales.Customers;
GO

---------------------------------------------------------------------
-- EXCEPT
---------------------------------------------------------------------

-- locations that are employee locations but not customer locations
SELECT country, region, city
FROM HR.Employees
EXCEPT
SELECT country, region, city
FROM Sales.Customers;
GO

-- cleanup
DROP TABLE IF EXISTS Sales.Orders2;
GO