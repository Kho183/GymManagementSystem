USE GymManagementDB;
GO

IF OBJECT_ID('dbo.fn_MemberStatus', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_MemberStatus;
GO

CREATE FUNCTION dbo.fn_MemberStatus
(
    @EndDate DATE
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Status VARCHAR(20);

    IF @EndDate >= CAST(GETDATE() AS DATE)
        SET @Status = 'Active';
    ELSE
        SET @Status = 'Expired';

    RETURN @Status;
END;
GO