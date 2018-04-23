# Nightly Tests

## Running Locally

Set `test_secrets.yml` values

```
NIMBUS_USER=
NIMBUS_PASSWORD=
NIMBUS_GW=
DRONE_BUILD_NUMBER=1
DOMAIN=eng.vmware.com
```

Run desired test suite

```
docker run --rm -v /go/src/github.com/vmware/vic-product:/go --env-file test_secrets.yml gcr.io/eminent-nation-87317/vic-integration-test:1.46 pybot tests/manual-test-cases/Group6-OVA-TLS
```

If selenium grid is needed, start it and replace `${GRID_URL}` in `Util.robot` with your IP address

```
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker run -d -p 4444:4444 --net grid --name selenium-hub selenium/hub:3.9.1 && docker run -d --net grid -e HUB_HOST=selenium-hub -v /dev/shm:/dev/shm --name firefox1 selenium/node-firefox:3.9.1
```
