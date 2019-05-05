USE AdventureWorksLT2017;
GO
-- Setup
CREATE VIEW SalesLT.vCustomers
AS
SELECT DISTINCT firstname,lastname
from SalesLT.Customer
where LastName >='M'
OR CustomerID=3;
GO

CREATE VIEW SalesLT.vEmployees
AS
SELECT DISTINCT firstname,lastname
from SalesLT.Customer
where LastName <='M'
OR CustomerID=3;
GO

-- Union example
SELECT FirstName, LastName
FROM SalesLT.vEmployees
UNION
SELECT FirstName, LastName
FROM SalesLT.vCustomers
ORDER BY LastName;
GO

