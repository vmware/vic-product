Test 2-06 Trusted Content
=======

# Purpose:
To verify that the trusted content feature of VIC product works across Admiral, Harbor, and Engine

# References:
1. [VIC Trusted Content Feature](https://vmware.github.io/vic-product/assets/files/html/1.3/vic_overview/introduction.html#notary)
2. [Using Notary to sign images for Harbor](https://vmware.github.io/vic-product/assets/files/html/1.3/vic_app_dev/configure_docker_client.html#notary)

# Environment:
This test requires that a vSphere server is running and available

# Test Steps:
1. Install VIC OVA into the vSphere server
2. Using the local docker client, push an image (`signed_image`) signed with Notary to the Harbor instance in the default project
3. Confirm that the image has a green check-mark in the Signed column in the management portal
4. Install a VCH into the same VC environment via vic-machine with the Harbor instance added as a secure registry (`--registry-ca` option)
5. Do a docker pull from docker hub - this should succeed
6. Do a docker login and pull an image from the harbor instance - this should succeed
7. Add the VCH as a container host to Admiral in the default project
8. Issue a docker info command to the VCH - it should say that the Registry Whitelist Mode is disabled
9. Enable content trust in the default project of Admiral
10. Issue a docker info command to the VCH - it should say that the Registry Whitelist Mode is enabled, and only Harbor should be whitelisted
11. Do a docker pull from docker hub - this should not succeed
12. Do a docker login and pull the dch-photon image (unsigned) from the harbor instance - this should fail
13. Do a docker login and pull the `signed_image` image from the harbor instance - this should succeed
14. Disable content trust in the default project of Admiral
15. Issue a docker info command to the VCH - it should say that the Registry Whitelist Mode is disabled
16. Do a docker pull from docker hub that should succeed
17. Do a docker pull of the dch-photon and the `signed_image` images from the Harbor instance, both should succeed
18. Create a new project in Admiral called 'definitely-not-default'
19. Enable content trust in the new project
20. Remove the VCH as a container host from the default project and add it into the new project
21. Issue a docker info command to the VCH - it should say that the Registry Whitelist Mode is enabled, and only Harbor should be whitelisted
22. Do a docker pull from docker hub that should not succeed
24. Using the local docker client, push an image (`signed_image`) signed with Notary and an unsigned image to the Harbor instance in the 'definitely-not-default' project
25. Do a docker login and pull the unsigned image from the Harbor instance - this should fail
26. Pull the signed image from the Harbor instance - this should succeed
27. Remove the VCH from all projects that it is still in within Admiral
28. Issue a docker info command to the VCH - it should say that the Registry Whitelist Mode is disabled
29. Do a docker pull from docker hub - this should succeed
30. Do a docker login and pull the dch-photon image (unsigned) from the harbor instance - this should succeed
31. Pull the `signed_image` image from the harbor instance - this should succeed

# Expected Outcome:
Admiral and Engine should work together to obey the enable content trust feature properly. When the VCH is within a project that has content trust enabled then users should be able to successfully pull only signed images from the Harbor instance

# Possible Problems:
1. Content trust does not change the whitelisted registries when the VCH is created with `--whitelist-registry`: https://github.com/vmware/vic/issues/6258
