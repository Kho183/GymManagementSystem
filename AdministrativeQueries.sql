USE GymManagementDB;
GO

/* 1. Xem toàn bộ dữ liệu các bảng */
SELECT * FROM GYM_PACKAGE;
SELECT * FROM MEMBER;
SELECT * FROM TRAINER;
SELECT * FROM MEMBERSHIP;
SELECT * FROM ATTENDANCE;
SELECT * FROM PAYMENT;
GO

/* 2. Danh sách thành viên kèm gói tập và HLV */
SELECT
    m.MemberID,
    m.FullName,
    gp.PackageName,
    t.TrainerName,
    ms.StartDate,
    ms.EndDate,
    ms.Status
FROM MEMBER m
INNER JOIN MEMBERSHIP ms ON m.MemberID = ms.MemberID
INNER JOIN GYM_PACKAGE gp ON ms.PackageID = gp.PackageID
LEFT JOIN TRAINER t ON ms.TrainerID = t.TrainerID;
GO

/* 3. Các thành viên đã hết hạn gói tập */
SELECT
    m.MemberID,
    m.FullName,
    ms.StartDate,
    ms.EndDate,
    dbo.fn_MemberStatus(ms.EndDate) AS MembershipStatus
FROM MEMBER m
INNER JOIN MEMBERSHIP ms ON m.MemberID = ms.MemberID
WHERE dbo.fn_MemberStatus(ms.EndDate) = 'Expired';
GO

/* 4. Đếm số lượt đi tập của từng thành viên */
SELECT
    m.MemberID,
    m.FullName,
    COUNT(a.AttendanceID) AS TotalVisits
FROM MEMBER m
LEFT JOIN ATTENDANCE a ON m.MemberID = a.MemberID
GROUP BY m.MemberID, m.FullName
ORDER BY TotalVisits DESC;
GO

/* 5. Doanh thu theo từng gói tập */
SELECT
    gp.PackageID,
    gp.PackageName,
    SUM(p.Amount) AS TotalRevenue
FROM GYM_PACKAGE gp
LEFT JOIN MEMBERSHIP ms ON gp.PackageID = ms.PackageID
LEFT JOIN PAYMENT p ON ms.MembershipID = p.MembershipID
GROUP BY gp.PackageID, gp.PackageName
ORDER BY TotalRevenue DESC;
GO

/* 6. Thành viên có số lần đi tập nhiều nhất */
SELECT TOP 1
    m.MemberID,
    m.FullName,
    COUNT(a.AttendanceID) AS TotalVisits
FROM MEMBER m
LEFT JOIN ATTENDANCE a ON m.MemberID = a.MemberID
GROUP BY m.MemberID, m.FullName
ORDER BY TotalVisits DESC;
GO

/* 7. Danh sách trainer và số thành viên họ đang phụ trách */
SELECT
    t.TrainerID,
    t.TrainerName,
    COUNT(ms.MemberID) AS TotalMembersManaged
FROM TRAINER t
LEFT JOIN MEMBERSHIP ms ON t.TrainerID = ms.TrainerID
GROUP BY t.TrainerID, t.TrainerName
ORDER BY TotalMembersManaged DESC;
GO

/* 8. Tính phí sau giảm giá bằng function */
SELECT
    PackageID,
    PackageName,
    Fee AS OriginalFee,
    dbo.fn_MembershipFeeWithDiscount(Fee, 10) AS FeeAfter10PercentDiscount
FROM GYM_PACKAGE;
GO

/* 9. Xem view tổng hợp thành viên */
SELECT * FROM dbo.vw_MemberMembershipSummary;
GO

/* 10. Update trạng thái membership tự động theo ngày hết hạn */
UPDATE MEMBERSHIP
SET Status = dbo.fn_MemberStatus(EndDate);
GO

/* 11. Xóa attendance của 1 thành viên cụ thể */
DELETE FROM ATTENDANCE
WHERE MemberID = 1
  AND CAST(CheckInTime AS DATE) = '2026-03-11';
GO

/* 12. Thử update payment âm để test trigger (sẽ báo lỗi) */
UPDATE PAYMENT
SET Amount = -1000
WHERE PaymentID = 1;
GO