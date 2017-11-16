# Appliance Console Shows OVF Error on Boot #

When you boot the vSphere Integrated Containers appliance, the VM console screen displays the error `unable to unmarshal ovf environment`. 

## Problem ##

When you see this error in the appliance VM console, the appliance is in an unusable state.

## Cause ##

The `ovfenv` data for the appliance is corrupted or missing.

## Solution ##

Perform the following steps to rewrite corrupted or missing `ovfenv` data.

1. In the Flex-based vSphere Client, right-click the appliance VM and select **Power** > **Shut Down Guest OS**.
2. Right-click the appliance again and select **Edit Settings**.
3. Select **vApp Options** and click **OK**.
4. Verify under **Recent Tasks** that a `Reconfigure virtual machine` task has run on the appliance.
5. Power on the appliance.
6. Open the appliance VM console to verify that the error message does not appear.