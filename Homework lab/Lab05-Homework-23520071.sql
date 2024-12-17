-- Câu hỏi và ví dụ về Triggers (101-110)
use lab1
-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
ALTER TABLE ChuyenGia
ADD NgayCapNhat smalldatetime

CREATE TRIGGER trigger_ngaycapnhat_chuyengia
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
	UPDATE ChuyenGia
	SET NgayCapNhat = GETDATE()
	FROM ChuyenGia CG
	JOIN INSERTED I ON CG.MaChuyenGia = I.MaChuyenGia
END

-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
CREATE TRIGGER trigger_ghilog_duan
ON DuAn
AFTER UPDATE, INSERT, DELETE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    PRINT 'Record in table DuAn is updated!'

	ELSE IF EXISTS (SELECT 1 FROM inserted)
    PRINT 'Record in table DuAn is inserted!'

	ELSE IF EXISTS (SELECT 1 FROM deleted)
    PRINT 'Record in table DuAn is deleted!';
END

-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trig_gioihanduan_cgduan
ON ChuyenGia_DuAn
AFTER UPDATE, INSERT
AS
BEGIN
	IF EXISTS (
		SELECT MaChuyenGia
		FROM inserted I
		WHERE (
			SELECT COUNT(MaDuAn) 
			FROM ChuyenGia_DuAn CGD
			WHERE CGD.MaChuyenGia = I.MaChuyenGia) > 5)

	rollback transaction
END

-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TRIGGER trg_soluongnhanvien_ChuyenGia
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Giảm số nhân viên khi có DELETE
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        UPDATE CongTy
        SET SoNhanVien = SoNhanVien - 1
        WHERE MaCongTy IN (
            SELECT DA.MaCongTy
            FROM deleted D
            INNER JOIN ChuyenGia_DuAn CGDA ON D.MaChuyenGia = CGDA.MaChuyenGia
            INNER JOIN DuAn DA ON CGDA.MaDuAn = DA.MaDuAn
        )
    END

    -- Tăng số nhân viên khi có INSERT
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE CongTy
        SET SoNhanVien = SoNhanVien + 1
        WHERE MaCongTy IN (
            SELECT DA.MaCongTy
            FROM inserted I
            INNER JOIN ChuyenGia_DuAn CGDA ON I.MaChuyenGia = CGDA.MaChuyenGia
            INNER JOIN DuAn DA ON CGDA.MaDuAn = DA.MaDuAn
        )
    END
END


-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER trg_xoaduanhoanthanh_duan
ON DUAN
INSTEAD OF DELETE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM DELETED
		WHERE TrangThai = N'Hoàn thành')
	BEGIN
        PRINT 'Không thể xóa dự án đã hoàn thành.'
    END

    ELSE

    BEGIN
        DELETE FROM DuAn WHERE MaDuAn IN (SELECT MaDuAn FROM deleted)
    END
END
-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.
CREATE TRIGGER trigger_capdokynang
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    UPDATE ChuyenGia_KyNang
    SET CapDo = CapDo + 1
    WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM INSERTED)
END

-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TRIGGER trg_thaydoicapdokynang
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM inserted I 
		WHERE EXISTS (
			SELECT 1
			FROM ChuyenGia_KyNang CGKN
			WHERE CGKN.MaChuyenGia = I.Machuyengia AND CGKN.CapDo != I.CapDo))
	BEGIN
		PRINT 'CẤP ĐỘ BỊ THAY ĐỔI!'
	END
END

-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
CREATE TRIGGER trigger_ngayketthuc_ngaybatdau
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
		SELECT 1
		FROM INSERTED
		WHERE NgayBatDau > NgayKetThuc)
	BEGIN
		ROLLBACK TRAN
	END
END

-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.
CREATE TRIGGER trg_banghi_chuyengiakynang
ON KyNang
AFTER DELETE
AS
BEGIN
    DELETE FROM ChuyenGia_KyNang WHERE MaKyNang IN (SELECT MaKyNang FROM deleted)
END

-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER trigger_khongquamuoiduan
ON DuAn
AFTER INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM DuAn WHERE MaCongTy IN (SELECT MaCongTy FROM INSERTED) AND TrangThai = N'Đang thực hiện') > 10
	ROLLBACK TRAN
END

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)

-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.
ALTER TABLE ChuyenGia
ADD Luong money

CREATE TRIGGER trigger_capnhatluong_chuyengia
ON ChuyenGia
AFTER INSERT, UPDATE
AS
BEGIN
	UPDATE CG
	SET CG.Luong = 1000 * CapDo * CG.NamKinhNghiem
	FROM ChuyenGia CG
	JOIN INSERTED I ON I.MaChuyenGia =  CG.MaChuyenGia
	JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = I.MaChuyenGia
END

-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).

-- Tạo bảng ThongBao nếu chưa có
CREATE TABLE ThongBao (
    MaThongBao INT IDENTITY PRIMARY KEY,
    MaDuAn CHAR(4),
    NgayThongBao SMALLDATETIME DEFAULT GETDATE(),
    NoiDung NVARCHAR(255)
)

