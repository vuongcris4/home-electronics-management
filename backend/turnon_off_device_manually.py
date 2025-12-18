# source ./venv/bin/activate
# python manage.py shell

from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

# 1. Lấy layer kết nối Redis
channel_layer = get_channel_layer()

# 2. Tên nhóm (Lấy từ log của bạn: "Code uses: 'room_1'")
group_name = 'room_1'

# 3. Gửi lệnh
# Tôi sẽ thử TẮT đèn (is_on: False) và đổi độ sáng thành 100
async_to_sync(channel_layer.group_send)(
    group_name,
    {
        # 'type' phải trùng tên hàm handler trong consumers.py
        'type': 'device_state_update', 
        
        # 'state' là dữ liệu mà App Flutter của bạn cần để vẽ lại UI
        'state': {
            'device_id': 9,
            'is_on': True,  
            'attributes': {'brightness': 100}
        }
    }
)