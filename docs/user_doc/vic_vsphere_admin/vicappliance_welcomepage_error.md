# Appliance Welcome Page Error #

When you provide a custom certificate while deploying a vSphere Integrated Containers appliance, the Welcome Page does not display.

## Problem ##

You can use SSH to access the appliance, but the file server fails to start with the `systemctl status fileserver` error. 

## Cause ##
The custom certificate that you provided has an encrypted private key.

## Solution ##
Provide a custom certificate with an unecrypted private key.

Perform the following steps to modify the custom certificate:

1. In the vSphere Client, right-click the appliance VM and select **Power** > **Shut Down Guest OS**.
2. Edit the settings with which you deployed the appliance.

  - In the Flex-based vSphere Web Client, right-click the appliance again, select **Edit Settings** > **vApp Options**.
  - In the HTML5 vSphere Client (vCenter Server 6.7 update 1 and later), select the appliance VM, then select **Configure** > **vApp Options** and scroll to the Properties section.
3. Under Appliance Configuration, specify the a custom certificate key in unencrypted PEM encoded PKCS#1 or unencrypted PEM encoded PKCS#8 format.
4. Power on the appliance.
5. Verify that you can see the vSphere Integrated Containers Appliance Welcome Page.