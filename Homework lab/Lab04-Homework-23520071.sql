USE Lab1

-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 CG.MaChuyenGia, HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY HoTen, CG.MaChuyenGia
ORDER BY COUNT(CGKN.MaKyNang) DESC

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT CG1.HoTen AS HoTenCG1, CG2.HoTen AS HoTenCG2
FROM ChuyenGia CG1, ChuyenGia CG2
WHERE ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <= 2
AND CG1.MaChuyenGia <> CG2.MaChuyenGia
AND CG1.ChuyenNganh = CG2.ChuyenNganh
AND CG1.MaChuyenGia < CG2.MaChuyenGia

----SOLUTION 2
SELECT CG1.HoTen AS HoTenCG1, CG2.HoTen AS HoTenCG2
FROM ChuyenGia CG1
JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh
WHERE ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <= 2
AND CG1.MaChuyenGia <> CG2.MaChuyenGia
AND CG1.MaChuyenGia < CG2.MaChuyenGia

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT TenCongTy, COUNT(DISTINCT DA.MaDuAn) AS SoLuongDuAn, SUM(NamKinhNghiem) AS TongSoNamKinhNghiem
FROM ChuyenGia_DuAn CGDA 
JOIN DuAn DA ON CGDA.MaDuAn = DA.MaDuAn
JOIN CongTy CT ON CT.MaCongTy = DA.MaCongTy
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY TenCongTy

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT MaChuyenGia
FROM ChuyenGia_KyNang CGKN
WHERE CapDo = 5
AND MaChuyenGia NOT IN (
	SELECT MaChuyenGia
	FROM ChuyenGia_KyNang 
	WHERE CapDo < 3)

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT CG.MaChuyenGia, COUNT(DISTINCT MaDuAn) AS SoLuongDuAn
FROM ChuyenGia_DuAn CGDA
LEFT JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY CG.MaChuyenGia

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
SELECT DISTINCT MaChuyenGia
FROM ChuyenGia_KyNang CGKN
WHERE CapDo IN (
	SELECT MAX(CapDo)
	FROM ChuyenGia_KyNang InnerCGKN
	WHERE CGKN.MaKyNang = InnerCGKN.MaKyNang
)

-----solution 2
WITH MaxCapDo AS (
	SELECT MaKyNang, Max(CapDo) AS highestLevel
	FROM ChuyenGia_KyNang CGKN
	GROUP BY MaKyNang
)

SELECT DISTINCT CG.MaChuyenGia
FROM ChuyenGia_KyNang CG
JOIN MaxCapDo MC 
ON CG.MaKyNang = MC.MaKyNang 
AND CG.CapDo = MC.highestLevel
-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh, 
	CAST(COUNT(MaChuyenGia) * 100.0 / (SELECT COUNT(*) FROM ChuyenGia) AS Decimal(5,2)) AS TyLePhanTram
FROM ChuyenGia
GROUP BY ChuyenNganh

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT 
    A.MaKyNang AS KyNang1, 
    B.MaKyNang AS KyNang2, 
    COUNT(*) AS SoLanXuatHien
FROM ChuyenGia_KyNang A
JOIN ChuyenGia_KyNang B 
ON A.MaChuyenGia = B.MaChuyenGia 
AND A.MaKyNang < B.MaKyNang--remove duplicate rows
GROUP BY 
	A.MaKyNang, B.MaKyNang
ORDER BY 
    SoLanXuatHien DESC

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT MaCongTy, 
	AVG(DATEDIFF(DAY, NgayBatDau, NgayKetThuc)) AS TrungBinhThoiGianDuAn
FROM DuAn
GROUP BY MaCongTy

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
WITH KetHopKyNang AS (
	SELECT MaChuyenGia,
	STRING_AGG(CAST(MaKyNang AS varchar), ',') AS BoKyNang
	FROM ChuyenGia_KyNang
	GROUP BY MaChuyenGia
)

SELECT KHKN.BoKyNang, KHKN.MaChuyenGia
FROM KetHopKyNang KHKN
WHERE (
	SELECT COUNT(InnerKHKN.BoKyNang)
	FROM KetHopKyNang InnerKHKN
	WHERE InnerKHKN.BoKyNang = KHKN.BoKyNang) = 1

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT CG.MaChuyenGia,
	COUNT(DISTINCT CGDA.MaDuAn) AS SoDuAn,
	SUM(CGKN.CapDo) AS TongCapDo,
	COUNT(DISTINCT CGDA.MaDuAn) + SUM(CGKN.CapDo) AS DiemXepHang
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
GROUP BY CG.MaChuyenGia
ORDER BY DiemXepHang 

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT 
	CGDA.MaDuAn
FROM 
	ChuyenGia_DuAn CGDA
JOIN 
	ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY 
	CGDA.MaDuAn
HAVING
	COUNT(DISTINCT CG.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia)

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT 
	MaCongTy,
	CAST(COUNT(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 END) * 100.0 /
	COUNT(MaDuAn) AS DECIMAL (5,2)) AS TyLethanhCong
FROM 
	DuAn DA
GROUP BY 
	MaCongTy

--SOLUTION 2
SELECT 
	MaCongTy,
	CAST((SELECT COUNT(*) * 100.0
		  FROM DuAn InnerDA
		  WHERE InnerDA.MaCongTy = DA.MaCongTy
		  AND InnerDA.TrangThai = N'Hoàn thành') AS decimal (5,2)) AS TyLeThanhCong
FROM 
	DuAn DA
GROUP BY 
	MaCongTy

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
WITH ChuyenGia1 AS (
    SELECT 
        cg1.MaChuyenGia AS MaCG1,
        cgkn1.MaKyNang AS MaKyNang1,
        cgkn2.MaKyNang AS MaKyNang2,
        cgkn1.CapDo AS CapDoKN1,
        cgkn2.CapDo AS CapDoKN2
    FROM ChuyenGia cg1
    JOIN ChuyenGia_KyNang cgkn1 ON cg1.MaChuyenGia = cgkn1.MaChuyenGia
    JOIN ChuyenGia_KyNang cgkn2 ON cg1.MaChuyenGia = cgkn2.MaChuyenGia
    WHERE cgkn1.MaKyNang < cgkn2.MaKyNang
)
SELECT 
    CG1.MaCG1 AS ChuyenGia1,
    cg2.MaChuyenGia AS ChuyenGia2,
    CG1.MaKyNang1 AS KyNang1,
    CG1.MaKyNang2 AS KyNang2,
    CG1.CapDoKN1 AS 'CG1_CapDo_KN1',
    CG1.CapDoKN2 AS 'CG1_CapDo_KN2',
    CGK3.CapDo AS 'CG2_CapDo_KN1',
    CGK4.CapDo AS 'CG2_CapDo_KN2'
FROM ChuyenGia1 CG1
JOIN ChuyenGia cg2 ON CG1.MaCG1 < cg2.MaChuyenGia
JOIN ChuyenGia_KyNang cgk3 ON cg2.MaChuyenGia = cgk3.MaChuyenGia 
    AND cgk3.MaKyNang = CG1.MaKyNang1
JOIN ChuyenGia_KyNang cgk4 ON cg2.MaChuyenGia = cgk4.MaChuyenGia 
    AND cgk4.MaKyNang = CG1.MaKyNang2
WHERE 
    -- Chuyên gia 1 giỏi kỹ năng A và yếu kỹ năng B
    CG1.CapDoKN1 > CG1.CapDoKN2
    -- Chuyên gia 2 giỏi kỹ năng B và yếu kỹ năng A
    AND cgk4.CapDo > cgk3.CapDo;
