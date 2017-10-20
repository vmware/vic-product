Test 1-01 - Install
=======

# Purpose:
To verify OVA is installed successfully and all required services are running

#References:

# Environment:
This test requires that a vSphere server is running and available

# Test Steps:
1. Install VIC product OVA
2. Wait for the register page to be up and running
3. SSH into VCH as a root user
4. Check status of harbor
5. Check status of admiral
6. Check status of fileserver
7. Check status of engine_installer

# Expected Outcome:
* OVA should be deployed and return the VCH IP
* Register page should return 200 status
* Step 4 - 7 should result in success

#Possible Problems:
Harbor and other services may take up to 10 min to start up once OVA is installed.
