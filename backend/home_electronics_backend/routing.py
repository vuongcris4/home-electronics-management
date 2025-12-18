# home_electronics_backend/routing.py

from django.urls import path
from devices.consumers import DeviceConsumer

websocket_urlpatterns = [
    # Ở đây bạn định nghĩa path WebSocket hoàn chỉnh luôn.
    # Khi client connect tới URL này, Router sẽ: 
        # 1. Match path -> gán room_id vào scope["url_route"]["kwargs"]
        # 2. Tạo instance Consumer tương ứng.
    path("ws/devices/<int:room_id>/", DeviceConsumer.as_asgi()),
]
