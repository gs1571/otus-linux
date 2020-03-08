# Web сервера

## Домашнее задание

Docker image загружен на Docker Hub в репозиторий gs1571 под именем lab27. Запусть его можно с помощью команды:

docker run -d -p 8000:80 gs1571/lab27

Проверка:
```
$ curl 127.0.0.1:8000/otus.txt
<html>
<head><title>302 Found</title></head>
<body>
<center><h1>302 Found</h1></center>
<hr><center>nginx/1.17.9</center>
</body>
</html>
$ curl -b botcheck=1 127.0.0.1:8000/otus.txt
gs1571
$
```

## Полезная информация

https://stackoverflow.com/questions/26226553/nginx-and-cookie-redirect?rq=1
https://serverfault.com/questions/227742/prevent-port-change-on-redirect-in-nginx