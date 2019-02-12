# Recover the Root Password for the vSphere Integrated Containers Appliance #

If you forget the root password for the vSphere Integrated Containers appliance, or need to change it after deployment, you can do so by using the GNU Grand Unified Bootloader (GRUB) edit menu in Photon OS. 

**NOTE**: During the initial deployment of the appliance, the installer uses `ovfenv` to set the root password on first boot. Subsequent boots ignore the `ovfenv` field.

**Procedure**

1. In the vSphere Client, open a remote console for the appliance VM.

    It is recommended to use VMware Remote Console and not the Web Console.
2. When the Photon OS splash screen appears, press `e` to enter the GNU GRUB edit menu.

    The Photon OS splash screen only appears very briefly, which is why it is better to use Remote Console rather than the Web Console.
3. In the GNU GRUB edit menu, use the arrow keys to go to the end of the line that begins with `linux`.
4. Add `rw init=/bin/bash` to the end of the `linux` line to start a bash shell.<pre>linux /boot/$photon_linux root=$rootpartition $photon_cmdline $systemd_cmdline consoleblank=0 <b>rw init=/bin/bash</b></pre>
5. Press the `F10` key.
6. At the bash command prompt, enter `passwd` then enter and reenter a new root password for the appliance.

    The password must meet the minimum requirements that Photon OS 2.0 imposes.
```
passwd
New password:
Retype new password:
passwd: password updated successfully```
7. At the command prompt, unmount the file system.
```
umount /
```
8. Reboot the appliance.
```
reboot -f
```

**Result**

You can use the new root password to log in to the vSphere Integrated Containers appliance.