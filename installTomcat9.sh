#!/bin/bash
# installs Tomcat9
# author: Thien P

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
initFile="tomcatInit.d"
tomcat_home="/opt/tomcat"
tomcatPidDir="/opt/tomcat/latest/temp"

javaDevKit="java-1.8.0-openjdk-devel"
tomcatUri="https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz"
tarBall=`echo $tomcatUri |awk -F "/" '{print $NF}'`
tomcatVer=$(echo $tarBall |sed "s/\.tar\.gz//")

#create tomcat user 
useradd -m -U -d $tomcat_home -s /bin/bash tomcat

if [ ! -e $tarBall ]; then 
  if ! [ $(which wget) ]; then yum -y install wget ; fi
  wget $tomcatUri
else echo "*** $tarBall exists. Using $tarBall instead of downloading new one ***"
fi 

if [ -f $tarBall ] ; then 
  #first install java
  yum -y install $javaDevKit
  
  tar -xvzf $tarBall
  mkdir -p $tomcat_home
  mv $tomcatVer $tomcat_home
  ln -s $tomcat_home/$tomcatVer $tomcat_home/latest
  chown -R tomcat:tomcat $tomcat_home
  chmod 755 $tomcat_home
  chmod u+x $tomcat_home/latest/bin/*.sh
  chmod 777 $tomcatPidDir
  
  if [ ! -d $tomcat_home/latest/etc ]; then mkdir $tomcat_home/latest/etc ; fi  #create etc dir
  if [ -f  $scriptDir/$initFile ] ; then 
    cp $scriptDir/$initFile $tomcat_home/latest/etc/tomcat 
    if [ ! -e /etc/init.d/tomcat ]; 
      then ln -s $tomcat_home/latest/etc/tomcat /etc/init.d/tomcat 
           chmod 750 $tomcat_home/latest/etc/tomcat
      else echo " **** /etc/init.d/tomcat already exists.  Don't create soft link. *****"
    fi
    # enable tomcat service
    chkconfig --add tomcat
    echo "**** start tomcat using: service tomcat start *****"
  else
    echo "*** no $scriptDir/$initFile to copy to $tomcat_home/latest/etc/tomcat ****"
  fi 

else
  echo "**** can't download tar file from $tomcatUri. tomcat not installed nor is $java-1.8.0-openjdk-devel ****"
  exit 1
fi

