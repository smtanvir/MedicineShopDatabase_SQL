
/*									SQL Project On 
									Retail Medicine Shop
									Project Made By
									Sharif Mahiuddin Ahmed
									Trainee ID: 1260319
									Batch ID: ESAD-CS/PNTL-A/45/01
*/

--Creating Objects Script

USE master
GO


IF EXISTS (SELECT NAME FROM SYS.sysdatabases WHERE NAME='msMedicineCorner_DB')
DROP DATABASE msMedicineCorner_DB
GO


CREATE DATABASE msMedicineCorner_DB
ON
(
	NAME= msMedicineCorner_DB_data,
	FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\msMedicineCorner_DB_data.mdf',
	SIZE=100MB,
	MAXSIZE=1GB,
	FILEGROWTH=20%
)
LOG ON
(
	NAME=msMedicineCorner_DB_log,
	FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\msMedicineCorner_DB_log.ldf',
	SIZE=50MB,
	MAXSIZE=800MB,
	FILEGROWTH=100MB
)
GO

USE msMedicineCorner_DB
GO



CREATE TABLE tbl_designations
(
	designationID INT PRIMARY KEY IDENTITY(101,1),
	designation VARCHAR(30) NOT NULL
)
GO

CREATE TABLE tbl_gender
(
	genderID INT PRIMARY KEY,
	gender VARCHAR(10) NOT NULL
)

