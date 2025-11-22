from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from myapp.models import CommunityPost

class CommunityPostsAPIView(APIView):
    permission_classes = [IsAuthenticated]

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
