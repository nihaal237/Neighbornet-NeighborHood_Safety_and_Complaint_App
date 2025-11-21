
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
        try:
            # Make sure field names match your model: 'isHighlighted' and 'dateTime'
            posts = CommunityPost.objects.all().order_by('-isHighlighted', '-dateTime')
            serializer = CommunityPostSerializer(posts, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response(
                {"error": f"Could not fetch posts: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
