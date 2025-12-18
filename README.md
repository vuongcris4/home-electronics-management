# Hướng Dẫn Triển Khai Ứng dụng QLTBĐ (MrH3)

Hệ thống quản lý thiết bị điện trong nhà gồm 2 phần: **Backend (Django)** chạy trên máy tính và **Frontend (Flutter)** chạy trên điện thoại.

## 🛠 Yêu Cầu Chuẩn Bị

1. **Máy tính (Server):**
* Đã cài đặt [Docker Desktop](https://www.docker.com/products/docker-desktop/).
* Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).


2. **Điện thoại (Client):**
* Điện thoại Android/iOS đã bật chế độ nhà phát triển (Developer Options) và gỡ lỗi USB (USB Debugging).


3. **Mạng:** Máy tính và Điện thoại bắt buộc phải kết nối **cùng một mạng Wifi**.
4. **Source Code:** Bạn cần có folder `backend`, folder `lib`, file `pubspec.yaml` (và folder `assets` nếu có).

---

## PHẦN 1: SETUP BACKEND (SERVER)

### Bước 1: Khởi chạy Server

Mở Terminal (Command Prompt/PowerShell hoặc VS Code Terminal), trỏ vào thư mục `backend`:

```bash
cd backend

```

Chạy Docker Compose để dựng container:

```bash
docker compose -p mrh3 up -d --build

```

*(Chờ đến khi các container `db`, `redis`, `backend` ở trạng thái Started)*

### Bước 2: Cấu hình hệ thống & Sửa lỗi giao diện Admin

Sau khi container chạy xong, bạn cần chạy lệnh gom file tĩnh (CSS/JS) để trang Admin không bị lỗi giao diện:

```bash
# Gom file tĩnh (Fix lỗi giao diện Admin)
docker compose -p mrh3 exec backend python manage.py collectstatic --noinput
```

Vào http://localhost:8005/admin để check xem BACKEND hoạt động ok chưa.

### Bước 3: Xác định IP của máy tính (Quan trọng)

Bạn cần biết IP máy tính để nạp vào App điện thoại.

* **Windows:** Mở CMD gõ `ipconfig` -> Tìm dòng **IPv4 Address** (Ví dụ: `192.168.1.5`).
* **Mac/Linux:** Mở Terminal gõ `ifconfig` -> Tìm dòng `inet` (Ví dụ: `192.168.1.5`).

> **Lưu ý:** Hãy ghi nhớ IP này cho Phần 2.

---

## PHẦN 2: SETUP FRONTEND (APP MOBILE)

Vì source code Frontend thường chỉ chứa phần lõi để giảm dung lượng, bạn cần khởi tạo khung dự án Flutter trước.

### Bước 1: Khởi tạo dự án

Mở Terminal tại thư mục cha (nơi bạn muốn lưu code frontend):

```bash
# Tạo dự án mới
flutter create home_electronics_management

# Di chuyển vào thư mục dự án
cd home_electronics_management

```

### Bước 2: Thay thế mã nguồn

Thực hiện thủ công trong File Explorer (Windows) hoặc Finder (Mac):

1. **Xóa:** Folder `lib` và file `pubspec.yaml` mặc định trong thư mục `home_electronics_management` vừa tạo.
2. **Copy & Paste:** Dán folder `lib` và file `pubspec.yaml` từ source code bạn nhận được vào đó.
3. **Cấu hình Assets (Hình ảnh/Icon):**
* Tạo thư mục tên là `assets` nằm cùng cấp với folder `lib`.
* Copy toàn bộ hình ảnh/icon vào thư mục `assets` này (đảm bảo cấu trúc đúng như trong file `pubspec.yaml` khai báo).



### Bước 3: Cài đặt thư viện

Tại terminal của thư mục frontend, chạy:

```bash
flutter pub get

```

### Bước 4: Chạy App lên điện thoại

Kết nối điện thoại với máy tính qua cáp USB. Chạy lệnh sau (Thay `YOUR_IP` bằng IP bạn tìm được ở Phần 1):

```bash
# Ví dụ: IP là 192.168.1.5
flutter run --dart-define=API_HOST=192.168.1.5:8005 --dart-define=PROTOCOL=http

```

---

## ❓ CÂU HỎI THƯỜNG GẶP (FAQ)

**1. App báo lỗi "Connection refused" hoặc xoay vòng (loading) mãi?**

* Kiểm tra điện thoại và máy tính có chung Wifi không.
* Tắt Tường lửa (Firewall) trên máy tính hoặc mở port `8005`.
* Kiểm tra lại địa chỉ IP trong lệnh `flutter run` đã đúng chưa.

**2. Vào trang Admin trên web (localhost:8005/admin) bị mất giao diện (chỉ có chữ)?**

* Bạn quên chưa chạy lệnh `collectstatic`. Hãy chạy lại lệnh ở **Phần 1 - Bước 2**.

**3. App báo lỗi "Asset not found" hoặc "Unable to load asset"?**

* Kiểm tra file `pubspec.yaml` phần `assets:`.
* Đảm bảo bạn đã tạo thư mục `assets` ở thư mục gốc và bỏ ảnh vào đó.
* Sau khi thêm ảnh, cần chạy lại `flutter pub get` và tắt app chạy lại từ đầu.

**4. Màn hình App trắng trơn sau khi mở?**

* Server Backend có thể chưa chạy xong hoặc Database bị lỗi.
* Kiểm tra log backend bằng lệnh: `docker compose -p mrh3 logs -f backend`.
