
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from myapp.models import CommunityPost
from myapp.serializers_communityposts import CommunityPostSerializer

class PoliceCommunityBoardView(APIView):
    """
    API for police (or any authenticated user) to view the community board.
    Highlighted posts appear first, then newest posts.
    """
    permission_classes = [IsAuthenticated]  # Only logged-in users can access

    def get(self, request):
        posts = CommunityPost.objects.all().order_by(
            "-isHighlighted",   # highlighted = True → comes first
            "-dateTime"         # newest first
        )

        data = [
            {
                "id": post.id,
                "content": post.content,
                "isHighlighted": post.isHighlighted,
                "dateTime": post.dateTime,
                "username": post.user.username if post.user else "Anonymous user",
            }
            for post in posts
        ]

        return Response(data)
