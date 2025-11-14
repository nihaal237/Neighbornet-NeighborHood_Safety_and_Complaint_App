from django.db import models
from django.contrib.auth import authenticate
from django.contrib.auth.models import AbstractUser

# Custom User Model

class User(AbstractUser): #inherits from AbstractUser so we get hashed passwords and full authentication
    """
    Extends Django's built-in user model with additional fields.
    """

    email = models.EmailField(unique=True)  
    phoneNo = models.CharField(max_length=15, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)

    USERNAME_FIELD = 'email' #overrides username field so we login with email instead 
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.username
    
    def save(self, *args, **kwargs): #handles default username from email
     if not self.username:
        self.username = self.email.split('@')[0]  # simple default from email
     super().save(*args, **kwargs)
    

# Admin model — linked to a user account, but doesn't delete if user is removed

class Admin(models.Model):
    user = models.OneToOneField( User, on_delete=models.SET_NULL, null=True, blank=True,related_name="admin_profile" )

    def __str__(self):
        return f"Admin: {self.user.username if self.user else 'Unlinked Admin'}"



# Local Police Authority

class LocalPoliceAuthority(models.Model):
    user = models.OneToOneField( User, on_delete=models.SET_NULL, null=True,blank=True, related_name="police_profile")
    stationName = models.CharField(max_length=255)
    contactInfo = models.CharField(max_length=255)
    areaAssigned = models.CharField(max_length=255)

    def __str__(self):
        return self.stationName



# Report and Evidence

class Report(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    dateTime = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=100, default="Pending")
    location = models.CharField(max_length=255)
    isAnonymous = models.BooleanField(default=False)

    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    assignedPolice = models.ForeignKey(LocalPoliceAuthority, on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return f"{self.title} ({self.status})"


class Evidence(models.Model):
    report = models.ForeignKey(
        Report,
        related_name='evidences',
        on_delete=models.CASCADE  # Delete all evidence if report is deleted
    )
    file = models.FileField(upload_to='evidences/')
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Evidence for {self.report.title}"



# Community Posts

class CommunityPost(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)  #  keep post even if user is deleted
    content = models.TextField()
    dateTime = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        username = self.user.username if self.user else "Deleted User"
        return f"Post by {username}"


# Alerts

class PriorityType(models.TextChoices):
    LOW = 'Low', 'Low'
    MID = 'Mid', 'Mid'
    HIGH = 'High', 'High'


class Alert(models.Model):
    title = models.CharField(max_length=255)
    message = models.TextField()
    dateTime = models.DateTimeField(auto_now_add=True)
    priority = models.CharField( max_length=10,choices=PriorityType.choices,default=PriorityType.LOW)
    highlighted = models.BooleanField(default=False)
    users = models.ManyToManyField(User, related_name='alerts', blank=True)

    def __str__(self):
        return f"[{self.priority}] {self.title}"
