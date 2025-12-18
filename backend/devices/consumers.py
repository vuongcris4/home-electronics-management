# /home/trand/D/personal/home_electronics_backend/devices/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from asgiref.sync import sync_to_async
from .models import Device, Room
from django.core.exceptions import PermissionDenied

class DeviceConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # 1. Lấy room_id từ URL
        # 2. Map sang group name: room_1, room_2,...
        # 3. Lấy self.scope['user'] đã được middleware gán
        # 4. Nếu anonymous -> close()
        # 5. Check quyền bằng check_room_owner: Chỉ cho phép user sở hữu Room đó connect.
        # 6. Nếu pass: Đăng ký WebSocket hiện tại vào group trên Redis.
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        
        # TÊN GROUP NAME
        self.room_group_name = f'room_{self.room_id}'
        
        print(f"🔌 [CONNECT] Client connected to Room: {self.room_id}")
        print(f"👉 [GROUP NAME] Code uses: '{self.room_group_name}'")
        print(f"🔑 [REDIS KEY] Actual key in Redis: 'asgi:group:{self.room_group_name}'")

        self.user = self.scope.get('user')

        if not self.user or self.user.is_anonymous:
            await self.close()
            return

        is_owner = await self.check_room_owner(self.room_id, self.user.id)
        if not is_owner:
            print(f"⛔ [DENIED] User {self.user.id} is not owner of Room {self.room_id}") # Log thêm nếu bị từ chối
            await self.close()
            return

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        print(f"❌ [DISCONNECT] Client left Room: {self.room_id}") # Log khi ngắt kết nối
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    # App gửi tới thì hàm này nhận
    async def receive(self, text_data):
        print(f"📩 [RECEIVE] App sent to Room {self.room_id}: {text_data}")

        try:
            data = json.loads(text_data)
            device_id = data.get('device_id')
            attributes = data.get('attributes')

            if device_id is None or attributes is None or not isinstance(attributes, dict):
                return

            # Cập nhật DB và 
            # trả về state mới { device_id, is_on, attributes }
            updated_device_state = await self.update_device_state(device_id, attributes, self.user)

            # Gửi message tới group của phòng
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'device_state_update',  # tên hàm handler được gọi khi message được group_send()
                    'state': updated_device_state,  # state là data bạn muốn gửi xuống client
                }
            )
        except PermissionDenied:
            await self.send(text_data=json.dumps({'error': 'Permission denied.'}))
        except Device.DoesNotExist:
            pass
        except json.JSONDecodeError:
            pass

    """
    Khi group_send() được gọi:
        - Channels tìm tất cả consumers đang nằm trong group room_<room_id>
        - Channels gọi method device_state_update() trên TỪNG consumer
        - Trong mỗi device_state_update(), bạn gọi self.send()
    """
    async def device_state_update(self, event):
        state = event['state']

        print(f"📢 [BROADCAST] Server replying to Room {self.room_id}: {state}")

        # Gửi toàn bộ state mới tới WebSocket client
        await self.send(text_data=json.dumps({
            'device_id': state['device_id'],
            'is_on': state['is_on'],
            'attributes': state['attributes']
        }))

    """
    Check double permission:
        1. Device phải thuộc về Room mà user đang connect.
        2. Room phải thuộc về chính user đó.
    is_on vẫn là field riêng -> Thuận tiện cho query/filter.
    """
    @sync_to_async
    def update_device_state(self, device_id, new_attributes, user):
        device = Device.objects.select_related('room__user').get(id=device_id)
        
        # kiểm tra quyền sở hữu của thiết bị.
        if device.room.user != user:
            raise PermissionDenied("You do not have permission to control this device.")
        
        # kiểm tra device có nằm trong room mà WebSocket kết nối hay không.
        if str(device.room.id) != str(self.room_id):
            raise PermissionDenied("Device is not in the connected room.")

        # Cập nhật is_on, has_changed = True nếu !is_on
        has_changed = False
        if 'is_on' in new_attributes and isinstance(new_attributes['is_on'], bool):
            if device.is_on != new_attributes['is_on']:
                device.is_on = new_attributes['is_on']
                has_changed = True

        # Cập nhật JSONField attributes
        # JSONField có thể None -> tránh lỗi
        current_attributes = device.attributes or {}
        for key, value in new_attributes.items():
            if key != 'is_on': # vòng lặp update từng key.
                if current_attributes.get(key) != value:
                    current_attributes[key] = value
                    has_changed = True
        
        # Gán lại JSON
        device.attributes = current_attributes

        # Nếu có thay đổi -> Lưu vào database.
        if has_changed:
            device.save(update_fields=['is_on', 'attributes'])

        # Trả về trạng thái đầy đủ sau khi cập nhật
        return {
            'device_id': device.id,
            'is_on': device.is_on,
            'attributes': device.attributes,
        }

    # Dùng để kiểm tra quyền trước khi join WebSocket room.
    @sync_to_async
    def check_room_owner(self, room_id, user_id):
        return Room.objects.filter(pk=room_id, user_id=user_id).exists()

"""
Client gửi WebSocket message:
{
    "device_id": 12,
    "attributes": {"is_on": true, "brightness": 80}
}

↓
Consumer gọi update_device_state()
↓
1. Lấy device + user
2. Check user sở hữu room
3. Check device thuộc room của WebSocket
4. Update is_on
5. Update attributes JSON
6. Save nếu có thay đổi
7. Trả về trạng thái mới
8. Consumer broadcast cho toàn room
"""