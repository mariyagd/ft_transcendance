from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenBlacklistView,
)
from .views import (
    RegisterView,
    UserProfileView,
    ChangePasswordView,
)

app_name = 'pong_app'

urlpatterns = [
    path('login/', TokenObtainPairView.as_view(), name='user_login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='user_register'),
    path('profile/', UserProfileView.as_view(), name='user_profile'),
    path('logout/', TokenBlacklistView.as_view(), name='user_logout'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
]