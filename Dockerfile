FROM ubuntu:14.04
MAINTAINER Andriy Kopachevskyy <andriy.kopachevskyy@semilimes.com>
LABEL vendor="Semilimes Inc."

# Update package repository. Install Dependencies
RUN apt-get update && \
   apt-get -y install language-pack-en zsh htop nano vim build-essential python-pip python-dev python-lxml libxml2-dev libxslt1-dev python-bcrypt libpq-dev unoconv postgresql postgresql-server-dev-all libsasl2-dev libssl-dev libffi-dev libldap2-dev python-setuptools npm wget curl nginx git && \
   easy_install pip


RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN pip install virtualenv
RUN mkdir /root/venv
RUN virtualenv /root/venv
RUN source /root/venv/bin/activate
RUN ln -s /usr/bin/nodejs /usr/bin/node


RUN /root/venv/bin/pip install psycopg2
RUN npm install -g gulp gulp-cli bower n --force

COPY trytond /home/app/trytond
WORKDIR /home/app/trytond
RUN /root/venv/bin/python /home/app/trytond/setup.py install

COPY modules.txt /home/app/
RUN /root/venv/bin/pip install -r /home/app/modules.txt

COPY trytond.conf /home/app
COPY tryton_db.sqlite /home/app

COPY sao /home/app/sao
WORKDIR /home/app/sao
RUN npm install
RUN n stable
RUN bower install --allow-root --force
RUN npm install -g grunt
RUN grunt

RUN apt install sqlite3



ENTRYPOINT /root/venv/bin/trytond -c /home/app/trytond.conf