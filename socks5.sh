clear
echo -e "Start Install Socks5 Proxy ..."
username="$1"
password="$2"
yum install -y gcc openldap-devel pam-devel openssl-devel wget
wget http://jaist.dl.sourceforge.net/project/ss5/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz
tar -vzx -f ss5-3.8.9-8.tar.gz
cd ss5-3.8.9/
./configure
make
make install
chmod a+x /etc/init.d/ss5
echo "auth    0.0.0.0/0               -               u" >> /etc/opt/ss5/ss5.conf
echo "permit u	0.0.0.0/0	-	0.0.0.0/0	-	-	-	-	-	" >> /etc/opt/ss5/ss5.conf
echo "$username $password" >> /etc/opt/ss5/ss5.passwd
service ss5 restart
cd ~
clear
echo -e "Install Socks5 Proxy Success"
