# Automated Integration Testing

## Approach

Automated tests are designed and developed using [Robot Framework](https://github.com/robotframework/robotframework) and are executed using pybot or pabot.
These tests are a mix of backend and browser UI tests and are executed in parallel within [Drone](https://github.com/drone/drone) container on CI.
Browser tests are run using [Docker Selenium Grid](https://github.com/SeleniumHQ/docker-selenium) with headless Firefox nodes which are started per build basis as Drone services.

Common OVA appliance is installed as part of the CI pipeline, before the integration test step, which is shared among all of the tests. It is cleaned up later once the test run is completed.
All the robot logs and screenshots are published on [Google storage](https://console.cloud.google.com/storage/browser/vic-ci-logs?project=eminent-nation-87317).

_TODO_ Local testing