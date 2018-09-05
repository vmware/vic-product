#Appliance Welcome Page Error#

When you provide a custom certificate while deploying a vSphere Integrated Containers appliance, the Welcome Page does not display.

##Problem##

You can use SSH to access the appliance, but the file server fails to start with the `systemctl status fileserver` error. 

## Cause ##
The custom certificate that you provided has an encrypted private key.

##Solution##
Provide a custom certificate with an unecrypted private key.

Perform the following steps to modify the custom certificate:

1. In the Flex-based vSphere Client, right-click the appliance VM and select **Power** > **Shut Down Guest OS**.
2. Right-click the appliance again and select **Edit Settings**.
3. Specify the a custom certificate in unencrypted PEM encoded PKCS#1 or unencrypted PEM encoded PKCS#8 format.
4. Power on the appliance.
5. Verify that you can see the vSphere Integrated Containers Appliance Welcome Page.