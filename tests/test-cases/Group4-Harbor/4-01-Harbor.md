Test 3-01 - Admiral
=======

# Purpose:
To verify Admiral UI page features.

#References:

# Environment:
This test requires that a:
- vSphere server is running and available
- Installed VIC appliance
- Browser is open and logged into VIC UI using single sign-on

# Test Steps:
1. Download VIC engine, if not already
2. Install VCH
3. Navigate to Admiral home page 
4. Navigate To Container Hosts Page and add installed VCH as new container host
5. Navigate To Containers Page and provision a new docker container
6. Delete added VCH host from UI


# Expected Outcome:
* Step 4 Verify VCH is added successfully
* Step 5 Docker container is provisioned successfully 
* Step 6 VCH host is removed successfully

#Possible Problems: