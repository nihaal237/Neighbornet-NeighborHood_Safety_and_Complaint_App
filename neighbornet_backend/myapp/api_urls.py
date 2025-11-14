from django.urls import path
from myapp.api_views.login_view import *
from myapp.api_views.signup_view import *

urlpatterns = [
    path('login/', LoginAPIView.as_view(), name='login-api'),
    path('signup/', SignupAPIView.as_view(),name='signup-api')
]