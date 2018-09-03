# Download the vSphere Integrated Containers Engine Bundle 

After you deploy the vSphere Integrated Containers appliance, you download the vSphere Integrated Containers Engine bundle from the appliance to your usual working machine.

The vSphere Integrated Containers Engine bundle includes: 

- Scripts that you run to install, upgrade, or remove the vSphere Client plug-in for vSphere Integrated Containers.
- The `vic-machine` command line utility, that you use to deploy virtual container hosts (VCHs) and manage their lifecycle. 

**Prerequisites**

- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Your working machine runs a 64-bit version of the following Windows, Mac OS, or Linux OS systems.   

|**Platform**|**Supported Versions**|
|---|---|
|Windows|7, 10|
|Mac OS X |10.11 (El Capitan)|
|Linux|Ubuntu 16.04 LTS|

The `vic-machine` utility has been tested and verified on the operating systems above. Other recent 64-bit OS versions should work but are untested.

**Procedure**

1. In a browser, go to the vSphere Integrated Containers Getting Started page.

    You can specify the address in one of the following formats:

    - <i>vic_appliance_address</i>
    - http://<i>vic_appliance_address</i>
    - https://<i>vic_appliance_address</i>:9443

    The first two formats redirect automatically to https://<i>vic_appliance_address</i>:9443. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, the redirect uses the port specified during deployment. If you specify HTTPS, you must include the port number in the address.
2. Scroll down to **Infrastructure deployment tools** and click the link to **download the vSphere Integrated Containers Engine bundle**.
3. Unpack the bundle on your working machine.

**Result**

When you unpack the vSphere Integrated Containers Engine bundle, you obtain following files:

| **File** | **Description** |
| --- | --- |
|`vic-machine-darwin` | The OSX command line utility for the deployment and management of VCHs. | 
|`vic-machine-linux` | The Linux command line utility for the deployment and management of VCHs. | 
|`vic-machine-windows.exe` | The Windows command line utility for the deployment and management of VCHs.| 
|`vic-machine-server`| The endpoint for the `vic-machine` API. The `vic-machine` API is currently experimental and unsupported.|
|`appliance.iso` | The Photon based boot image for the virtual container host (VCH) endpoint VM. |
|`bootstrap.iso` | The Photon based boot image for the container VMs.|
|`ui/` | A folder that contains the files and scripts for the installation of the vSphere Client plug-in. | 
|`vic-ui-darwin` | The OSX executable for the deployment of the vSphere Client plug-in. **NOTE**: Do not run this executable directly.| 
|`vic-ui-linux` | The Linux executable for the deployment of the vSphere Client plug-in. **NOTE**: Do not run this executable directly. | 
|`vic-ui-windows.exe` | The Windows executable for the deployment of the vSphere Client plug-in. **NOTE**: Do not run this executable directly. | 
|`README`|Contains a link to the vSphere Integrated Containers Engine repository on GitHub. |
|`LICENSE`|The license file. |

**What to Do Next**

- If you have not done so, install the vSphere Client plug-ins. For information, see [Manually Install the vSphere Client Plug-Ins](install_vic_plugin.md). If you are using vSphere Integrated Containers 1.4.3 or later, by default the plug-ins are installed automatically.   
- Use either the `vic-machine` CLU utility or the Create Virtual Container Host wizard in the vSphere Client to [Deploy Virtual Container Hosts](deploy_vch.md).