USE GymManagementDB;
GO

IF OBJECT_ID('dbo.trg_Payment_NoNegative', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Payment_NoNegative;
GO

CREATE TRIGGER dbo.trg_Payment_NoNegative
ON PAYMENT
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE Amount < 0
    )
    BEGIN
        RAISERROR('Payment amount cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO