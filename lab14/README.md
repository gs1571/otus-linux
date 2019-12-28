# Пользователи и группы. Авторизация и аутентификация 

## Домашнее задание

1. Зпустить VM с помощью vagrant:

```
vagrant up
```

После старта VM создается два пользователя user_admin и user_noadmin и группа admin. Пользователь user_admin помещается в группу admin. Обоим пользователям назначается пароль 'Otus2019'.

2. Проверка условия PAM: 

*Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников*

```
$ ssh user_admin@192.168.11.150
The authenticity of host '192.168.11.150 (192.168.11.150)' can't be established.
ECDSA key fingerprint is SHA256:lRTl9CP5ri+MU++VP1LvE0cLQ8uDMwxcuE8GGXGmZ6A.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.11.150' (ECDSA) to the list of known hosts.
user_admin@192.168.11.150's password:
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[user_admin@lab14 ~]$ exit
logout
Connection to 192.168.11.150 closed.
$ ssh user_noadmin@192.168.11.150
user_noadmin@192.168.11.150's password:
/usr/local/bin/check_login.sh failed: exit code 1
Connection closed by 192.168.11.150 port 22
```

## Полезная информация

