Test 9-1 - VIC UI Installation
======

# Purpose:
To test all possible installation failures and success scenarios on VCSA

# References:

# Environment:
* Testing VIC UI requires a working VCSA setup

# Test Steps:
1. Ensure UI plugin is not registered with VC before testing
2. Try installing UI with invalid vCenter IP
3. Try installing UI with wrong vCenter credentials
4. Try installing UI with unmatching VCSA fingerprint
5. Install UI successfully
6. Try upgrading UI when it is already installed

# Expected Outcome:
* Each step should return success

# Possible Problems:
