Test 6-01 - OVA TLS
=======

# Purpose:
To verify the VIC OVA appliance works with various TLS certificate configuration

# References:

# Environment:
This test requires access to a vCenter environment

# Test Cases:

### User Provided Certificate

#### Test Steps:

1. Generate a certificate and certificate authority
2. Supply generated certificate and certificate authority during deploy of VIC appliance
3. Initialize the VIC appliance
4. Wait for services to start and verify that the provided certificate is used by all services
   running on the VIC appliance

#### Expected Outcome:
The VIC appliance deployment should succeed without error and the provided TLS certificate should be
used for all services running on the VIC appliance


### User Provided Certificate PKCS8

#### Test Steps:

1. Generate a certificate with private key in PKCS8 format and certificate authority
2. Supply generated certificate and certificate authority during deploy of VIC appliance
3. Initialize the VIC appliance
4. Wait for services to start and verify that the provided certificate is used by all services
   running on the VIC appliance

#### Expected Outcome:
The VIC appliance deployment should succeed without error and the provided TLS certificate should be
used for all services running on the VIC appliance
