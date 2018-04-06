# Nightly Tests

## Running Locally

```
docker run --rm -v /go/src/github.com/vmware/vic-product:/go --env-file test_secrets.yml gcr.io/eminent-nation-87317/vic-integration-test:1.46 pabot tests/manual-test-cases/Group6-OVA-TLS
```

test_secrets.yml

```
NIMBUS_USER=
NIMBUS_PASSWORD=
NIMBUS_GW=
DRONE_BUILD_NUMBER=1
DOMAIN=eng.vmware.com
```
