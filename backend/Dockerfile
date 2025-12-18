FROM python:3.11-slim

# Ngăn Python tạo file .pyc và giúp log hiển thị ngay lập tức
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Cài đặt dependencies hệ thống cho psycopg2 và các thư viện khác
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt thư viện Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ mã nguồn vào container
COPY . .

# Port này là port nội bộ của container, sẽ được docker-compose map ra ngoài
EXPOSE 8000

# Lệnh khởi chạy sử dụng daphne cho WebSocket
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "home_electronics_backend.asgi:application"]