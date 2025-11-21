# myapp/serializers_report.py
from rest_framework import serializers
from .models import Report, Evidence, StatusType


class EvidenceSerializer(serializers.ModelSerializer):
    """
    Serializer for Evidence model. Provides an absolute file URL when `request`
    is passed in serializer context (useful for frontend to open/download files).
    """
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = Evidence
        fields = ['id', 'file_url', 'timestamp']

    def get_file_url(self, obj):
        if not obj.file:
            return None
        request = self.context.get('request')
        # if request available, build absolute uri, otherwise return relative url
        if request:
            try:
                return request.build_absolute_uri(obj.file.url)
            except Exception:
                return obj.file.url
        return obj.file.url


class ReportSerializer(serializers.ModelSerializer):
    """
    Serializer for Report model including nested evidences and small user/police info.
    `status` uses the StatusType choices to validate incoming values.
    """
    evidences = EvidenceSerializer(many=True, read_only=True)
    status = serializers.ChoiceField(choices=StatusType.choices)
    assigned_police = serializers.SerializerMethodField()
    user_info = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = [
            'id',
            'title',
            'description',
            'dateTime',
            'status',
            'latitude',
            'longitude',
            'location',
            'isAnonymous',
            'isFake',
            'user_info',
            'assigned_police',
            'evidences',
        ]
        read_only_fields = ['dateTime', 'user_info', 'evidences']

    def get_assigned_police(self, obj):
        """
        Returns a compact representation of the assigned police authority.
        """
        if obj.assignedPolice:
            p = obj.assignedPolice
            return {
                'id': p.id,
                'stationName': p.stationName,
                'user_email': p.user.email if p.user else None,
            }
        return None

    def get_user_info(self, obj):
        """
        Returns minimal info about the report creator (if present).
        """
        if obj.user:
            return {
                'id': obj.user.id,
                'username': obj.user.username,
                'email': obj.user.email,
                'phoneNo': obj.user.phoneNo,
            }
        return None
