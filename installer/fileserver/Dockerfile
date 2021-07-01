# Building:
# from installer directory
# make ova-webserver
# docker build --no-cache -t vmware/fileserver:ova -f fileserver/Dockerfile .

FROM photon:2.0

RUN set -eux; \
    tdnf distro-sync --refresh -y; \
    tdnf install shadow -y; \
    tdnf info installed; \
    tdnf clean all

# Default location for TLS - Specify `-v /host/cert/path:/certs` to use defaults
# Override by providing a volume and values for `-e TLS_CERTIFICATE` and `-e TLS_PRIVATE_KEY`
ENV TLS_CERTIFICATE=/certs/server.crt
ENV TLS_PRIVATE_KEY=/certs/server.key
ENV PORT 80
ENV TLS_PORT 9443

EXPOSE $PORT
EXPOSE $TLS_PORT

COPY bin/ova-webserver /usr/local/bin/

RUN setcap cap_net_bind_service=+ep /usr/local/bin/ova-webserver

# Create a VIC  user to run the application.
RUN groupadd -g 10000 vic && \
    useradd -u 10000 -g vic -s /sbin/nologin -c "VIC user" vic

# Change to the VIC user.
USER vic

ENTRYPOINT /usr/local/bin/ova-webserver --addr ":${TLS_PORT}" --cert "${TLS_CERTIFICATE}" --key "${TLS_PRIVATE_KEY}"
