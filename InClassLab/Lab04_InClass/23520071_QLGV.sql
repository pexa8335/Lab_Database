USE QLGV

------------------------------Bài tập 2-------------------------

--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT TOP 1
	MAKHOA, TENKHOA
FROM	
	KHOA
ORDER BY 
	NGTLAP ASC
--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT
	COUNT(MAGV) AS TrinhDoPGS_GS
FROM 
	GIAOVIEN
WHERE
	HOCHAM = 'GS' OR HOCHAM = 'PGS'

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi
--khoa.
SELECT 
	MAKHOA,
	COUNT(MAGV) AS SoGiaoVien
FROM 
	GIAOVIEN
WHERE 
	HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY 
	MAKHOA

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT
	MAMH, KQUA,
	COUNT(MAHV) AS SoLuongHocVien
FROM
	KETQUATHI
GROUP BY
	MAMH, KQUA

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho
--lớp đó ít nhất một môn học.
SELECT
	MAGV, HOTEN
FROM
	GIAOVIEN GV
WHERE 
	MAGV IN (
		SELECT 
			MAGVCN
		FROM
			LOP
		WHERE 
			MAGVCN IN (
				SELECT 
					MAGV
				FROM 
					GIANGDAY 
				WHERE 
					MAGV = GV.MAGV
				GROUP BY
					MAGV
				HAVING 
					COUNT(DISTINCT MALOP) >= 1))
-----SOLUTION 2----
SELECT 
    GV.MAGV, 
    GV.HOTEN
FROM 
	GIAOVIEN GV
JOIN 
	GIANGDAY GD ON GD.MAGV = GV.MAGV
JOIN 
	LOP L ON L.MAGVCN = GV.MAGV
GROUP BY 
	GV.MAGV, GV.HOTEN
HAVING 
	COUNT(DISTINCT MAMH) >=1

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
INNER JOIN LOP ON HOCVIEN.MAHV = LOP.TRGLOP
WHERE LOP.SISO = (SELECT MAX(SISO) FROM LOP);

--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả
--các lần thi).
SELECT 
	HOCVIEN.HO, HOCVIEN.TEN
FROM 
	HOCVIEN
JOIN 
	KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE HOCVIEN.MAHV IN 
	(SELECT TRGLOP FROM LOP)
GROUP BY	
	HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
HAVING 
	SUM(CASE WHEN KETQUATHI.KQUA = 'Không đạt' THEN 1 ELSE 0 END) <= 3
------------------------------Bài tập 4------------------------------
--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT TOP 1 
	HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN,
	COUNT(*) AS SoMonDiemCao
FROM 
	HOCVIEN
JOIN 
	KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE 
	KETQUATHI.DIEM IN (9, 10)
GROUP BY 
	HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
ORDER BY 
	SoMonDiemCao DESC

--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT MALOP, MAHV, HO, TEN, SoMonDiemCao
FROM (
 SELECT HOCVIEN.MALOP, HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, COUNT(*)
AS SoMonDiemCao,
 RANK() OVER (PARTITION BY HOCVIEN.MALOP ORDER BY COUNT(*) DESC) AS
XepHang
 FROM HOCVIEN
 INNER JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
 WHERE KETQUATHI.DIEM IN (9, 10)
 GROUP BY HOCVIEN.MALOP, HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
) AS Temp
WHERE XepHang = 1
--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao
--nhiêu lớp.SELECT HOCKY, NAM, MAGV, COUNT(DISTINCT MAMH) AS SoMon, COUNT(DISTINCT
MALOP) AS SoLop
FROM GIANGDAY
GROUP BY HOCKY, NAM, MAGV--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT HOCKY, NAM, GIAOVIEN.MAGV, GIAOVIEN.HOTEN, COUNT(*) AS SoBuoiDay
FROM GIANGDAY
INNER JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
GROUP BY HOCKY, NAM, GIAOVIEN.MAGV, GIAOVIEN.HOTEN
ORDER BY SoBuoiDay DESC
--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1)
--nhất.
SELECT TOP 1 MONHOC.MAMH, MONHOC.TENMH, COUNT(*) AS SoLuongKhongDat
FROM KETQUATHI
INNER JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE KETQUATHI.LANTHI = 1 AND KETQUATHI.KQUA = 'Không đạt'
GROUP BY MONHOC.MAMH, MONHOC.TENMH
ORDER BY SoLuongKhongDat DESC
--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE NOT EXISTS (
 SELECT 1
 FROM KETQUATHI
 WHERE KETQUATHI.MAHV = HOCVIEN.MAHV AND KETQUATHI.LANTHI = 1 AND
KETQUATHI.KQUA = 'Không đạt')
--32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE NOT EXISTS (
SELECT MAMH
FROM MONHOC
WHERE NOT EXISTS (
 SELECT 1
 FROM KETQUATHI
 WHERE KETQUATHI.MAHV = HOCVIEN.MAHV
 AND KETQUATHI.MAMH = MONHOC.MAMH
 AND KETQUATHI.LANTHI = (
 SELECT MAX(LANTHI)
 FROM KETQUATHI AS KT
 WHERE KT.MAHV = KETQUATHI.MAHV AND KT.MAMH = KETQUATHI.MAMH
 )
 AND KETQUATHI.KQUA = 'DAT'
 )
)
--33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1).SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE NOT EXISTS (
 SELECT MAMH
 FROM MONHOC
 WHERE NOT EXISTS (
 SELECT 1
 FROM KETQUATHI
 WHERE KETQUATHI.MAHV = HOCVIEN.MAHV
 AND KETQUATHI.MAMH = MONHOC.MAMH
 AND KETQUATHI.LANTHI = 1
 AND KETQUATHI.KQUA = 'DAT'
 )
)
--34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau
--cùng).
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE NOT EXISTS (
 SELECT MAMH
 FROM MONHOC
 WHERE NOT EXISTS (
 SELECT 1
 FROM KETQUATHI
 WHERE KETQUATHI.MAHV = HOCVIEN.MAHV
 AND KETQUATHI.MAMH = MONHOC.MAMH
 AND KETQUATHI.LANTHI = (
 SELECT MAX(LANTHI)
 FROM KETQUATHI AS KT
 WHERE KT.MAHV = KETQUATHI.MAHV AND KT.MAMH = KETQUATHI.MAMH
 )
 AND KETQUATHI.KQUA = 'DAT'
 )
)
--35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần
--thi sau cùng).
SELECT DISTINCT KETQUATHI.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM KETQUATHI
INNER JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE KETQUATHI.DIEM = (
 SELECT MAX(DIEM)
 FROM KETQUATHI AS KT
 WHERE KT.MAMH = KETQUATHI.MAMH
 AND KT.LANTHI = (
 SELECT MAX(LANTHI)
 FROM KETQUATHI AS KT2
 WHERE KT2.MAHV = KT.MAHV AND KT2.MAMH = KT.MAMH
 )
)