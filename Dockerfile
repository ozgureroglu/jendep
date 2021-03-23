# Set the base image to use to Ubuntu
FROM jenkins/jenkins

# become root 
USER root

# lets add docker-compose to this jenkins image
RUN apt update && apt install curl
RUN apt install -y python-pip
RUN apt install -y maven
RUN apt install -y docker-compose
RUN echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main'>>/etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt update && apt install -y ansible

# Stop the setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Dhudson.footerURL=http://inavitas.com"

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_OPTS --argumentsRealm.passwd.admin=admin --argumentsRealm.roles.user=admin --argumentsRealm.roles.admin=admin

COPY jenkins-pass.txt /run/secrets/jenkins-pass.txt
COPY jenkins-user.txt /run/secrets/jenkins-user.txt
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY ssh.tgz /root/


# jenkins user after the task
USER jenkins
RUN jenkins-plugin-cli --plugins -f /usr/share/jenkins/ref/plugins.txt
USER root
RUN git config --global http.sslverify false
RUN cd /root/ && tar -xvf ssh.tgz && rm ssh.tgz

COPY credentials.tgz /usr/share/jenkins/ref/
COPY full.tar /usr/share/jenkins/ref/
RUN cd /usr/share/jenkins/ref/ && tar -xvf credentials.tgz && mkdir jenkins-backup && mv full.tar jenkins-backup && cd jenkins-backup && tar -xvf full.tar


