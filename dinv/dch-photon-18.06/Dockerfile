# Build certgen in separate container
FROM golang:1.13.1 AS build-env
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
    openssh \
    procps-ng-3.3.15-2.ph2 \
    sed \
    vim \
    nano \
    iptables-1.6.1-4.ph2 > /dev/null 2>&1

#RUN ls -al /etc/
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

ENV TERM=linux \
    NOTVISIBLE="in users profile"

COPY --from=base /temp_chroot /

RUN echo -e VMware@12345\\\nVMware@12345\\\n|passwd && \
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
echo "export VISIBLE=now" >> /etc/profile && \
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' && \
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile
#RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

EXPOSE 2375 2376 22

VOLUME /certs
VOLUME /var/lib/docker

WORKDIR /

ENTRYPOINT [ "/dinv" ]
