# myapp/serializers_report.py
from rest_framework import serializers
from .models import Report, Evidence, StatusType

class EvidenceSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()
    is_text = serializers.SerializerMethodField()

    class Meta:
        model = Evidence
        fields = ['id', 'file_url', 'timestamp', 'is_text']

    def get_file_url(self, obj):
        if not obj.file:
            return None
        request = self.context.get('request')
        
        # Convert file.url to string
        file_url = str(obj.file.url)

        # Remove double 'evidences/' if exists
        if file_url.startswith('/evidences/evidences/'):
            file_url = file_url.replace('/evidences/evidences/', '/evidences/')

        if request:
            return request.build_absolute_uri(file_url)

        # fallback if no request in context
        return f"http://127.0.0.1:8000{file_url}"

    def get_is_text(self, obj):
        # detect if file is a text file
        if obj.file and str(obj.file.name).endswith('.txt'):
            return True
        return False


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
