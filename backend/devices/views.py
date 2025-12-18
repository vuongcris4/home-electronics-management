# /home/trand/D/personal/home_electronics_backend/devices/views.py
from rest_framework import viewsets, permissions, serializers
from rest_framework.response import Response
from .models import Room, Device
from .serializers import RoomSerializer, DeviceSerializer

class IsOwner(permissions.BasePermission):
    """
    Cho phép đọc (GET, HEAD, OPTIONS) với điều kiện khác được quản lý bởi get_queryset.
    Với thao tác ghi (Put/ Patch/ Delete):
        - Nếu object là Room -> User phải là chủ của Room
        - Nếu object là Device -> User phải là chủ của Room chứa Device.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        if isinstance(obj, Room):
            return obj.user == request.user
        if isinstance(obj, Device):
            return obj.room.user == request.user
        return False

class RoomViewSet(viewsets.ModelViewSet):
    """
    Mọi endpoint rooms/:
        - /api/rooms/ (list, create)
        - /api/rooms/<id>/ (retrieve, update, delete)
    """
    serializer_class = RoomSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    # Lấy Room
    def get_queryset(self):
        return Room.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    # Ghi đè phương thức update để xử lý PUT như PATCH cho nhất quán
    def update(self, request, *args, **kwargs):
        """
        Dù client gọi PUT, bạn vẫn xử lý như PATCH
        -> Flutter chỉ gửi field cần sửa, không phải gửi full object
        """
        partial = kwargs.pop('partial', True)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)


class DeviceViewSet(viewsets.ModelViewSet):
    """
    Chỉ trả devices thuộc những room của user đang login.
    """
    serializer_class = DeviceSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get_queryset(self):
        return Device.objects.filter(room__user=self.request.user)

    def perform_create(self, serializer):
        """
        1. Lấy room từ body
        2. Tìm Room; nếu không thấy -> lỗi "Room not found"
        3. Check room.user == request.user, nếu không -> forbid.
        4. Lấy device_type (default = binarySwitch)
        5. Lấy attributes (default {})
            - Nếu là dimmableLight và chưa có brightness -> set brightness = 100.
        6. save.
        """
        room_id = self.request.data.get('room')
        if not room_id:
            raise serializers.ValidationError({"room": "This field is required."})
            
        try:
            room = Room.objects.get(pk=room_id)
            if room.user != self.request.user:
                self.permission_denied(self.request, message="You do not have permission to add a device to this room.")
            
            device_type = self.request.data.get('device_type', Device.DeviceType.BINARY_SWITCH)
            attributes = self.request.data.get('attributes', {})

            if device_type == Device.DeviceType.DIMMABLE_LIGHT and 'brightness' not in attributes:
                attributes['brightness'] = 100

            serializer.save(device_type=device_type, attributes=attributes)

        except Room.DoesNotExist:
            raise serializers.ValidationError({"room": "Room not found."})

    def update(self, request, *args, **kwargs):
        # Mọi update đều là partial.
        # 
        partial = kwargs.pop('partial', True) 
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)