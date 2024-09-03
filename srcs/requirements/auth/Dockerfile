FROM debian:bullseye-slim

# www-data group is already created because of the shared volume with the host and nginx
ENV GROUPNAME=www-data

# pong will be the name of the new created user
ENV USERNAME=pong

# Specifies where pip can install packages if a non-root user uses pip
ENV PATH="/home/$USERNAME/.local/lib:$PATH"
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

# Specifies the default time zone
ENV TZ="Europe/Zurich"

# Create folder for pip packages installed as non root user
RUN mkdir -p /home/$USERNAME/.local/lib  \
             /home/$USERNAME/.local/bin  \
             /logs \
             /usr/src/app

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY pong_site/ ./
COPY conf/gunicorn.conf.py ./
COPY scripts/init.sh ./
COPY scripts/generate_certs.sh ./
COPY scripts/wait-for-it.sh ./

# Create group and user, adjust ownership
RUN useradd $USERNAME &&  \
    usermod -a -G $GROUPNAME $USERNAME && \
    chown -R $USERNAME:$GROUPNAME /home/$USERNAME/.local/lib  \
                                  /home/$USERNAME/.local/bin  \
                                  /logs  \
                                  /usr/src/app

RUN chmod +x init.sh \
             wait-for-it.sh \
             generate_certs.sh

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3 \
                   python3-pip \
                   # for postgres test use: psql -h postgres -U your_username -d your_database -W
                   postgresql-client \
                   # for ping test: ping postgres
                   iputils-ping \
                   # for api test
                   curl

RUN sh generate_certs.sh

USER $USERNAME

RUN pip3 install --no-cache-dir -r requirements.txt && \
    gunicorn --version


EXPOSE 8000

#CMD ["gunicorn", "-c", "gunicorn.conf.py" , "pong_site.wsgi:application"]

CMD [ "sh", "/usr/src/app/init.sh" ]