CREATE TRIGGER trg_ThongBao_DuAnSapDenHan
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO ThongBao (MaDuAn, NgayThongBao, NoiDung)
    SELECT MaDuAn, 
		   GETDATE(),
           CONCAT('Dự án "', TenDuAn, '" sắp đến hạn trong 7 ngày.')
    FROM DuAn
    WHERE DATEDIFF(DAY, GETDATE(), NgayKetThuc) = 7;
END

-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.
CREATE TRIGGER trg_nganchanxoacapnhap_ChuyenGia
ON ChuyenGia
AFTER DELETE, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM deleted D
        JOIN ChuyenGia_DuAn CG_DA ON D.MaChuyenGia = CG_DA.MaChuyenGia
    )
    BEGIN
        RAISERROR ('Không thể xóa hoặc cập nhật chuyên gia đang tham gia dự án.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.

-- Tạo bảng ThongKeChuyenNganh nếu chưa có
CREATE TABLE ThongKeChuyenNganh (
    ChuyenNganh NVARCHAR(100),
    SoLuong INT
)

ALTER TABLE ThongKeChuyenNganh
ALTER COLUMN ChuyenNganh NVARCHAR(50)

CREATE TRIGGER trg_ThongKe_ChuyenNganh
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
	INSERT INTO ThongKeChuyenNganh (ChuyenNganh)
	SELECT CG.ChuyenNganh
	FROM ChuyenGia CG
	WHERE NOT EXISTS (
		SELECT 1 FROM ThongKeChuyenNganh WHERE ThongKeChuyenNganh.ChuyenNganh = CG.ChuyenNganh)

	UPDATE tk
	SET tk.SoLuong = (SELECT COUNT(*) FROM ChuyenGia cg WHERE cg.ChuyenNganh = tk.ChuyenNganh GROUP BY cg.ChuyenNganh)
	FROM ThongKeChuyenNganh tk
	WHERE EXISTS (
        SELECT 1
        FROM ChuyenGia CG
        WHERE CG.ChuyenNganh = tk.ChuyenNganh)
END

-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.

-- Tạo bảng DuAnHoanThanh nếu chưa có
CREATE TABLE DuAnHoanThanh (
    MaDuAn INT PRIMARY KEY,
    TenDuAn NVARCHAR(200),
    NgayBatDau DATE,
    NgayKetThuc DATE,
    TrangThai NVARCHAR(50),
)

CREATE TRIGGER trg_BackupCompleted_DuAn
ON DuAn
AFTER UPDATE
AS
BEGIN
    INSERT INTO DuAnHoanThanh (MaDuAn, TenDuAn, NgayBatDau, NgayKetThuc, TrangThai)
    SELECT MaDuAn, TenDuAn, NgayBatDau, NgayKetThuc, TrangThai
    FROM inserted
    WHERE TrangThai = N'Hoàn thành';
END

-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
ALTER TABLE CongTy
ADD DiemDanhGiaTrungBinh numeric(4,2)

CREATE TRIGGER trg_UpdateRating_CongTy
ON DuAn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE CongTy
    SET DiemDanhGiaTrungBinh = (
        SELECT AVG(DiemDanhGia)
        FROM DuAn
        WHERE DuAn.MaCongTy = CongTy.MaCongTy
    )
    WHERE MaCongTy IN (
        SELECT MaCongTy FROM inserted
        UNION
        SELECT MaCongTy FROM deleted
    )
END


-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.
CREATE TRIGGER trg_phancongchuyengia
ON DuAn
AFTER INSERT
AS
BEGIN
    INSERT INTO ChuyenGia_DuAn (MaChuyenGia, NgayThamGia)
    SELECT C.MaChuyenGia,  GETDATE()
    FROM inserted I
	INNER JOIN ChuyenGia_DuAn CGDA ON I.MaDuAn = CGDA.MaDuAn
	INNER JOIN ChuyenGia C  ON C.MaChuyenGia = CGDA.MaChuyenGia
    WHERE  CGDA.MaDuAn = I.MaDuAn 
END


-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.
ALTER TABLE ChuyenGia
add TrangThai NVARCHAR(50)

CREATE TRIGGER trg_trangthaiban
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    UPDATE C
    SET C.TrangThai = N'Bận'
    FROM ChuyenGia C
	WHERE C.MaChuyenGia IN (SELECT MaChuyenGia FROM inserted)
END


-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.
CREATE TRIGGER trg_nganthemkynangtrunglap
ON ChuyenGia_KyNang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM ChuyenGia_KyNang
        WHERE MaChuyenGia = (SELECT MaChuyenGia FROM inserted) 
        AND MaKyNang = (SELECT MaKyNang FROM inserted)
    )
    BEGIN
        RAISERROR ('Kỹ năng này đã tồn tại cho chuyên gia.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO ChuyenGia_KyNang (MaChuyenGia, MaKyNang)
        SELECT MaChuyenGia, MaKyNang FROM inserted;
    END
END


-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.
CREATE TABLE BaoCaoDuAn (
    MaDuAn INT,
    TenDuAn NVARCHAR(200),
    NgayKetThuc DATE,
    BaoCao NVARCHAR(1000)
)

CREATE TRIGGER trg_baocaotongket
ON DuAn
AFTER UPDATE
AS
BEGIN
    INSERT INTO BaoCaoDuAn (MaDuAn, TenDuAn, NgayKetThuc, BaoCao)
    SELECT MaDuAn, TenDuAn, NgayKetThuc, 
           CONCAT('Dự án "', TenDuAn, '" đã hoàn thành')
    FROM inserted
    WHERE TrangThai = N'Hoàn thành';
END

--133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.
ALTER TABLE CongTy
ADD XepHang BIGINT

ALTER TABLE DuAn
ADD DiemDanhGia INT
CREATE TRIGGER trg_UpdateCompanyRank
ON DuAn
AFTER UPDATE
AS
BEGIN
    UPDATE CongTy
    SET XepHang = (
        SELECT TOP 1 Rank() OVER (ORDER BY COUNT(*) DESC, AVG(DiemDanhGia) DESC)
        FROM DuAn
        WHERE MaCongTy = CongTy.MaCongTy AND TrangThai = N'Hoàn thành'
    )
    WHERE MaCongTy IN (SELECT MaCongTy FROM inserted);
END

-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).
-- Tạo bảng thông báo nếu chưa có
ALTER TABLE ThongBao
ADD MaChuyenGia INT

