# source ./venv/bin/activate
# python manage.py shell

from django.contrib.auth import get_user_model

# Lấy model User hiện tại của dự án
User = get_user_model()

# Tìm user theo email trong ảnh
u = User.objects.get(email='abc@123.com')

# Đặt mật khẩu mới (Django sẽ tự động hash nó)
u.set_password('abcd')

# Lưu lại vào database
u.save()

print("Đã đổi mật khẩu thành công!")
exit()