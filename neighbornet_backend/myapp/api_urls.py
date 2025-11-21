from django.urls import path
from myapp.api_views.login_view import *
from myapp.api_views.signup_view import *
from myapp.api_views.login_as_admin_view import *
from myapp.api_views.login_as_police_view import *
from myapp.api_views.profile_view import *
from myapp.api_views.users_community_posts_view import CommunityPostsAPIView
from myapp.api_views.user_create_community_post_view import CreateCommunityPostAPIView

urlpatterns = [
    path('login/', LoginAPIView.as_view(), name='login-api'),
    path('signup/', SignupAPIView.as_view(),name='signup-api'),
    path('admin/login/',LoginasAdminAPIView.as_view(),name='login-as-admin-api'),
    path('police/login/', LoginasPoliceAPIView.as_view(), name='login-as-police-api'),
    path('user/profile/', UserProfileAPIView.as_view(), name='user-profile'),
    path('user/profile/update/', UpdateUserProfileAPIView.as_view(), name='profile-update'),
    path('community-posts/', CommunityPostsAPIView.as_view(), name='community-posts'),
    path('community-posts/create/', CreateCommunityPostAPIView.as_view(), name='create-community-post')
]