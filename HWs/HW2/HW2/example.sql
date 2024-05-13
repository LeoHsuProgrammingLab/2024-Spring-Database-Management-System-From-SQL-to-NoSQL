/* create and use database */
CREATE DATABASE MovieDB;
USE MovieDB;

/* info */
CREATE TABLE self (
    StuID varchar(10) NOT NULL,
    Department varchar(10) NOT NULL,
    SchoolYear int DEFAULT 1,
    Name varchar(10) NOT NULL,
    PRIMARY KEY (StuID)
);

INSERT INTO self
VALUES ('r07000000', '電機所', 1, '大中天');

SELECT DATABASE();
SELECT * FROM `self`;



/* create table */
CREATE TABLE Users (
    UserID int,
    UserName varchar(40),
    FirstName varchar(40),
    PRIMARY KEY (UserID)
);



/* insert */
INSERT INTO Users
VALUES 
('1', 'Snoopy', 'Dog'),
('2', 'Sumikko', 'Gurashi');


/* create two views (Each view should be based on two tables.)*/
CREATE VIEW Users_view AS
SELECT UserID, UserName
FROM Users;


/* select from all tables and views */
SELECT * FROM Users;


/* drop database */
DROP DATABASE MovieDB;
