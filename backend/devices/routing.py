# devices/routing.py
from django.urls import path
from .consumers import DeviceConsumer

# Bỏ tiền tố "ws/" ở đây
websocket_urlpatterns = [
    path('devices/<int:room_id>/', DeviceConsumer.as_asgi()),
]