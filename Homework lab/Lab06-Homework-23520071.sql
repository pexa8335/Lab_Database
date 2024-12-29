-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger
USE LAB1
-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT * 
FROM ChuyenGia

--2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email
FROM ChuyenGia
WHERE GioiTinh = N'Nữ'

--3. Liệt kê các công ty có trên 100 nhân viên.
SELECT MaCongTy, TenCongTy
FROM CongTy
WHERE SoNhanVien > 100

--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau
FROM DuAn
WHERE YEAR(NGAYBATDAU) = 2023

--5

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAnThamGia
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAN CGDA ON CGDA.MaChuyenGia = CG.MaChuyenGia
GROUP BY HoTen 

--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT MaDuAn
FROM ChuyenGia_DuAn CGDA
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CGDA.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
WHERE KN.TenKyNang = 'Python' 
AND CGKN.CapDo >= 4

--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT TenCongTy, COUNT(MaDuAn) AS SOLUONGDUAN_INWORKING
FROM DuAn DA
JOIN CongTy CT ON CT.MaCongTy = DA.MaCongTy
WHERE DA.TrangThai <> N'Hoàn thành'
GROUP BY TenCongTy

--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT MaChuyenGia, HoTen
FROM ChuyenGia CG
WHERE NamKinhNghiem = (
	SELECT MAX(NamKinhNghiem)
	FROM ChuyenGia cg2
	WHERE cg2.ChuyenNganh = CG.ChuyenNganh)

--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT DISTINCT CG1.MaChuyenGia AS CG1, CG2.MaChuyenGia AS CG2, CG1.MaDuAn
FROM ChuyenGia_DuAn CG1
JOIN ChuyenGia_DuAn CG2 ON CG1.MaDuAn = CG2.MaDuAn
WHERE CG1.MaChuyenGia < CG2.MaChuyenGia
ORDER BY CG1.MaChuyenGia, CG2.MaChuyenGia

-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT CGDA.MaChuyenGia, SUM(DATEDIFF(DAY, NgayThamGia, NgayKetThuc)) AS TONGTHOIGIAN
FROM ChuyenGia_DuAn CGDA
JOIN DuAn ON CGDA.MaDuAn = DuAn.MaDuAn
GROUP BY MaChuyenGia

--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT TenCongTy
FROM CongTy	CT
JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
GROUP BY TenCongTy
HAVING CAST (SUM(CASE WHEN DA.TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) AS float)/CAST(COUNT(*) AS float) > 0.9

--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT TOP 3 WITH TIES
    kn.MaKyNang,
    kn.TenKyNang,
    COUNT(DISTINCT MaDuAn) AS SOLUONG
FROM KyNang KN
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaKyNang = KN.MaKyNang
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY KN.MaKyNang, KN.TenKyNang
ORDER BY COUNT(DISTINCT MaDuAn) DESC

--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
SELECT 
CASE
	WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
	WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
	WHEN NamKinhNghiem > 5 THEN 'Junior'
END AS CAPDOKINHNGHIEM,
AVG(Luong) as LuongTB
FROM ChuyenGia CG
GROUP BY 
CASE
	WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
	WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
	WHEN NamKinhNghiem > 5 THEN 'Junior'
END

--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.

SELECT MaDuAn
FROM ChuyenGia_DuAn CGDA
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY MaDuAn
HAVING COUNT(DISTINCT CG.ChuyenNganh) = (
	SELECT COUNT(DISTINCT ChuyenNganh))

SELECT MaDuAn
FROM DuAn DA
WHERE NOT EXISTS (
	SELECT 1
	FROM ChuyenGia CG
	WHERE NOT EXISTS (
		SELECT 1
		FROM ChuyenGia_DuAn CGDA
		WHERE CGDA.MaChuyenGia = CG.MaChuyenGia
		AND CGDA.MaDuAn = DA.MaDuAn))

-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
ALTER TABLE CongTy
ADD SoLuongDuAn tinyINT

CREATE TRIGGER trigger_insert_delete 
ON DuAN
AFTER INSERT, DELETE
AS
BEGIN
	SET NOCOUNT ON 

	UPDATE CongTy
	SET SoLuongDuAn = ISNULL(SoLuongDuAn, 0) + 1
	WHERE MaCongTy IN (
		SELECT MaCongTy
		FROM inserted)

	UPDATE CongTy
	SET SoLuongDuAn = ISNULL(SoLuongDuAn, 0) -1
	WHERE MaCongTy IN (
		SELECT MaCongTy 
		FROM inserted)
END


--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TABLE ChuyenGia_log
(
	LogID INT PRIMARY KEY IDENTITY(1,1),
    TriggerName VARCHAR(255),
    LogMessage VARCHAR(MAX),
    LogTime DATETIME DEFAULT GETDATE()
)

CREATE TRIGGER trg_chuyengia_log
ON ChuyenGia
AFTER UPDATE, INSERT, DELETE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @message varchar(MAX)
END

--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trg_GioiHanThamGia
ON ChuyenGia_DuAn
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
    SELECT 1
    FROM inserted i
    JOIN ChuyenGia_DuAn cgd ON i.MaChuyenGia = cgd.MaChuyenGia
    GROUP BY i.MaChuyenGia
    HAVING COUNT(cgd.MaDuAn) > 5)
		BEGIN
			ROLLBACK TRAN
			PRINT '1 CHUYÊN GIA CHỈ ĐƯỢC THAM GIA DƯỚI 5 DỰ ÁN'
		END
END
--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
ALTER TABLE ChuyenGia_DuAn
ADD TrangThaiCongViec nvarchar(20)

CREATE TRIGGER trg_Update_Status
ON ChuyenGia_DuAn
AFTER UPDATE
AS
BEGIN
	UPDATE DuAn
	SET TrangThai = N'Hoàn thành'
	FROM DuAn DA
	WHERE MaDuAn IN (
		SELECT MaDuAn
		FROM ChuyenGia CG
		JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia = CG.MaChuyenGia --Lấy TrangThaiCongViec
		WHERE MaDuAn IN (
			SELECT MaDuAn FROM inserted)--chọn các mã có liên quan tới sự thay đổi 
		GROUP BY MaDuAn
		HAVING COUNT (CASE WHEN CGDA.TrangThaiCongViec = N'Kết thúc' THEN 1 END) 
		= COUNT(*))
END
--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung 
--bình của công ty dựa trên điểm đánh giá của các dự án.

CREATE TRIGGER trg_calc_update_avg_ratingCompany
ON DuAn
AFTER UPDATE, INSERT, DELETE
AS
BEGIN
	UPDATE CT
	SET CT.DiemDanhGiaTrungBinh = (
		SELECT AVG(DiemDanhGia)
		FROM DuAn DA
		WHERE DA.MaCongTy = CT.MaCongTy)
	FROM CongTy CT
	WHERE ct.MaCongTy IN (
    SELECT MaCongTy FROM inserted
    UNION
    SELECT MaCongTy FROM deleted
  )

END