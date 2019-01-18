# installs Tomcat

tomcatUri="https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz"
tarBall=`echo $tomcatUri |awk -F "/" '{print $NF}'`
tomcatVer=$(echo $tarBall |sed "s/\.tar\.gz//")

yum -y install java-1.8.0-openjdk-devel

useradd -m -U -d /opt/tomcat -s /bin/bash tomcat

wget $tomcatUri
if [ -f $tarBall ] ; then 
  tar -xvzf $tarBall
  mkdir -p /opt/tomcat
  mv $tomcatVer /opt/tomcat/
  ln -s /opt/tomcat/$tomcatVer /opt/tomcat/latest
  chown -R tomcat:tomcat /opt/tomcat
  chmod 755 /opt/tomcat
  chmod +x /opt/tomcat/latest/bin/*.sh
else
  echo "can't download tar file from $tomcatUri. tomcat not installed"
  exit 1
fi

# enable tomcat service
chkconfig --add tomcat
service tomcat start
