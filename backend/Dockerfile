FROM python:3.11-slim

# Thiết lập biến môi trường
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Cài đặt dependencies hệ thống
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

# Cài đặt thư viện Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy mã nguồn
COPY . .

# Chạy ứng dụng bằng daphne (hỗ trợ WebSocket)
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "home_electronics_backend.asgi:application"]