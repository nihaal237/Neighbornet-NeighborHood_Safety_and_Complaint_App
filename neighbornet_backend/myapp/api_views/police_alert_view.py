from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from ..models import Alert
from ..serializers import AlertSerializer

class PoliceAlertView(APIView):
    """
    API view for police users to fetch alerts from the database.
    """
    permission_classes = [permissions.IsAuthenticated]  # only logged-in users

    def get(self, request):
        # fetch all alerts from the database
        alerts = Alert.objects.all().order_by('-dateTime')
        
        # serialize alerts
        serializer = AlertSerializer(alerts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
