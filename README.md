# Hướng Dẫn Triển Khai Ứng dụng QLTBĐ (MrH3)

Hệ thống quản lý thiết bị điện trong nhà gồm 2 phần: **Backend (Django)** chạy trên máy tính và **Frontend (Flutter)** chạy trên điện thoại.

## 🛠 Yêu Cầu Chuẩn Bị

1. **Máy tính (Server):**
* Đã cài đặt [Docker Desktop](https://www.docker.com/products/docker-desktop/).
* Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).
---

## PHẦN 1: SETUP BACKEND (SERVER)

### Bước 1: Khởi chạy Server

```bash
cd backend

```

Chạy Docker Compose để dựng container:

```bash
docker compose -p mrh3 up -d --build

```
### Bước 2: Django Collectstatic


```bash
docker compose -p mrh3 exec backend python manage.py collectstatic --noinput
```

Vào http://localhost:8005/admin để check xem BACKEND hoạt động ok chưa.

### Bước 3: Django Migrate (để tạo table trên docker Postgresql)
```bash
docker exec -it smart_home_backend python manage.py migrate
```



### Bước 4: Xác định IP của máy tính

* **Windows:** Mở CMD gõ `ipconfig` -> Tìm dòng **IPv4 Address** (Ví dụ: `192.168.1.5`).
* **Mac/Linux:** Mở Terminal gõ `ifconfig` -> Tìm dòng `inet` (Ví dụ: `192.168.1.5`).
---

## PHẦN 2: SETUP FRONTEND (APP MOBILE)

### Bước 1: Vào thư mục frontend

```bash
cd frontend
```

### Bước 2: Cài đặt thư viện
Tại terminal của thư mục frontend, chạy:

```bash
flutter pub get

```

### Bước 3: Chạy App lên điện thoại

Kết nối điện thoại với máy tính qua cáp USB. Chạy lệnh sau (Thay `YOUR_IP` bằng IP bạn tìm được ở Phần 1):

```bash
# Ví dụ: IP là 192.168.1.5
flutter run --dart-define=API_HOST=192.168.1.5:8005 --dart-define=PROTOCOL=http

```
