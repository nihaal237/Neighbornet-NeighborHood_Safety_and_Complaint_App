from rest_framework import serializers
from .models import User, Alert,Report,CommunityPost


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phoneNo', 'address','role']


class AlertSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alert
        fields = ['id', 'title', 'message', 'priority', 'dateTime']
        read_only_fields = ['dateTime']

class AdminProfileSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, min_length=6)
    email = serializers.EmailField(required=False)  # optional now

    class Meta:
        model = User
        fields = ['email', 'password']

    def update(self, instance, validated_data):
        if 'email' in validated_data:
            instance.email = validated_data['email']
        if 'password' in validated_data:
            instance.set_password(validated_data['password'])  # hash password
        instance.save()
        return instance

class ReportSerializer(serializers.ModelSerializer):
    user_deleted = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = ['id', 'title', 'status', 'isAnonymous', 'user_deleted']

    def get_user_deleted(self, obj):
        return obj.user is None



class CommunityPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommunityPost
        fields = ['id', 'user', 'content', 'dateTime', 'isHighlighted']
from .models import Alert

class AlertSerializer(serializers.ModelSerializer):

    class Meta:
        model = Alert
        fields = ['id', 'title', 'message', 'dateTime', 'priority', 'users']



class VerifyIdentitySerializer(serializers.Serializer):
    email = serializers.EmailField()
    phoneNo = serializers.CharField()

    def validate(self, data):
        email = data["email"]
        phoneNo = data["phoneNo"]

        try:
            user = User.objects.get(email=email, phoneNo=phoneNo)
        except User.DoesNotExist:
            raise serializers.ValidationError("Invalid email or phone number")

        data["user"] = user
        return data
    

class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    new_password = serializers.CharField(min_length=6)

    def validate(self, data):
        try:
            user = User.objects.get(email=data["email"])
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found")

        data["user"] = user
        return data

    def save(self):
        user = self.validated_data["user"]
        user.set_password(self.validated_data["new_password"])
        user.save()
        return user

