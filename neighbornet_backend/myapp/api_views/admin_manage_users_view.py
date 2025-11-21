from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.models import User, Report
from myapp.serializers import UserSerializer

class AdminManageUsersAPIView(APIView):
    """y
    API endpoint to view users who have at least one rejected report
    and delete a user by ID.
    """

    def get(self, request, *args, **kwargs):
        # Users with at least one rejected report
        rejected_user_ids = Report.objects.filter(status="Rejected").values_list('user_id', flat=True).distinct()
        users = User.objects.filter(id__in=rejected_user_ids)
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def delete(self, request, user_id=None, *args, **kwargs):
        """
        Delete a specific user by ID.
        URL example: /admin/manage-users/<user_id>/
        """
        if user_id is None:
            return Response({"detail": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(id=user_id)
            user.delete()
            return Response({"detail": "User deleted successfully."}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)
