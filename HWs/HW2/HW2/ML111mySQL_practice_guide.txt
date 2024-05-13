# Getting started with MySQL

NTU EE5178 DBMS from SQL to NoSQL

## Installation 

Before start practicing with MySQL server, make sure you have installed MySQL successfully:
  * Go to https://www.mysql.com (https://dev.mysql.com/downloads/)
  * Install MySQL community edition (free version) version 8.0 and up.
    * If you are using Windows.  You can download and run "MySQL Installer for Windows".  It will install most necessary software for you.
	* For linux or MAC user, you can go to https://dev.mysql.com/doc/refman/8.0/en/installing.html and follow the instructions.
	* You don't need to register for an Oracle account if the website prompts you to log in for downloading. Look for the option "No thanks, just start my download" located below if you don't want to register.
  * We use version 8.0 as example in this course
  * The installation should include 
    * “MySQL8.0 Command line Client”
    * “MySQL8.0 Command line Client - Unicode” 
    * “MySQL shell”
  * You may optionally install
    * MySQL8.0 workbench, but it's not absolutely necessary at this point.

## Create user account
* The installation process should guide you through root account creation.
  * You can try to create more accounts, or use root account for your learning process.

## Start using mySQL
After you have installed the mySQL server, each time before start using mySQL:
* Make sure you have.
  * If you have configure MySQL to run automatically each time your computer starts up, there is no problem.
  * Otherwise, you may have to start the server manually.

To start use mySQL:
* Start up “MySQL8.0 Command line Client - Unicode”
* Enter password and login
* Then you will see the MySQL command prompt, and you can start using mySQL
* Note there are two types of things you can type at the Comment line Client:
  * DBMS commands, which do not requirement an ending semicolon, and 
  * SQL commands and statements, which require an ending semicolon

## Important DBMS command and SQL commands
### Initial exploration
* Help
* Status
* Help Contents;
* Show databases;

# Explore a database
* Use \<database_name\>;
  * e.g: Use sakila;
* Show tables;
* Describe \<table_name\>;
  * Describe actor;
  * Describe actor_info;
* show create table \<table_name>\;
  * Show create table actor;
  * Show create table actor_info;
* Find out how many rows there are in a table:
  * "select count(*) from actor;"
* Find out how the data looks like in a table:
  * "select * from actor limit 5;"

## Retrieve general information
* Select version();
* Select version(), current_date;
* Select 365*24;
* Select PI()/2;
* Select user();
* Select database();

## Create and connect to your own db

* Create your database
  * create database \<database_name\>
  * e.g.: create database test
* If you want to delete your database (use this very carefully, as you will delete all information in your database):
  * drop database \<database_name\>
  * e.g.: drop database test
* Connect to your database in order to use it
  * use \<database_name\>
  * e.g.: use test

* try to create a table:
```
Create table student(
SID int(9) unsigned 	primary key not NULL,
Fname char(20) 				not NULL,
Lname char(20) 				not NULL,
Dept char(20) 				not NULL,
Division char,
Year tinyint unsigned)
;
```

* try to insert some rows:
```
Insert into student values (1, 'john', 'smith', 'physics', 'u', 2);
insert into student values (3, 'peter', 'chen', 'chemistry', 'p', 4);
```
* Verify that the data was inserted successfully:
```
select * from student;
```

## More informations
* [Video Series: MySQL 101 for Beginners](https://www.youtube.com/playlist?list=PLWx5a9Tn2EvHIXXPPWnYxW7oB3tHQwMk_)
* [MySQL Tutorial: Introduction to MySQL](https://dev.mysql.com/doc/refman/8.0/en/tutorial.html)



