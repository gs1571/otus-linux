# Запусть VM с Linux Centos 7

## Обновить ядро

Обновляем с 3.10.0-957.12.2.el7.x86_64 до 5.3.8-1.el7.elrepo.x86_64

```bash
[vagrant@kernel-update ~]$ uname -r
5.3.8-1.el7.elrepo.x86_64
```

## Сделать через packet новый box Vagrant

```bash
gsol@cray-mini:~/dev/otus/otus-linux/lab01/packer$ packer build centos.json
centos-7.7 output will be in this color.
[..cut..]
==> Builds finished. The artifacts of successful builds are:
--> centos-7.7: 'virtualbox' provider box: centos-7.7.1908-kernel-5-x86_64-Minimal.box

gsol@cray-mini:~/dev/otus/otus-linux/lab01/test$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
[..cut..]
    default: /vagrant => /Users/gsol/dev/otus/otus-linux/lab01/test
Vagrant was unable to mount VirtualBox shared folders. This is usually
because the filesystem "vboxsf" is not available. This filesystem is
made available via the VirtualBox Guest Additions and kernel module.
Please verify that these guest additions are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant

The error output from the command was:

mount: unknown filesystem type 'vboxsf'
[..cut..]

gsol@cray-mini:~/dev/otus/otus-linux/lab01/test$ vagrant ssh
Last login: Sat Nov  2 10:26:37 2019 from 10.0.2.2
[vagrant@localhost ~]$ uname -r
5.3.8-1.el7.elrepo.x86_64
```

## Залить образ на Vagrant Cloud

```bash
gsol@cray-mini:~/dev/otus/otus-linux/lab01/packer$ vagrant cloud publish --release gs1571/centos-7-5 1.0 virtualbox centos-7.7.1908-kernel-5-x86_64-Minimal.box 
You are about to publish a box on Vagrant Cloud with the following options:
gs1571/centos-7-5:   (v1.0) for provider 'virtualbox'
Automatic Release:     true
Do you wish to continue? [y/N] y
==> cloud: Creating a box entry...
==> cloud: Creating a version entry...
==> cloud: Creating a provider entry...
==> cloud: Uploading provider with file /Users/gsol/dev/otus/otus-linux/lab01/packer/centos-7.7.1908-kernel-5-x86_64-Minimal.box
==> cloud: Releasing box...
Complete! Published gs1571/centos-7-5
tag:             gs1571/centos-7-5
username:        gs1571
name:            centos-7-5
private:         false
downloads:       0
created_at:      2019-11-03T11:00:13.462+03:00
updated_at:      2019-11-03T11:27:27.479+03:00
current_version: 1.0
providers:       virtualbox
old_versions:    ...
```

## Вопросы

- Собрать ядро из исходников

```
yum install -y ncurses-devel make gcc bc bison flex elfutils-libelf-devel openssl-devel grub2 wget
cd /usr/src/
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz
tar -xf linux-5.3.8.tar.xz
cd linux-5.3.8
cp -v /boot/config-3.10.0-957.12.2.el7.x86_64 /usr/src/linux-5.3.8/.config
make -j 2
make -j 2 modules
make install
make modules_install
```

- Добавить поддержку VirtualBox FileShare