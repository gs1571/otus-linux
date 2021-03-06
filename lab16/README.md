# Резервное копирование

## Домашнее задание

Создан стенд из двух VM:
* client - для этого сервера организуется backup папки /etc
* server - это сервер является хранилищем backup

Стенд разворачивается через ansible playbook.

Система backup развернута на основе Borg, на VM client находится скрипт ```/etc/scripts/borg-init-etc.sh``` который отправляет данные в repository нв VM server ```/home/borg/storage/lab16-client-etc```. Скрипт запускается через Cron каждые 10 минут.
Настроено:
* дедупликация (часть стандартного функционала Borg)
* сжатие lz4
* шифрование паролем

Стратегия для сохранения backup:
* один backup каждые 10 минут для первых трех backup
* один backup для первых 24 часов в сутках
* один backup для каждого следующего дня
* один backup для следующих четырех недель
* один backup для следующих шести месяцев

Результат работы за два часа после разворачивания стэнда:
```bash
[root@lab16-client vagrant]# borg list borg@server:storage/lab16-client-etc
Enter passphrase for key ssh://borg@server/./storage/lab16-client-etc:
2020-01-17-09-50                     Fri, 2020-01-17 09:50:02 [57abb6d38d81513bef042176fa0c15e611ed1aee31bbbc5ec279e3293af01398]
2020-01-17-10-50                     Fri, 2020-01-17 10:50:02 [7001ccfd75523c0ffd779526a130519ac6753c806e8e937a426be96ee8b7dda4]
2020-01-17-11-30                     Fri, 2020-01-17 11:30:03 [d36a7976b8ee32a35968c4175df5dca8664228d94a1c7af4281ccc8d9759304f]
2020-01-17-11-40                     Fri, 2020-01-17 11:40:02 [3b8fc5b7fb9566f1acbaf63d12e60b378a41e7dace17be8ec965148464fbcb66]
2020-01-17-11-50                     Fri, 2020-01-17 11:50:02 [c398e6716564cbc492f94d54cc9c3eee979230b396f0397a07d373c33347e166]
```

## Полезная информация

