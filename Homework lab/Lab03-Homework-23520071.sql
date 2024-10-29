use Lab1
-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT TenKyNang, CapDo
FROM KyNang KN
JOIN ChuyenGia_KyNang CGKN ON KN.MaKyNang = CGKN.MaKyNang
JOIN ChuyenGia ON CGKN.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE ChuyenGia.MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
JOIN DUAN ON CGDA.MaDuAn = DUAN.MaDuAn
WHERE DUAN.MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn
FROM DUAN
JOIN CongTy ON CongTy.MaCongTy = CongTy.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(MaChuyenGia) AS SoLuongChuyenGia
FROM ChuyenGia 
GROUP BY ChuyenNganh


-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT TOP 1 CG.HoTen, CG.NamKinhNghiem
FROM ChuyenGia CG
ORDER BY CG.NamKinhNghiem DESC

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(CGDA.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY CG.HoTen
-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn
FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy
-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT TOP 1 TenKyNang, COUNT(CGKN.MaChuyenGia) AS SoLuongChuyenGia
FROM KyNang KN
INNER JOIN ChuyenGia_KyNang CGKN ON KN.MaKyNang = CGKN.MaKyNang
GROUP BY KN.TenKyNang
ORDER BY SoLuongChuyenGia DESC


-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen
FROM ChuyenGia CG
INNER JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
INNER JOIN KyNang KN ON CGKN.MaKyNang = KN.MaKyNang
WHERE KN.TenKyNang = 'Python' AND CGKN.CapDo >= 4

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TOP 1 TenDuAn, COUNT(CGDA.MaChuyenGia) AS SoLuongChuyenGia
FROM DuAn
INNER JOIN ChuyenGia_DuAn CGDA ON DuAn.MaDuAn = CGDA.MaDuAn
GROUP BY DuAn.TenDuAn
ORDER BY SoLuongChuyenGia DESC


-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT CG.HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.HoTen
-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen ChuyenGia2
FROM ChuyenGia_DuAn cda1
INNER JOIN ChuyenGia_DuAn cda2 ON cda1.MaDuAn = cda2.MaDuAn AND cda1.MaChuyenGia < cda2.MaChuyenGia
INNER JOIN ChuyenGia c1 ON cda1.MaChuyenGia = c1.MaChuyenGia
INNER JOIN ChuyenGia c2 ON cda2.MaChuyenGia = c2.MaChuyenGia

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT CG.HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNangCap5
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
WHERE CGKN.CapDo = 5
GROUP BY CG.HoTen
-- 21. Tìm các công ty không có dự án nào.
SELECT TenCongTy
FROM CongTy CT
LEFT JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
WHERE MaDuAn IS NULL

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT CG.HoTen, TenDuAn
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
LEFT JOIN DuAn ON CGDA.MaDuAn = DuAn.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT CG.HoTen
FROM ChuyenGia CG
INNER JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.HoTen
HAVING COUNT(CGKN.MaKyNang) >= 3
-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT TenCongTy, SUM(CG.NamKinhNghiem) AS TongSoNamKinhNghiem
FROM CongTy CT
INNER JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
INNER JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn = CGDA.MaDuAn
INNER JOIN ChuyenGia CG ON CGDA.MaChuyenGia = CG.MaChuyenGia
GROUP BY TenCongTy

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT TenCongTy, SUM(CG.NamKinhNghiem) AS TongSoNamKinhNghiem
FROM CongTy CT
INNER JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
INNER JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn = CGDA.MaDuAn
INNER JOIN ChuyenGia CG ON CGDA.MaChuyenGia = CG.MaChuyenGia
GROUP BY TenCongTy
-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.

SELECT TOP 1 CG.HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.HoTen
ORDER BY SoLuongKyNang DESC

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen AS ChuyenGia2 
FROM ChuyenGia c1
INNER JOIN ChuyenGia c2 ON c1.ChuyenNganh = c2.ChuyenNganh AND c1.MaChuyenGia < c2.MaChuyenGia;
-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.

SELECT TOP 1 TenCongTy, SUM(CG.NamKinhNghiem) AS TongSoNamKinhNghiem
FROM CongTy CT
INNER JOIN  DuAn DA ON CT.MaCongTy = DA.MaCongTy
INNER JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn = CGDA.MaDuAn
INNER JOIN ChuyenGia CG ON CGDA.MaChuyenGia = CG.MaChuyenGia
GROUP BY TenCongTy
ORDER BY TongSoNamKinhNghiem DESC

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT KyNang.TenKyNang
FROM KyNang
WHERE NOT EXISTS (
    SELECT 1
    FROM ChuyenGia_KyNang
    WHERE ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
    GROUP BY ChuyenGia_KyNang.MaKyNang
    HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaChuyenGia) < (SELECT COUNT(*) FROM ChuyenGia)
)