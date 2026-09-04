/*
  PROG6212 POE - Part 1
  RaceDay SQL Server Database Script
  Designed to match RaceDay_ERD.png and RaceDay_API_Endpoint_Plan.md
*/

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END;
GO

CREATE DATABASE RaceDayDB;
GO
USE RaceDayDB;
GO

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) CONSTRAINT PK_Users PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(255) NOT NULL CONSTRAINT UQ_Users_Email UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CONSTRAINT DF_Users_Role DEFAULT ('Participant'),
    Phone NVARCHAR(30) NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser','Participant'))
);
GO

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Categories_Name UNIQUE,
    DistanceKm DECIMAL(6,2) NOT NULL,
    MaxParticipants INT NOT NULL,
    CONSTRAINT CK_Categories_Distance CHECK (DistanceKm > 0),
    CONSTRAINT CK_Categories_MaxParticipants CHECK (MaxParticipants > 0)
);
GO

CREATE TABLE Events (
    EventId INT IDENTITY(1,1) CONSTRAINT PK_Events PRIMARY KEY,
    OrganiserId INT NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    Venue NVARCHAR(200) NOT NULL,
    EventDate DATE NOT NULL,
    RegistrationOpen DATE NOT NULL,
    RegistrationClose DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Events_Status DEFAULT ('Open'),
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Events_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Events_Status CHECK (Status IN ('Draft','Open','Closed','Completed','Cancelled')),
    CONSTRAINT CK_Events_RegistrationDates CHECK (RegistrationClose >= RegistrationOpen)
);
GO

CREATE TABLE EventCategories (
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL CONSTRAINT DF_EventCategories_EntryFee DEFAULT (0),
    CONSTRAINT PK_EventCategories PRIMARY KEY (EventId, CategoryId),
    CONSTRAINT FK_EventCategories_Event FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE,
    CONSTRAINT FK_EventCategories_Category FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CK_EventCategories_EntryFee CHECK (EntryFee >= 0)
);
GO

CREATE TABLE UserProfiles (
    ProfileId INT IDENTITY(1,1) CONSTRAINT PK_UserProfiles PRIMARY KEY,
    UserId INT NOT NULL CONSTRAINT UQ_UserProfiles_UserId UNIQUE,
    DateOfBirth DATE NULL,
    Gender NVARCHAR(30) NULL,
    EmergencyContactName NVARCHAR(100) NULL,
    EmergencyContactPhone NVARCHAR(30) NULL,
    Address NVARCHAR(300) NULL,
    CONSTRAINT FK_UserProfiles_User FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);
GO

CREATE TABLE Enrolments (
    EnrolmentId INT IDENTITY(1,1) CONSTRAINT PK_Enrolments PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME2(0) NOT NULL CONSTRAINT DF_Enrolments_Date DEFAULT (SYSUTCDATETIME()),
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Enrolments_Status DEFAULT ('Active'),
    RaceNumber INT NOT NULL,
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId) REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_EventCategory FOREIGN KEY (EventId, CategoryId) REFERENCES EventCategories(EventId, CategoryId),
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantId, EventId),
    CONSTRAINT UQ_Enrolments_RaceNumber UNIQUE (EventId, RaceNumber),
    CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Active','Cancelled','Completed')),
    CONSTRAINT CK_Enrolments_RaceNumber CHECK (RaceNumber > 0)
);
GO

CREATE TABLE Results (
    ResultId INT IDENTITY(1,1) CONSTRAINT PK_Results PRIMARY KEY,
    EnrolmentId INT NOT NULL CONSTRAINT UQ_Results_Enrolment UNIQUE,
    FinishTime TIME(0) NULL,
    Position INT NULL,
    ResultStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Results_Status DEFAULT ('Finished'),
    RecordedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Results_RecordedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE,
    CONSTRAINT CK_Results_Position CHECK (Position IS NULL OR Position > 0),
    CONSTRAINT CK_Results_Status CHECK (ResultStatus IN ('Finished','DNF','DNS','DSQ'))
);
GO

/* Seed users: 2 Organisers and 2 Participants */
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, Phone)
VALUES
('Thabo','Mokoena','thabo.organiser@raceday.test','HASHED_PASSWORD_01','Organiser','0710000001'),
('Lerato','Maseko','lerato.organiser@raceday.test','HASHED_PASSWORD_02','Organiser','0710000002'),
('Naledi','Molefe','naledi.participant@raceday.test','HASHED_PASSWORD_03','Participant','0710000003'),
('Kabelo','Dlamini','kabelo.participant@raceday.test','HASHED_PASSWORD_04','Participant','0710000004');
GO

INSERT INTO UserProfiles (UserId, DateOfBirth, Gender, EmergencyContactName, EmergencyContactPhone, Address)
VALUES
(3,'2004-05-14','Female','Mpho Molefe','0721000003','Pretoria, Gauteng'),
(4,'2003-11-02','Male','Neo Dlamini','0721000004','Johannesburg, Gauteng');
GO

/* Categories */
INSERT INTO Categories (Name, DistanceKm, MaxParticipants)
VALUES
('5 KM Fun Run',5.00,500),
('10 KM Challenge',10.00,750),
('21 KM Half Marathon',21.10,1000),
('42 KM Marathon',42.20,1200);
GO

/* 3 Events */
INSERT INTO Events (OrganiserId, Name, Description, Venue, EventDate, RegistrationOpen, RegistrationClose, Status)
VALUES
(1,'Pretoria Spring Run','Community road race through central Pretoria.','Pretoria National Botanical Garden','2026-10-18','2026-08-01','2026-10-10','Open'),
(1,'Johannesburg City Challenge','Road-running event for recreational and competitive runners.','Mary Fitzgerald Square','2026-11-08','2026-08-15','2026-11-01','Open'),
(2,'Gauteng Heritage Marathon','A multi-distance event celebrating local running communities.','Cradle of Humankind Visitor Centre','2026-12-06','2026-09-01','2026-11-29','Open');
GO

/* Categories for each event */
INSERT INTO EventCategories (EventId, CategoryId, EntryFee)
VALUES
(1,1,80.00),(1,2,120.00),(1,3,180.00),
(2,1,90.00),(2,2,140.00),(2,3,200.00),
(3,1,100.00),(3,2,150.00),(3,3,220.00),(3,4,300.00);
GO

/* Sample enrolments */
INSERT INTO Enrolments (ParticipantId, EventId, CategoryId, Status, RaceNumber)
VALUES
(3,1,1,'Completed',101),
(4,1,2,'Completed',102),
(3,2,2,'Active',201),
(4,3,3,'Active',301);
GO

/* Sample results for completed enrolments */
INSERT INTO Results (EnrolmentId, FinishTime, Position, ResultStatus)
VALUES
(1,'00:31:42',1,'Finished'),
(2,'00:58:17',2,'Finished');
GO

/* Verification queries for SSMS */
SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventCategories;
SELECT * FROM Enrolments;
SELECT * FROM Results;
GO
