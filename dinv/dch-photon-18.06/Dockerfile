# Build certgen in separate container
FROM golang:1.8 AS build-env
# copy the non-version specific files first so version specific can overwrite
ADD . /go/src/dinv
ADD ./dch-photon-18.06/* /go/src/dinv/
RUN cd /go/src/dinv && go get -v ./... && go build -o dinv && strip dinv

# Build photon base image
FROM photon:2.0 as base

# Create temporary chroot environment
ENV TEMP_CHROOT /temp_chroot

RUN mkdir /data &&\
    mkdir $TEMP_CHROOT &&\
    mkdir -p $TEMP_CHROOT/var/lib/rpm &&\
    tdnf install -y rpm &&\
    rpm --root $TEMP_CHROOT/ --initdb &&\
    rpm --root $TEMP_CHROOT --import /etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY

RUN echo "> Installing photon base system in chroot, killing output to avoid offending drone" &&\
    tdnf --releasever 2.0 --installroot $TEMP_CHROOT/ --refresh install -y \
    bash-4.4.12-3.ph2 \
    photon-release-2.0-2.ph2 \
    photon-repos-2.0-2.ph2 \
    tdnf-1.2.3-4.ph2 \
    docker-18.06.2-3.ph2 \
    procps-ng-3.3.15-2.ph2 \
    iptables-1.6.1-4.ph2 > /dev/null 2>&1

RUN cp /etc/resolv.conf $TEMP_CHROOT/etc/
RUN mkdir $TEMP_CHROOT/certs
COPY --from=build-env /go/src/dinv/dinv $TEMP_CHROOT/

# Cleanup
RUN cd $TEMP_CHROOT && rm -rf usr/src/ && rm -rf home/* && rm -rf var/log/*

# Build rootfs
RUN cd $TEMP_CHROOT && cp -pr etc/skel/. root/.

# Build container
FROM scratch

LABEL maintainer "fabio@vmware.com"

ENV TERM linux

COPY --from=base /temp_chroot /

EXPOSE 2375 2376

VOLUME /certs
VOLUME /var/lib/docker

WORKDIR /

ENTRYPOINT [ "/dinv" ]
