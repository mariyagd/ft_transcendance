from django.contrib.auth.models import AbstractUser
from django.db import models


# create a custom user model with all fields and methods
# of the default User model ( inheritance from AbstractUser)
# additional fields and methods can be added later
class User(AbstractUser):
    # checks the value for a valid email address using EmailValidator.
    # unique = True: each e-mail in database must be unique.
    # if it's not unqiue: exception IntegrityError
    # The default User model doesn't have the unique parameter
    email = models.EmailField(unique=True)

    # USERNAME_FIELD: email will be used for authentication
    # the default is username
    USERNAME_FIELD = 'email'

    # for image must install pillow and add MEDIA and MEDIA_ROOT in settings.py
    profile_photo = models.ImageField(upload_to='images/', default='images/default-user-profile-photo.jpg')

    # 'USERNAME_FIELD' for a custom user model must not be included in 'REQUIRED_FIELDS'
    # This means that email should not be included in REQUIRED_FIELDS
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']
