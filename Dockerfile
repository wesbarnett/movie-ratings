# To install latest Docker on Ubuntu go to:
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

# To build:
#   # docker build -t apache-flask .

# To run:
#   # SECRET_KEY=$(python -c 'import os; print(os.urandom(16))')
#   # docker run -v /etc/letsencrypt:/etc/letsencrypt -p 80:80 -p 443:443 -e SECRET_KEY='$SECRET_KEY' -d apache-flask

FROM ubuntu:rolling

MAINTAINER Wes Barnett

WORKDIR /var/www/apache-flask

# Use Python3 and install Python requirements
COPY requirements.txt .

# Update system and install needed packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        apache2 \
        apache2-dev \
        build-essential \
        libapache2-mod-wsgi-py3 \
        python3-dev \
        python3-pip \
        python3-setuptools\
        vim && \
    apt-get clean && \ 
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ./requirements.txt

# Copy and enable apache configurations
COPY ./apache/* /etc/apache2/sites-available/
RUN a2ensite apache-flask apache-flask-ssl && \
    a2enmod rewrite ssl && \
    a2dissite 000-default.conf

# Copy application itself
COPY --chown=www-data application application

# Expose ports for web server
EXPOSE 80 443

# Run the webserver
CMD /usr/sbin/apache2ctl -D FOREGROUND
