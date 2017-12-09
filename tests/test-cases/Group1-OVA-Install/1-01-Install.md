Test 1-01 - Install
=======

# Purpose:
To verify OVA is installed successfully, all required services are running, able to download vic engine archive file.

#References:

# Environment:
This test requires that a:
- vSphere server is running and available
- Installed VIC appliance

# Test Steps:
1. SSH into OVA as a root user
2. Check status of harbor
3. Check status of admiral
4. Check status of fileserver
5. Download VIC engine tar file from management portal UI
6. Extract VIC engine files and Install VCH
7. Run docker info command against the installed VCH

# Expected Outcome:
* Register page should return 200 status
* Step 2 - 5 should result in success
* VIC engine archive file should get downloaded and extracted
* Step 8 should pass and contain expected output

#Possible Problems:
Harbor and other services may take up to 10 min to start up once OVA is installed.
