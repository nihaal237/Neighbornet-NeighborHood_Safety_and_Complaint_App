from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from myapp.models import LocalPoliceAuthority  # adjust app name

class LoginasPoliceAPIView(APIView):
    """
    API endpoint for Police login.
    Expects email and password in POST request.
    """

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        # Authenticate user
        user = authenticate(request, username=email, password=password)

        if not user:
            return Response(
                {"error": "Invalid credentials"},
                status=status.HTTP_401_UNAUTHORIZED
            )

        # Safe check for police profile
        if not hasattr(user, 'police_profile') or user.police_profile is None:
            return Response(
                {"error": "User is not registered as a police officer"},
                status=status.HTTP_403_FORBIDDEN
            )

        police_profile = user.police_profile

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)

        return Response({
            "refresh": str(refresh),
            "access": str(refresh.access_token),

            # station info
            "police_station": police_profile.stationName,

            # user info
            "id": user.id,
            "email": user.email,
            "username": user.username,
            "phoneNo": user.phoneNo,
            "address": user.address,
        }, status=status.HTTP_200_OK)
