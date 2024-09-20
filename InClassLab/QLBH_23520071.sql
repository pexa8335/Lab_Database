CREATE TABLE KHACHHANG
(
	MAKH char(4) NOT NULL,
	HOTEN varchar(40),
	DCHI varchar(50),
	SODT varchar(20),
	NGSINH smalldatetime,
	NGDK smalldatetime,
	DOANHSO money,
	CONSTRAINT PK_MAKH PRIMARY KEY (MAKH)
)

--10 Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
ALTER TABLE KHACHHANG
ADD CHECK (NGDK > NGSINH)

CREATE TABLE NHANVIEN
( 
	MANV char(4) NOT NULL,
	HOTEN varchar (40),
	SODT varchar (20),
	NGVL smalldatetime,
	CONSTRAINT PK_MANV PRIMARY KEY (MANV)
)

CREATE TABLE SANPHAM
(
	MASP char(4) NOT NULL,
	TENSP varchar(40),
	DVT varchar(20),
	NUOCSX varchar (40),
	GIA money,
	CONSTRAINT PK_MASP PRIMARY KEY (MASP)
)

CREATE TABLE HOADON 
( 
	SOHD int NOT NULL,
	NGHD smalldatetime,
	MAKH char(4),
	MANV char(4),
	TRIGIA money,
	CONSTRAINT PK_SOHD PRIMARY KEY (SOHD),
	CONSTRAINT FK_MAKH FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH),
	CONSTRAINT FK_MANV FOREIGN KEY (MANV) REFERENCES  NHANVIEN(MANV),
)

CREATE TABLE CTHD
(
	SOHD int NOT NULL,
	MASP char(4) NOT NULL,
	SL int,
	CONSTRAINT PK_CTHD PRIMARY KEY (SOHD,MASP),
	CONSTRAINT FK_SOHD FOREIGN KEY (SOHD) REFERENCES HOADON(SOHD),
	CONSTRAINT FK_MASP FOREIGN KEY (MASP) REFERENCES SANPHAM(MASP)
)
--2 Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.
ALTER TABLE SANPHAM
ADD GHICHU varchar(20)

--3 Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
ALTER TABLE KHACHHANG
ADD LOAIKH tinyint

--4 Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
ALTER TABLE SANPHAM 
ALTER COLUMN GHICHU varchar(100)

--5 Xóa thuộc tính GHICHU trong quan hệ SANPHAM.
ALTER TABLE SANPHAM
DROP COLUMN GHICHU

--6 Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang
--lai”, “Thuong xuyen”, “Vip”…
ALTER TABLE KHACHHANG 
ALTER COLUMN LOAIKH varchar(50)

--7 Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
ALTER TABLE SANPHAM
ADD CONSTRAINT CK_DVT CHECK (DVT IN ('cay', 'hop', 'cai', 'quyen', 'chuc'));

--8 Giá bán của sản phẩm từ 500 đồng trở lên
ALTER TABLE SANPHAM
ADD CHECK (GIA > 500)

--9 Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm
ALTER TABLE CTHD
ADD CHECK (SL > 0)

