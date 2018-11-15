# Deploy a Test `dch-photon` Instance

To use `dch-photon` with vSphere Integrated Containers Registry and a VCH, you must perform the following tasks, in order:

1. Obtain an appropriately configured VCH by following the procedure in [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](../vic_vsphere_admin/deploy_vch_dchphoton.md).
2. Provide the vSphere Integrated Containers Registry certificate to a `dch-photon` instance in one of the following ways:

  - [Add the Registry Certificate to a Custom  `dch-photon`  Image](photon_cert_custom.md)
  - [Manually Add the Registry Certificate to a `dch-photon` VM](photon_cert_manual.md)
2. Test the dch-photon instance by following the procedure in [Build, Push, and Pull an Image with `dch-photon`](test_photon.md).
