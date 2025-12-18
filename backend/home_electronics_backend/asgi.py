# /home/trand/D/personal/home_electronics_backend/home_electronics_backend/asgi.py
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'home_electronics_backend.settings')

from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter

django_asgi_app = get_asgi_application()

from home_electronics_backend.token_auth_middleware import TokenAuthMiddleware
from home_electronics_backend import routing

# Nếu request là HTTP -> dùng django_asgi_app (bình thường như Django).
# Nếu là websocket -> chạy qua TokenAuthMiddleware + URLRouter.
application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": 
    # Kích hoạt middleware xác thực token
    TokenAuthMiddleware(
        URLRouter(routing.websocket_urlpatterns)
    ),
})