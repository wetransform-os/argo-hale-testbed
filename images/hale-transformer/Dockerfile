FROM wetransform/hale-cli:4.2.0-SNAPSHOT

ENV DATA_DIR /opt/data

# Install required utilities and set up folders
RUN apt-get update -y && \
  apt-get install -y zip unzip curl file && \
  apt-get autoremove -y && \
  apt-get clean && \
  mkdir -p $DATA_DIR

COPY success.groovy /success.groovy

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh
