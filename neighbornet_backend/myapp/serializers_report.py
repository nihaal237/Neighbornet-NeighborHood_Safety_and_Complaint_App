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
    evidences = EvidenceSerializer(many=True, read_only=True)
    assigned_police = serializers.SerializerMethodField()
    user = serializers.SerializerMethodField()
    user_display = serializers.SerializerMethodField()

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
            'user',
            'user_display',
            'assigned_police',
            'evidences',
        ]

    def get_user(self, obj):
        user = getattr(obj, "user", None)
        if user is None:
            return None

        return {
            "id": getattr(user, "id", None),
            "username": getattr(user, "username", None),
            "email": getattr(user, "email", None),
            "phoneNo": getattr(user, "phoneNo", None),
        }

    def get_user_display(self, obj):
        user = getattr(obj, "user", None)
        if user is None:
            return "User: Anonymous"
        username = getattr(user, "username", None)
        if username:
            return f"User: {username}"
        return "User: Unknown"

    def get_assigned_police(self, obj):
        police = getattr(obj, "assignedPolice", None)
        if police is None:
            return None

        return {
            "id": getattr(police, "id", None),
            "stationName": getattr(police, "stationName", None),
            "user_email": getattr(police.user, "email", None) if police.user else None,
        }

class SubmitReportSerializer(serializers.ModelSerializer):
    evidences = serializers.ListField(
        child=serializers.FileField(),
        write_only=True,
        min_length=2,
        max_length=2
    )

    class Meta:
        model = Report
        fields = ["title", "description", "location", "latitude", "longitude", "evidences"]

    def validate_evidences(self, value):
        txt_count = sum(1 for f in value if f.name.endswith(".txt"))
        img_count = sum(1 for f in value if f.name.lower().endswith((".jpg",".png")))
        if txt_count != 1 or img_count != 1:
            raise serializers.ValidationError("Exactly one text file and one image (jpg/png) required.")
        return value

    def create(self, validated_data):
        files = validated_data.pop("evidences")
        report = Report.objects.create(**validated_data, user=self.context["request"].user)
        for f in files:
            Evidence.objects.create(report=report, file=f)
        return report