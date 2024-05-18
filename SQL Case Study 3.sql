
create Database casestudy3
use casestudy3
select * from  Continent
select* from customers
select * from Transactions

/* 1. Display the count of customers in each region who have
done the transaction in the year 2020. */

SELECT COUNT(C.CUSTOMER_ID) AS NOOFCUSTOMERS, C.REGION_ID
FROM CUSTOMERS C
INNER JOIN TRANSACTIONS T ON C.CUSTOMER_ID = T.CUSTOMER_ID
WHERE YEAR(T.TXN_DATE) = 2020
GROUP BY C.REGION_ID;

/* 2. Display the maximum and minimum transaction amount of
each transaction type. */

SELECT MAX(TXN_AMOUNT) AS MAXAMOUNT, MIN(TXN_AMOUNT) AS MINAMOUNT, TXN_TYPE
FROM TRANSACTIONS
GROUP BY TXN_TYPE;

/* 3. Display the customer id, region name and transaction amount
where transaction type is deposit and transaction amount > 2000. */

SELECT C.CUSTOMER_ID, CO.REGION_NAME, T.TXN_AMOUNT
FROM CUSTOMERS C
INNER JOIN TRANSACTIONS T ON C.CUSTOMER_ID = T.CUSTOMER_ID
INNER JOIN CONTINENT CO ON CO.REGION_ID = C.REGION_ID
WHERE T.TXN_TYPE = 'DEPOSIT' AND T.TXN_AMOUNT > 2000;

/* 4. Find duplicate records in the Customer table. */

SELECT CUSTOMER_ID, REGION_ID, START_DATE, END_DATE
FROM CUSTOMERS
GROUP BY CUSTOMER_ID, REGION_ID, START_DATE, END_DATE
HAVING COUNT(*) > 1;

/* 5. Display the customer id, region name, transaction type and transaction
amount for the minimum transaction amount in deposit. */

SELECT C.CUSTOMER_ID, CO.REGION_NAME, T.TXN_TYPE, T.TXN_AMOUNT
FROM CUSTOMERS C
INNER JOIN TRANSACTIONS T ON C.CUSTOMER_ID = T.CUSTOMER_ID
INNER JOIN CONTINENT CO ON CO.REGION_ID = C.REGION_ID
WHERE TXN_TYPE = 'DEPOSIT' AND TXN_AMOUNT = (SELECT MIN(TXN_AMOUNT) FROM TRANSACTIONS);

/*6. Create a stored procedure to display details of customers in the
Transaction table where the transaction date is greater than Jun 2020.*/

CREATE PROCEDURE CUSTOMER_DETAILS
AS
    SELECT C.*
    FROM CUSTOMERS C
    INNER JOIN TRANSACTIONS T ON C.CUSTOMER_ID = T.CUSTOMER_ID
    WHERE YEAR(T.TXN_DATE) > 2020 AND MONTH(T.TXN_DATE) > 6;
GO

EXEC CUSTOMER_DETAILS;

/* 7. Create a stored procedure to insert a record in the Continent table. */

CREATE PROCEDURE INSERT_RECORD @val INT, @val2 varchar(20)
AS
    INSERT INTO CONTINENT
    VALUES (@val, @val2)
GO

EXEC INSERT_RECORD @val = 6, @val2 = 'Antartica';

/* 8. Create a stored procedure to display the details of transactions that
happened on a  specific day. */

CREATE PROCEDURE SPECIFIC_DATE @date varchar(20)
AS
BEGIN
    SELECT *
    FROM TRANSACTIONS
    WHERE txn_date = @date
END

EXEC SPECIFIC_DATE @date = '2020-01-21';

/* 9. Create a user defined function to add 10% of the transaction amount in a
table.https://www.youtube.com/watch?v=cdr0TuKCvDU*/

CREATE FUNCTION ADD_TENPERCENT()
RETURNS TABLE
AS
RETURN
(
    SELECT TXN_AMOUNT * 1.1O FROM TRANSACTIONS
)

SELECT * FROM ADD_TENPERCENT();

/* 10. Create a user defined function to find the total transaction amount
for a given transaction type. */

CREATE FUNCTION TOTAL_AMOUNT(@TXN_TYPE AS VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(TXN_AMOUNT), @TXN_TYPE FROM TRANSACTIONS GROUP BY @TXN_TYPE
)
END

SELECT * FROM TOTAL_AMOUNT('deposit');


/* 11. Create a table value function which comprises the columns customer_id, region_id, 
txn_date , txn_type , txn_amount which will retrieve data from the above table. */

CREATE FUNCTION DisplayColumns (@customer_id INT)
RETURNS TABLE
AS
RETURN
    SELECT C.CUSTOMER_ID, C.REGION_ID, T.TXN_DATE, T.TXN_TYPE, T.TXN_AMOUNT
    FROM TRANSACTIONS T
    INNER JOIN CUSTOMERS C ON T.CUSTOMER_ID = C.CUSTOMER_ID
    WHERE C.CUSTOMER_ID = @customer_id;

SELECT *
FROM DisplayColumns(429)

