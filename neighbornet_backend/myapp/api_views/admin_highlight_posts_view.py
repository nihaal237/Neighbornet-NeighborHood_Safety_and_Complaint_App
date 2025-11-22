from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from myapp.models import CommunityPost
from myapp.serializers import CommunityPostSerializer

class AdminListCommunityPostsAPIView(APIView):
    """
    List all community posts for admin.
    """
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


class AdminHighlightPostAPIView(APIView):
    """
    Toggle highlight status of a post.
    """
    def post(self, request, post_id):
        try:
            post = CommunityPost.objects.get(id=post_id)
        except CommunityPost.DoesNotExist:
            return Response({"error": "Post not found"}, status=status.HTTP_404_NOT_FOUND)

        # Toggle highlight
        post.isHighlighted = not post.isHighlighted
        post.save()
        return Response(
            {"id": post.id, "isHighlighted": post.isHighlighted},
            status=status.HTTP_200_OK
        )
