# home_electronics_backend/urls.py
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('admin/', admin.site.urls),

    # API endpoints cho xác thực
    path('api/users/', include('users.urls')),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'), # Đăng nhập
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'), # Làm mới token

    path('api/', include('devices.urls')),
]