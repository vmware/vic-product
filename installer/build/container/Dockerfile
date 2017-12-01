FROM vmware/photon

ENV GOVERSION=1.9.2
ENV PATH=$PATH:/root/gsutil:/usr/local/go/bin

RUN set -eux; \
    tdnf install -y make tar gzip python2 python-pip sed git \
    gawk docker gptfdisk e2fsprogs grub2 parted xz; \
    curl -L'#' -k https://storage.googleapis.com/pub/gsutil.tar.gz | tar xzf - -C $HOME;  \
    curl -L'#' -k https://storage.googleapis.com/golang/go$GOVERSION.linux-amd64.tar.gz | tar xzf - -C /usr/local; \
    curl -o /usr/bin/jq -L'#' -k https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod +x /usr/bin/jq;

RUN set -eux; \
    curl -OL'#' https://storage.googleapis.com/vic-product-ova-build-deps/qemu-img.xz; \
    xz -d qemu-img.xz; \
    chmod +x qemu-img; \
    mv qemu-img /usr/bin/qemu-img;
