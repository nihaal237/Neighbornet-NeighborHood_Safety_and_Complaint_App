from django.urls import path, include

urlpatterns = [
    #path('admin/', admin.site.urls),
    path('', include('myapp.api_urls')),  # root URL will now match /main/
]
