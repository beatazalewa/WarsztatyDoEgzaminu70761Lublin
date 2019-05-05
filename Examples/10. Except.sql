USE AdventureWorksLT2017;
GO

SELECT FirstName, LastName
FROM SalesLT.vCustomers
EXCEPT
SELECT FirstName, LastName
FROM SalesLT.vEmployees;
GO
