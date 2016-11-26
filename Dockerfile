FROM elasticsearch:5.0.1
MAINTAINER Madhukar Thota <madhukar.thota@gmail.com>
WORKDIR /usr/share/elasticsearch

# Install EC2 Discovery Plugin
RUN elasticsearch-plugin install --batch discovery-ec2

COPY docker-entrypoint.sh /docker-entrypoint.sh
