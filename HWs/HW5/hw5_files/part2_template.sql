/***** use database *****/
USE DB_class;

/***** info *****/
CREATE TABLE self (
    StuID varchar(10) NOT NULL,
    Department varchar(10) NOT NULL,
    SchoolYear int DEFAULT 1,
    Name varchar(10) NOT NULL,
    PRIMARY KEY (StuID)
);

INSERT INTO self
VALUES ('r10900001', '電機所', 2, 'OOO');

SELECT DATABASE();
SELECT * FROM self;

/* Prepared statement */

/* Stored-function */

/* Stored procedure */

/* View  */

/* Trigger */

/* drop database */