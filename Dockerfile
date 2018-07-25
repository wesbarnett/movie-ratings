# To install latest Docker on Ubuntu go to:
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

# To build:
#   # docker build -t apache-flask .

# To run:
#   # docker run -v /etc/letsencrypt:/etc/letsencrypt -p 80:80 -p 443:443 -e SECRET_KEY="$(python3 -c 'import os; print(os.urandom(16))')" -d apache-flask

FROM wesbarnett/apache-flask:bionic-x86_64

MAINTAINER Wes Barnett

# Copy and enable apache configurations
COPY ./apache/* /etc/apache2/sites-available/
RUN a2ensite apache-flask apache-flask-ssl

# Copy application itself, changing ownership of files
COPY --chown=www-data application /var/www/apache-flask/application
