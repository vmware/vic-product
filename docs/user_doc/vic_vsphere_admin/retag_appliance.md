# Re-Tag the vSphere Integrated Containers Appliance #

vSphere Integrated Containers Registry implements Docker content trust to sign images. As such, the vSphere Integrated Containers appliance requires a specific VM tag to identify it as a content trust source.

In some cases, you might need to re-tag the appliance VM, for example if the tag has been accidentally deleted. 

**Procedure**

1. In the Hosts and Clusters view of the vSphere Client right-click the OVA VM and select **Tags & Custom Attributes** > **Remove Tag**.
2. Check that the `ProductVM` tag is present in the list of tags and click **Cancel**.
3. If the `ProductVM` tag is missing, go to the vSphere Integrated Containers Getting Started page at http://<i>vic_appliance_address</i>.
4. Scroll to the bottom of the page and click the  **Re-Initialize the  vSphere Integrated Containers Appliance** button. 
5. Enter the vCenter Server address and credentials and click **Continue**.
6. After initialization, check in the vSphere Client that the `ProductVM` tag is present.