CREATE TABLE tbl_employees
(
	employeeID INT PRIMARY KEY IDENTITY(1101,1),
	firstName VARCHAR(50) NOT NULL,
	lastName VARCHAR(50) NULL,
	dateOfBirth DATETIME NOT NULL,
	genderID INT REFERENCES tbl_gender(genderID) NOT NULL,
	contactNo VARCHAR(15) NOT NULL,
	email VARCHAR(80) NULL,
	nationalID CHAR(13) UNIQUE NOT NULL CHECK(nationalID LIKE '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	designationID INT REFERENCES tbl_designations(designationID) NOT NULL,
	streetAddress VARCHAR(100) NOT NULL,
	postalCode INT NOT NULL,
	city VARCHAR(30) NOT NULL
)
GO

CREATE TABLE tbl_customers
(
	customerID INT PRIMARY KEY,
	firstName VARCHAR(50) NOT NULL,
	lastName VARCHAR(50) NULL,
	contactNo VARCHAR(15) NOT NULL,
	streetAddress VARCHAR(100) NULL,
	postalCode INT NULL,
	city VARCHAR(30) NULL
)
GO


CREATE TABLE tbl_suppliers
(
	supplierID INT IDENTITY(90001,1) PRIMARY KEY,
	companyName VARCHAR(70) NOT NULL,
	contactFirstName VARCHAR(50) NOT NULL,
	contactLastName VARCHAR(40),
	contactNo VARCHAR(15) NOT NULL,
	email VARCHAR(70),
	streetAddress VARCHAR(100) NOT NULL,
	postalCode INT NOT NULL,
	city VARCHAR(20) NOT NULL
)
GO

CREATE TABLE tbl_drugsGroup
(
	GroupCode INT IDENTITY(501,1) PRIMARY KEY NONCLUSTERED,
	genericGroup VARCHAR(40) NOT NULL
)
GO

CREATE TABLE tbl_drugsShelf
(
	shelfID INT PRIMARY KEY IDENTITY(1,1),
	shelfNo CHAR(5) UNIQUE NOT NULL CHECK(shelfNo LIKE '[A-Z][-][0-9][0-9][0-9]'),
	drugsGroupCode INT REFERENCES tbl_drugsGroup(GroupCode)
)
GO


CREATE TABLE tbl_drugs
(
	drugsID INT IDENTITY(10001,1) PRIMARY KEY,
	drugsName VARCHAR(50) NOT NULL,
	shelfID INT REFERENCES tbl_drugsShelf(shelfID),
	genericGroupCode INT REFERENCES tbl_drugsGroup(GroupCode),
	supplierID INT REFERENCES tbl_suppliers(supplierID),
	packSize INT NOT NULL CHECK(packSize>0),
	sizeUnit VARCHAR(20) NOT NULL,
	unitPrice MONEY NOT NULL CHECK (unitPrice>0),
	discountRate FLOAT DEFAULT 0.04
	)
GO

CREATE TABLE tbl_stock
(
	stockID	INT PRIMARY KEY IDENTITY(50001,1),
	drugsID INT REFERENCES tbl_drugs(drugsID) UNIQUE,
	quantity INT CHECK(quantity>0),
	quantityUnit VARCHAR(20)
)
GO



CREATE TABLE tbl_salesDetails
(
	salesID INT IDENTITY(100001,1) PRIMARY KEY,
	cusotmersID INT REFERENCES tbl_customers(customerID),
	drugsID INT REFERENCES tbl_drugs(drugsID),
	employeeID INT REFERENCES tbl_employees(employeeID),
	salesDate DATETIME DEFAULT GETDATE(),
	quantity INT NOT NULL CHECK(quantity>0),
	price MONEY,
	discountRate FLOAT,
	amount AS quantity*price,
	discount AS price * discountRate*quantity,
	netPrice AS (price*quantity)-(price * discountRate*quantity)
	)
GO

/***	===================== Data Insert on Gender Table & then Restrict Gender Table from Modifying =====================		***/

--Inserting Data to Gender Table
INSERT INTO tbl_gender VALUES 
(1, 'Male'),
(2,'Female')
GO

--Restrict Gender Table from Modifying
CREATE TRIGGER tr_LockGender
	ON tbl_gender
	FOR INSERT,UPDATE,DELETE
AS
	PRINT 'You can''t modify this table!'
	ROLLBACK TRANSACTION
GO




/***	========================================== INDEX ==========================================		***/

--Clustered Index on Primary Key field on DrugsGroup Table
CREATE CLUSTERED INDEX IX_drugsGroup
ON tbl_drugsGroup(GroupCode)
GO


--NonClustered Index on  Designation Table
CREATE NONCLUSTERED INDEX IX_designation
ON tbl_designations(designation)
GO





/***	=======================================	Stored Procedure =======================================	***/

--Stored Procedure for Inserting Data to Designation Table
CREATE PROC sp_InsertDesignation
					@designation VARCHAR(30)

AS
BEGIN
	INSERT INTO tbl_designations VALUES(@designation)
END
GO


--Stored Procedure for Updating Data to Designation Table
CREATE PROC sp_UpdateDesignation
					@id INT,
					@designation VARCHAR(30)

AS
BEGIN
	UPDATE tbl_designations
	SET designation=@designation
	WHERE designationID=@id
END
GO


--Stored Procedure for Deleting Data from Designation Table 
CREATE PROC sp_DeleteDesignation
					@id INT

AS
BEGIN
	DELETE tbl_designations
	WHERE designationID=@id
END
GO


--Stored Procedure for Inserting Data to Employees Table
CREATE PROC sp_InsertEmployees
					@firstName VARCHAR(50),
					@lastName VARCHAR(50),
					@dateOfBirth DATETIME,
					@genderID INT,
					@contactNo VARCHAR(15),
					@email VARCHAR(70),
					@nationalIDNo CHAR(13),
					@designationID INT,
					@streetAddress VARCHAR(100),
					@postalCode INT,
					@city VARCHAR(30)			

AS
BEGIN
	INSERT INTO tbl_employees VALUES
		(@firstName,@lastName,@dateOfBirth,@genderID,@contactNo,@email,@nationalIDNo,
		@designationID,@streetAddress,@postalCode,@city)
END
GO


--Stored Procedure for Deleting Data from Employees Table
CREATE PROC sp_DeleteEmployees
					@id INT

AS
BEGIN
	DELETE tbl_employees
	WHERE employeeID=@id
END
GO


--Stored Procedure for Inserting Data to Suppliers Table 
CREATE PROC sp_InsertSuppliers
						@companyName VARCHAR(70),
						@contactFirstName VARCHAR(50),
						@contactLastName VARCHAR(40),
						@contactNo VARCHAR(15),
						@email VARCHAR(70),
						@streetAddress VARCHAR(100),
						@postalCode INT,
						@city VARCHAR(20)

AS
BEGIN
	INSERT INTO tbl_suppliers VALUES
		(@companyName,@contactFirstName,@contactLastName,@contactNo,@email,@streetAddress,@postalCode,@city)
END
GO


--Stored Procedure for Deleting Data to Suppliers Table 
CREATE PROC spDeleteSuppliers
					@id INT

AS
BEGIN
	DELETE tbl_suppliers
	WHERE supplierID=@id
END
GO


--Stored Procedure to Inserting Data to Drugs Table
CREATE PROC sp_Insertdrugs
							@drugsName VARCHAR(50),
							@shelfID INT,
							@genericGroupCode INT,
							@supplierID INT,
							@packSize INT,
							@sizeUnit VARCHAR(20),
							@unitPrice MONEY,
							@discountRate FLOAT,
							@initialStock INT,
							@quantityUnit VARCHAR(20)

AS
BEGIN
	INSERT INTO tbl_drugs VALUES
		(@drugsName,@shelfID,@genericGroupCode,@supplierID,@packSize,@sizeUnit,@unitPrice,@discountRate)
	DECLARE @ID INT;
	SET @ID=@@IDENTITY
	INSERT INTO tbl_stock VALUES(@@IDENTITY,@initialStock,@quantityUnit)
END
GO



--Stored Procedure to Inserting Drugs to SalesDetails Table
CREATE PROC sp_AddDrugsToSales
							@customerID INT,
							@drugsID INT,
							@employeeID INT,
							@quantity INT

AS
BEGIN
	DECLARE @price MONEY;
	DECLARE @discountRate FLOAT;
	SELECT @price=unitPrice FROM tbl_drugs WHERE drugsID=@drugsID
	SELECT @discountRate=discountRate FROM tbl_drugs WHERE drugsID=@drugsID
	INSERT INTO tbl_salesDetails(cusotmersID,drugsID,employeeID,quantity,price,discountRate) VALUES
			(@customerID,@drugsID,@employeeID,@quantity,@price,@discountRate)
END
GO






/***	======================================= Trigger =======================================		***/

--Trigger for Automatics Updates on Stock Table
CREATE TRIGGER tr_AddDrugsToSales
    ON tbl_salesDetails
    AFTER INSERT
	AS
    BEGIN
		DECLARE @quantity INT;
		DECLARE @drugsID INT;
		SELECT @drugsID=drugsID FROM inserted
		SELECT @quantity=quantity FROM inserted
		UPDATE tbl_stock
		SET quantity=quantity-@quantity
		WHERE drugsID=@drugsID
	 END
GO

--Restrict Deletion of Data from SalesDetails Table
CREATE TRIGGER tr_RistrictDeleteSalesDetails
ON tbl_salesDetails
	FOR DELETE
AS
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'Data cannot be deleted !!!'
	END
GO






/***	======================================= VIEW =======================================		***/

--View for Employee Wise Sales
CREATE VIEW view_EmployeeWiseSales
AS
SELECT E.employeeID,(E.firstName+' '+E.lastName) EmployeeName,D.designation,SUM(S.amount) AS totalSales FROM tbl_salesDetails S
INNER JOIN tbl_employees E ON E.employeeID= S.employeeID
INNER JOIN tbl_designations D ON D.designationID=E.designationID 
GROUP BY E.employeeID,E.firstName,E.lastName,D.designation
GO





/***	======================================= User-defined Function =======================================	***/

--Function for Employee wise sales
CREATE FUNCTION fn_EmployeeWiseSales	(@employeeID INT)
RETURNS TABLE
AS 
RETURN
(		SELECT E.employeeID,(E.firstName+' '+E.lastName) AS EmployeeName,D.designation,
		SUM(S.amount) AS totalSales FROM tbl_salesDetails S
		INNER JOIN tbl_employees E ON E.employeeID= S.employeeID
		INNER JOIN tbl_designations D ON D.designationID=E.designationID 
		WHERE E.employeeID=@employeeID
		GROUP BY E.employeeID,E.firstName,E.lastName,D.designation
)
GO


--Function for Monthwise sales
CREATE FUNCTION fn_MonthWiseSales (@month INT,@year INT)
RETURNS @EmployeeWiseSales TABLE 
(
	employeeID INT,
	EmployeeName VARCHAR(60),
	designation VARCHAR(20),
	totalSales MONEY
)
AS
BEGIN
		INSERT INTO @EmployeeWiseSales
		SELECT E.employeeID,(E.firstName+' '+E.lastName) AS EmployeeName,D.designation,
		SUM(S.amount) totalSales FROM tbl_salesDetails S
		INNER JOIN tbl_employees E ON E.employeeID= S.employeeID
		INNER JOIN tbl_designations D ON D.designationID=E.designationID 
		WHERE MONTH(S.salesDate)=@month AND YEAR (S.salesDate)=@year
		GROUP BY E.employeeID,E.firstName,e.lastName,D.designation
		RETURN 
END
GO


--Function for Monthly Total Sales
CREATE FUNCTION fn_MonthlyTotalSales (@month INT, @year INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @totalSales MONEY
    SELECT @totalSales=SUM(amount) FROM tbl_salesDetails 
	WHERE MONTH(salesDate)=@month AND YEAR(salesDate)=@year
	RETURN @totalSales 
END
GO






/***	======================================= Data Insert =======================================	***/


--Data insert to Designation Table
EXEC sp_InsertDesignation 'Pharmacist'
EXEC sp_InsertDesignation 'Sales Manager'
EXEC sp_InsertDesignation 'Accountant' 
EXEC sp_InsertDesignation 'Salesperson'



--Data insert to Employees Table
EXEC sp_InsertEmployees 'Habib','Adnan','04-21-1998',1,'01848608988','mann.eddie@ymail.com','7660679117630',101,'Dhanmondi',1222,'Dhaka'
EXEC sp_InsertEmployees 'Fatema','Khanom','11-14-1996',2,'01780809822','khanom@gmail.com','889102446151877',103,'Kalabagan',1205,'Dhaka'
EXEC sp_InsertEmployees 'Bashir','Hossain','06-10-1993',1,'01805656939','bashir@gmail.com','8891084151877',104,'Palton',1000,'Dhaka'
EXEC sp_InsertEmployees 'Nazrul','Islam','01-12-1992',1,'01754443091','nazrul@gmail.com','8891024151807',104,'New Market',1203,'Dhaka'
EXEC sp_InsertEmployees 'Topu','Raihan','01-04-1990',1,'01948378244','topu@gmail.com','8891024851877',104,'Green Road',1203,'Dhaka'
EXEC sp_InsertEmployees 'Rafiq','Ahmed','06-21-1988',1,'01777926259','ahmed@gmail.com','7660679417630',102,'Bangla Motor',1205,'Dhaka'
EXEC sp_InsertEmployees 'Tasnim','Tammana','01-14-1996',2,'01905656939','tamanna@gmail.com','8891024451877',104,'New Market',1203,'Dhaka'



--Data insert to Customers Table
INSERT INTO tbl_customers VALUES (1,'Sakib','Hasan','01818148134','Lalbag',1000, 'Dhaka')
INSERT INTO tbl_customers VALUES (2,'Tamin','Hasan','01922424555','Shahbag',1000, 'Dhaka')
INSERT INTO tbl_customers VALUES (3,'Hamim','Hasan','01518181334','Palton',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (4,'Harun','Hasan','01918181334','Gulistan',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (5,'Mamun','Hasan','01822424555','Dahanmondi',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (6,'Rakib','Hasan','01718181334','Firmgate',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (7,'Mahmud','Hasan','01824148134','Lalbag',1000, 'Dhaka')
INSERT INTO tbl_customers VALUES (8,'Tamim','Iqbal','01562424555','Shahbag',1000, 'Dhaka')
INSERT INTO tbl_customers VALUES (9,'Mahmudul','Hasan','01518181334','Palton',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (10,'Raihan','Hasan','01918181334','Gulistan',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (11,'Mukibul','Hasan','01822424555','Dahanmondi',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (12,'Rakibul','Hasan','01718181334','Firmgate',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (13,'Nahidul','Hasan','01818148134','GPO',1000, 'Dhaka')
INSERT INTO tbl_customers VALUES (14,'Rafiqul','Hasan','01922424555','Press Club',1000, 'Dhaka')
INSERT INTO tbl_customers VALUES (15,'Shahriar','Hasan','01518181334','Motijhil',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (16,'Nayem','Hasan','01918181334','Kakrail',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (17,'Bashir','Hasan','01822424555','Kathalbagan',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (18,'Tanvir','Hasan','01718181334','Lake Curkas',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (19,'Sakib','Mahmud','01818148134','Indira Road',1205, 'Dhaka')
INSERT INTO tbl_customers VALUES (20,'Tamin','Khan','01922424555','Rajabazar',1205, 'Dhaka')
INSERT INTO tbl_customers VALUES (21,'Hamim','Rahman','01518181334','Tejgaon',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (22,'Harun','Ur Rashid','01918181334','Golap Shah Mazar',1000,'Dhaka')
INSERT INTO tbl_customers VALUES (23,'Mamun','Mia','01822424555','Pantopath',1205,'Dhaka')
INSERT INTO tbl_customers VALUES (24,'Rakib','Talukder','01718181334','Green Road',1205,'Dhaka')



--Data insert to Suppliers Table
EXEC sp_InsertSuppliers 'Beximco Pharma Ltd.','Safiqul','Islam','01899030416','safiqul.islam@gmail.com','Karwan Bazar',1204,'Dhaka'
EXEC sp_InsertSuppliers 'Square Pharmaceutical Ltd.','Absus','Sobhan','01847726864','sobhan@gmail.com','Uttara',1239,'Dhaka'
EXEC sp_InsertSuppliers 'Opsonin Pharmaceutical Ltd.','Jamal','Hossain','01979642735','jhossain@gmail.com','Rajabazar, Dhanmondi',1211,'Dhaka'
EXEC sp_InsertSuppliers 'IBN Sina Pharmaceutical Ltd.','Atik','Rahman','01758252893','atik@gmail.com','Shahbag, Motijheel',1237,'Dhaka'
EXEC sp_InsertSuppliers 'Drug International','Sadat','Rahman','01825991993','sadat@gmail.com','Karwan Bazar, Tejgaon',1233,'Dhaka'
EXEC sp_InsertSuppliers 'HealthCare Pharmaceutical Ltd.','Hamid','Hasan','01838539168','hhasan@gmail.com','Uttara-13, Uttara',1234,'Dhaka'
EXEC sp_InsertSuppliers 'Jayson Pharma Ltd.','Hasin','Ahmed','01712421398','hahmed@gmail.com','Kamlapur,Motijheel',1224,'Dhaka'
EXEC sp_InsertSuppliers 'Incepta Pharmaceutical Ltd.','Topu','Ryan','01746488255','ryan.topu@gmail.com','Shahbag, Motijheel',1237,'Dhaka'
EXEC sp_InsertSuppliers 'Acme Pharmaceutical Ltd.','Golam','Rabbani','01740062345','sharp.doyle@gmail.com','Karwan Bazar, Tejgaon',1233,'Dhaka'
EXEC sp_InsertSuppliers 'ACI Pharmaceutical Ltd.','Nancy','Garcia','01728147685','garcia.nancy@gmail.com','Uttara-13, Uttara',1234,'Dhaka'
EXEC sp_InsertSuppliers 'Eskayef Bangladesh Ltd.','Ziaur','Rahman','01728149685','rahman@gmail.com','Dhanmondi',1204,'Dhaka'
EXEC sp_InsertSuppliers 'Orion Pharma','Zed','Islam','01728549685','zdislam@gmail.com','Dhanmondi',1204,'Dhaka'



--Data insert to Drugs Groups Table
INSERT INTO tbl_drugsGroup VALUES ('Aceclofenac')
INSERT INTO tbl_drugsGroup VALUES ('Albendazole')
INSERT INTO tbl_drugsGroup VALUES ('Ambraxol')
INSERT INTO tbl_drugsGroup VALUES ('Antacid')
INSERT INTO tbl_drugsGroup VALUES ('Azithromycin')
INSERT INTO tbl_drugsGroup VALUES ('Diazepam')
INSERT INTO tbl_drugsGroup VALUES ('Diclofenac')
INSERT INTO tbl_drugsGroup VALUES ('Estriol')
INSERT INTO tbl_drugsGroup VALUES ('Bilastine')
INSERT INTO tbl_drugsGroup VALUES ('Baclofen')
INSERT INTO tbl_drugsGroup VALUES ('Cefixime')
INSERT INTO tbl_drugsGroup VALUES ('Carbimazole')
INSERT INTO tbl_drugsGroup VALUES ('Ketoconazole')
INSERT INTO tbl_drugsGroup VALUES ('Loratadine')
INSERT INTO tbl_drugsGroup VALUES ('Melatonin')
INSERT INTO tbl_drugsGroup VALUES ('Menthol')
INSERT INTO tbl_drugsGroup VALUES ('Metronidazole')
INSERT INTO tbl_drugsGroup VALUES ('Omeprazole')
INSERT INTO tbl_drugsGroup VALUES ('Oxiconazole')
INSERT INTO tbl_drugsGroup VALUES ('Paracetamol')
INSERT INTO tbl_drugsGroup VALUES ('Pantoprazole')
INSERT INTO tbl_drugsGroup VALUES ('Remdesivir')
INSERT INTO tbl_drugsGroup VALUES ('Rabeprazole')
INSERT INTO tbl_drugsGroup VALUES ('Zinc Oxide')
INSERT INTO tbl_drugsGroup VALUES ('Naproxen')



--Data insert to Drugs Shelf Table
INSERT INTO tbl_drugsShelf VALUES ('A-001',501)
INSERT INTO tbl_drugsShelf VALUES ('A-002',502)
INSERT INTO tbl_drugsShelf VALUES ('A-003',503)
INSERT INTO tbl_drugsShelf VALUES ('B-001',504)
INSERT INTO tbl_drugsShelf VALUES ('C-001',505)
INSERT INTO tbl_drugsShelf VALUES ('D-001',506)
INSERT INTO tbl_drugsShelf VALUES ('E-001',507)
INSERT INTO tbl_drugsShelf VALUES ('F-001',508)
INSERT INTO tbl_drugsShelf VALUES ('G-001',509)
INSERT INTO tbl_drugsShelf VALUES ('H-001',510)
INSERT INTO tbl_drugsShelf VALUES ('I-001',511)
INSERT INTO tbl_drugsShelf VALUES ('J-001',512)
INSERT INTO tbl_drugsShelf VALUES ('K-001',513)
INSERT INTO tbl_drugsShelf VALUES ('L-001',514)
INSERT INTO tbl_drugsShelf VALUES ('M-001',515)
INSERT INTO tbl_drugsShelf VALUES ('A-011',516)
INSERT INTO tbl_drugsShelf VALUES ('A-012',517)
INSERT INTO tbl_drugsShelf VALUES ('A-013',518)
INSERT INTO tbl_drugsShelf VALUES ('B-011',519)
INSERT INTO tbl_drugsShelf VALUES ('C-011',520)
INSERT INTO tbl_drugsShelf VALUES ('K-011',521)
INSERT INTO tbl_drugsShelf VALUES ('P-001',522)
INSERT INTO tbl_drugsShelf VALUES ('D-010',523)
INSERT INTO tbl_drugsShelf VALUES ('D-011',524)
INSERT INTO tbl_drugsShelf VALUES ('E-011',525)



--Data insert to Drugs Table
EXEC sp_Insertdrugs 'Preservin',1,501,90004,50,'Pcs',5,.01,300,'Pcs'
EXEC sp_Insertdrugs 'Reservix',1,501,90008,100,'Pcs',4,.01,1000,'Pcs'
EXEC sp_Insertdrugs 'Beklo',11,510,90003,30,'Pcs',8,.01,300,'Pcs'
EXEC sp_Insertdrugs 'Flexi',1,501,90002,100,'Pcs',5,.01,2000,'Pcs'
EXEC sp_Insertdrugs 'Flexifen',11,510,90004,20,'Pcs',16,.01,500,'Pcs'
EXEC sp_Insertdrugs 'Paino',1,501,90011,100,'Pcs',4,.01,1000,'Pcs'
EXEC sp_Insertdrugs 'Alben DS',2,502,90011,100,'Pcs',5,.015,1000,'Pcs'
EXEC sp_Insertdrugs 'Zithrox',5,505,90011,6,'Pcs',20,.01,300,'Pcs'
EXEC sp_Insertdrugs 'Azimex',5,505,90005,20,'Pcs',25,.01,250,'Pcs'
EXEC sp_Insertdrugs 'Azin',5,505,90009,11,'Pcs',35,.01,250,'Pcs'
EXEC sp_Insertdrugs 'Azithrocin',5,505,90001,10,'Pcs',25,.01,500,'Pcs'
EXEC sp_Insertdrugs 'Ace Plus',20,520,90002,200,'Pcs',2.51,.01,3000,'Pcs'
EXEC sp_Insertdrugs 'Cafedon',20,520,90006,100,'Pcs',2.50,.01,300,'Pcs'
EXEC sp_Insertdrugs 'Hedax',20,520,90012,100,'Pcs',1.51,.01,300,'Pcs'
EXEC sp_Insertdrugs 'Napa Extra',20,520,90001,240,'Pcs',2.50,.01,3000,'Pcs'
EXEC sp_Insertdrugs 'Tamen X',20,520,90012,150,'Pcs',2.50,.01,500,'Pcs'
EXEC sp_Insertdrugs 'Pansec',21,521,90005,56,'Pcs',5,.01,3000,'Pcs'
EXEC sp_Insertdrugs 'Panoral',21,521,90011,40,'Pcs',4,.04,1000,'Pcs'
EXEC sp_Insertdrugs 'Zimax',5,505,90001,12,'Pcs',25,.01,1200,'Pcs'
EXEC sp_Insertdrugs 'Amacid Plus',4,504,90008,200,'Pcs',1.20,0,1000,'Pcs'
EXEC sp_Insertdrugs 'Antacid MAX',4,504,90001,100,'Pcs',2,.0,2000,'Pcs'
EXEC sp_Insertdrugs 'Antanil PLUS',4,504,90004,100,'Pcs',1.50,0,300,'Pcs'
EXEC sp_Insertdrugs 'Avlocid PLUS',4,504,90010,250,'Pcs',2,.005,1000,'Pcs'
EXEC sp_Insertdrugs 'Entacyd PLUS',4,504,90002,200,'Pcs',2,0,2000,'Pcs'
EXEC sp_Insertdrugs 'Geludrox HS',4,504,90005,120,'Pcs',1,0,100,'Pcs'
EXEC sp_Insertdrugs 'Diclofen',7,507,90003,100,'Pcs',1,0,1000,'Pcs'
EXEC sp_Insertdrugs 'A Fenac',7,507,90009,100,'Pcs',1,0,1000,'Pcs'
EXEC sp_Insertdrugs 'Anodyne MR',7,507,90008,50,'Pcs',4,.01,1000,'Pcs'
EXEC sp_Insertdrugs 'Rabeca',23,523,90002,50,'Pcs',5,.01,1000,'Pcs'
EXEC sp_Insertdrugs 'Acifix',23,523,90001,50,'Pcs',5,.01,1000,'Pcs'





-- Add Some records to SalesDetails Table
EXEC sp_AddDrugsToSales 1,10001,1104,50
EXEC sp_AddDrugsToSales 2,10002,1107,50
EXEC sp_AddDrugsToSales 3,10003,1104,40
EXEC sp_AddDrugsToSales 4,10005,1107,30
EXEC sp_AddDrugsToSales 5,10008,1105,30
EXEC sp_AddDrugsToSales 6,10009,1107,30
EXEC sp_AddDrugsToSales 1,10010,1107,30
EXEC sp_AddDrugsToSales 2,10011,1105,40
EXEC sp_AddDrugsToSales 11,10015,1104,50
EXEC sp_AddDrugsToSales 12,10017,1107,50
EXEC sp_AddDrugsToSales 13,10018,1104,40
EXEC sp_AddDrugsToSales 14,10019,1107,30
EXEC sp_AddDrugsToSales 15,10020,1105,30
EXEC sp_AddDrugsToSales 16,10026,1107,30
EXEC sp_AddDrugsToSales 10,10029,1107,30
EXEC sp_AddDrugsToSales 20,10030,1105,40
EXEC sp_AddDrugsToSales 24,10008,1107,30
EXEC sp_AddDrugsToSales 22,10011,1107,30
EXEC sp_AddDrugsToSales 21,10015,1105,100