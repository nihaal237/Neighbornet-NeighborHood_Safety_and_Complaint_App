from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.models import Alert
from myapp.serializers import AlertSerializer
from django.shortcuts import get_object_or_404

class AdminAlertAPIView(APIView):
    """
    API View for Admin to GET all alerts, POST new alerts, and DELETE alerts.
    """

    def get(self, request):
        alerts = Alert.objects.all().order_by('-dateTime')
        serializer = AlertSerializer(alerts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = AlertSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()  # create alert
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk=None):
        """
        Delete an alert by ID (pk).
        The Flutter client will call /admin/alerts/<id>/
        """
        if pk is None:
            return Response({"error": "Alert ID required"}, status=status.HTTP_400_BAD_REQUEST)

        alert = get_object_or_404(Alert, pk=pk)
        alert.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
