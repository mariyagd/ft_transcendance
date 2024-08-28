from rest_framework import generics
from django.contrib.auth.models import User
from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from .serializers import RegisterSerializer, UserProfileSerializer, ChangePasswordSerializer
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.password_validation import validate_password, password_changed
from django.contrib.auth import get_user_model


User = get_user_model()

# RegisterView : uses RegisterViewSerializer to validates data and create a new user
# accepts HTTP requests
class RegisterView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    queryset = User.objects.all()
    serializer_class = RegisterSerializer

# UserProfileView: PUT, PATCH, DELETE, GET requests
class UserProfileView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    def get_object(self):
        # Renvoie l'utilisateur connecté (self.request.user)
        return self.request.user


class ChangePasswordView(generics.UpdateAPIView):
    queryset = User.objects.all()
    permission_classes = [IsAuthenticated]
    serializer_class = ChangePasswordSerializer

    def get_object(self, queryset=None):
        return self.request.user

    def update(self, request, *args, **kwargs):
        user = self.get_object()
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            # Check old password
            if not user.check_password(serializer.validated_data['old_password']):
                return Response({"old_password": ["Wrong password."]}, status=status.HTTP_400_BAD_REQUEST)

            # Set the new password
            user.set_password(serializer.validated_data['new_password'])
            user.save()

            password_changed(serializer.data.get("new_password"), user=user)
            return Response({"detail": "Password updated successfully."}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
