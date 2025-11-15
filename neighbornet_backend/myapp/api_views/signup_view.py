from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
# Import your Custom User model correctly
from django.contrib.auth import get_user_model 

User = get_user_model() # Recommended way to get the active User model

class SignupAPIView(APIView):
    def post(self, request):
        data = request.data
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        phoneNo = data.get('phoneNo') 
        address = data.get('address')   

        # Check for required fields and existing email (since it's unique)
        if not all([username, email, password]):
            return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)
        
        if User.objects.filter(email=email).exists():
            return Response({'error': 'Email already registered'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # 1. Create the User object, passing ALL fields directly
            user = User.objects.create_user(
                username=username, 
                email=email, 
                password=password,
                phoneNo=phoneNo,   # <-- Saved directly to the Custom User model
                address=address    # <-- Saved directly to the Custom User model
            )

            return Response({'message': 'User created successfully'}, status=status.HTTP_201_CREATED)
        
        except Exception as e:
            # Handle any potential errors (e.g., if username is unexpectedly empty)
            return Response({'error': f'Registration failed: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)