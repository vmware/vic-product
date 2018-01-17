Test 1-01 - Install
=======

# Purpose:
To download vic engine archive file and verify the engine binary can create a vch.

#References:

# Environment:
This test requires that a:
- vSphere server is running and available
- Installed VIC appliance

# Test Steps:
1. Download VIC engine tar file from fileserver
2. Extract VIC engine files and Install VCH
3. Run docker info command against the installed VCH

# Expected Outcome:
* VIC engine archive file should get downloaded and extracted
3 Step 8 should pass and contain expected output

#Possible Problems:
Harbor and other services may take up to 10 min to start up once OVA is installed.
