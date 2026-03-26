USE GymManagementDB;
GO

IF OBJECT_ID('dbo.vw_MemberMembershipSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_MemberMembershipSummary;
GO

CREATE VIEW dbo.vw_MemberMembershipSummary
AS
SELECT
    m.MemberID,
    m.FullName,
    m.Phone,
    m.Email,
    gp.PackageName,
    gp.DurationMonths,
    gp.Fee,
    t.TrainerName,
    ms.StartDate,
    ms.EndDate,
    dbo.fn_MemberStatus(ms.EndDate) AS CurrentStatus,
    (
        SELECT COUNT(*)
        FROM ATTENDANCE a
        WHERE a.MemberID = m.MemberID
    ) AS TotalVisits
FROM MEMBER m
INNER JOIN MEMBERSHIP ms ON m.MemberID = ms.MemberID
INNER JOIN GYM_PACKAGE gp ON ms.PackageID = gp.PackageID
LEFT JOIN TRAINER t ON ms.TrainerID = t.TrainerID;
GO