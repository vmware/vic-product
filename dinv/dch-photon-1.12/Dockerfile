# Build dinv in separate container
FROM golang:1.8 AS build-env
ADD . /go/src/dinv
RUN cd /go/src/dinv && go get -v ./... && go build -o dinv && strip dinv

# Build photon base image
FROM photon:latest as base

# Create temporary chroot environment
ENV TEMP_CHROOT /temp_chroot

RUN mkdir /data &&\
    mkdir $TEMP_CHROOT &&\
    mkdir -p $TEMP_CHROOT/var/lib/rpm &&\
    rpm --root $TEMP_CHROOT/ --initdb &&\
    rpm --root $TEMP_CHROOT --import /etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY

RUN echo "> Installing photon base system in chroot, killing output to avoid offending drone" &&\
    tdnf --releasever 1.0 --installroot $TEMP_CHROOT/ --refresh install -y \
    bash-4.3.30-9.ph1 \
    coreutils-8.25-2.ph1 \
    filesystem-1.0-10.ph1 \
    photon-release-1.0-6.ph1 \
    photon-repos-1.0-4.ph1 \
    tdnf-1.1.0-1.ph1 \
    docker-1.12.6-1.ph1 \
    procps-ng-3.3.11-4.ph1 \
    iptables-1.6.0-6.ph1 > /dev/null 2>&1

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

COPY --from=base /temp_chroot /

EXPOSE 2375 2376

VOLUME /certs
VOLUME /var/lib/docker

WORKDIR /

ENTRYPOINT [ "/dinv" ]
