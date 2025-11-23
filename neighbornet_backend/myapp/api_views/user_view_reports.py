# myapp/views_reports.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from myapp.serializers_report import ReportSerializer
from myapp.models import Report

class UserReportsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Get all reports submitted by this authenticated user
        reports = Report.objects.filter(user=request.user).order_by('-dateTime')

        serializer = ReportSerializer(reports, many=True, context={'request': request})

        return Response(serializer.data)
