#!/bin/bash

#set -e # stop at first error

PERMISSIONS=$(stat -c "%a" /usr/src/app/media)
OWNER=$(stat -c "%U" /usr/src/app/media)
GROUP=$(stat -c "%G" /usr/src/app/media)

if [ "$OWNER" != "$USERNAME" ] || [ "$GROUP" != "$GROUPNAME" ]; then
    echo "Changing the owner and the group of /usr/src/app/media to $USERNAME and $GROUPNAME"
    chown -R "$USERNAME":"$GROUPNAME" /usr/src/app/media
fi

if [ "$PERMISSIONS" -ne 755 ]; then
    echo "Changing the permissions of /usr/src/app/media to 755"
    chmod -R 755 /usr/src/app/media
fi

./wait-for-it.sh postgres:5432 --timeout=30 --strict -- echo "PostgreSQL is up"

DJANGO_SUPERUSER_PASSWORD=$(cat "$DJANGO_SUPERUSER_PASSWORD_FILE")
DJANGO_SUPERUSER_USERNAME=$(cat "$DJANGO_SUPERUSER_USERNAME_FILE")
DJANGO_SUPERUSER_EMAIL=$(cat "$DJANGO_SUPERUSER_EMAIL_FILE")
DJANGO_SUPERUSER_FIRST_NAME=$(cat "$DJANGO_SUPERUSER_FIRST_NAME_FILE")
DJANGO_SUPERUSER_LAST_NAME=$(cat "$DJANGO_SUPERUSER_LAST_NAME_FILE")

export DJANGO_SUPERUSER_PASSWORD
export DJANGO_SUPERUSER_USERNAME
export DJANGO_SUPERUSER_EMAIL

# create tables from models
python3 manage.py makemigrations pong_app

echo "LOG_LEVEL is set to $LOG_LEVEL"

if [ "$LOG_LEVEL" = "DEBUG" ]; then
    echo "executing python3 manage.py sqlmigrate pong_app 0001"
    python3 manage.py sqlmigrate pong_app 0001
fi

# check migrations
#python3 manage.py sqlmigrate pong_app 0001

# save migrations to db
python3 manage.py migrate

sleep 5

# create a superuser
# must specify all because of required_fields in the custom user model
python3 manage.py createsuperuser --noinput \
                                  --email $DJANGO_SUPERUSER_EMAIL \
                                  --username $DJANGO_SUPERUSER_USERNAME \
                                  --first_name $DJANGO_SUPERUSER_FIRST_NAME \
                                  --last_name $DJANGO_SUPERUSER_LAST_NAME \

# declare the superuser's password
python3 manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
user = User.objects.get(username='$DJANGO_SUPERUSER_USERNAME')
user.set_password('$DJANGO_SUPERUSER_PASSWORD')
user.save()
END

gunicorn -c gunicorn.conf.py pong_site.wsgi:application