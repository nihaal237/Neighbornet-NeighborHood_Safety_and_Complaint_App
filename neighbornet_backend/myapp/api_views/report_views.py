# myapp/api_views/report_view.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from django.shortcuts import get_object_or_404

from myapp.models import Report
from myapp.serializers_report import ReportSerializer


class PoliceReportListAPIView(APIView):
    """
    GET /police/reports/
    - Shows all reports in database to police users
    - Includes all evidences
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user

        if not hasattr(user, 'police_profile') or user.police_profile is None:
            return Response(
                {"detail": "Only police users can access this endpoint."},
                status=status.HTTP_403_FORBIDDEN
            )

        reports = Report.objects.all().order_by('-dateTime')
        serializer = ReportSerializer(reports, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


class PoliceReportDetailAPIView(APIView):
    """
    GET /police/reports/{pk}/
    - Police can view any report and its evidences
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        report = get_object_or_404(Report, pk=pk)
        user = request.user

        if not hasattr(user, 'police_profile') or user.police_profile is None:
            return Response(
                {"detail": "Only police users can view this report."},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = ReportSerializer(report, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


class PoliceUpdateReportStatusAPIView(APIView):
    """
    PATCH /police/reports/{pk}/status/
    - Only police can update report status
    - Body: { "status": "Processing" }
    """
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        report = get_object_or_404(Report, pk=pk)
        user = request.user

        if not hasattr(user, 'police_profile') or user.police_profile is None:
            return Response(
                {"detail": "Only police users can update report status."},
                status=status.HTTP_403_FORBIDDEN
            )

        new_status = request.data.get('status')
        if not new_status:
            return Response({"error": "Provide 'status' in request body."}, status=status.HTTP_400_BAD_REQUEST)

        valid_statuses = [choice[0] for choice in Report._meta.get_field('status').choices]
        if new_status not in valid_statuses:
            return Response({"error": f"Invalid status. Valid values: {valid_statuses}"}, status=status.HTTP_400_BAD_REQUEST)

        report.status = new_status
        report.save()

        serializer = ReportSerializer(report, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
