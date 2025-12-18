# Hướng Dẫn Triển Khai Hệ Thống Smart Home (LAN)

Hệ thống bao gồm Backend (Django) chạy trên máy tính và Frontend (Flutter) chạy trên điện thoại.

### Chuẩn bị

1. **Máy tính:** Đã cài [Docker Desktop](https://www.docker.com/products/docker-desktop/) và [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. **Điện thoại Android:** Đã bật chế độ Developer Options (Gỡ lỗi USB).
3. **Mạng:** Máy tính và Điện thoại phải kết nối **cùng một Wifi**.
4. **Dữ liệu nhận được:** Folder `backend`, folder `lib`, file `pubspec.yaml` (và folder `assets` nếu có).

---

## PHẦN 1: SETUP BACKEND (Trên Máy Tính)

**Bước 1: Lấy địa chỉ IP của máy tính**

* **Windows:** Mở CMD, gõ `ipconfig`. Tìm dòng **IPv4 Address** (ví dụ: `192.168.1.5`).
* **Mac/Linux:** Mở Terminal, gõ `ifconfig`.
* *Lưu ý IP này để dùng ở Phần 2.*

**Bước 2: Cấu hình và chạy Docker**

1. Vào thư mục `backend`, mở file `.env`.
2. Thêm IP máy tính vào dòng `ALLOWED_HOSTS`:
```env
ALLOWED_HOSTS=*,localhost,127.0.0.1,192.168.1.5

```


3. Tại thư mục `backend` (nơi có file `docker-compose.yml`), mở Terminal chạy:
```bash
docker-compose up --build

```


4. Đợi server chạy xong (Backend port `5123`).

---

## PHẦN 2: SETUP FRONTEND (Trên máy tính để nạp vào điện thoại)

Do mã nguồn Frontend chỉ gồm các thành phần cốt lõi, bạn cần khởi tạo khung dự án trước.

**Bước 1: Khởi tạo dự án mới**
Mở Terminal tại thư mục muốn chứa code và chạy:

```bash
flutter create home_electronics_management
cd home_electronics_management

```

**Bước 2: Thay thế mã nguồn (Quan trọng)**

1. Vào thư mục dự án `home_electronics_management` vừa tạo.
2. **Xóa** folder `lib` và file `pubspec.yaml` mặc định đi.
3. **Copy** folder `lib` và file `pubspec.yaml` bạn nhận được dán vào đó.
4. **Lưu ý về Assets:**
* Mở file `pubspec.yaml` kiểm tra phần `assets:`. Nếu thấy có khai báo (ví dụ `- assets/icons/`), bạn **bắt buộc** phải có thư mục `assets` tương ứng nằm cùng cấp với thư mục `lib`.
* *Nếu người gửi chưa gửi thư mục `assets`, hãy yêu cầu họ gửi thêm, nếu không App sẽ lỗi.*



**Bước 3: Cài đặt thư viện**
Tại thư mục dự án, chạy lệnh sau để tải tự động các thư viện đã khai báo trong `pubspec.yaml`:

```bash
flutter pub get

```

**Bước 4: Kết nối điện thoại và Chạy App**

1. Cắm cáp USB kết nối điện thoại với máy tính.
2. Chạy lệnh sau (Thay `192.168.1.5` bằng IP máy tính bạn lấy ở Phần 1):
```bash
flutter run --dart-define=API_HOST=192.168.1.5:5123 --dart-define=PROTOCOL=http

```



---

## CÂU HỎI THƯỜNG GẶP (FAQ)

**Q: App báo lỗi "Connection refused" hoặc xoay vòng mãi?**
A:

1. Kiểm tra xem điện thoại và máy tính có chung Wifi không.
2. Tắt Tường lửa (Firewall) trên máy tính (hoặc mở port 5123).
3. Đảm bảo IP trong lệnh `flutter run` chính xác là IP LAN của máy tính.

**Q: App báo lỗi "Asset not found"?**
A: Bạn thiếu thư mục ảnh. Hãy tạo thư mục `assets` ở thư mục gốc dự án và bỏ các hình ảnh/icon vào đúng cấu trúc như trong file `pubspec.yaml` mô tả.

**Q: Mở App lên màn hình trắng trơn?**
A: Kiểm tra lại backend xem Docker có đang chạy ổn định không và đã tạo database chưa. Nếu chưa có tài khoản đăng nhập, hãy chạy lệnh tạo admin ở backend: `docker-compose exec backend python manage.py createsuperuser`.
