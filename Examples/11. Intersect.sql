USE AdventureWorksLT2017;
GO

SELECT FirstName, LastName
FROM SalesLT.vCustomers
INTERSECT
SELECT FirstName, LastName
FROM SalesLT.vEmployees;
GO