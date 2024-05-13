/* create and use database */
CREATE DATABASE `NTUBTMS`;
USE `NTUBTMS`;

CREATE TABLE `self` (
    StudentID VARCHAR(9) NOT NULL,
    Name VARCHAR(31) NOT NULL,
    Department VARCHAR(63) NOT NULL,
    Year ENUM('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate') NOT NULL,
    GPA FLOAT NOT NULL, 
    Dream VARCHAR(255) NOT NULL,

    PRIMARY KEY (StudentID)
);

-- TODO: csv, show engines, look up the default dir of MySQL

INSERT INTO `self`
VALUES ('r10625016', 'Chih-Chuan Hsu', 'Forestry and Resource Conservation', 'Graduate', 4.14, 'To be a software engineer.');

SELECT DATABASE();
SELECT * FROM `self`;

CREATE TABLE Team (
    TeamID INT AUTO_INCREMENT NOT NULL,
    School VARCHAR(31) NOT NULL,
    SportsType VARCHAR(31) NOT NULL,
    Division ENUM('D1', 'D2', 'D3') NOT NULL,

    PRIMARY KEY (TeamID)
);

/* create tables */
CREATE TABLE TeamMember (
	SSN VARCHAR(9) NOT NULL, 
    Name VARCHAR(31) NOT NULL, 
    Birthday DATE NOT NULL,
    TeamID INT,
    PhoneNumber VARCHAR(15) NOT NULL,
    Address JSON,

    PRIMARY KEY (SSN),
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

CREATE TABLE Player (
    SSN VARCHAR(9) NOT NULL,
    Position JSON NOT NULL,
    Height FLOAT NOT NULL,
    JoinDate DATE NOT NULL,
    LeaveDate DATE,
    Stats VARCHAR(255),   -- Season, Role, Score, Rebound, Offensive Rebound, Defensive Rebound, Assist, Steal, Block, Turnover, etc.
    
    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN)
);

CREATE TABLE Coach (
    SSN VARCHAR(9) NOT NULL,
    Role VARCHAR(63) NOT NULL,
    Payment INT DEFAULT 0 Check (Payment >= 0),
    JoinDate DATE NOT NULL,
    LeaveDate DATE,

    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN)
);

CREATE TABLE Manager (
    SSN VARCHAR(9) NOT NULL,
    Skill JSON,
    JoinDate DATE NOT NULL,
    LeaveDate DATE, 

    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN)
);

CREATE TABLE Analyst (
    SSN VARCHAR(9) NOT NULL,
    Skill JSON,
    JoinDate DATE NOT NULL,
    LeaveDate DATE,

    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN)
);

CREATE TABLE PhysicalTherapist (
    SSN VARCHAR(9) NOT NULL, 
    Responsibility JSON NOT NULL,
    JoinDate DATE NOT NULL,
    LeaveDate DATE,

    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN)
);

CREATE TABLE Student (
    SSN VARCHAR(9) NOT NULL,
    StudentID VARCHAR(9) NOT NULL,
    School VARCHAR(63) NOT NULL,
    Department VARCHAR(63) NOT NULL,
    UniversityYear ENUM('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate') NOT NULL,
    GPA FLOAT Check(GPA >= 0 AND GPA <= 4.3 OR GPA IS NULL),

    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN)
);

CREATE TABLE Company (
    CompanyID INT AUTO_INCREMENT NOT NULL,
    Name VARCHAR(31) NOT NULL,
    Address JSON NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL, 
    CapitalAmount BIGINT DEFAULT 1000000 CHECK (CapitalAmount >= 0),   

    PRIMARY KEY (CompanyID)
);

CREATE TABLE TheEmployeed (
    SSN VARCHAR(9) NOT NULL,
    CompanyID INT NOT NULL, 
    Title VARCHAR(63) NOT NULL,
    Salary INT DEFAULT 27470 CHECK (Salary >= 0), 

    PRIMARY KEY (SSN),
    FOREIGN KEY (SSN) REFERENCES TeamMember(SSN),
    FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID)
);

