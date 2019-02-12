#!/bin/bash
# installs Tomcat9
# author: Thien P

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
initFile="tomcatInit.d"
CATALINA_HOME="/opt/tomcat"
tomcatPidDir="/opt/tomcat/temp"

javaDevKit="java-1.8.0-openjdk-devel"
tomcatUri="http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz"
tarBall=`echo $tomcatUri |awk -F "/" '{print $NF}'`
tomcatVer=$(echo $tarBall |sed "s/\.tar\.gz//")

#create tomcat user 
#useradd -m -U -s /bin/bash tomcat
useradd -m -U -s /bin/false tomcat

if [ ! -e $tarBall ]; then 
  if ! [ $(which wget) ]; then yum -y install wget ; fi
  wget $tomcatUri
else echo "*** $tarBall exists. Using $tarBall instead of downloading new one ***"
fi 

if [ -f $tarBall ] ; then 
  #first install java
  yum -y install $javaDevKit
  
  tar -xvzf $tarBall
  mkdir -p $CATALINA_HOME
  if [ ! -d $CATALINA_HOME ]; then mv $CATALINA_HOME $CATALINA_HOME.old ; fi
  mv $tomcatVer tomcat; mv tomcat /opt/
  chown -R tomcat:tomcat $CATALINA_HOME
  chmod 755 $CATALINA_HOME
  chmod u+x $CATALINA_HOME/bin/*.sh
  chmod 777 $tomcatPidDir
  
  if [ -f  $scriptDir/$initFile ] ; then 
    if [ ! -d $CATALINA_HOME/etc ]; then mkdir $CATALINA_HOME/etc ; fi  #create etc dir
    cp $scriptDir/$initFile $CATALINA_HOME/etc/tomcat 
    chmod 750 /opt/tomcat/etc/tomcat
    if [ ! -e /etc/init.d/tomcat ]; 
      then ln -s $CATALINA_HOME/etc/tomcat /etc/init.d/tomcat 
      else echo " **** /etc/init.d/tomcat already exists.  Don't create soft link. *****"
    fi
    # enable tomcat service
    chkconfig --add tomcat
    echo "**** start tomcat using: service tomcat start *****"
  else
    echo "*** no $scriptDir/$initFile to copy to $CATALINA_HOME/etc/tomcat ****"
  fi 

else
  echo "**** can't download tar file from $tomcatUri. tomcat not installed nor is $java-1.8.0-openjdk-devel ****"
  exit 1
fi

