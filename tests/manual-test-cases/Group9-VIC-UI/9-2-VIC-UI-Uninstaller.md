Test 9-2 - VIC UI Uninstallation
======

# Purpose:
To test all possible uninstallation failures and success scenarios on VCSA

# References:

# Environment:
* Testing VIC UI requires a working VCSA setup

# Test Steps:
1. Ensure UI plugin is not registered with VC before testing
2. Try uninstalling UI with wrong vCenter IP
3. Try uninstalling UI with wrong vCenter credentials
4. Uninstall UI successfully
5. Try uninstalling UI when it's already uninstalled

# Expected Outcome:
* Each step should return success

# Possible Problems:
