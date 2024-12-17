USE QLBH
-- BAI TAP 1: Sinh viên hoàn thành Phần I bài tập QuanLyBanHang từ câu 11 đến 14. 

--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
CREATE TRIGGER trigger_NGHD_NGDK
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		JOIN KHACHHANG K ON I.MAKH = K.MAKH
		WHERE I.NGHD < K.NGDK)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
CREATE TRIGGER trigger_NGHD_NGVL
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN NHANVIEN N ON I.MANV = N.MANV
		WHERE I.NGHD < N.NGVL)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--13. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó. 
CREATE TRIGGER trigger_trigia_hoadon
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN CTHD C ON C.SOHD = I.SOHD
		INNER JOIN SANPHAM S ON S.MASP = C.MASP 
		WHERE I.TRIGIA != C.SL*S.GIA)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--14. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua. 
CREATE TRIGGER trigger_doanhso_khachhang
ON KHACHHANG
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		WHERE I.DOANHSO != (
		SELECT SUM(TRIGIA)
		FROM HOADON HD
		WHERE HD.MAKH = I.MAKH))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--BAI TAP 2: Sinh viên hoàn thành Phần I bài tập QuanLyGiaoVu câu 9, 10 và từ câu 15 đến câu 24.
USE QLGV
-- 9. Lớp trưởng của một lớp phải là học viên của lớp đó. 
CREATE TRIGGER trg_loptruong
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		LEFT JOIN HOCVIEN HV ON I.MALOP = HV.MALOP AND I.TRGLOP = HV.MAHV
		WHERE HV.MAHV IS NULL )
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

-- 10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER trg_truongkhoa
ON KHOA
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		LEFT JOIN GIAOVIEN GV ON I.MAKHOA = GV.MAKHOA AND I.TRGKHOA = GV.MAGV
		WHERE GV.MAGV IS NULL OR GV.HOCVI NOT IN ('TS','PTS'))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này. 
CREATE TRIGGER trg_ngthi_ketquathi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		INNER JOIN GIANGDAY GD ON I.MAMH = GD.MAMH
		WHERE I.NGTHI < GD.DENNGAY OR GD.DENNGAY < GETDATE())
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn. 
CREATE TRIGGER trg_somonhoc_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		JOIN GIANGDAY GD ON I.MALOP = GD.MALOP
		WHERE I.HOCKY = GD.HOCKY AND I.NAM = GD.NAM
		GROUP BY GD.MALOP, GD.HOCKY, GD.NAM
		HAVING COUNT(GD.MAMH) > 3)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. 
CREATE TRIGGER trg_siso_lop
ON HOCVIEN
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    UPDATE LOP
    SET SISO = (
        SELECT COUNT(*)
        FROM HOCVIEN
        WHERE HOCVIEN.MALOP = LOP.MALOP
    )
    FROM LOP
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.MALOP = LOP.MALOP
        UNION
        SELECT 1
        FROM deleted d
        WHERE d.MALOP = LOP.MALOP
    )
END

--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng 
--một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”). 
CREATE TRIGGER trg_dieukien
ON DIEUKIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM INSERTED I
		WHERE I.MAMH = I.MAMH_TRUOC)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
		RETURN
	END
	
	IF EXISTS (
		SELECT 1 
		FROM inserted I
		JOIN DIEUKIEN DK ON DK.MAMH = I.MAMH_TRUOC AND DK.MAMH_TRUOC = I.MAMH)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
		RETURN;
	END

	PRINT 'Success!'
END

--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau. 
CREATE TRIGGER trg_mucluong_giaovien
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT * 
		FROM inserted I 
		WHERE EXISTS (
			SELECT * 
			FROM GIAOVIEN GV 
			WHERE I.HOCHAM = GV.HOCHAM AND I.HOCVI = GV.HOCVI AND I.HESO = GV.HESO AND I.MUCLUONG != GV.MUCLUONG)
		)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5. 
CREATE TRIGGER trg_thilai_ketquathi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE I.LANTHI > 1 AND (
			SELECT DIEM
			FROM KETQUATHI KQT
			WHERE I.MAHV = KQT.MAHV AND I.MAMH = KQT.MAMH AND KQT.LANTHI = I.LANTHI - 1) >= 5)
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

-- 21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học). 
CREATE TRIGGER trg_ngaythi_ketquathi
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE I.NGTHI < (
			SELECT NGTHI
			FROM KETQUATHI KQT
			WHERE I.MAHV = KQT.MAHV AND I.MAMH = KQT.MAMH AND KQT.LANTHI = I.LANTHI - 1))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

-- 22. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau 
--khi học xong những môn học phải học trước mới được học những môn liền sau). 
CREATE TRIGGER trg_phancong_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE (
			SELECT MAMH_TRUOC 
			FROM DIEUKIEN 
			WHERE DIEUKIEN.MAMH = I.MAMH) IS NOT NULL AND
			
			NOT EXISTS (
				SELECT 1 
				FROM GIANGDAY GD
				WHERE GD.MALOP = I.MALOP AND 
					GD.MAMH = (
						SELECT MAMH_TRUOC 
						FROM DIEUKIEN 
						WHERE DIEUKIEN.MAMH = I.MAMH) AND
					GD.DENNGAY < I.TUNGAY))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END

-- 23. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER trg_monthuockhoa_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted I
		WHERE (SELECT MAKHOA FROM GIAOVIEN WHERE GIAOVIEN.MAGV = I.MAGV) != (SELECT MAKHOA FROM MONHOC WHERE MONHOC.MAMH = I.MAMH))
	BEGIN
		ROLLBACK TRAN	
		PRINT 'Fail!'
	END
	ELSE
		PRINT 'Success!'
END