#!/bin/bash

#set -e # stop at first error

PERMISSIONS=$(stat -c "%a" /usr/src/app/media)
OWNER=$(stat -c "%U" /usr/src/app/media)
GROUP=$(stat -c "%G" /usr/src/app/media)

echo "username: $USERNAME, groupname: $GROUPNAME"

if [ "$OWNER" != "$USERNAME" ] || [ "$GROUP" != "$GROUPNAME" ]; then
    echo "$OWNER is not equal to $USERNAME or $GROUP is not equal to $GROUPNAME"
    echo "Changing the owner and the group of /usr/src/app/media to $USERNAME and $GROUPNAME"
    chown -R "$USERNAME":"$GROUPNAME" /usr/src/app/media
fi

if [ "$PERMISSIONS" -ne 755 ]; then
    echo "$OWNER is not equal to $USERNAME or $GROUP is not equal to $GROUPNAME"
    echo "Changing the permissions of /usr/src/app/media to 755"
    chmod -R 755 /usr/src/app/media
fi

./scripts/wait-for-it.sh postgres:5432 --timeout=30 --strict -- echo "PostgreSQL is up"

DJANGO_SUPERUSER_PASSWORD=$(cat "$DJANGO_SUPERUSER_PASSWORD_FILE")
DJANGO_SUPERUSER_USERNAME=$(cat "$DJANGO_SUPERUSER_USERNAME_FILE")
DJANGO_SUPERUSER_EMAIL=$(cat "$DJANGO_SUPERUSER_EMAIL_FILE")
DJANGO_SUPERUSER_FIRST_NAME=$(cat "$DJANGO_SUPERUSER_FIRST_NAME_FILE")
DJANGO_SUPERUSER_LAST_NAME=$(cat "$DJANGO_SUPERUSER_LAST_NAME_FILE")

export DJANGO_SUPERUSER_PASSWORD
export DJANGO_SUPERUSER_USERNAME
export DJANGO_SUPERUSER_EMAIL

# create tables from models
echo "Make migrations"
python3 manage.py makemigrations pong_app

echo "LOG_LEVEL is set to $LOG_LEVEL"

if [ "$LOG_LEVEL" = "DEBUG" ]; then
    echo "executing python3 manage.py sqlmigrate pong_app 0001"
    python3 manage.py sqlmigrate pong_app 0001
fi

# Check if there are any unapplied migrations
UNAPPLIED_MIGRATIONS=$(python3 manage.py showmigrations --plan | grep '\[ \]' | wc -l)

if [ "$UNAPPLIED_MIGRATIONS" -gt 0 ]; then
    echo "Applying migrations..."
    python3 manage.py migrate
else
    echo "No migrations to apply."
fi

sleep 5

# Check if superuser exists
SUPERUSER_EXISTS=$(python3 manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists())")

if [ "$SUPERUSER_EXISTS" = "True" ]; then
    echo "Superuser '$DJANGO_SUPERUSER_USERNAME' already exists."
else
    echo "Creating superuser '$DJANGO_SUPERUSER_USERNAME'..."
    python3 manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()

# Create the superuser with the required fields
user = User.objects.create_superuser(
    email='$DJANGO_SUPERUSER_EMAIL',
    username='$DJANGO_SUPERUSER_USERNAME',
    password='$DJANGO_SUPERUSER_PASSWORD',
    first_name='$DJANGO_SUPERUSER_FIRST_NAME',
    last_name='$DJANGO_SUPERUSER_LAST_NAME'
)
user.save()
END
    echo "Superuser '$DJANGO_SUPERUSER_USERNAME' created successfully."
fi

gunicorn -c gunicorn.conf.py pong_site.wsgi:application