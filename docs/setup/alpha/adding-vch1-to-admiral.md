Here we are going to Add the VIC Virtual Container Host that we deployed previously (```VCH1```) to Admiral.

This is how we do that:

A) Specify 10.140.51.101 as your Docker host IP address (```10.140.51.101``` is the IP of the VCH1 Endpoint VM).

B) Enter the credentials for the VCH. Since Admiral only works with Docker APIs (i.e. it doesn’t try to SSH into the hosts) we are going to provide the certificates to connect to the daemon. If you look in the vic directory (from where you launched the ```vic-machine-linux``` command to create ```VCH1```) you should find a couple of files that have been generated during the VCH deployment:

```
root@lab-vic01:~/vic# ll

total 433108

drwxr-xr-x 3 root root 4096 Aug 16 01:34 ./

drwx------ 7 root root 4096 Aug 16 07:33 ../

-rw-r--r-- 1 root root 134086656 Aug 15 08:40 appliance.iso

-rw-r--r-- 1 root root 65339392 Aug 15 08:40 bootstrap.iso

-rw-r--r-- 1 root root 183989 Aug 15 08:40 LICENSE

-rw-r--r-- 1 root root 57 Aug 15 08:40 README

drwxr-xr-x 5 root root 4096 Aug 15 08:40 ui/

-rw-r--r-- 1 root root 1034 Aug 16 01:54 VCH1-cert.pem

-rw-r--r-- 1 root root 1675 Aug 16 01:54 VCH1-key.pem

-rwxr-xr-x 1 root root 41873680 Aug 15 08:40 vic-machine-darwin

-rwxr-xr-x 1 root root 42179888 Aug 15 08:40 vic-machine-linux

-rw-r--r-- 1 root root 12632 Aug 16 01:54 vic-machine.log

-rwxr-xr-x 1 root root 41931264 Aug 15 08:40 vic-machine-windows.exe

-rwxr-xr-x 1 root root 39172720 Aug 15 08:40 vic-ui-darwin

-rwxr-xr-x 1 root root 39458184 Aug 15 08:40 vic-ui-linux

-rwxr-xr-x 1 root root 39221248 Aug 15 08:40 vic-ui-windows.exe
```

C) You can now just cat the two files (```VCH1-cert.pem``` and ```VCH1-key.pem```) and copy and paste their content respectively in the credentials window on the top and in the window at the bottom.

D) For now, in the ```Resource Pool``` field you can just leave the ```default-resource-pool``` and all the other fields empty.

E) When you Add the VCH, Admiral will inform you that the certificate isn’t trusted. Just click yes.

Congratulations! You have added your VCH to Admiral
