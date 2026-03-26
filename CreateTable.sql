USE master;
GO

IF DB_ID('GymManagementDB') IS NOT NULL
BEGIN
    ALTER DATABASE GymManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GymManagementDB;
END
GO

CREATE DATABASE GymManagementDB;
GO

USE GymManagementDB;
GO

/* =========================
   TABLE: GYM_PACKAGE
   ========================= */
CREATE TABLE GYM_PACKAGE
(
    PackageID INT IDENTITY(1,1) PRIMARY KEY,
    PackageName VARCHAR(100) NOT NULL,
    DurationMonths INT NULL,
    Fee DECIMAL(10,2) NULL,
    SessionLimit INT NULL,

    CONSTRAINT CHK_GYM_PACKAGE_DurationMonths
        CHECK (DurationMonths IS NULL OR DurationMonths > 0),

    CONSTRAINT CHK_GYM_PACKAGE_Fee
        CHECK (Fee IS NULL OR Fee >= 0),

    CONSTRAINT CHK_GYM_PACKAGE_SessionLimit
        CHECK (SessionLimit IS NULL OR SessionLimit > 0)
);
GO

/* =========================
   TABLE: MEMBER
   ========================= */
CREATE TABLE MEMBER
(
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    DOB DATE NULL,
    Gender VARCHAR(10) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    JoinDate DATE NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CHK_MEMBER_Gender
        CHECK (Gender IS NULL OR Gender IN ('Male', 'Female', 'Other'))
);
GO

/* =========================
   TABLE: TRAINER
   ========================= */
CREATE TABLE TRAINER
(
    TrainerID INT IDENTITY(1,1) PRIMARY KEY,
    TrainerName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Salary DECIMAL(10,2) NULL,

    CONSTRAINT CHK_TRAINER_Salary
        CHECK (Salary IS NULL OR Salary >= 0)
);
GO

/* =========================
   TABLE: MEMBERSHIP
   ========================= */
CREATE TABLE MEMBERSHIP
(
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    PackageID INT NOT NULL,
    TrainerID INT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT FK_MEMBERSHIP_MEMBER
        FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),

    CONSTRAINT FK_MEMBERSHIP_PACKAGE
        FOREIGN KEY (PackageID) REFERENCES GYM_PACKAGE(PackageID),

    CONSTRAINT FK_MEMBERSHIP_TRAINER
        FOREIGN KEY (TrainerID) REFERENCES TRAINER(TrainerID),

    CONSTRAINT CHK_MEMBERSHIP_DateRange
        CHECK (EndDate >= StartDate),

    CONSTRAINT CHK_MEMBERSHIP_Status
        CHECK (Status IN ('Active', 'Expired', 'Cancelled'))
);
GO

/* =========================
   TABLE: ATTENDANCE
   ========================= */
CREATE TABLE ATTENDANCE
(
    AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    CheckInTime DATETIME NOT NULL DEFAULT GETDATE(),
    CheckOutTime DATETIME NULL,

    CONSTRAINT FK_ATTENDANCE_MEMBER
        FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),

    CONSTRAINT CHK_ATTENDANCE_Time
        CHECK (CheckOutTime IS NULL OR CheckOutTime >= CheckInTime)
);
GO

/* =========================
   TABLE: PAYMENT
   ========================= */
CREATE TABLE PAYMENT
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    MembershipID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL DEFAULT GETDATE(),
    PaymentMethod VARCHAR(30) NULL,
    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Paid',

    CONSTRAINT FK_PAYMENT_MEMBERSHIP
        FOREIGN KEY (MembershipID) REFERENCES MEMBERSHIP(MembershipID),

    CONSTRAINT CHK_PAYMENT_Amount
        CHECK (Amount >= 0),

    CONSTRAINT CHK_PAYMENT_Method
        CHECK (PaymentMethod IS NULL OR PaymentMethod IN ('Cash', 'Card', 'Transfer', 'E-Wallet')),

    CONSTRAINT CHK_PAYMENT_Status
        CHECK (PaymentStatus IN ('Paid', 'Pending', 'Failed'))
);
GO

/* =========================
   SAMPLE DATA
   ========================= */
INSERT INTO GYM_PACKAGE (PackageName, DurationMonths, Fee, SessionLimit)
VALUES
('Basic Package', 1, 300000.00, 30),
('Standard Package', 3, 800000.00, 90),
('Premium Package', 6, 1500000.00, 180),
('VIP Package', 12, 2800000.00, 365);
GO

INSERT INTO MEMBER (FullName, DOB, Gender, Phone, Email, JoinDate)
VALUES
('Nguyen Van A', '2003-02-10', 'Male', '0901234567', 'a@gmail.com', '2026-03-01'),
('Tran Thi B', '2004-07-15', 'Female', '0902345678', 'b@gmail.com', '2026-03-02'),
('Le Van C', '2002-11-20', 'Male', '0903456789', 'c@gmail.com', '2026-03-03'),
('Pham Thi D', '2001-05-12', 'Female', '0904567890', 'd@gmail.com', '2026-03-04');
GO

INSERT INTO TRAINER (TrainerName, Specialty, Phone, Email, Salary)
VALUES
('Coach Minh', 'Weight Training', '0911111111', 'minh@gym.com', 12000000),
('Coach Lan', 'Yoga', '0922222222', 'lan@gym.com', 10000000),
('Coach Huy', 'Cardio', '0933333333', 'huy@gym.com', 11000000);
GO

INSERT INTO MEMBERSHIP (MemberID, PackageID, TrainerID, StartDate, EndDate, Status)
VALUES
(1, 1, 1, '2026-03-01', '2026-03-31', 'Active'),
(2, 2, 2, '2026-03-02', '2026-06-02', 'Active'),
(3, 3, 1, '2026-03-03', '2026-09-03', 'Active'),
(4, 4, 3, '2026-03-04', '2027-03-04', 'Active');
GO

INSERT INTO ATTENDANCE (MemberID, CheckInTime, CheckOutTime)
VALUES
(1, '2026-03-10 08:00:00', '2026-03-10 09:30:00'),
(2, '2026-03-10 09:00:00', '2026-03-10 10:15:00'),
(3, '2026-03-10 17:30:00', '2026-03-10 19:00:00'),
(1, '2026-03-11 08:10:00', '2026-03-11 09:20:00');
GO

INSERT INTO PAYMENT (MembershipID, Amount, PaymentDate, PaymentMethod, PaymentStatus)
VALUES
(1, 300000, '2026-03-01', 'Cash', 'Paid'),
(2, 800000, '2026-03-02', 'Card', 'Paid'),
(3, 1500000, '2026-03-03', 'Transfer', 'Paid'),
(4, 2800000, '2026-03-04', 'E-Wallet', 'Paid');
GO