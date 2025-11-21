from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.models import Report
from myapp.serializers import ReportSerializer

class AllReportsAPIView(APIView):
    """Return all reports (normal + anonymous + deleted)"""
    def get(self, request):
        reports = Report.objects.all()
        data = []
        for r in reports:
            data.append({
                "title": r.title,
                "status": r.status,
                "user": r.user.username if r.user else None,
                "isAnonymous": r.isAnonymous,
            })
        return Response(data, status=status.HTTP_200_OK)


class AnonymousReportsAPIView(APIView):
    """Return only anonymous reports"""
    def get(self, request):
        reports = Report.objects.filter(isAnonymous=True)
        data = []
        for r in reports:
            data.append({
                "title": r.title,
                "status": r.status,
                "user": "Anonymous",
                "isAnonymous": r.isAnonymous,
            })
        return Response(data, status=status.HTTP_200_OK)


class DeletedUserReportsAPIView(APIView):
    """Return reports where user is deleted (user=None)"""
    def get(self, request):
        reports = Report.objects.filter(user__isnull=True, isAnonymous=False)
        data = []
        for r in reports:
            data.append({
                "title": r.title,
                "status": r.status,
                "user": "Deleted",
                "isAnonymous": r.isAnonymous,
            })
        return Response(data, status=status.HTTP_200_OK)


class SpecificUserReportsAPIView(APIView):
    """Return reports of a specific user"""
    def get(self, request, user_id):
        reports = Report.objects.filter(user_id=user_id)
        data = []
        for r in reports:
            data.append({
                "title": r.title,
                "status": r.status,
                "user": r.user.username if r.user else "Deleted",
                "isAnonymous": r.isAnonymous,
            })
        return Response(data, status=status.HTTP_200_OK)
