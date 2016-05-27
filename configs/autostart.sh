#!/bin/bash
service apache2 start
service ssh start
service mysql start
service supervisor start
service postfix start

/bin/bash -c 'mysqladmin -uroot -proot create magento'

echo "
#!/bin/bash
service apache2 start
service ssh start
service mysql start
service supervisor start
service postfix start
" > /root/autostart.sh

