# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.

## URLS

### tmux
- [Краткая шпаргалка по tmux (менеджеру терминалов)](https://habr.com/ru/post/126996/)
- [Терминальный сервер для админа; Ни единого SSH-разрыва](https://habr.com/ru/company/vdsina/blog/472746/)

### git
- [.gitignore](https://www.atlassian.com/git/tutorials/saving-changes/gitignore)

### markdown
- [How to use Markdown for writing Docs](https://docs.microsoft.com/en-us/contribute/how-to-write-use-markdown)

## books
How linux works 
UNIX AND LINUX SYSTEM ADMINISTRATION HANDBOOK by Evi Nemeth 

## Parallel vagrant up

vagrant status | awk 'BEGIN{ tog=0; } /^$/{ tog=!tog; } /./ { if(tog){print $1} }' | xargs -P10 -I {} vagrant up {} --no-provision