CREATE TABLE OtherAlumni (
    SSN VARCHAR(9) NOT NULL, 
    Name VARCHAR(31) NOT NULL,
    Occupation VARCHAR(63) NOT NULL,
    Department VARCHAR(63) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL, 

    PRIMARY KEY (SSN)
);

CREATE TABLE Rival (
    AnalystSSN VARCHAR(9) NOT NULL,
    Season VARCHAR(31) NOT NULL,
    School VARCHAR(31) NOT NULL,
    Tactics VARCHAR(255) NOT NULL,
    Report JSON NOT NULL,

    PRIMARY KEY (AnalystSSN, Season, School),
    FOREIGN KEY (AnalystSSN) REFERENCES Analyst(SSN)
);

CREATE TABLE Sponsor (
    SponsorID INT AUTO_INCREMENT NOT NULL,
    SponsorshipType ENUM ('Cash', 'Device', 'Service') NOT NULL,
    SponsorshipDESC VARCHAR(255),
    SponsorshipPeriod ENUM ('Monthly', 'Quarterly', 'Yearly', 'Forever') NOT NULL,
    SpecialRequest JSON,

    SponsorEntityType ENUM ('Company', 'TheEmployeed', 'OtherAlumni') NOT NULL,
    SSN VARCHAR(9),
    CompanyID INT,

    PRIMARY KEY (SponsorID)
);

/* Relationship */
CREATE TABLE Supervision (
    SupervisorSSN VARCHAR(9) NOT NULL,
    SuperviseeSSN VARCHAR(9) NOT NULL,

    PRIMARY KEY (SupervisorSSN, SuperviseeSSN),
    FOREIGN KEY (SupervisorSSN) REFERENCES Player(SSN),
    FOREIGN KEY (SuperviseeSSN) REFERENCES Player(SSN)
);

CREATE TABLE Instruct (
    CoachSSN VARCHAR(9) NOT NULL,
    PlayerSSN VARCHAR(9) NOT NULL,

    PRIMARY KEY (CoachSSN, PlayerSSN),
    FOREIGN KEY (CoachSSN) REFERENCES Coach(SSN),
    FOREIGN KEY (PlayerSSN) REFERENCES Player(SSN)
);

CREATE TABLE Treat (
    PhysicalTherapistSSN VARCHAR(9) NOT NULL,
    PlayerSSN VARCHAR(9) NOT NULL,

    PRIMARY KEY (PhysicalTherapistSSN, PlayerSSN),
    FOREIGN KEY (PhysicalTherapistSSN) REFERENCES PhysicalTherapist(SSN),
    FOREIGN KEY (PlayerSSN) REFERENCES Player(SSN)
);

CREATE TABLE `Analyze` (
    AnalystSSN VARCHAR(9) NOT NULL,
    Season VARCHAR(31) NOT NULL,
    School VARCHAR(31) NOT NULL,

    PRIMARY KEY (AnalystSSN, Season, School),
    FOREIGN KEY (AnalystSSN) REFERENCES Analyst(SSN),
    FOREIGN KEY (AnalystSSN, Season, School) REFERENCES Rival(AnalystSSN, Season, School)
);

