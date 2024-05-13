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

-- TODO: make the foreign key in Sponsor nullable
SELECT * FROM Sponsor
LEFT JOIN Company ON Sponsor.SponsorEntityType = 'Company' AND Sponsor.SSN = Company.CompanyID
LEFT JOIN TheEmployeed ON Sponsor.SponsorEntityType = 'TheEmployeed' AND Sponsor.SSN = TheEmployeed.SSN
LEFT JOIN OtherAlumni ON Sponsor.SponsorEntityType = 'OtherAlumni' AND Sponsor.SSN = OtherAlumni.SSN;

/* insert */
INSERT INTO Team (School, SportsType, Division) VALUES ('NTUST', 'Basketball', 'D2');
INSERT INTO Team (School, SportsType, Division) VALUES ('NCTU', 'Basketball', 'D1');
INSERT INTO Team (School, SportsType, Division) VALUES ('NTNU', 'Basketball', 'D1');

INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('123456789', 'Chih-Chuan Hsu', '1998-10-01', 1, '0987654321', '{"City": "Taipei", "Street": "No. 1, Sec. 4, Roosevelt Rd."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('234567891', 'John Dick', '1995-05-15', 1, '0912345658', '{"City": "New York", "Street": "121 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('567890123', 'Emily Williams', '1993-03-20', 1, '0945678901', '{"City": "Houston", "Street": "101 Pine St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('890123456', 'David Martinez', '1985-09-18', 1, '0978901234', '{"City": "Dallas", "Street": "404 Cedar St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('098765432', 'Sarah Garcia', '1997-04-25', 1, '0910909090', '{"City": "Phoenix", "Street": "707 Oak St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('234567890', 'John Doe', '1995-05-15', 1, '0912345678', '{"City": "New York", "Street": "123 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('678901234', 'Christopher Brown', '1996-11-10', 2, '0956789012', '{"City": "Miami", "Street": "202 Maple St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('901234567', 'Jessica Lee', '1994-02-14', 2, '0989012345', '{"City": "Boston", "Street": "505 Birch St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('234567892', 'John Bosh', '1995-05-15', 2, '0912345668', '{"City": "New York", "Street": "127 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('456789012', 'Michael Johnson', '1988-08-03', 3, '0934567890', '{"City": "Chicago", "Street": "789 Oak St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('789012345', 'Amanda Wilson', '1991-07-05', 3, '0967890123', '{"City": "Seattle", "Street": "303 Walnut St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('012345678', 'Daniel Taylor', '1989-06-30', 3, '0990123456', '{"City": "San Francisco", "Street": "606 Pine St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438134', 'John Doe', '1995-05-15', 2, '0912345645', '{"City": "New York", "Street": "124 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438135', 'Jane Smith', '1992-07-15', 2, '0923456784', '{"City": "Texas", "Street": "125 College St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438136', 'Michael Johnson', '1993-09-15', 2, '0934567893', '{"City": "California", "Street": "126 High St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438137', 'Emily Davis', '1994-11-15', 2, '0945678902', '{"City": "Florida", "Street": "127 Low St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438138', 'Andrew Wilson', '1995-01-15', 2, '0956789013', '{"City": "Washington", "Street": "128 Middle St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('765438139', 'LeBron James', '1996-03-15', 2, '0967890124', '{"City": "Oregon", "Street": "129 High St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('278438140', 'JJ Redick', '1995-05-15', 3, '0912345646', '{"City": "New York", "Street": "125 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265248141', 'Jason Tatum', '1992-07-15', 3, '0923456785', '{"City": "Texas", "Street": "126 College St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('269876142', 'Donte Exum', '1993-09-15', 3, '0934567894', '{"City": "California", "Street": "127 High St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438571', 'Anthony Davis', '1994-11-15', 3, '0945678903', '{"City": "Florida", "Street": "128 Low St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('298138144', 'Andrew Wiggins', '1995-01-15', 3, '0956789014', '{"City": "Washington", "Street": "129 Middle St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('815438145', 'Jessica Ezely', '1996-03-15', 3, '0967890125', '{"City": "Oregon", "Street": "130 High St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('995438146', 'Joe Johnson', '1995-05-15', 3, '0912345647', '{"City": "New York", "Street": "126 Main St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('455438147', 'Jane Stevens', '1992-07-15', 3, '0923456786', '{"City": "Texas", "Street": "127 College St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('265438148', 'Michael Jordan', '1993-09-15', 3, '0934567895', '{"City": "California", "Street": "128 High St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('165134349', 'Ed Davis', '1994-11-15', 3, '0945678904', '{"City": "Florida", "Street": "129 Low St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('565423450', 'Andrew Suggs', '1995-01-15', 3, '0956789015', '{"City": "Washington", "Street": "130 Middle St."}');
INSERT INTO TeamMember (SSN, Name, Birthday, TeamID, PhoneNumber, Address) VALUES ('290438151', 'Brandon Taylor', '1996-03-15', 3, '0967890126', '{"City": "Oregon", "Street": "131 High St."}');

INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('765438139', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 172, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 10, "Rebound": 5, "Offensive Rebound": 2, "Defensive Rebound": 3, "Assist": 5, "Steal": 2, "Block": 1, "Turnover": 3}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('123456789', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 180, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 10, "Rebound": 5, "Offensive Rebound": 2, "Defensive Rebound": 3, "Assist": 5, "Steal": 2, "Block": 1, "Turnover": 3}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('098765432', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 182, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 20, "Rebound": 12, "Offensive Rebound": 6, "Defensive Rebound": 6, "Assist": 1, "Steal": 5, "Block": 3, "Turnover": 6}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('234567890', '{"PG": 1, "SG": 0, "SF": 0, "PF": 0, "C": 0}', 179, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 22, "Rebound": 14, "Offensive Rebound": 7, "Defensive Rebound": 7, "Assist": 0, "Steal": 6, "Block": 4, "Turnover": 7}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('265438136', '{"PG": 0, "SG": 1, "SF": 0, "PF": 0, "C": 0}', 174, '2019-06-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 24, "Rebound": 16, "Offensive Rebound": 8, "Defensive Rebound": 8, "Assist": 0, "Steal": 7, "Block": 5, "Turnover": 8}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('278438140', '{"PG": 0, "SG": 1, "SF": 0, "PF": 0, "C": 0}', 176, '2021-10-01', NULL, '{"Season": "2021-2022", "Role": "Bench", "Score": 26, "Rebound": 18, "Offensive Rebound": 9, "Defensive Rebound": 9, "Assist": 0, "Steal": 8, "Block": 6, "Turnover": 9}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('265248141', '{"PG": 0, "SG": 1, "SF": 0, "PF": 0, "C": 0}', 178, '2021-10-01', NULL, '{"Season": "2021-2022", "Role": "Starter", "Score": 28, "Rebound": 20, "Offensive Rebound": 10, "Defensive Rebound": 10, "Assist": 0, "Steal": 9, "Block": 7, "Turnover": 10}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('815438145', '{"PG": 0, "SG": 1, "SF": 0, "PF": 0, "C": 0}', 180, '2021-10-01', NULL, '{"Season": "2021-2022", "Role": "Bench", "Score": 3, "Rebound": 2.2, "Offensive Rebound": 1, "Defensive Rebound": 1.2, "Assist": 0, "Steal": 0.4, "Block": 0, "Turnover": 1.3}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('269876142', '{"PG": 0, "SG": 0, "SF": 1, "PF": 0, "C": 0}', 180, '2021-10-01', NULL, '{"Season": "2021-2022", "Role": "Bench", "Score": 30, "Rebound": 22, "Offensive Rebound": 11, "Defensive Rebound": 11, "Assist": 0, "Steal": 10, "Block": 8, "Turnover": 11}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('234567891', '{"PG": 0, "SG": 0, "SF": 1, "PF": 0, "C": 0}', 185, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 12, "Rebound": 6, "Offensive Rebound": 3, "Defensive Rebound": 3, "Assist": 4, "Steal": 1, "Block": 0, "Turnover": 2}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('265438571', '{"PG": 0, "SG": 0, "SF": 1, "PF": 0, "C": 0}', 187, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 14, "Rebound": 8, "Offensive Rebound": 4, "Defensive Rebound": 4, "Assist": 3, "Steal": 2, "Block": 1, "Turnover": 3}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('298138144', '{"PG": 0, "SG": 0, "SF": 1, "PF": 0, "C": 0}', 181, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 15, "Rebound": 8, "Offensive Rebound": 4, "Defensive Rebound": 4, "Assist": 3, "Steal": 3, "Block": 1, "Turnover": 4}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('995438146', '{"PG": 0, "SG": 0, "SF": 0, "PF": 1, "C": 0}', 184, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 4.3, "Rebound": 3.8, "Offensive Rebound": 2.7, "Defensive Rebound": 1.1, "Assist": 0.2, "Steal": 0.4, "Block": 0.2, "Turnover": 0.5}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('455438147', '{"PG": 0, "SG": 0, "SF": 0, "PF": 1, "C": 0}', 186, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 5.3, "Rebound": 4.8, "Offensive Rebound": 3.7, "Defensive Rebound": 1.1, "Assist": 0.3, "Steal": 0.5, "Block": 0.3, "Turnover": 0.6}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('567890123', '{"PG": 0, "SG": 0, "SF": 0, "PF": 1, "C": 0}', 190, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 15, "Rebound": 8, "Offensive Rebound": 4, "Defensive Rebound": 4, "Assist": 3, "Steal": 3, "Block": 1, "Turnover": 4}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('265438148', '{"PG": 0, "SG": 0, "SF": 0, "PF": 1, "C": 0}', 192, '2021-06-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 6.2, "Rebound": 5.8, "Offensive Rebound": 1.7, "Defensive Rebound": 4.1, "Assist": 0.4, "Steal": 0.6, "Block": 0.4, "Turnover": 0.7}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('890123456', '{"PG": 0, "SG": 0, "SF": 0, "PF": 0, "C": 1}', 195, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 18, "Rebound": 10, "Offensive Rebound": 5, "Defensive Rebound": 5, "Assist": 2, "Steal": 4, "Block": 2, "Turnover": 5}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('165134349', '{"PG": 0, "SG": 0, "SF": 0, "PF": 0, "C": 1}', 191, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 20, "Rebound": 12, "Offensive Rebound": 6, "Defensive Rebound": 6, "Assist": 1, "Steal": 5, "Block": 3, "Turnover": 6}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('565423450', '{"PG": 0, "SG": 0, "SF": 0, "PF": 0, "C": 1}', 189, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Bench", "Score": 2.2, "Rebound": 1.4, "Offensive Rebound": 0.1, "Defensive Rebound": 1.3, "Assist": 0, "Steal": 0.6, "Block": 0.1, "Turnover": 0.7}');
INSERT INTO Player (SSN, Position, Height, JoinDate, LeaveDate, Stats) VALUES ('290438151', '{"PG": 0, "SG": 0, "SF": 0, "PF": 0, "C": 1}', 188, '2020-10-01', NULL, '{"Season": "2020-2021", "Role": "Starter", "Score": 4.3, "Rebound": 3.8, "Offensive Rebound": 2.7, "Defensive Rebound": 1.1, "Assist": 0.2, "Steal": 0.4, "Block": 0.2, "Turnover": 0.5}');

INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('123456789', 'Assistant Coach', 0, '2020-10-01', NULL);
INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('234567891', 'Assistant Coach', 17900, '2020-10-01', NULL);
INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('567890123', 'AC Coach', 20000, '2020-10-01', NULL);
INSERT INTO Coach (SSN, Role, Payment, JoinDate, LeaveDate) VALUES ('901234567', 'Head Coach', 0, '2022-10-01', NULL);

INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('890123456', '{"Skill": "Management, Photographer"}', '2020-10-01', NULL);
INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('098765432', '{"Skill": "Management, Digital Marketing"}', '2022-10-02', '2023-06-30');
INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('234567890', '{"Skill": "Management"}', '2020-10-01', NULL);
INSERT INTO Manager (SSN, Skill, JoinDate, LeaveDate) VALUES ('265438135', '{"Skill": "Management, Marketing"}', '2021-10-01', NULL);

INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('678901234', '{"Skill": "Data Analysis, Machine Learning"}', '2020-10-01', NULL);
INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('901234567', '{"Skill": "Data Analysis, Data Visualization"}', '2019-05-01', '2020-07-31');
INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('234567892', '{"Skill": ""}', '2020-10-01', NULL);
INSERT INTO Analyst (SSN, Skill, JoinDate, LeaveDate) VALUES ('265438137', '{"Skill": "Data Analysis, Data Mining"}', '2021-5-27', NULL);

INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('456789012', '{"Responsibility": "Physical Therapy, Nutrition"}', '2020-10-01', NULL);
INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('789012345', '{"Responsibility": "Physical Therapy, Massage"}', '2020-10-01', '2022-06-30');
INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('012345678', '{"Responsibility": "Physical Therapy, Acupuncture"}', '2020-10-01', NULL);
INSERT INTO PhysicalTherapist (SSN, Responsibility, JoinDate, LeaveDate) VALUES ('265438138', '{"Responsibility": "Physical Therapy, Chiropractic"}', '2021-10-01', NULL);

INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('123456789', 'r10625016', 'NTU', 'Forestry and Resource Conservation', 'Graduate', 4.14);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('234567891', 'r10625017', 'NTU', 'Forestry and Resource Conservation', 'Graduate', 4.13);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('567890123', 'r08904017', 'NTU', 'Physics', 'Graduate', 4.13);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('890123456', 'r10901018', 'NTU', 'Computer Science', 'Graduate', 3.85);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('098765432', 'r10901013', 'NTU', 'Computer Science', 'Graduate', 3.76);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('234567890', 'r07901012', 'NTU', 'Computer Science', 'Graduate', 3.23);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('678901234', 'r10902123', 'NTU', 'Electrical Engineering', 'Graduate', 4.04);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('265438135', 'B10902079', 'NTU', 'Electrical Engineering', 'Freshman', 4.05);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('265438136', 'B07902079', 'NTU', 'Electrical Engineering', 'Senior', 3.27);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('265438137', 'B08402017', 'NTU', 'Horiculture', 'Junior', 3.05);
INSERT INTO Student (SSN, StudentID, School, Department, UniversityYear, GPA) VALUES ('265438138', 'B08302018', 'NTU', 'Foreign Language and Literature', 'Senior', 3.15);

INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Google', '{"City": "Mountain View", "Street": "1600 Amphitheatre Pkwy"}', '6502530000', 1200000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Microsoft', '{"City": "Redmond", "Street": "One Microsoft Way"}', '4258828080', 1000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Apple', '{"City": "Cupertino", "Street": "One Apple"}', '4089961010', 5000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Amazon', '{"City": "Seattle", "Street": "410 Terry Ave N"}', '2062661000', 1000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Facebook', '{"City": "Menlo Park", "Street": "1 Hacker Way"}', '6505434800', 540000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Tesla', '{"City": "Palo Alto", "Street": "3500 Deer Creek Rd"}', '6506815000', 1000000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('NVIDIA', '{"City": "Santa Clara", "Street": "2788 San Tomas Expy"}', '4084862000', 70000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Intel', '{"City": "Santa Clara", "Street": "2200 Mission College Blvd"}', '4087658080', 900000000);
INSERT INTO Company (Name, Address, PhoneNumber, CapitalAmount) VALUES ('Hsu Yuan', '{"City": "Taipei", "Street": "1 Rosevelt"}', '2771478203', 9000000000);

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

/***** homework 3 commands *****/

/* basic select */
SELECT * 
FROM Student
WHERE ((Student.School = 'NTU' AND UniversityYear = 'Graduate') 
    OR (Student.School = 'NTU' AND UniversityYear = 'Senior'))
    AND (Student.Department NOT LIKE '%Conservation%');

/* basic projection */
SELECT SSN, Name, Birthday
FROM TeamMember;

/* basic rename */
SELECT Name AS FullName, Occupation AS Job, PhoneNumber AS Phone
FROM OtherAlumni;

/* equijoin */
SELECT Company.Name, TheEmployeed.Title, TheEmployeed.Salary
FROM Company
JOIN TheEmployeed ON Company.CompanyID = TheEmployeed.CompanyID;

/* natural join */
-- Automatically join the columns with the same name
SELECT *
FROM TeamMember
NATURAL JOIN TheEmployeed;

/* theta join */
SELECT *
FROM TeamMember
JOIN TheEmployeed ON TeamMember.SSN = TheEmployeed.SSN
WHERE TheEmployeed.Salary > 100000;

/* three table join */
SELECT TeamMember.SSN, TeamMember.Name, Player.Position, Coach.Role
FROM TeamMember
JOIN Player ON TeamMember.SSN = Player.SSN
JOIN Coach ON TeamMember.SSN = Coach.SSN;

/* aggregate */
SELECT Position, MAX(Height) AS MaxHeight, MIN(Height) AS MinHeight, COUNT(*)
FROM Player GROUP BY Position;

/* aggregate 2 */
SELECT Position, AVG(Height) AS AvgHeight, SUM(Stats->"$.Rebound") AS TotalRebound, COUNT(Stats->"$.Role" = "Bench") AS BenchPlayerCount
FROM Player 
GROUP BY Position
HAVING TotalRebound > 25;

/* in */
SELECT Company.Name, Company.CapitalAmount
FROM Company
WHERE Company.CapitalAmount IN (5000000000, 7000000000, 9000000000);

/* in 2 */
SELECT SSN, Name
FROM TeamMember
WHERE SSN IN (SELECT SSN FROM Player WHERE Position->"$.SF" = 1);

/* correlated nested query */
SELECT Player.SSN, TeamMember.Name
FROM Player
INNER JOIN TeamMember ON Player.SSN = TeamMember.SSN
WHERE (Player.Stats, Player.Height)
IN (SELECT P.Stats, P.Height 
    FROM Player AS P
    WHERE P.SSN = Player.SSN AND TeamMember.TeamID = 3)
    AND Player.Height > 180;

/* correlated nested query 2 */
SELECT Coach.SSN, TeamMember.Name
FROM Coach
INNER JOIN TeamMember ON Coach.SSN = TeamMember.SSN
WHERE EXISTS (SELECT *
    FROM Coach AS C
    WHERE C.SSN = Coach.SSN AND TeamMember.TeamID = 1)
    AND Coach.Payment > 10000;

/* correlated nested query 3 */
SELECT Manager.SSN, Manager.JoinDate, TeamMember.Name
FROM Manager
INNER JOIN TeamMember ON Manager.SSN = TeamMember.SSN
WHERE NOT EXISTS (SELECT *
        FROM Manager AS M
        WHERE M.SSN = Manager.SSN AND (TeamMember.TeamID = 2 OR M.JoinDate > '2022-01-01'));

CREATE TABLE t1 (
    a INT, 
    b INT
);
INSERT INTO t1 VALUES ROW(4,2), ROW(3,4); 

CREATE TABLE t2 (
    a INT, 
    b INT
);
INSERT INTO t2 VALUES ROW(1,2), ROW(3,4);

/* UNION */
(SELECT *
FROM t1)
UNION
(SELECT *
FROM t2);

/* Intersect */
(SELECT *
FROM t1)
INTERSECT
(SELECT *
FROM t2);

/* Difference */
(SELECT *
FROM t1)
EXCEPT
(SELECT *
FROM t2);

/* DROP TABLE */
DROP TABLE student;

CREATE TABLE student(
    ID INT, 
    YEAR INT
);
INSERT INTO student VALUES ROW(11, 3), ROW(12,3), ROW(13,4), ROW(14,4); 

CREATE TABLE staff(
    ID INT, 
    RANKING INT
); 
INSERT INTO staff VALUES ROW(15,22), ROW(16,23);

/* bonus 1 */
SELECT ID, YEAR, NULL AS ranking
FROM student
UNION ALL
SELECT ID, NULL AS year, RANKING
FROM staff;

/* bonus 2 */
SELECT s.ID, s.RANKING
FROM staff AS s
LEFT JOIN student AS st ON s.ID = st.ID
WHERE st.ID IS NULL;

/* select from all tables and views */
-- SELECT * FROM TeamMember;
-- SELECT * FROM Player;
-- SELECT * FROM Coach;
-- SELECT * FROM Manager;
-- SELECT * FROM Analyst;
-- SELECT * FROM PhysicalTherapist;
-- SELECT * FROM Student;
-- SELECT * FROM TheEmployeed;
-- SELECT * FROM OtherAlumni;
-- SELECT * FROM Company;
-- SELECT * FROM Sponsor;
-- SELECT * FROM Team;
-- SELECT * FROM Rival;
-- SELECT * FROM Supervision;
-- SELECT * FROM Instruct;
-- SELECT * FROM Treat;
-- SELECT * FROM Support;

-- SELECT * FROM PointGuardPlayer;
-- SELECT * FROM SponsorForNCTU;

/* drop database */
DROP DATABASE NTUBTMS;
