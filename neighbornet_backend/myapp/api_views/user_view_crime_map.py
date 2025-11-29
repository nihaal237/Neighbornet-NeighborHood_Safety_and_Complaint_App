from rest_framework.views import APIView
from rest_framework.response import Response
from myapp.models import Report
from myapp.serializers_report import ReportSerializer

class ReportLocationsAPIView(APIView):
    def get(self, request):
        reports = Report.objects.filter(
            latitude__isnull=False,
            longitude__isnull=False
        )

        serializer = ReportSerializer(reports, many=True, context={'request': request})
        return Response(serializer.data)
