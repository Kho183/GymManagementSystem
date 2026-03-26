USE GymManagementDB;
GO

IF OBJECT_ID('dbo.sp_PackageReport', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_PackageReport;
GO

CREATE PROCEDURE dbo.sp_PackageReport
    @PackageID INT,
    @TopN INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    /* Result set 1: thống kê gói tập */
    SELECT
        gp.PackageID,
        gp.PackageName,
        COUNT(ms.MembershipID) AS TotalMembers,
        AVG(CAST(p.Amount AS DECIMAL(10,2))) AS AveragePayment,
        MIN(p.Amount) AS MinPayment,
        MAX(p.Amount) AS MaxPayment
    FROM GYM_PACKAGE gp
    LEFT JOIN MEMBERSHIP ms ON gp.PackageID = ms.PackageID
    LEFT JOIN PAYMENT p ON ms.MembershipID = p.MembershipID
    WHERE gp.PackageID = @PackageID
    GROUP BY gp.PackageID, gp.PackageName;

    /* Result set 2: top N thành viên đi tập nhiều nhất trong gói */
    SELECT TOP (@TopN)
        m.MemberID,
        m.FullName,
        gp.PackageName,
        COUNT(a.AttendanceID) AS TotalVisits
    FROM MEMBER m
    INNER JOIN MEMBERSHIP ms ON m.MemberID = ms.MemberID
    INNER JOIN GYM_PACKAGE gp ON ms.PackageID = gp.PackageID
    LEFT JOIN ATTENDANCE a ON m.MemberID = a.MemberID
    WHERE gp.PackageID = @PackageID
    GROUP BY m.MemberID, m.FullName, gp.PackageName
    ORDER BY TotalVisits DESC, m.FullName ASC;
END;
GO

EXEC dbo.sp_PackageReport @PackageID = 1, @TopN = 3;