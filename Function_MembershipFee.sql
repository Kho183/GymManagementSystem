USE GymManagementDB;
GO

IF OBJECT_ID('dbo.fn_MembershipFeeWithDiscount', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_MembershipFeeWithDiscount;
GO

CREATE FUNCTION dbo.fn_MembershipFeeWithDiscount
(
    @BaseFee DECIMAL(10,2),
    @DiscountPercent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Result DECIMAL(10,2);

    SET @BaseFee = ISNULL(@BaseFee, 0);
    SET @DiscountPercent = ISNULL(@DiscountPercent, 0);

    SET @Result = @BaseFee - (@BaseFee * @DiscountPercent / 100.0);

    RETURN @Result;
END;
GO