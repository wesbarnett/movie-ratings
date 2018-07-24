# To install latest Docker on Ubuntu go to:
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

FROM ubuntu:rolling

MAINTAINER Wes Barnett

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apache2 apache2-dev libapache2-mod-wsgi-py3 build-essential python3 python3-dev python3-pip vim && \
    apt-get clean && \ 
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

COPY ./requirements.txt /var/www/apache-flask/requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir -r /var/www/apache-flask/requirements.txt

COPY ./apache/apache-flask.conf /etc/apache2/sites-available/apache-flask.conf
COPY ./apache/apache-flask-ssl.conf /etc/apache2/sites-available/apache-flask-ssl.conf
RUN a2ensite apache-flask
RUN a2ensite apache-flask-ssl
RUN a2enmod headers
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2dissite 000-default.conf

COPY --chown=www-data ./config.py  /var/www/apache-flask/config.py
COPY --chown=www-data ./run.py /var/www/apache-flask/run.py
COPY --chown=www-data ./app /var/www/apache-flask/app/
COPY --chown=www-data ./data.gz /var/www/apache-flask/data.gz

EXPOSE 80
EXPOSE 443

WORKDIR /var/www/apache-flask

CMD /usr/sbin/apache2ctl -D FOREGROUND
