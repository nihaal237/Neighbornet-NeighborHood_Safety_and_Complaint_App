from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.models import Alert
from myapp.serializers import AlertSerializer


class UserAlertsAPIView(APIView):
    """
    Returns ALL alerts for all users.
    Sorted: HIGH → MID → LOW → newest in each group.
    """

    def get(self, request):

        priority_order = ["High", "Mid", "Low"]

        # Sort using Python's key ordering
        alerts = sorted(
            Alert.objects.all(),
            key=lambda a: (priority_order.index(a.priority), -a.id)
        )

        serializer = AlertSerializer(alerts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