CREATE TABLE Support (
    SponsorID INT NOT NULL,
    TeamID INT NOT NULL,

    PRIMARY KEY (SponsorID, TeamID),
    FOREIGN KEY (SponsorID) REFERENCES Sponsor(SponsorID),
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

/* overlapping specialization */
SELECT * FROM TeamMember
LEFT JOIN Player ON TeamMember.SSN = Player.SSN
LEFT JOIN Coach ON TeamMember.SSN = Coach.SSN
LEFT JOIN Manager ON TeamMember.SSN = Manager.SSN
LEFT JOIN Analyst ON TeamMember.SSN = Analyst.SSN
LEFT JOIN PhysicalTherapist ON TeamMember.SSN = PhysicalTherapist.SSN;

/* disjoint specialization */
DELIMITER $$
CREATE TRIGGER CheckStudentSSNUnique
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    DECLARE ssn_cnt INT;
    SELECT COUNT(*) INTO ssn_cnt FROM TheEmployeed WHERE SSN = NEW.SSN;
    IF ssn_cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SSN already exists in TheEmployeed table.';
    END IF;
END $$

CREATE TRIGGER CheckTheEmployeedSSNUnique
BEFORE INSERT ON TheEmployeed
FOR EACH ROW
BEGIN
    DECLARE ssn_cnt INT;
    SELECT COUNT(*) INTO ssn_cnt FROM Student WHERE SSN = NEW.SSN;
    IF ssn_cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SSN already exists in Student table.';
    END IF;
END $$
DELIMITER ;

SELECT * FROM TeamMember
LEFT JOIN Student ON TeamMember.SSN = Student.SSN
LEFT JOIN TheEmployeed ON TeamMember.SSN = TheEmployeed.SSN;

/* union generalization */
DELIMITER $$
CREATE TRIGGER CheckSponsorReference 
BEFORE INSERT ON Sponsor
FOR EACH ROW
BEGIN 
    IF NEW.SponsorEntityType = 'Company' THEN
        IF NOT EXISTS (SELECT * FROM Company WHERE CompanyID = NEW.CompanyID) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Company does not exist.';
        END IF;
    ELSEIF NEW.SponsorEntityType = 'TheEmployeed' THEN
        IF NOT EXISTS (SELECT * FROM TheEmployeed WHERE SSN = NEW.SSN) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'TheEmployeed does not exist.';
        END IF;
    ELSEIF NEW.SponsorEntityType = 'OtherAlumni' THEN
        IF NOT EXISTS (SELECT * FROM OtherAlumni WHERE SSN = NEW.SSN) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'OtherAlumni does not exist.';
        END IF;
    END IF;
END $$
DELIMITER ;

SELECT * FROM Sponsor
LEFT JOIN Company ON Sponsor.SponsorEntityType = 'Company' AND Sponsor.SSN = Company.CompanyID
LEFT JOIN TheEmployeed ON Sponsor.SponsorEntityType = 'TheEmployeed' AND Sponsor.SSN = TheEmployeed.SSN
LEFT JOIN OtherAlumni ON Sponsor.SponsorEntityType = 'OtherAlumni' AND Sponsor.SSN = OtherAlumni.SSN;

/* insert */
INSERT INTO Team (School, SportsType, Division) VALUES ('NTUST', 'Basketball', 'D2');
INSERT INTO Team (School, SportsType, Division) VALUES ('NCTU', 'Basketball', 'D1');
INSERT INTO Team (School, SportsType, Division) VALUES ('NTNU', 'Basketball', 'D1');

INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('123456789', 'Chih-Chuan Hsu', '1998-10-01', 1, '0987654321', '{"City": "Taipei", "Street": "No. 1, Sec. 4, Roosevelt Rd."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('234567891', 'John Doe', '1995-05-15', 1, '0912345658', '{"City": "New York", "Street": "123 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('567890123', 'Emily Williams', '1993-03-20', 1, '0945678901', '{"City": "Houston", "Street": "101 Pine St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('890123456', 'David Martinez', '1985-09-18', 1, '0978901234', '{"City": "Dallas", "Street": "404 Cedar St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('098765432', 'Sarah Garcia', '1997-04-25', 1, '0910909090', '{"City": "Phoenix", "Street": "707 Oak St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('234567890', 'John Doe', '1995-05-15', 1, '0912345678', '{"City": "New York", "Street": "123 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('678901234', 'Christopher Brown', '1996-11-10', 2, '0956789012', '{"City": "Miami", "Street": "202 Maple St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('901234567', 'Jessica Lee', '1994-02-14', 2, '0989012345', '{"City": "Boston", "Street": "505 Birch St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('234567892', 'John Doe', '1995-05-15', 2, '0912345668', '{"City": "New York", "Street": "123 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('456789012', 'Michael Johnson', '1988-08-03', 3, '0934567890', '{"City": "Chicago", "Street": "789 Oak St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('789012345', 'Amanda Wilson', '1991-07-05', 3, '0967890123', '{"City": "Seattle", "Street": "303 Walnut St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('012345678', 'Daniel Taylor', '1989-06-30', 3, '0990123456', '{"City": "San Francisco", "Street": "606 Pine St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438134', 'John Doe', '1995-05-15', 2, '0912345645', '{"City": "New York", "Street": "123 Main St."}');

INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('123456789', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 180, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 10, "Rebound": 5, "Offensive Rebound": 2, "Defensive Rebound": 3, "Assist": 5, "Steal": 2, "Block": 1, "Turnover": 3}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('234567891', '{"PG": 0, "SG": 1, "SF": 0, "PF": 0, "C": 0}', 185, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 12, "Rebound": 6, "Offensive Rebound": 3, "Defensive Rebound": 3, "Assist": 4, "Steal": 1, "Block": 0, "Turnover": 2}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('567890123', '{"PG": 0, "SG": 0, "SF": 1, "PF": 0, "C": 0}', 190, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 15, "Rebound": 8, "Offensive Rebound": 4, "Defensive Rebound": 4, "Assist": 3, "Steal": 3, "Block": 1, "Turnover": 4}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('890123456', '{"PG": 0, "SG": 0, "SF": 0, "PF": 1, "C": 0}', 195, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 18, "Rebound": 10, "Offensive Rebound": 5, "Defensive Rebound": 5, "Assist": 2, "Steal": 4, "Block": 2, "Turnover": 5}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('098765432', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 200, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 20, "Rebound": 12, "Offensive Rebound": 6, "Defensive Rebound": 6, "Assist": 1, "Steal": 5, "Block": 3, "Turnover": 6}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('234567890', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 205, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 22, "Rebound": 14, "Offensive Rebound": 7, "Defensive Rebound": 7, "Assist": 0, "Steal": 6, "Block": 4, "Turnover": 7}');

INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('123456789', 'Assistant Coach', 0, '2020-10-01', NULL);
INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('234567891', 'Assistant Coach', 0, '2020-10-01', NULL);
INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('567890123', 'AC Coach', 0, '2020-10-01', NULL);
INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('901234567', 'Head Coach', 0, '2022-10-01', NULL);

INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('890123456', '{"Skill": "Management, Photographer"}', '2020-10-01', NULL);
INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('098765432', '{"Skill": "Management, Digital Marketing"}', '2020-10-01', '2023-06-30');
INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('234567890', '{"Skill": "Management"}', '2020-10-01', NULL);

INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('678901234', '{"Skill": "Data Analysis, Machine Learning"}', '2020-10-01', NULL);
INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('901234567', '{"Skill": "Data Analysis, Data Visualization"}', '2019-05-01', '2020-07-31');
INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('234567892', '{"Skill": ""}', '2020-10-01', NULL);

INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('456789012', '{"Responsibility": "Physical Therapy, Nutrition"}', '2020-10-01', NULL);
INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('789012345', '{"Responsibility": "Physical Therapy, Massage"}', '2020-10-01', '2022-06-30');
INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('012345678', '{"Responsibility": "Physical Therapy, Acupuncture"}', '2020-10-01', NULL);

INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('123456789', 'r10625016', 'NTU', 'Forestry and Resource Conservation', 'Graduate', 4.14);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('234567891', 'r10625017', 'NTU', 'Forestry and Resource Conservation', 'Graduate', 4.13);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('567890123', 'r10625017', 'NTU', 'Physics', 'Graduate', 4.13);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('890123456', 'r10625018', 'NTU', 'Computer Science', 'Graduate', 3.85);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('098765432', 'r10625019', 'NTU', 'Computer Science', 'Graduate', 3.76);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('234567890', 'r10625020', 'NTU', 'Computer Science', 'Graduate', 3.23);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('678901234', 'r10625021', 'NTU', 'Electrical Engineering', 'Graduate', 4.04);

INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Google', '{"City": "Mountain View", "Street": "1600 Amphitheatre Pkwy"}', '6502530000', 1200000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Microsoft', '{"City": "Redmond", "Street": "One Microsoft Way"}', '4258828080', 1000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Apple', '{"City": "Cupertino", "Street": "One Apple"}', '4089961010', 5000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Amazon', '{"City": "Seattle", "Street": "410 Terry Ave N"}', '2062661000', 1000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Facebook', '{"City": "Menlo Park", "Street": "1 Hacker Way"}', '6505434800', 540000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Tesla', '{"City": "Palo Alto", "Street": "3500 Deer Creek Rd"}', '6506815000', 1000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('NVIDIA', '{"City": "Santa Clara", "Street": "2788 San Tomas Expy"}', '4084862000', 70000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Intel', '{"City": "Santa Clara", "Street": "2200 Mission College Blvd"}', '4087658080', 900000000);

INSERT INTO TheEmployeed (SSN, CompanyID, Title, Salary) VALUES ('901234567', 1, 'Software Engineer', 130000);
INSERT INTO TheEmployeed (SSN, CompanyID, Title, Salary) VALUES ('012345678', 3, 'HR Manager', 85000);
INSERT INTO TheEmployeed (SSN, CompanyID, Title, Salary) VALUES ('789012345', 3, 'Financial Analyst', 75000);
INSERT INTO TheEmployeed (SSN, CompanyID, Title, Salary) VALUES ('456789012', 2, 'Marketing Manager', 80000);
INSERT INTO TheEmployeed (SSN, CompanyID, Title, Salary) VALUES ('234567892', 1, 'Software Engineer', 150000);

INSERT INTO OtherAlumni (SSN, Name, Occupation, Department, PhoneNumber) VALUES ('233333390', 'John Doe', 'Software Engineer', 'Computer Science', '0912345645');
INSERT INTO OtherAlumni (SSN, Name, Occupation, Department, PhoneNumber) VALUES ('233333391', 'Jane Smith', 'Data Analyst', 'Statistics', '0923456789');
INSERT INTO OtherAlumni (SSN, Name, Occupation, Department, PhoneNumber) VALUES ('233333392', 'Michael Johnson', 'Marketing Manager', 'Marketing', '0934567890');
INSERT INTO OtherAlumni (SSN, Name, Occupation, Department, PhoneNumber) VALUES ('233333393', 'Emily Davis', 'Financial Advisor', 'Finance', '0945678901');
INSERT INTO OtherAlumni (SSN, Name, Occupation, Department, PhoneNumber) VALUES ('233333394', 'Andrew Wilson', 'Human Resources Specialist', 'Human Resources', '0956789012');
INSERT INTO OtherAlumni (SSN, Name, Occupation, Department, PhoneNumber) VALUES ('233333395', 'Jessica Taylor', 'Software Developer', 'Information Technology', '0967890123');

INSERT INTO Sponsor (SponsorshipType, SponsorshipDESC, SponsorshipPeriod, SpecialRequest, SponsorEntityType, SSN, CompanyID) VALUES ('Cash', '100000', 'Yearly', '{"SpecialRequest": "FB Post"}', 'Company', NULL, 1);
INSERT INTO Sponsor (SponsorshipType, SponsorshipDESC, SponsorshipPeriod, SpecialRequest, SponsorEntityType, SSN, CompanyID) VALUES ('Device', 'A new gym.', 'Forever', '{"SpecialRequest": "None"}', 'TheEmployeed', '901234567', NULL);
INSERT INTO Sponsor (SponsorshipType, SponsorshipDESC, SponsorshipPeriod, SpecialRequest, SponsorEntityType, SSN, CompanyID) VALUES ('Service', 'Free massage.', 'Monthly', '{"SpecialRequest": "None"}', 'OtherAlumni', '233333390', NULL);
INSERT INTO Sponsor (SponsorshipType, SponsorshipDESC, SponsorshipPeriod, SpecialRequest, SponsorEntityType, SSN, CompanyID) VALUES ('Cash', '50000', 'Yearly', '{"SpecialRequest": "None"}', 'Company', NULL, 2);

INSERT INTO Rival (AnalystSSN, Season, School, Tactics, Report) VALUES ('678901234', '2020-2021', 'NTNU', 'Floppy, Horns, Transition', '{"Star Player": "Lin", "Startegy": ["Zone Defense", "Slow Pace"]}');
INSERT INTO Rival (AnalystSSN, Season, School, Tactics, Report) VALUES ('901234567', '2020-2021', 'NCTU', 'Pick and Roll, Fast Break, Post Up', '{"Star Player": "Chen", "Startegy": ["Transition", "Hedge", "3/4 Deny"]}');
INSERT INTO Rival (AnalystSSN, Season, School, Tactics, Report) VALUES ('234567892', '2020-2021', 'NTUST', 'Isolation, Motion, Zone', '{"Star Player": "Wang", "Startegy": ["Pack Line Defense", "Transition", "Early Offense"]}');

INSERT INTO Supervision (SupervisorSSN, SuperviseeSSN) VALUES ('123456789', '123456789');
INSERT INTO Supervision (SupervisorSSN, SuperviseeSSN) VALUES ('123456789', '234567891');
INSERT INTO Supervision (SupervisorSSN, SuperviseeSSN) VALUES ('123456789', '567890123');
INSERT INTO Supervision (SupervisorSSN, SuperviseeSSN) VALUES ('234567891', '567890123');
INSERT INTO Supervision (SupervisorSSN, SuperviseeSSN) VALUES ('123456789', '890123456');
INSERT INTO Supervision (SupervisorSSN, SuperviseeSSN) VALUES ('567890123', '890123456');

INSERT INTO Instruct (CoachSSN, PlayerSSN) VALUES ('901234567', '123456789');
INSERT INTO Instruct (CoachSSN, PlayerSSN) VALUES ('901234567', '234567891');
INSERT INTO Instruct (CoachSSN, PlayerSSN) VALUES ('901234567', '567890123');

INSERT INTO Treat (PhysicalTherapistSSN, PlayerSSN) VALUES ('456789012', '123456789');
INSERT INTO Treat (PhysicalTherapistSSN, PlayerSSN) VALUES ('456789012', '234567891');
INSERT INTO Treat (PhysicalTherapistSSN, PlayerSSN) VALUES ('456789012', '567890123');

INSERT INTO `Analyze` (AnalystSSN, Season, School) VALUES ('678901234', '2020-2021', 'NTNU');
INSERT INTO `Analyze` (AnalystSSN, Season, School) VALUES ('901234567', '2020-2021', 'NCTU');
INSERT INTO `Analyze` (AnalystSSN, Season, School) VALUES ('234567892', '2020-2021', 'NTUST');

INSERT INTO Support (SponsorID, TeamID) VALUES (3, 1);
INSERT INTO Support (SponsorID, TeamID) VALUES (1, 2);
INSERT INTO Support (SponsorID, TeamID) VALUES (2, 2);
INSERT INTO Support (SponsorID, TeamID) VALUES (3, 2);

/* create two views (Each view should be based on two tables.)*/
CREATE VIEW PointGuardPlayer AS
SELECT TeamMember.SSN, TeamMember.Name, TeamMember.Birthday, TeamMember.TeamID, TeamMember.PhoneNumber, TeamMember.Address, Player.Position, Player.Height, Player.JoinDate, Player.LeaveDate, Player.Stats
FROM TeamMember
JOIN Player ON TeamMember.SSN = Player.SSN AND Player.Position->"$.PG" = 1;


CREATE VIEW SponsorForNCTU AS 
SELECT Sponsor.SponsorID, Sponsor.SponsorshipType, Sponsor.SponsorshipDESC, Sponsor.SponsorshipPeriod, Sponsor.SpecialRequest, Sponsor.SponsorEntityType, Sponsor.SSN, Sponsor.CompanyID, Support.TeamID
FROM Sponsor
JOIN Support ON Support.SponsorID = Sponsor.SponsorID AND Support.TeamID = 2;

/* select from all tables and views */
SELECT * FROM TeamMember;
SELECT * FROM Player;
SELECT * FROM Coach;
SELECT * FROM Manager;
SELECT * FROM Analyst;
SELECT * FROM PhysicalTherapist;
SELECT * FROM Student;
SELECT * FROM TheEmployeed;
SELECT * FROM OtherAlumni;
SELECT * FROM Company;
SELECT * FROM Sponsor;
SELECT * FROM Team;
SELECT * FROM Rival;
SELECT * FROM Supervision;
SELECT * FROM Instruct;
SELECT * FROM Treat;
SELECT * FROM `Analyze`;
SELECT * FROM Support;

SELECT * FROM PointGuardPlayer;
SELECT * FROM SponsorForNCTU;

/* drop database */
DROP DATABASE NTUBTMS;
