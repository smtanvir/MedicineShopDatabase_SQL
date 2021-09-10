
/*									SQL Project On 
									Retail Medicine Shop
									Project Made By
									Sharif Mahiuddin Ahmed
									Trainee ID: 1260319
									Batch ID: ESAD-CS/PNTL-A/45/01
*/

--Query  Script

USE msMedicineCorner_DB
GO
/***	======================================= Data View From Table =======================================	***/

--Data View From Designations Table
SELECT * FROM tbl_designations
GO

--Data View From Gender Table
SELECT * FROM tbl_gender
GO

--Data View From Employees Table
SELECT * FROM tbl_employees
GO

--Data View From Customers Table
SELECT * FROM tbl_customers
GO

--Data View From Suppliers Table
SELECT * FROM tbl_suppliers
GO

--Data View From Drugs Group Table
SELECT * FROM tbl_drugsGroup
GO

--Data View From Drugs Shelf Table
SELECT * FROM tbl_drugsShelf
GO

--Data View From Drug Table
SELECT * FROM tbl_drugs
GO

--Data View From Stock Table
SELECT * FROM tbl_stock
GO

--Data View From Sales Details Table
SELECT * FROM tbl_salesDetails
GO



/***	======================================= Join Query =======================================	***/

--Join Query for Employee wise Sales Deatails
SELECT E.employeeID,(E.firstName+' '+E.lastName) AS EmployeeName,DS.designation,
SUM(S.amount) AS TotalSales FROM tbl_salesDetails S
INNER JOIN tbl_employees E ON E.employeeID= S.employeeID
INNER JOIN tbl_designations DS ON DS.designationID=E.designationID 
GROUP BY E.employeeID,E.firstName,E.lastName,DS.designation
ORDER BY E.employeeID


--Join Query Sales Deatails with Employee & Products Details
Select SD.salesID,CAST(SD.salesDate AS DATE) SalesDate, (E.firstName+' '+E.lastName) AS SalesPersonName, D.drugsName, 
SD.quantity,SD.price,(SD.quantity*SD.price) AS TotalPrice, (STR(SD.discountRate*100)+'%') AS DiscountRate  ,SD.discount,SD.netPrice AS NetPayable   from tbl_salesDetails SD
INNER JOIN tbl_drugs D on SD.drugsID=D.drugsID
INNER JOIN tbl_employees E on E.employeeID=SD.employeeID 
WHERE (SD.quantity*SD.price)>100 AND netPrice<1000
ORDER BY TotalPrice DESC
GO


--Join Query for Drugs Group wise Sales Deatails
SELECT E.employeeID,(E.firstName+' '+E.lastName) AS EmployeeName,DS.designation,DG.genericGroup,
SUM(S.amount) AS TotalSales FROM tbl_salesDetails S
INNER JOIN tbl_employees E ON E.employeeID= S.employeeID
INNER JOIN tbl_designations DS ON DS.designationID=E.designationID 
INNER JOIN tbl_drugs D ON D.drugsID=S.drugsID
INNER JOIN tbl_drugsGroup DG ON DG.GroupCode=D.genericGroupCode
WHERE designation='Salesperson'
GROUP BY E.employeeID,E.firstName,E.lastName,DS.designation,DG.genericGroup 
HAVING SUM(S.amount)>200
ORDER BY TotalSales 
GO





/***	======================================= Subquery =======================================	***/

--Subquery for Which Employee have not sales any Drugs

SELECT e.employeeID,e.firstName,e.lastName,e.contactNo,e.contactNo,g.gender,d.designation 
FROM tbl_employees e
INNER JOIN tbl_designations d ON d.designationID=e.designationID
INNER JOIN tbl_gender g ON g.genderID=e.genderID
WHERE employeeID NOT IN(SELECT employeeID FROM tbl_salesDetails)
GO


--Subquery for  Which Company's Drugs hasn't Sales

SELECT d.drugsID,d.drugsName,dg.genericGroup,sp.companyName FROM tbl_drugs d
INNER JOIN tbl_drugsGroup dg ON dg.GroupCode=d.genericGroupCode
INNER JOIN tbl_suppliers sp ON sp.supplierID=d.supplierID
WHERE drugsID NOT IN (SELECT drugsID FROM tbl_salesDetails)
ORDER BY drugsID
GO


/***	======================================= INDEX Details =======================================	***/

--Clustered INDX
EXEC sp_helpindex tbl_drugsGroup
GO

--NonClustered INDX
EXEC sp_helpindex tbl_designations
GO



/***	======================================= Calling View =======================================	***/

SELECT * FROM view_EmployeeWiseSales
GO


/***	======================================= Calling User-defined Function =======================================	***/

-- Calling Functions Employee Sales
SELECT * FROM fn_EmployeeWiseSales(1107)
GO

-- Calling Functions Monthwise Sales
SELECT * FROM fn_MonthWiseSales(1,2021)
GO

-- Calling Scalar UDF
SELECT dbo.fn_MonthlyTotalSales(1,2021) AS 'Total Sales'
Go


/***	======================================= CTE =======================================	***/

WITH SalesCount (employeeID,EmployeeName,TotalSales)
AS
(
	SELECT e.employeeID,(e.firstName+' '+e.lastName) AS EmployeeName, 
	COUNT(*) as TotalSales FROM tbl_salesDetails s
	INNER JOIN tbl_employees e ON e.employeeID=s.employeeID
	GROUP BY e.employeeID,e.firstName,e.lastName
)
SELECT * FROM SalesCount
ORDER BY TotalSales
GO


/***	======================================= Test Restrict Deletion of Data from SalesDetails Table =======================================	***/

DELETE FROM tbl_salesDetails WHERE salesID=18 
GO

/***	=======================================  Deletion of Data from Employee Table  =======================================	***/
--Delete Data which Employee ID is 1106
EXEC sp_DeleteEmployees 1106
GO

/***	=======================================  Update Data on Employee Table  =======================================	***/
--Update Data on which Employee ID is 1103
UPDATE tbl_employees 
SET designationID=102 WHERE employeeID=1103
GO




