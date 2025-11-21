# myapp/api_views/report_view.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from django.shortcuts import get_object_or_404

from myapp.models import Report, LocalPoliceAuthority
from myapp.serializers_report import ReportSerializer


class IsStaffOrAssignedPolice:
    """
    Helper used in view to check object-level permission:
    staff users (is_staff) OR the user linked to report.assignedPolice can modify status.
    """
    @staticmethod
    def has_permission(request, report: Report):
        user = request.user
        if not user or not user.is_authenticated:
            return False
        if user.is_staff:
            return True
        try:
            return bool(report.assignedPolice and report.assignedPolice.user == user)
        except Exception:
            return False


class PoliceReportListAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        """
        GET /police/reports/
        - Admin (is_staff) => all reports
        - Police users (have police_profile) => reports assigned to their LocalPoliceAuthority
        - Regular users => reports created by them
        Optional query param: ?status=Pending
        """
        user = request.user
        qs = Report.objects.all().order_by('-dateTime')

        status_q = request.query_params.get('status')
        if status_q:
            qs = qs.filter(status=status_q)

        if not user.is_staff:
            # police: show assigned; normal user: show own
            if hasattr(user, 'police_profile') and user.police_profile is not None:
                qs = qs.filter(assignedPolice__user=user)
            else:
                qs = qs.filter(user=user)

        serializer = ReportSerializer(qs, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


class PoliceReportDetailAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        """
        GET /police/reports/{pk}/ - returns report + evidences
        """
        report = get_object_or_404(Report, pk=pk)
        # enforce view permissions for non-staff
        if not request.user.is_staff:
            if hasattr(request.user, 'police_profile') and request.user.police_profile is not None:
                # police: must be assigned to view
                if report.assignedPolice is None or report.assignedPolice.user != request.user:
                    return Response({"detail": "Not allowed to view this report."}, status=status.HTTP_403_FORBIDDEN)
            else:
                # normal user: only owner can view
                if report.user != request.user:
                    return Response({"detail": "Not allowed to view this report."}, status=status.HTTP_403_FORBIDDEN)

        serializer = ReportSerializer(report, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


class PoliceUpdateReportStatusAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        """
        PATCH /police/reports/{pk}/status/  with body: { "status": "Processing" }
        Only staff or assigned police can update the status.
        """
        report = get_object_or_404(Report, pk=pk)

        if not IsStaffOrAssignedPolice.has_permission(request, report):
            return Response({"detail": "You are not allowed to change this report's status."},
                            status=status.HTTP_403_FORBIDDEN)

        new_status = request.data.get('status')
        if not new_status:
            return Response({"error": "Provide 'status' in request body."},
                            status=status.HTTP_400_BAD_REQUEST)

        # Validate new_status against choices
        valid_values = [choice[0] for choice in Report._meta.get_field('status').choices]
        if new_status not in valid_values:
            return Response({"error": f"Invalid status. Valid values: {valid_values}"},
                            status=status.HTTP_400_BAD_REQUEST)

        report.status = new_status
        report.save()
        serializer = ReportSerializer(report, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
