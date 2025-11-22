from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from myapp.models import CommunityPost

class CreateCommunityPostAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        content = request.data.get('content', '').strip()

        if not content:
            return Response({"error": "Content cannot be empty."}, status=400)

        post = CommunityPost.objects.create(
            user=request.user,
            content=content,
        )

        return Response({
            "id": post.id,
            "content": post.content,
            "isHighlighted": post.isHighlighted,
            "dateTime": post.dateTime,
            "username": request.user.username,
        }, status=201)
