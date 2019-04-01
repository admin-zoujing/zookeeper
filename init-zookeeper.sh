#! /bin/bash
#centos7.4源码编译zookeeper安装脚本

chmod -R 777 /usr/local/src/zookeeper
#1、时间时区同步，修改主机名
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate cn.pool.ntp.org
hwclock --systohc
echo "*/30 * * * * root ntpdate -s 3.cn.poop.ntp.org" >> /etc/crontab

sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux 
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux
setenforce 0 && systemctl stop firewalld && systemctl disable firewalld 
setenforce 0 && systemctl stop iptables && systemctl disable iptables

rm -rf /var/run/yum.pid 
rm -rf /var/run/yum.pid
#一、-----------------------------------安装zookeeper--------------------------------------------------
#1）解决依赖关系
#yum -y install pcre-devel openssl-devel make gcc expat-devel
#cd /usr/local/src/zookeeper/rpm
#rpm -ivh /usr/local/src/zookeeper/rpm/*.rpm --force --nodeps
#2)编译安装zookeeper
groupadd zookeeper
useradd -g zookeeper -s /sbin/nologin zookeeper
cd /usr/local/src/zookeeper
mkdir -pv /usr/local/zookeeper
tar -zxvf zookeeper-3.4.11.tar.gz -C /usr/local/zookeeper
cd /usr/local/zookeeper/zookeeper-3.4.11/conf
cp zoo_sample.cfg zoo.cfg
mkdir -pv /usr/local/zookeeper/zookeeper-3.4.11/{data,logs}

sed -i 's|dataDir=/tmp/zookeeper|dataDir=/usr/local/zookeeper/zookeeper-3.4.11/data|' /usr/local/zookeeper/zookeeper-3.4.11/conf/zoo.cfg
sed -i '/dataDir=\/usr\/local\/zookeeper\/zookeeper-3.4.11\/data/a\dataLogDir=\/usr\/local\/zookeeper\/zookeeper-3.4.11\/logs' /usr/local/zookeeper/zookeeper-3.4.11/conf/zoo.cfg

#二进制程序：
echo 'export PATH=/usr/local/zookeeper/zookeeper-3.4.11/bin:$PATH' > /etc/profile.d/zookeeper.sh 
source /etc/profile.d/zookeeper.sh
#头文件输出给系统：
#ln -sv /usr/local/apache/include /usr/include/httpd
#库文件输出：
echo '/usr/local/zookeeper/zookeeper-3.4.11/lib' > /etc/ld.so.conf.d/zookeeper.conf
#让系统重新生成库文件路径缓存
ldconfig
#导出man文件：
#echo 'MANDATORY_MANPATH                       /usr/local/apache/man' >> /etc/man_db.conf
source /etc/profile.d/zookeeper.sh 

#设置开机自启动
cat >> /usr/lib/systemd/system/zookeeper.service <<EOF
[Unit]
Description=The Zookeeper Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:zookeeper(8)

[Service]
Type=forking
ExecStart=/usr/local/zookeeper/zookeeper-3.4.11/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/zookeeper-3.4.11/bin/zkServer.sh stop
ExecRestart=/usr/local/zookeeper/zookeeper-3.4.11/bin/zkServer.sh restart
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
chown -Rf zookeeper:zookeeper /usr/local/zookeeper
systemctl daemon-reload
systemctl enable zookeeper.service
systemctl restart zookeeper.service

ps aux |grep zookeeper
sleep 5
rm -rf /usr/local/src/zookeeper







