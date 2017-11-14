Test 1-01 - Install
=======

# Purpose:
To verify OVA is installed successfully, all required services are running, able to download vic engine archive file.

#References:

# Environment:
This test requires that a vSphere server is running and available

# Test Steps:
1. Install VIC product OVA
2. Wait for the register page to be up and running
3. SSH into OVA as a root user
4. Check status of harbor
5. Check status of admiral
6. Check status of fileserver
7. Check status of engine_installer
8. Download VIC engine tar file from management portal UI
9. Extract VIC engine files and Install VCH
10. Run docker info command against the installed VCH

# Expected Outcome:
* OVA should be deployed and return the OVA IP
* Register page should return 200 status
* Step 4 - 7 should result in success
* VIC engine archive file should get downloaded and extracted
* Step 10 should pass and contain expected output

#Possible Problems:
Harbor and other services may take up to 10 min to start up once OVA is installed.
