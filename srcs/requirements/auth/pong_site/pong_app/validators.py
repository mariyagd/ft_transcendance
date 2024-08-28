from django.core.exceptions import ValidationError

def validate_password_match(new_password, new_password2):
    if new_password != new_password2:
        raise ValidationError("The two passwords don't match.")
    return new_password