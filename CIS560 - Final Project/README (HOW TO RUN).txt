-- Open up your SQL Server Management Studio 
- ensure that you are on localdb

-- Run DataBase_Setup_Query 

-- Open up Data.sql
- ensure that you change all of the file addresses to where you have this stored, mine is 
	'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\[CSV NAME]'
- now you can run it. 

-- Run Procedures.sql

-- Open up Visual Studio 
-- you should be able to open repository straight from GitHub 



NOTE: we do not exist in USERS_MOCK.CSV , so run this query at the end to establish us in the DB

UPDATE dbo.Users
SET isAdmin = 0;

INSERT INTO dbo.Users (Email, Alias, Name, Age, CreatedAt, DeletedAt, isAdmin)
VALUES
    ('tjlarson@ksu.edu',  'tjlarson',     'TJ Larson',      21, GETDATE(), NULL, 1),
    ('zkf@ksu.edu',       'zekeflippo',   'Zeke Flippo',    21, GETDATE(), NULL, 1),
    ('jwuthnow@ksu.edu',  'jacobwuthnow', 'Jacob Wuthnow',  20, GETDATE(), NULL, 1);


