# Инициализация системы. Systemd и SysV

## Vagrant

В разделе provision добавлены команды по автоматическому выполнению задач домашнего задания.
Все файлы храняться в папке **lab05** в соотвествующих подпапаках.
В конце провижининга выставлена пауза в 1 минуту, что бы дать сервису **watchlog.timer** несколько раз запустить процесс **watchlog.service**.
Последим шагом провижинига является вывод отчета по выполнению домашнего задания.

## Полезная информация

Основные каталоги:
* **/usr/lib/systemd** - основной каталог
* **/usr/lib/systemd/system** - все unit-файлы прилетающие из пакетов
* **/etc/systemd** - конфигурация
* **/etc/systemd/system** - оверлей куда пишет администратор, положенные сюда юнит файлы имеют высший приоритет над юнит-файлами из /usr/lib/
* **/etc/systemd/system/*.wants** - каталоги уровней, в которые кладутся симлинки при **systemctl enable**
* **/etc/sysconfig** - каталог, содержащий переменные

Управление:
```
systemctl status somename.service
systemctl start|stop|(try)-restart|reload somename.service
systemctl reload|reload-or-(try)-restart somename.service
systemctl (re)enable (--now)|disable|mask|unmask somename.service
systemctl daemon-reload
```
