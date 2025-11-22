from rest_framework import serializers
from myapp.models import Report, Evidence

class EvidenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Evidence
        fields = ['id', 'file', 'timestamp']


class ReportSerializer(serializers.ModelSerializer):
    evidences = EvidenceSerializer(many=True, read_only=True)

    class Meta:
        model = Report
        fields = [
            'id', 'title', 'description', 'location',
            'dateTime', 'status', 'isAnonymous',
            'latitude', 'longitude', 'user', 'evidences'
        ]
