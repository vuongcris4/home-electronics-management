# devices/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import RoomViewSet, DeviceViewSet

router = DefaultRouter()
router.register(r'rooms', RoomViewSet, basename='room')
router.register(r'devices', DeviceViewSet, basename='device')

urlpatterns = [
    path('', include(router.urls)),
]