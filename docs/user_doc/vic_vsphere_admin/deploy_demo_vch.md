# Deploy a Demo Virtual Container Host

A web service is automatically started on the VIC OVA upon successful installation. This web service, the **Demo VCH Installer,** allows you to install a VCH without using the CLI, albeit with limited options.

Only the Bridge Network, Public Network, Image Store, and Compute Resource options are currently supported, as those are the requirements for a bare-minimum vCenter install. This is not meant to be a full-featured installer and does not include TLS support. For advanced usage please use the `vic-machine create` CLI.

### Usage

Once your OVA is installed, navigate to `https://<OVA-IP>:1337` in your browser and trust the certificate. The web service contains two pages - a login page and an execution page. 

##### Login

In the Login page you should enter the IP, Username, and Password of the vCenter instance that's running the OVA. If your credentials are valid you'll be directed to the next page. 

##### Execution
Once on the Execution page you'll find a series of drop down boxes and text fields for VCH creation options. All fields should be populated *with the exception of the target thumbprint*. 

Select the appropriate options - leaving thumbprint blank - and press Execute. The Execution Output should contain a thumbprint of the vCenter target, which you can copy and paste into the thumbprint field. Press Execute again and your `vic-machine create` command should start running. 

You can scroll down as more output logs are appended. It is advised to stay on the Installer page until command completion - your logs may stop streaming if you switch tabs or windows. 

The `vic-machine create` command output upon execution may be copied to a cli and used as a template for creating other VCHs.

### Admiral Integration

The OVA Appliance also runs instances of Harbor and Admiral. Upon successful creation of the VCH, the Demo Installer web service will attempt to add the new VCH to the Admiral instance running on the OVA. You can check the VCHs attached to Admiral at `https://<OVA-IP>:8282`