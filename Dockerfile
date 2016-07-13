FROM resin/raspberrypi-node:5.3.0-slim-20160114


ENV DEBIAN_FRONTEND noninteractive

# Enable systemd
ENV INITSYSTEM on

#Add Java repos
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

#Add unifi repos
RUN echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/unifi.list
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50

RUN apt-get update

RUN echo "Europe/London" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -y locales apt-utils
RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen
ENV LANGUAGE en_US:en
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN dpkg-reconfigure locales


#Configure Java installer
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | \
		debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | \
		debconf-set-selections


RUN apt-get install -y --no-install-recommends \
		python \
		build-essential \
		mongodb \
		oracle-java8-installer \
		unifi \

	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /datadb


#Unifi config
RUN sed -i 's@^set_java_home$@#set_java_home\n\n# Use Oracle Java 8 JVM instead.\nJAVA_HOME=/usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt@' /usr/lib/unifi/bin/unifi.init
RUN cp /lib/systemd/system/unifi.service /etc/systemd/system/
RUN sed -i '/^\[Service\]$/a Environment=JAVA_HOME=/usr/lib/jvm/jdk-8-oracle-arm-vfp-hflt' /etc/systemd/system/unifi.service
#Create new user
RUN sudo useradd -r unifi
RUN sudo sed -i '/^\[Service\]$/a User=unifi' /etc/systemd/system/unifi.service

COPY package.json .

RUN npm install

COPY . .

EXPOSE 8080

CMD bash start.sh
