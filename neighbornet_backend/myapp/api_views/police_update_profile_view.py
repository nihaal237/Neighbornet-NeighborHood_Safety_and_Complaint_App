from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.authentication import JWTAuthentication

User = get_user_model()

class PoliceUpdateProfileAPIView(APIView):
    """
    Police can update phoneNo, username, password.
    Requires JWT Authentication.
    """
    authentication_classes = [JWTAuthentication]
    permission_classes = [permissions.IsAuthenticated]

    def put(self, request):
        user = request.user  # logged-in police

        data = request.data

        if "username" in data:
            user.username = data["username"]

        if "phoneNo" in data:
            user.phoneNo = data["phoneNo"]

        if "password" in data:
            user.set_password(data["password"])  # hashed password

        user.save()

        return Response({
            "message": "Profile updated successfully",
            "id": user.id,
            "username": user.username,
            "phoneNo": user.phoneNo,
            "email": user.email,
        }, status=status.HTTP_200_OK)
