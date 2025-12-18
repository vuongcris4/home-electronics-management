# devices/models.py
from django.db import models
from django.conf import settings

class Room(models.Model):
    """
    - Room thuộc về CustomUser (AUTH_USER_MODEL).
    - related_name='rooms' -> users.rooms.all()
    """
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='rooms'
    )
    name = models.CharField(max_length=100)

    def __str__(self):
        return f"{self.name} (của {self.user.email})"

class Device(models.Model):
    """
    Enum type cho device, dùng cho:
        - Backend validation.
        - Frontend map UI (binary switch vs dimmable light).
    """
    
    class DeviceType(models.TextChoices):
        BINARY_SWITCH = 'binarySwitch', 'Binary Switch'
        DIMMABLE_LIGHT = 'dimmableLight', 'Dimmable Light'

    room = models.ForeignKey(
        Room,
        on_delete=models.CASCADE,
        related_name='devices'
    )
    name = models.CharField(max_length=100)
    subtitle = models.CharField(max_length=100, blank=True, null=True)
    icon_asset = models.CharField(max_length=255)
    is_on = models.BooleanField(default=False)
    
    device_type = models.CharField(
        max_length=20,
        choices=DeviceType.choices,
        default=DeviceType.BINARY_SWITCH
    )
    
    attributes = models.JSONField(default=dict, blank=True)

    def __str__(self):
        return f"{self.name} ({self.get_device_type_display()}) in {self.room.name}"