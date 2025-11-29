# views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from myapp.serializers import VerifyIdentitySerializer, ResetPasswordSerializer

class VerifyIdentityView(APIView):
    def post(self, request):
        serializer = VerifyIdentitySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        return Response({
            "message": "Identity verified. You may now reset your password."
        }, status=200)


class ResetPasswordView(APIView):
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({"message": "Password updated successfully"}, status=200)
