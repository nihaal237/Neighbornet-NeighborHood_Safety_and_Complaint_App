from django.urls import path
from myapp.api_views.login_view import *
from myapp.api_views.signup_view import *
from myapp.api_views.login_as_admin_view import *
from myapp.api_views.login_as_police_view import *
from myapp.api_views.police_update_profile_view import PoliceUpdateProfileAPIView
from myapp.api_views.police_alert_view import PoliceAlertView
from myapp.api_views.police_communitypost_view import *  
from myapp.api_views.admin_alerts_view import *
from myapp.api_views.admin_profile_view import AdminProfileAPIView
from myapp.api_views.admin_manage_users_view import AdminManageUsersAPIView
from myapp.api_views.admin_view_users_view import AdminViewUsersAPIView
from myapp.api_views.admin_user_reports_view import (
    AllReportsAPIView,
    AnonymousReportsAPIView,
    DeletedUserReportsAPIView,
    SpecificUserReportsAPIView
)
from myapp.api_views.admin_highlight_posts_view import (
    AdminListCommunityPostsAPIView,
    AdminHighlightPostAPIView
)

from myapp.api_views.profile_view import*
from myapp.api_views.admin_alerts_view import *
from myapp.api_views.admin_profile_view import AdminProfileAPIView
from myapp.api_views.admin_manage_users_view import AdminManageUsersAPIView
from myapp.api_views.admin_view_users_view import AdminViewUsersAPIView
from myapp.api_views.admin_user_reports_view import (
    AllReportsAPIView,
    AnonymousReportsAPIView,
    DeletedUserReportsAPIView,
    SpecificUserReportsAPIView
)
from myapp.api_views.admin_highlight_posts_view import (
    AdminListCommunityPostsAPIView,
    AdminHighlightPostAPIView
)

from myapp.api_views.profile_view import *
from myapp.api_views.users_community_posts_view import CommunityPostsAPIView
from myapp.api_views.user_create_community_post_view import CreateCommunityPostAPIView
from myapp.api_views.report_views import (
    PoliceReportListAPIView,
    PoliceReportDetailAPIView,
    PoliceUpdateReportStatusAPIView
)


urlpatterns = [
    path('login/', LoginAPIView.as_view(), name='login-api'),
    path('signup/', SignupAPIView.as_view(),name='signup-api'),
    path('admin/login/',LoginasAdminAPIView.as_view(),name='login-as-admin-api'),
    path('police/login/', LoginasPoliceAPIView.as_view(), name='login-as-police-api'),
    path('profile/',UserProfileAPIView.as_view(),name='user-profile'),
    path('police/update-profile/', PoliceUpdateProfileAPIView.as_view(), name='police-update-profile-api'),
    path('api/police/alerts/', PoliceAlertView.as_view(), name='police-alerts'),
    path('profile/update/',UpdateUserProfileAPIView.as_view(),name='profile-update'),
    path('police/reports/', PoliceReportListAPIView.as_view(), name='police-reports-list'),
    path('police/reports/<int:pk>/', PoliceReportDetailAPIView.as_view(), name='police-reports-detail'),
    path('police/reports/<int:pk>/status/', PoliceUpdateReportStatusAPIView.as_view(), name='police-update-report-status'),
    path('admin/alerts/', AdminAlertAPIView.as_view(), name='admin-alerts'),
    path('admin/alerts/<int:pk>/', AdminAlertAPIView.as_view()),  # for DELETE
    path('admin/profile/', AdminProfileAPIView.as_view(), name='admin-profile'),
    path('admin/manage-users/', AdminManageUsersAPIView.as_view(), name='admin-manage-users'),
    path('admin/manage-users/<int:user_id>/', AdminManageUsersAPIView.as_view(), name='admin-delete-user'),
    path('admin/view-users/', AdminViewUsersAPIView.as_view(), name='admin-view-users'),
    path('admin/all-reports/', AllReportsAPIView.as_view(), name='all-reports'),
    path('admin/anonymous-reports/', AnonymousReportsAPIView.as_view(), name='anonymous-reports'),
    path('admin/deleted-user-reports/', DeletedUserReportsAPIView.as_view(), name='deleted-user-reports'),
    path('admin/user-reports/<int:user_id>/', SpecificUserReportsAPIView.as_view(), name='specific-user-reports'),
    path('admin/community-posts/', AdminListCommunityPostsAPIView.as_view(), name='admin-community-posts'),
    path('admin/community-posts/<int:post_id>/highlight/', AdminHighlightPostAPIView.as_view(), name='admin-highlight-post'),
    path('community-posts/', CommunityPostsAPIView.as_view(), name='community-posts'),
    path('community-posts/create/', CreateCommunityPostAPIView.as_view(), name='create-community-post')

]