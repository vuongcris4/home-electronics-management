# /home/trand/D/personal/home_electronics_backend/users/views.py
from rest_framework import generics, status, permissions
from rest_framework.response import Response
from .models import CustomUser
from .serializers import UserRegisterSerializer, UserProfileSerializer

class RegisterView(generics.CreateAPIView):
    """
    Ai cũng gọi được (kể cả chưa login).
    Override create() để trả message cho gọn.
    -> API: POST /api/users/register/
    """
    serializer_class = UserRegisterSerializer
    permission_classes = (permissions.AllowAny,)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(
            {"message": "User registered successfully."},
            status=status.HTTP_201_CREATED,
            headers=headers
        )

class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Chỉ user đã đăng nhập mới dùng được (IsAuthenticated).
    Luôn trả lại chính user đang login (không truyền id gì cả).
    → API:
        - `GET /api/users/me/` → lấy profile.
        - `PATCH /api/users/me/` → update name, phone_number.
    """
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user