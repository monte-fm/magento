FROM      ubuntu:14.04.2
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install Apche2 && PHP
RUN apt-get update -y
RUN apt-get install -y software-properties-common python-software-properties
RUN apt-get install -y git git-core vim nano mc screen curl unzip
RUN apt-get install -y apache2 libapache2-mod-php5
RUN apt-get install -y wget php5 php5-fpm php5-cli php5-common php5-intl 
RUN apt-get install -y php5-json php5-mysql php5-gd php5-imagick
RUN apt-get install -y php5-curl php5-mcrypt php5-dev php5-xdebug
RUN sudo rm /etc/php5/apache2/php.ini
COPY configs/php.ini /etc/php5/apache2/php.ini
COPY configs/magento-1.9.2.1.zip /home/magento-1.9.2.1.zip
COPY configs/apache2/magento.conf /etc/apache2/sites-available/magento.conf
RUN sudo a2ensite magento.conf

#MySQL install + password
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN sudo apt-get  install -y mysql-server mysql-client

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

#aliases
RUN alias ll='ls -la'

#Add colorful command line
RUN echo "force_color_prompt=yes" >> .bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> .bashrc

#Unzip console magento
RUN unzip -d /var/www /home/magento-1.9.2.1.zip
RUN chown -R www-data:www-data /var/www
RUN rm /home/magento-1.9.2.1.zip

#open ports
EXPOSE 80 22
