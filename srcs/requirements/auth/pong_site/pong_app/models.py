from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models


# create a custom user model with all fields and methods
# of the default User model ( inheritance from AbstractUser)
# additional fields and methods can be added later
class User(AbstractUser):
    #groups = models.ManyToManyField(Group, related_name="custom_user_set", blank=True)
    #user_permissions = models.ManyToManyField(Permission, related_name="custom_user_set", blank=True)
    # checks the value for a valid email address using EmailValidator.
    # unique = True: each e-mail in database must be unique.
    # if it's not unqiue: exception IntegrityError
    # The default User model doesn't have the unique parameter
    email = models.EmailField(unique=True)

    # USERNAME_FIELD: email will be used for authentication
    # the default is username
    USERNAME_FIELD = 'email'

    # for image must install pillow and add MEDIA and MEDIA_ROOT in settings.py
    profile_photo = models.ImageField(
        upload_to='images/',
        default='images/default-user-profile-photo.jpg',
        height_field='image_height',
        width_field='image_width',
        max_length=50, # This is the max length of varchar stored in the database, default is 100
    )
    image_height = models.PositiveSmallIntegerField(null=True, blank=True, editable=False)
    image_width = models.PositiveSmallIntegerField(null=True, blank=True, editable=False)

    # A list of the field names that will be prompted for when creating a user via the
    # createsuperuser management command. The user will be prompted to supply a value for
    # each of these fields. It must include any field for which blank is False
    # 'USERNAME_FIELD' and 'password'  must not be included in 'REQUIRED_FIELDS'
    # This means that email should not be included in REQUIRED_FIELDS
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']

