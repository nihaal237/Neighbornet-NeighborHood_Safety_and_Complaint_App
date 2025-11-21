# police_communitypost_view.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CommunityPost
from .serializers_communityposts import CommunityPostSerializer

class PoliceCommunityBoardView(APIView):
    """
    API for police (or any authenticated user) to view the community board.
    Highlighted posts appear first, then newest posts.
    """
    permission_classes = [IsAuthenticated]  # Only logged-in users can access

    def get(self, request):
        posts = CommunityPost.objects.all().order_by('-isHighlighted', '-dateTime')
        serializer = CommunityPostSerializer(posts, many=True)
        return Response(serializer.data)
