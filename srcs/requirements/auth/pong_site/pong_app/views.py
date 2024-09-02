from rest_framework import generics
from django.contrib.auth.models import update_last_login
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken, SlidingToken

from .serializers import RegisterSerializer, UserProfileSerializer, ChangePasswordSerializer, UserLoginSerializer
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.password_validation import validate_password, password_changed
from django.contrib.auth import get_user_model, authenticate

User = get_user_model()


#-----------------------------------------------------------------------------------------------------------------------
# RegisterView : uses RegisterViewSerializer to validates data and create a new user
# accepts HTTP requests
class RegisterView(generics.CreateAPIView):
    http_method_names = ['post']
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]
    queryset = User.objects.all()


#-----------------------------------------------------------------------------------------------------------------------
class UserLoginView(APIView):
    http_method_names = ['post']
    serializer_class = UserLoginSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True) # sends HTTP 400 if not valid
        user = serializer.validated_data

        # update last login
        update_last_login(None, user)
        if not user.is_active:
            user.is_active = True
            user.save()

        refresh = RefreshToken.for_user(user)
        access = refresh.access_token

        return Response({
            'refresh': str(refresh),
            'access': str(access),
        }, status=status.HTTP_200_OK)

#-----------------------------------------------------------------------------------------------------------------------
# UserProfileView: PUT, PATCH, GET requests because RetrieveUpdateDestroyAPIView is used
# POST is not allowed
class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        # Renvoie l'utilisateur connecté (self.request.user)
        return self.request.user

#-----------------------------------------------------------------------------------------------------------------------
class ChangePasswordView(generics.UpdateAPIView):
    serializer_class = ChangePasswordSerializer
    queryset = User.objects.all()
    permission_classes = [IsAuthenticated]
    http_method_names = ['post']

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

#-----------------------------------------------------------------------------------------------------------------------