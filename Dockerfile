FROM nginx:1.15-alpine
LABEL maintainer="Awesometic <awesometic.lab@gmail.com>" \
      description="Lightweight h5ai 0.29 container with Nginx 1.15 & PHP 7 based on Alpine Linux."

RUN apk update
RUN apk add --no-cache \
    bash bash-completion supervisor tzdata \
    php7 php7-fpm php7-session php7-json php7-xml php7-mbstring php7-exif \
    php7-intl php7-gd php7-imagick php7-gmagick php7-zip \
    ffmpeg imagemagick graphicsmagick zip apache2-utils

# Environments
ENV TZ='Europe/Zurich'
ENV HTPASSWD='false'
ENV HTPASSWD_USER='guest'

# Copy configuration files
COPY config/h5ai.conf /etc/nginx/conf.d/h5ai.conf
COPY config/php_set_timezone.ini /etc/php7/conf.d/zzz_custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy h5ai
COPY config/_h5ai /usr/share/h5ai/_h5ai

# Configure Nginx server
RUN sed --in-place=.bak 's/worker_processes  1/worker_processes  auto/g' /etc/nginx/nginx.conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

# Add shell script, patch files
ADD config/init.sh /
ADD config/h5ai.conf.htpasswd.patch /
ADD config/h5ai-root_path.patch /
RUN cd /usr/share/h5ai/_h5ai && patch -p1 -i /h5ai-root_path.patch
# Set entry point file permission
RUN chmod a+x /init.sh

EXPOSE 80
VOLUME [ "/config", "/h5ai" ]
ENTRYPOINT [ "/init.sh" ]
