FROM elasticsearch:5.0.0-rc1
MAINTAINER Madhukar Thota <madhukar.thota@gmail.com>
WORKDIR /usr/share/elasticsearch
RUN elasticsearch-plugin install discovery-ec2
COPY docker-entrypoint.sh /docker-entrypoint.sh
