from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
import re

User = get_user_model()

class UserProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response({
            "username": user.username,
            "email": user.email,
            "phoneNo": user.phoneNo,
            "address": user.address,
        })


class UpdateUserProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user

        username = request.data.get("username")
        email = request.data.get("email")
        phoneNo = request.data.get("phoneNo")
        address = request.data.get("address")
        password = request.data.get("password")

        # ---------- VALIDATIONS ----------
        errors = {}

        if username and len(username.strip()) < 3:
            errors["username"] = "Username must have at least 3 characters."

        if email:
            if "@" not in email or "." not in email:
                errors["email"] = "Enter a valid email format."
            elif User.objects.filter(email=email).exclude(id=user.id).exists():
                errors["email"] = "Email is already taken."

        if phoneNo:
            if not re.fullmatch(r"03\d{9}", phoneNo):
                errors["phoneNo"] = "Phone number must be 11 digits (03XXXXXXXXX)."

        if password:
            if len(password) < 8:
                errors["password"] = "Password must be at least 8 characters long."

        if address and len(address.strip()) < 5:
            errors["address"] = "Address must contain at least 5 characters."

        # If any validation failed → return errors
        if errors:
            return Response({"errors": errors}, status=400)

        # ---------- APPLY CHANGES ----------
        if username:
            user.username = username
        
        if email:
            user.email = email
        
        if phoneNo:
            user.phoneNo = phoneNo
        
        if address:
            user.address = address
        
        if password:
            user.set_password(password)

        user.save()

        return Response({"message": "Profile updated successfully!"}, status=200)