CREATE TRIGGER trg_SendLevelUpNotification
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    INSERT INTO ThongBao (MaChuyenGia, NgayThongBao, NoiDung)
    SELECT MaChuyenGia, 
		   GETDATE(),
           CONCAT('Chuyên gia "', HoTen, '" đã được thăng cấp do có kinh nghiệm ', NamKinhNghiem, ' năm.')
    FROM inserted
    WHERE NamKinhNghiem >= 5;
END

-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.
CREATE TRIGGER trg_UpdateProjectStatusToUrgent
ON DuAn
AFTER UPDATE
AS
BEGIN
    UPDATE DuAn
    SET TrangThai = N'Khẩn cấp'
    WHERE DATEDIFF(DAY, GETDATE(), NgayKetThuc) < DATEDIFF(DAY, NgayBatDau, NgayKetThuc) * 0.1;
END

-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.
ALTER TABLE ChuyenGia
ADD SoDuAnDangThucHien int

CREATE TRIGGER trg_soluongduandangthuchien
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE C
    SET C.SoDuAnDangThucHien = (
        SELECT COUNT(*) 
        FROM ChuyenGia_DuAn CGDA
        WHERE CGDA.MaChuyenGia = C.MaChuyenGia AND EXISTS (
			SELECT 1 FROM DuAn WHERE CGDA.MaDuAn = DuAn.MaDuAn AND TrangThai = N'Đang thực hiện')
    )
    FROM ChuyenGia C
END

-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.
ALTER TABLE CongTy
ADD TyLeThangCong numeric(4,2)

CREATE TRIGGER trg_capnhaptylethanhcong
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE CongTy
    SET TyLeThangCong = (
        SELECT CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM DuAn WHERE MaCongTy = CongTy.MaCongTy) * 100
        FROM DuAn
        WHERE DuAn.MaCongTy = CongTy.MaCongTy AND TrangThai = N'Hoàn thành'
    )
    WHERE MaCongTy IN (SELECT MaCongTy FROM inserted);
END

-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.
-- Tạo bảng log nếu chưa có
CREATE TABLE LogLuongChuyenGia (
    MaChuyenGia INT,
    LuongCu INT,
    LuongMoi INT,
    ThoiGian DATETIME DEFAULT GETDATE()
)

CREATE TRIGGER trg_luongthaydoi
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    INSERT INTO LogLuongChuyenGia (MaChuyenGia, LuongCu, LuongMoi)
    SELECT inserted.MaChuyenGia, deleted.Luong, inserted.Luong
    FROM inserted
    INNER JOIN deleted ON inserted.MaChuyenGia = deleted.MaChuyenGia
    WHERE inserted.Luong != deleted.Luong;
END

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.
ALTER TABLE CongTy
ADD SoChuyenGiaCapCao int 

CREATE TRIGGER trg_UpdateSeniorExpertsCount
ON ChuyenGia
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE CongTy
    SET SoChuyenGiaCapCao = (
        SELECT COUNT(*)
        FROM ChuyenGia c
		inner join ChuyenGia_DuAn cgda on cgda.MaChuyenGia = c.MaChuyenGia
		inner join DuAn da on da.MaDuAn = cgda.MaDuAn
        WHERE da.MaCongTy = CongTy.MaCongTy AND EXISTS (
			SELECT 1 FROM ChuyenGia_KyNang cgkn WHERE c.MaChuyenGia = cgkn.MaChuyenGia AND CapDo > 3)
    )
END

-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.
CREATE TRIGGER trg_capnhaptrangthaicanbosungnhanluc
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE D
    SET D.TrangThai = N'Cần bổ sung nhân lực'
    FROM DuAn D
    WHERE D.MaDuAn IN (
        SELECT MaDuAn
        FROM ChuyenGia_DuAn
        GROUP BY MaDuAn
        HAVING COUNT(*) < 1
    )
END