create FUNCTION MVF(@type varchar(30))
RETURNS @mvf TABLE
(
customer_id int,
region_id int,
txn_date date,
txn_type varchar(30),
txn_amount int
)
AS
BEGIN
INSERT INTO @mvf
select c.customer_id, c.region_id, t.txn_date,t.txn_type, t.txn_amount from Customers c
inner join Transactions t
on c.customer_id = t.customer_id
where t.txn_type = @type
return
end

/* 12. Create a TRY...CATCH block to print a region id and region name in a single column. */

BEGIN TRY
    SELECT CAST(REGION_ID AS VARCHAR(20))
    FROM CONTINENT
    UNION
    SELECT REGION_NAME
    FROM CONTINENT
END TRY
BEGIN CATCH
    PRINT('ERROR WITH UNION')
END CATCH

/* 13. Create a TRY...CATCH block to insert a value in the Continent table. */

BEGIN TRY
    INSERT INTO CONTINENT
    VALUES ( 6,'Antartica')
END TRY
BEGIN CATCH
    PRINT('ERROR WITH INSERT')
END CATCH

/* 14. Create a trigger to prevent deleting a table in a database. */

CREATE TABLE InsteadofTriggerTest
(
ID int,
Name varchar(100)
);
GO
CREATE OR ALTER TRIGGER InsteadofDeleteTrigger
ON [dbo].[InsteadofTriggerTest]
INSTEAD OF DELETE
AS
SELECT  'trigger is fired'

INSERT INTO Audit (Id,Name,Modifieduser, Operation)
SELECT ID,Name,SYSTEM_USER,'Insteadofdelete'
FROM deleted
 
Insert Into InsteadofTriggerTest
select 12, 'Ramesh'

DELETE from InsteadofTriggerTest
where ID = 12
select * from Audit

/*15. Create a trigger to audit the data in a table.*/
CREATE TABLE Audit
(
ID int,
Name varchar (100),
Modifieddate datetime default (GETDATE()),
Modifieduser  varchar (100),
operation varchar (100)
) 

---- AFTER INSERT TRIGGER--------------------------------------

CREATE TABLE After_Trigger_Test
(
ID int,
Name varchar(100)
);
GO

CREATE OR Alter TRIGGER trgafterInsert
ON [dbo].[After_Trigger_Test]
FOR INSERT ---for which operation
AS 
 SELECT 'Trigger is fired'
 
 INSERT INTO Audit(ID,Name,ModifiedUser,Operation)
 Select ID ,Name, System_user,'Insert'
 FROM Inserted
 go
Insert Into After_Trigger_Test (ID, Name)
select 10, 'Ram'n
Insert Into After_Trigger_Test (ID, Name)
select 11, 'Sham'
 
 -----AFTER DELETE TRIGGER------------------------
 CREATE TABLE After_Trigger_Test
(
ID int,
Name varchar(100)
);
GO
 CREATE OR ALTER TRIGGER TrgAfterDelete
 ON[dbo].[After_Trigger_Test]
 FOR DELETE
 AS 
      SELECT 'TRIGGERED IS FIRED'

	  INSERT INTO Audit (ID, Name, Modifieduser, Operation)
	  SELECT ID, Name, SYSTEM_USER,'DELETE'
	  FROM DELETED
GO

DELETE FROM After_Trigger_Test
WHERE ID=11

CREATE OR ALTER TRIGGER trgAfterUpdate
ON [dbo].[After_Trigger_Test]
FOR UPDATE
AS
      INSERT INTO Audit( ID, Name, Modifieduser,Operation)
	  SELECT ID, Name, SYSTEM_USER, 'DeleteOldRecord'
	  FROM DELETED

      INSERT INTO Audit( ID, Name, Modifieduser,Operation)
	  SELECT ID, Name, SYSTEM_USER, 'InsertNewRecord'
	  FROM INSERTED

  UPDATE  After_Trigger_Test
  SET Name = 'Sri'
  WHERE ID = 10

SELECT * FROM Audit

/*16. Create a trigger to prevent login of the same user id in multiple pages.*/

select * from sys.dm_exec_sessions order by is_user_process desc
select is_user_process, original_login_name from sys.dm_exec_sessions
order by is_user_process desc

create trigger trg_logon
on all server
for logon
as begin
declare @LoginName varchar(50)
set @LoginName = ORIGINAL_LOGIN()
if(select count(*) from sys.dm_exec_sessions where
	is_user_process = 1 and original_login_name = @LoginName) > 3
	begin
	print 'Fourth connection attempt by ' +@loginName + 'Blocked'
	rollback;
	end
end

drop trigger trg_logon on all server
    

/*17.  Display top n customers on the basis of transaction type (amount).*/
SELECT * FROM (
		SELECT *,
	            DENSE_RANK () OVER (
					PARTITION BY txn_type
					ORDER BY txn_amount DESC
	            ) amount_rank
		FROM
				[dbo].[Transactions]
) t
WHERE amount_rank < 5;

/*18. Create a pivot table to display the total purchase, withdrawal and deposit for all the customers.*/

SELECT *
FROM (SELECT CUSTOMER_ID, TXN_TYPE, TXN_AMOUNT FROM TRANSACTIONS) AS T
    PIVOT (SUM(TXN_AMOUNT) FOR TXN_TYPE IN (PURCHASE, DEPOSIT, WITHDRAWAL)) AS P
ORDER BY customer_id ASC