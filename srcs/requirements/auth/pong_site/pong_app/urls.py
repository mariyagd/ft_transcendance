from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenBlacklistView,
)

from .views import (
    RegisterView,
    UserProfileView,
    ChangePasswordView,
    UserLoginView,
)

app_name = 'pong_app'

urlpatterns = [
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='user_register'),
    path('profile/', UserProfileView.as_view(), name='user_profile'),
    path('login/', UserLoginView.as_view(), name='user_login'),
    path('logout/', TokenBlacklistView.as_view(), name='user_logout'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
]