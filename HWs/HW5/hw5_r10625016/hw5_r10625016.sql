/***** use database *****/
USE DB_class;

/***** info *****/
CREATE TABLE IF NOT EXISTS self(
    StuID varchar(10) NOT NULL,
    Department varchar(10) NOT NULL,
    SchoolYear int DEFAULT 1,
    Name varchar(10) NOT NULL,
    PRIMARY KEY (StuID)
);

INSERT INTO self
VALUES ('r10625016', '森林所', 2, '許致銓');

SELECT DATABASE();
SELECT * FROM self;

/* Prepared statement */
SET @dept = '森林環資所';
PREPARE selectByDept FROM 'SELECT * FROM Student WHERE 系所 = ?';
SET @dept_var = @dept;
EXECUTE selectByDept USING @dept_var;

SET @dept_var = '經濟系';
EXECUTE selectByDept USING @dept_var;

DEALLOCATE PREPARE selectByDept;

/* Stored-function */
DELIMITER //
CREATE FUNCTION IF NOT EXISTS GetChineseName(fullname VARCHAR(255))
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    RETURN TRIM(SUBSTRING_INDEX(fullname, ' (', 1));
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION IF NOT EXISTS GetEnglishName(fullname VARCHAR(255))
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    RETURN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(fullname, '(', -1), ')', 1));
END //
DELIMITER ;

SELECT 學號, GetChineseName(姓名) AS ChineseName, GetEnglishName(姓名) AS EnglishName
FROM Student
WHERE `group` = 9;  

/* Stored procedure */
--  clean the white space in original department data
UPDATE Student SET 系所 = TRIM(系所);

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS CountStudentsByDepartment(IN dept_name VARCHAR(255))
BEGIN
    SELECT COUNT(*) INTO @STCOUNT FROM Student WHERE 系所 = dept_name;
END //

DELIMITER ;

CALL CountStudentsByDepartment('資工系');
SELECT @STCOUNT AS StudentsInComputerScience;

CALL CountStudentsByDepartment('材料所');
SELECT @STCOUNT AS GraduateStudentsInMaterialSience;

/* View  */
CREATE VIEW new_student AS 
SELECT  身份, 系所, 年級, 學號, 信箱, 班別, `group`, `captain`, GetChineseName(姓名) AS 中文名, GetEnglishName(姓名) AS 英文名
FROM Student;

SELECT 系所, 年級, 學號, 中文名, 英文名 
FROM new_student
WHERE 系所 = '森林環資所';


/* Trigger */
CREATE TABLE record_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(10),
    action_timestamp DATETIME,
    action_by_user VARCHAR(255)
);

SET @NUMINS = 0;
SET @NUMDEL = 0;

DELIMITER //
CREATE TRIGGER after_student_insert
AFTER INSERT ON Student
FOR EACH ROW
BEGIN
  INSERT INTO record_table (action_type, action_timestamp, action_by_user)
  VALUES ('INSERT', NOW(), USER());
  SET @NUMINS = @NUMINS + 1;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_student_delete
AFTER DELETE ON Student
FOR EACH ROW
BEGIN
  INSERT INTO record_table (action_type, action_timestamp, action_by_user)
  VALUES ('DELETE', NOW(), USER());
  SET @NUMDEL = @NUMDEL + 1;
END //
DELIMITER ;

SELECT * FROM record_table;
SELECT @NUMINS AS InsertedStudents, @NUMDEL AS DeletedStudents;

-- 3 Insert & 2 Delete
INSERT INTO Student (身份, 系所, 年級, 學號, 姓名, 信箱, 班別, `group`, `captain`)
VALUES ('學生', '資工系', 3, 'B09901024',  '周杰倫', 'B09901024@ntu.edu.tw', '資料庫系統-從SQL到NoSQL (EE5178)', 9, 0);

INSERT INTO Student (身份, 系所, 年級, 學號, 姓名, 信箱, 班別, `group`, `captain`)
VALUES ('學生', '資工系', 3, 'B09902037',  '陳奕迅', 'B09902037@ntu.edu.tw', '資料庫系統-從SQL到NoSQL (EE5178)', 9, 0); 

INSERT INTO Student (身份, 系所, 年級, 學號, 姓名, 信箱, 班別, `group`, `captain`)
VALUES ('學生', '資工系', 5, 'B07902102',  '陳信宏', 'B07902102@ntu.edu.tw', '資料庫系統-從SQL到NoSQL (EE5178)', 9, 0); 

DELETE FROM Student WHERE 學號 = 'R12527A01';
DELETE FROM Student WHERE 學號 = 'R12631069';

SELECT * FROM record_table;
SELECT @NUMINS AS InsertedStudents, @NUMDEL AS DeletedStudents;

/* drop database */
DROP DATABASE IF EXISTS DB_class;