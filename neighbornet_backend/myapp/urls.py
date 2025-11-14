from django.urls import path,include
#from .views import main,login_view  # import home view

urlpatterns = [
    path('', include('myapp.api_urls')),  # your API base path
    
]
