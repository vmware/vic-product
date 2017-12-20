# Building:
# from vic-product root directory
# docker build --no-cache -t vic-appliance-landing -f installer/landing/Dockerfile .
# docker tag vic-appliance-landing gcr.io/eminent-nation-87317/vic-appliance-landing:1.x
# gcloud auth login
# gcloud docker -- push gcr.io/eminent-nation-87317/vic-appliance-landing:1.x

FROM nginx:alpine

COPY installer/landing/default.conf /etc/nginx/conf.d/default.conf
COPY installer/landing/html/index.html /var/www/index.html

# Specify `-v /host/cert/path:/certs` for TLS certs
# Provide server.crt and server.key
EXPOSE 80 443
