FROM photon:2.0

ENV GOVERSION=1.9.2
ENV PATH=$PATH:/root/gsutil:/usr/local/go/bin:/usr/local/google-cloud-sdk/bin/

RUN set -eux; \
    tdnf erase -y toybox; \
    tdnf install -y make tar gzip python2 python-pip sed git diff \
    gawk docker gptfdisk e2fsprogs grub2 parted xz docker util-linux which findutils grub2-pc rpm; \
    curl -L'#' -k https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-200.0.0-linux-x86_64.tar.gz  | tar xzf - -C /usr/local; \
    mkdir -p /root/.gsutil/; \
    /usr/local/google-cloud-sdk/install.sh --quiet; \
    curl -L'#' -k https://storage.googleapis.com/golang/go$GOVERSION.linux-amd64.tar.gz | tar xzf - -C /usr/local; \
    curl -o /usr/bin/jq -L'#' -k https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod +x /usr/bin/jq;

RUN set -eux; \
    curl -OL'#' https://storage.googleapis.com/vic-product-ova-build-deps/qemu-img.xz; \
    xz -d qemu-img.xz; \
    chmod +x qemu-img; \
    mv qemu-img /usr/bin/qemu-img;
