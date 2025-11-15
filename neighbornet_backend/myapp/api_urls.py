from django.urls import path
from myapp.api_views.login_view import *
from myapp.api_views.signup_view import *
from myapp.api_views.login_as_admin_view import *
from myapp.api_views.login_as_police_view import *

urlpatterns = [
    path('login/', LoginAPIView.as_view(), name='login-api'),
    path('signup/', SignupAPIView.as_view(),name='signup-api'),
    path('admin/login/',LoginasAdminAPIView.as_view(),name='login-as-admin-api'),
    path('police/login/', LoginasPoliceAPIView.as_view(), name='login-as-police-api')
]