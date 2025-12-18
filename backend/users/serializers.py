# /home/trand/D/personal/home_electronics_backend/users/serializers.py
from rest_framework import serializers
from .models import CustomUser

# Serializer cho profile.
class UserProfileSerializer(serializers.ModelSerializer):
    """
    Dùng để hiển thị và cập nhật profile user.
    id & email readonly -> user không sửa được email/ id qua API
    """
    class Meta:
        model = CustomUser
        fields = ('id', 'email', 'name', 'phone_number')
        # Ngăn user thay đổi email hoặc id khi cập nhật.
        read_only_fields = ('id', 'email')


# Serializer đăng ký 
class UserRegisterSerializer(serializers.ModelSerializer):
    """
    Có 2 field password để check confirm.
    Check 2 password giống nhau.
    Tạo user bằng create_user của manager -> đảm bảo hash password đúng.
    """
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    password2 = serializers.CharField(write_only=True, required=True, label="Confirm Password")

    class Meta:
        model = CustomUser
        fields = ('email', 'name', 'phone_number', 'password', 'password2')
        extra_kwargs = {
            'name': {'required': True},
        }

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs

    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            email=validated_data['email'],
            name=validated_data['name'],
            phone_number=validated_data.get('phone_number', ''),
            password=validated_data['password']
        )
        return user