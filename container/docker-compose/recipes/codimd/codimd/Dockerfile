FROM hackmdio/hackmd:1.3.1-alpine

#COPY docker-entrypoint.sh /usr/local/bin/

# overwrite HackMD config file
RUN rm -f /files/config.json && rm -f /codimd/config.json
COPY config.json /files/
RUN ln -s /files/config.json /codimd/config.json

# create sqlite data dir
RUN mkdir /files/sqlite && chown codimd /files/sqlite
RUN ln -s /files/sqlite /codimd/sqlite
