from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from myapp.models import Report, Evidence
from myapp.serializers_report import ReportSerializer
from django.utils.text import get_valid_filename
import os

class SubmitReportAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user

        title = request.data.get('title')
        description = request.data.get('description')
        location = request.data.get('location', '')
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')

        txt_file = request.FILES.get('txt_file')
        img_file = request.FILES.get('img_file')

        # Validate required fields
        if not all([title, description, latitude, longitude, txt_file, img_file]):
            return Response({"error": "Missing fields"}, status=status.HTTP_400_BAD_REQUEST)

        # Create the report object
        report = Report.objects.create(
            title=title,
            description=description,
            location=location,
            latitude=latitude,
            longitude=longitude,
            user=user
        )

        # Save files safely
        if txt_file:
            txt_file.name = get_valid_filename(os.path.basename(txt_file.name))
            Evidence.objects.create(report=report, file=txt_file)

        if img_file:
            img_file.name = get_valid_filename(os.path.basename(img_file.name))
            Evidence.objects.create(report=report, file=img_file)

        # Serialize and return the report
        serializer = ReportSerializer(report, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)
