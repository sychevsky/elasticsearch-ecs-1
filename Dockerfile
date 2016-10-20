FROM elasticsearch:2.4
MAINTAINER Martin Halamicek <martin@keboola.com>
WORKDIR /usr/share/elasticsearch
RUN bin/plugin install cloud-aws
COPY docker-entrypoint.sh /docker-entrypoint.sh
