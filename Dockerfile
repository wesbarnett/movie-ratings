FROM ubuntu:rolling

MAINTAINER Wes Barnett

SHELL ["/bin/bash", "-c"]

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y apache2 apache2-dev libapache2-mod-wsgi build-essential python3 python3-dev python3-pip vim
RUN apt-get clean
RUN apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*

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

COPY ./config.py /var/www/apache-flask/config.py
COPY ./run.py /var/www/apache-flask/run.py
COPY ./app /var/www/apache-flask/app/
COPY ./data.gz /var/www/apache-flask/data.gz

EXPOSE 80
EXPOSE 443

WORKDIR /var/www/apache-flask

CMD /usr/sbin/apache2ctl -D FOREGROUND
