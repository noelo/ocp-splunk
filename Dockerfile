FROM centos:latest
MAINTAINER noconnor@redhat.com

WORKDIR /tmp

RUN yum update -y && yum install -y wget && yum clean all

RUN wget -O splunkforwarder-6.5.1-f74036626f0c-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=6.5.1&product=universalforwarder&filename=splunkforwarder-6.5.1-f74036626f0c-linux-2.6-x86_64.rpm&wget=true' && rpm -ihv splunkforwarder-6.5.1-f74036626f0c-linux-2.6-x86_64.rpm && rm splunkforwarder-6.5.1-f74036626f0c-linux-2.6-x86_64.rpm

WORKDIR /opt/splunkforwarder/bin/

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

#RUN mkdir -p /tmp/splunk/
#RUN chmod a+rw /tmp/splunk
#ENV SPLUNK_SERVER=
#ENV SPLUNK_MONITOR_LOCN=/tmp

ENTRYPOINT ["/sbin/entrypoint.sh"]
