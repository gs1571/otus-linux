# Динамический веб контент

## Домашнее задание

Сетенд состоит из одного сервера, который конфигурируется через ansible playbook.
На сервере поднят nginx и создано четыре сайта:
* base - содержит индексный файл (порт 8080);
* wp - WordPress запущенный на php-fpm (порт 8081);
* flask - простое приложение Hello World! запущенное на flask (порт 8082);
* nodejs - простое приложение из Интернета написанное на NodeJS (порт 8083);

Все порты проброшены с локальной машины, индексный файл доступен по адресу - [localhost:8080](http://localhost:8080)

## Полезная информация

### WordPress/php-fpm
* https://linuxize.com/post/how-to-install-wordpress-with-nginx-on-centos-7/

### flask
* https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-uwsgi-and-nginx-on-centos-7

### NodeJS
* https://www.phusionpassenger.com/library/walkthroughs/deploy/nodejs/ownserver/nginx/oss/el7/deploy_app.html