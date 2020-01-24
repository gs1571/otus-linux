# Сбор и анализ логов

## Домашнее задание

Стенд состоит из двух VM:
* web - сервер с nginx, является источником логов
* log - сервер - коллектор логов 

Логи на VM log храняться в journald, для их просмотра можно использовать команду ```journalctl -D /var/log/journal/remote/ --follow```

Для запуска стенда используется vagrnat, файл стенда - [Vagrantfile](Vagrantfile). Стенд конфигурируется через [ansible-playbook](provision.yml)

## Полезная информация

* [Defining Audit Rules](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-defining_audit_rules_and_controls)  
* [NGINX Documentation: Configuring Logging](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/)
* [No way to restart auditd](https://bugzilla.redhat.com/show_bug.cgi?id=973697)  
