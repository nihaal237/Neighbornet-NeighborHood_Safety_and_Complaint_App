# myapp/api_views/user_submit_report_view.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.files.storage import default_storage
from django.utils.text import get_valid_filename
from myapp.models import Report, Evidence
from myapp.serializers_report import ReportSerializer

class SubmitReportAPIView(APIView):
    parser_classes = [MultiPartParser, FormParser]  # <-- very important

    def post(self, request):
        title = request.data.get("title")
        description = request.data.get("description")
        location = request.data.get("location")
        isAnonymous = request.data.get("isAnonymous") in ("true", "True", "1", True)

        # If user is not submitting anonymously, require authentication
        if not isAnonymous and (not request.user or request.user.is_anonymous):
            return Response({"error": "Authentication required for non-anonymous reports."},
                            status=status.HTTP_401_UNAUTHORIZED)

        evidence_files = request.FILES.getlist("evidences")

        errors = {}

        # ---- VALIDATIONS ----
        if not title or len(title.strip()) < 3:
            errors["title"] = "Title must be at least 3 characters."

        if not description or len(description.strip()) < 10:
            errors["description"] = "Description must be at least 10 characters."

        if not location or len(location.strip()) < 3:
            errors["location"] = "Location is required."

        if not evidence_files or len(evidence_files) == 0:
            errors["evidences"] = "At least one evidence file is required."

        if errors:
            return Response({"errors": errors}, status=status.HTTP_400_BAD_REQUEST)

        # ---- CREATE REPORT ----
        report = Report.objects.create(
            title=title,
            description=description,
            location=location,
            isAnonymous=isAnonymous,
            user=request.user
        )

        # ---- HANDLE EVIDENCE FILES ----
        for idx, uploaded_file in enumerate(evidence_files, start=1):
            # sanitize filename
            safe_name = get_valid_filename(uploaded_file.name)
            filename = f"report_{report.id}_{idx}_{safe_name}"
            saved_path = default_storage.save(f"evidences/{filename}", uploaded_file)

            Evidence.objects.create(
                report=report,
                file=saved_path
            )

        serializer = ReportSerializer(report)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
