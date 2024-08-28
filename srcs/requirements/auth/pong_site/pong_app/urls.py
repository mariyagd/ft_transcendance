from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, UserProfileView, ChangePasswordView

app_name = 'pong_app'

urlpatterns = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='user_register'),
    path('profile/', UserProfileView.as_view(), name='user_profile'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
]