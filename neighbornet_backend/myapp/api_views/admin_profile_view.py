from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.serializers import AdminProfileSerializer
from myapp.models import Admin

class AdminProfileAPIView(APIView):

    def get_admin_user(self):
        """Helper to get the single admin's user object"""
        admin_instance = Admin.objects.first()
        if not admin_instance or not admin_instance.user:
            return None
        return admin_instance.user

    def get(self, request):
        """Fetch the current admin profile"""
        admin_user = self.get_admin_user()
        if not admin_user:
            return Response({"detail": "Admin not found."}, status=status.HTTP_404_NOT_FOUND)
        serializer = AdminProfileSerializer(admin_user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def put(self, request):
        """Update admin email and/or password"""
        admin_user = self.get_admin_user()
        if not admin_user:
            return Response({"detail": "Admin not found."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = AdminProfileSerializer(admin_user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
