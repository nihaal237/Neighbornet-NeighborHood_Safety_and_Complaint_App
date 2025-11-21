from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from myapp.models import Alert
from myapp.serializers import AlertSerializer

class AdminAlertAPIView(APIView):
  

    def get(self, request):
        alerts = Alert.objects.all().order_by('-dateTime')
        serializer = AlertSerializer(alerts, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = AlertSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()   # create alert
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
