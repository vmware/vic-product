# Connections Fail with Certificate or Platform Services Controller Token Errors #

Connections to virtual container hosts (VCHs) that use full TLS authentication with trusted Certificate Authority (CA) certificates fail with certificate errors. Connections to vSphere Integrated Containers Management Portal fail with Platform Services Controller token errors.

## Problem ##
 
- `vic-machine` operations on a VCH result in a "bad certificate" error:<pre>Connection failed with TLS error "bad certificate" 
  check for clock skew on the host
  Collecting host-227 hostd.log
  vic-machine-windows.exe failed: tls: bad certificate
  </pre>**NOTE**: `vic-machine` tolerates a 1 day skew. A skew of 1 day might result in a different certificate error than time skew.
- Connections to the VCH Admin portal for the VCH fail with an `ERR_CERT_DATE_INVALID` error.
- Connections to the VCH from Docker clients fail with a `bad certificate` error.
- Connections to vSphere Integrated Containers Management Portal fail with Platform Services Controller token errors.

## Cause ##
There is potentially a clock skew between the VCH and the system from which you are connecting to the VCH, or between the vSphere Integrated Containers appliance and the ESXi host on which it is running.

## Solutions ##

Ensure that the system time is synchronized between VCHs and systems that connect to them, and between the appliance and the underlying host.

### VCH Certificate Errors

1. Go to the VCH Admin portal for the VCH at https://<i>vch_address</i>:2378 and check the System Time under **VCH Info**.
2. If the system time of the VCH is wrong, run `vic-machine debug` to enable SSH access to the VCH. 

    For information about enabling SSH on a VCH, see [Authorize SSH Access to the VCH Endpoint VM](vch_ssh_access.md).
2.  Connect to the VCH endpoit VM by using SSH.<pre>ssh root@<i>vch_address</i></pre>
3.  Use the `date --set` Linux command to set the system clock to the correct date and time.

    The two most common date formats are the following:

   - Unix Time Stamp: `date --set='@1480969133'`
   - `YYYYMMDD HH:MM` format: `date --set="20161205 14:31"`  

To prevent this issue recurring on VCHs that you deploy in the future, verify that the host time is correct on the ESXi host on which you deploy VCHs. For information about verifying time synchronization on ESXi hosts, see [VMware KB 1003736](https://kb.vmware.com/kb/1003736).

### Platform Services Controller Token Errors

Configure the vSphere Integrated Containers appliance to use Network Time Protocol (NTP) synchronization. For information about configuring NTP by using the vSphere Client, see [VMware KB 1014038](https://kb.vmware.com/s/article/1014038).

Alternatively, configure NTP directly in the appliance VM.

1. Use SSH to connect to the vSphere Integrated Containers appliance as root user.<pre>ssh root@<i>vic_appliance_address</i></pre>
2. Enable NTP in the appliance.<pre>timedatectl set-ntp true</pre>
3. (Optional) Open `/etc/systemd/timesyncd.conf` in a text editor, uncomment the `NTP` line, and add an NTP server address.<pre>[Time]
NTP=<i>ntp_server_address</i></pre>
