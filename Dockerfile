# To install latest Docker on Ubuntu go to:
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

FROM ubuntu:rolling

MAINTAINER Wes Barnett

WORKDIR /var/www/apache-flask

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apache2 apache2-dev libapache2-mod-wsgi-py3 build-essential python3 python3-dev python3-pip vim && \
    apt-get clean && \ 
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir -r ./requirements.txt

COPY ./apache/* /etc/apache2/sites-available/
RUN a2ensite apache-flask apache-flask-ssl
RUN a2enmod rewrite ssl
RUN a2dissite 000-default.conf

COPY --chown=www-data ./config.py .
COPY --chown=www-data ./run.py .
COPY --chown=www-data ./app .
COPY --chown=www-data ./data.gz .

EXPOSE 80
EXPOSE 443

CMD /usr/sbin/apache2ctl -D FOREGROUND
