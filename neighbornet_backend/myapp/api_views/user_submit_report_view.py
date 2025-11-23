from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from myapp.serializers_report import SubmitReportSerializer

class SubmitReportView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = SubmitReportSerializer(data=request.data, context={"request": request})
        if serializer.is_valid():
            serializer.save()
            return Response({"success": "Report submitted successfully"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
