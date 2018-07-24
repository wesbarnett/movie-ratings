# To install latest Docker on Ubuntu go to:
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

# To build:
#   # docker build -t apache-flask .

# To run:
#   # docker run -v /etc/letsencrypt:/etc/letsencrypt -p 80:80 -p 443:443 -d apache-flask

FROM alpine:3.8

MAINTAINER Wes Barnett

WORKDIR /var/www/apache-flask

COPY requirements.txt .

RUN apk add --update \
    apache2 \
    apache2-dev \
    apache2-mod-wsgi \
    build-base \
    python \
    python-dev \
    py-pip \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r ./requirements.txt \
  && rm -rf /var/cache/apk/*

# Copy and enable apache configurations
COPY ./apache/* /etc/apache2/sites-available/
RUN a2ensite apache-flask apache-flask-ssl && \
    a2enmod rewrite ssl && \
    a2dissite 000-default.conf

# Copy application itself
COPY --chown=www-data ./config.py .
COPY --chown=www-data ./run.py .
COPY --chown=www-data ./app app
COPY --chown=www-data ./data.gz .

# Expose ports for web server
EXPOSE 80
EXPOSE 443

# Run the webserver
CMD /usr/sbin/apache2ctl -D FOREGROUND
