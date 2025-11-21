from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.models import User
from myapp.serializers import UserSerializer

class AdminViewUsersAPIView(APIView):
    """
    API endpoint to view all users (read-only)
    """

    def get(self, request, *args, **kwargs):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
