---------------------------------------------------------------------
-- Exam Ref 70-761 Querying Data with Transact-SQL
-- Chapter 1 - Manage Data with Transact-SQL
-- Skill 1.2: Query multiple tables by using joins
-- © Itzik Ben-Gan
---------------------------------------------------------------------

-- add a row to the suppliers table
USE TSQLV4;
GO

INSERT INTO Production.Suppliers
  (companyname, contactname, contacttitle, address, city, postalcode, country, phone)
  VALUES(N'Supplier XYZ', N'Jiru', N'Head of Security', N'42 Sekimai Musashino-shi',
         N'Tokyo', N'01759', N'Japan', N'(02) 4311-2609');
GO

---------------------------------------------------------------------
-- Cross Joins
---------------------------------------------------------------------

-- a cross join returning a row for each day of the week
-- and shift number out of three
SELECT D.n AS theday, S.n AS shiftno  
FROM dbo.Nums AS D
  CROSS JOIN dbo.Nums AS S
WHERE D.n <= 7
  AND S.N <= 3
ORDER BY theday, shiftno;
GO

---------------------------------------------------------------------
-- Inner Joins
---------------------------------------------------------------------

-- suppliers from Japan and products they supply
-- suppliers without products not included
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
  INNER JOIN Production.Products AS P
    ON S.supplierid = P.supplierid
WHERE S.country = N'Japan';
GO

-- same meaning
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
  INNER JOIN Production.Products AS P
    ON S.supplierid = P.supplierid
    AND S.country = N'Japan';
GO

-- employees and their managers
-- employee without manager (CEO) not included
SELECT E.empid,
  E.firstname + N' ' + E.lastname AS emp,
  M.firstname + N' ' + M.lastname AS mgr
FROM HR.Employees AS E
  INNER JOIN HR.Employees AS M
    ON E.mgrid = M.empid;
GO
---------------------------------------------------------------------
-- Outer Joins
---------------------------------------------------------------------
-- suppliers from Japan and products they supply
-- suppliers without products included
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
  LEFT OUTER JOIN Production.Products AS P
    ON S.supplierid = P.supplierid
WHERE S.country = N'Japan';
GO

-- return all suppliers
-- show products for only suppliers from Japan
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
  LEFT OUTER JOIN Production.Products AS P
    ON S.supplierid = P.supplierid
   AND S.country = N'Japan';
GO

---------------------------------------------------------------------
-- Queries with composite joins and NULLs in join columns
---------------------------------------------------------------------

-- employees and their managers
-- employee without manager (CEO) included
SELECT E.empid,
  E.firstname + N' ' + E.lastname AS emp,
  M.firstname + N' ' + M.lastname AS mgr
FROM HR.Employees AS E
  LEFT OUTER JOIN HR.Employees AS M
    ON E.mgrid = M.empid;
GO

-- sample data for composite join example
DROP TABLE IF EXISTS dbo.EmpLocations;
GO

SELECT country, region, city, COUNT(*) AS numemps
INTO dbo.EmpLocations
FROM HR.Employees
GROUP BY country, region, city;
GO

ALTER TABLE dbo.EmpLocations ADD CONSTRAINT UNQ_EmpLocations
  UNIQUE CLUSTERED(country, region, city);
GO

DROP TABLE IF EXISTS dbo.CustLocations;
GO

SELECT country, region, city, COUNT(*) AS numcusts
INTO dbo.CustLocations
FROM Sales.Customers
GROUP BY country, region, city;
GO

ALTER TABLE dbo.CustLocations ADD CONSTRAINT UNQ_CustLocations
  UNIQUE CLUSTERED(country, region, city);
GO

-- query EmpLocations table
SELECT country, region, city, numemps
FROM dbo.EmpLocations;
GO

-- query CustLocations table
SELECT country, region, city, numcusts
FROM dbo.CustLocations;
GO

-- join tables, incorrect handling of NULLs
SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER JOIN dbo.CustLocations AS CL
    ON EL.country = CL.country
    AND EL.region = CL.region
    AND EL.city = CL.city;
GO

-- correct handling of NULLs, but cannot rely on index order
SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER JOIN dbo.CustLocations AS CL
    ON EL.country = CL.country
    AND ISNULL(EL.region, N'<N/A>') = ISNULL(CL.region, N'<N/A>')
    AND EL.city = CL.city;
GO
-- force MERGE join algorithm, observe sorting in the plan
SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER MERGE JOIN dbo.CustLocations AS CL
    ON EL.country = CL.country
    AND ISNULL(EL.region, N'<N/A>') = ISNULL(CL.region, N'<N/A>')
    AND EL.city = CL.city;
GO

-- correct handling of NULLs, can rely on index order
SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER JOIN dbo.CustLocations AS CL
    ON EL.country = CL.country
    AND (EL.region = CL.region OR (EL.region IS NULL AND CL.region IS NULL))
    AND EL.city = CL.city;
GO

-- force MERGE join algorithm, observe no sorting in the plan
SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER MERGE JOIN dbo.CustLocations AS CL
    ON EL.country = CL.country
    AND (EL.region = CL.region OR (EL.region IS NULL AND CL.region IS NULL))
    AND EL.city = CL.city;
GO

-- alternative combining a join and a set operator while preserving order
SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER JOIN dbo.CustLocations AS CL
    ON EXISTS (SELECT EL.country, EL.region, EL.city
               INTERSECT 
               SELECT CL.country, CL.region, CL.city);
GO

SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
  INNER MERGE JOIN dbo.CustLocations AS CL
    ON EXISTS (SELECT EL.country, EL.region, EL.city
               INTERSECT 
               SELECT CL.country, CL.region, CL.city);
GO

-- cleanup
DROP TABLE IF EXISTS dbo.CustLocations;
GO
DROP TABLE IF EXISTS dbo.EmpLocations;
GO

---------------------------------------------------------------------
-- Multi join queries
---------------------------------------------------------------------

-- attempt to include product category from Production.Categories table
-- inner join nullifies outer part of outer join
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice,
  C.categoryname
FROM Production.Suppliers AS S
  LEFT OUTER JOIN Production.Products AS P
    ON S.supplierid = P.supplierid
  INNER JOIN Production.Categories AS C
    ON C.categoryid = P.categoryid
WHERE S.country = N'Japan';
GO

-- fix using outer joins in both joins
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice,
  C.categoryname
FROM Production.Suppliers AS S
  LEFT OUTER JOIN Production.Products AS P
    ON S.supplierid = P.supplierid
  LEFT OUTER JOIN Production.Categories AS C
    ON C.categoryid = P.categoryid
WHERE S.country = N'Japan';
GO

-- fix using parentheses
SELECT
  S.companyname AS supplier, S.country,
  P.productid, P.productname, P.unitprice,
  C.categoryname
FROM Production.Suppliers AS S
  LEFT OUTER JOIN 
    (Production.Products AS P
       INNER JOIN Production.Categories AS C
         ON C.categoryid = P.categoryid)
    ON S.supplierid = P.supplierid
WHERE S.country = N'Japan';
GO

-- cleanup
DELETE FROM Production.Suppliers WHERE supplierid > 29;
GO