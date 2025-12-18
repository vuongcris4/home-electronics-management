# /home/trand/D/personal/home_electronics_backend/devices/serializers.py
from rest_framework import serializers
from .models import Room, Device

class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = [
            'id', 
            'name', 
            'subtitle', 
            'icon_asset', 
            'is_on', 
            'room',
            'device_type', 
            'attributes'
        ]
        # Khi tạo mới Device:
        #   - room vẫn phải có trong request.data (nhưng view sẽ xử lí)
        # Khi update:
        #   - room không bắt buộc; bạn vẫn có thể gửi patch 1, 2 field (name, subtitle, attributes,...)
        extra_kwargs = {
            'room': {'required': False}
        }


class RoomSerializer(serializers.ModelSerializer):
    devices = DeviceSerializer(many=True, read_only=True)
    # Room trả về luôn list devices bên trong -> Rất hợp UI Flutter màn hình Room detail
    # user readonly -> Room luôn thuộc về user đang login.

    class Meta:
        model = Room
        fields = ['id', 'name', 'user', 'devices']
        read_only_fields = ['user']