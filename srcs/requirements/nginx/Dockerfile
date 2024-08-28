# Nginx Dockerfile
FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      nginx \
      openssl \
      gettext

COPY scripts/entrypoint.sh /
COPY conf/nginx.conf /etc/nginx/nginx.conf.template
COPY scripts/generate_certs.sh /etc/nginx/certs/generate_certs.sh

RUN chmod +x ./entrypoint.sh \
              /etc/nginx/certs/generate_certs.sh && \
    sh /etc/nginx/certs/generate_certs.sh

# Expose ports for HTTP and HTTPS
EXPOSE 80
EXPOSE 443

CMD ["./entrypoint.sh"]

