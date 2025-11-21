# serializers_communityposts.py
from rest_framework import serializers
from .models import CommunityPost, User

# Nested User serializer to show basic info of the poster
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "email"]

# CommunityPost serializer
class CommunityPostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = CommunityPost
        fields = ["id", "user", "content", "dateTime", "isHighlighted"]
