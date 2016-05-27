FROM      ubuntu:14.04.4
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install Apche2 && PHP && supervisor && postfix
RUN apt-get update 
RUN apt-get upgrade -y
RUN apt-get install -y language-pack-en-base
RUN apt-get install -y software-properties-common python-software-properties
RUN echo "postfix postfix/mailname string magento.hostname.com" | sudo debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Magento E-commerce'" | sudo debconf-set-selections
RUN apt-get install -y supervisor postfix
RUN apt-get install -y git git-core vim nano mc screen curl unzip
RUN apt-get install -y apache2 libapache2-mod-php5 libcurl3
RUN apt-get install -y wget php5 php5-fpm php5-cli php5-common php5-intl 
RUN apt-get install -y php5-json php5-mysql php5-gd php5-imagick
RUN apt-get install -y php5-curl php5-mcrypt php5-dev php5-xdebug
RUN sudo rm /etc/php5/apache2/php.ini
RUN sudo rm -rf /etc/apache2/sites-available/*
COPY configs/php.ini /etc/php5/apache2/php.ini
COPY configs/Magento-CE-2.0.7.zip /home/magento.zip
COPY configs/apache2/magento.conf /etc/apache2/sites-available/magento.conf
RUN sudo a2ensite magento.conf
RUN sudo php5enmod mcrypt

#Install Percona Mysql 5.6 server
RUN wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb
RUN dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb
RUN rm percona-release_0.1-3.$(lsb_release -sc)_all.deb
RUN apt-get update
RUN echo "percona-server-server-5.6 percona-server-server/root_password password root" | sudo debconf-set-selections
RUN echo "percona-server-server-5.6 percona-server-server/root_password_again password root" | sudo debconf-set-selections
RUN apt-get install -y percona-server-server-5.6
COPY configs/mysql/my.cnf /etc/mysql/my.cnf
RUN mysqladmin -uroot -proot create magento

# SSH service
RUN sudo apt-get install -y openssh-server openssh-client
RUN sudo mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc
COPY configs/.bashrc /root/.bashrc

#Install locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

#Add colorful command line
RUN echo "force_color_prompt=yes" >> .bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> .bashrc

#Unzip console magento
RUN rm -rf /var/www/*
RUN unzip -d /var/www /home/magento.zip
RUN chown -R www-data:www-data /var/www
RUN rm /home/magento.zip

#etcKeeper
RUN mkdir -p /root/etckeeper
COPY configs/etckeeper.sh /root/etckeeper.sh
COPY configs/etckeeper-hook.sh /root/etckeeper/etckeeper-hook.sh
RUN chmod +x /root/etckeeper/*.sh
RUN chmod +x /root/*.sh
RUN /root/etckeeper.sh

#open ports
EXPOSE 80 22
