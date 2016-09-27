### Installing Admiral

Similarly to what we did for [Harbor](install-configure-harbor.md), for the time being we are going to instantiate Admiral on the Linux VM. 

#### Preparing the Admiral installation
You can grab the latest Admiral bits from [docker hub](https://hub.docker.com/r/vmware/admiral/)

#### Installation procedure for Admiral
We assume you are logged in as root inside the Linux VM and that you have your Admiral image pulled/built already and available locally. Before you start deploying Admiral, make sure you don't have stale environment variables from previous experiments, such as DOCKER_HOST. Simplest way to do this is by running a new shell:

```
sudo bash
```
This is the command we are using to instantiate Admiral:
```
root@lab-vic01:~/harbor/Deploy# docker run -d -p 8282:8282 --volume /data/admiral:/var/admiral --name admiral vmware/admiral
676c060aa2595b7d3c4758887e4cce66adfe3b7f5f56d26eb71567f0595db534
```
Admiral is now running on the Linux VM and is exposed on port 8282. This is the complete URL you need to point your browser to: http://10.140.50.77:8282/ (where 10.140.50.77 is the IP the Linux host it's running on). 

Congratulations! You have just deployed Admiral successfully! 

### Adding a Harbor instance to Admiral 

Admiral supports adding additional registries to the default registry set (registry.hub.docker.com). 

To manage registries, you need to go to the Templates tab and click ***Manage Registry***. 

If you click ***Add***, you can add additional registries. 

Now we are going to add the Harbor instance we just deployed by giving it a name and filling the IP / Hostname field with `http://10.140.50.77:80`.

As a reminder, Harbor runs on port 80 of our Linux VM (whose IP is 10.140.50.77). Make sure you specify port 80 when you enter the IP address because Admiral will otherwise default to port 5000 for registries. Make sure also to specify http. Leaving this out will try to connect using https and fail.

We are also going to define new credentials in Admiral to match the credentials we have used for the admin user in Harbor (admin/Vmware123!).

If everything worked, you should now see two registries listed and available: docker hub and the harbor registry.

### Adding a VCH to Admiral 

Here we are going to Add the VIC Virtual Container Host that we deployed [previously]() (VCH1). 

This is how we do that:

A) Specify `10.140.51.101` as your Docker host IP address (10.140.51.101 is the IP of the VCH1 Endpoint VM). 

B) Enter the credentials for the VCH. Since Admiral only works with Docker APIs (i.e. it doesn’t try to SSH into the hosts) we are going to provide the certificates to connect to the daemon. If you look in the vic directory (from where you launched the vic-machine-linux command to create VCH1) you should find a couple of files that have been generated during the VCH deployment: 
```
root@lab-vic01:~/vic# ll 
total 433108
drwxr-xr-x 3 root root      4096 Aug 16 01:34 ./
drwx------ 7 root root      4096 Aug 16 07:33 ../
-rw-r--r-- 1 root root 134086656 Aug 15 08:40 appliance.iso
-rw-r--r-- 1 root root  65339392 Aug 15 08:40 bootstrap.iso
-rw-r--r-- 1 root root    183989 Aug 15 08:40 LICENSE
-rw-r--r-- 1 root root        57 Aug 15 08:40 README
drwxr-xr-x 5 root root      4096 Aug 15 08:40 ui/
-rw-r--r-- 1 root root      1034 Aug 16 01:54 VCH1-cert.pem
-rw-r--r-- 1 root root      1675 Aug 16 01:54 VCH1-key.pem
-rwxr-xr-x 1 root root  41873680 Aug 15 08:40 vic-machine-darwin*
-rwxr-xr-x 1 root root  42179888 Aug 15 08:40 vic-machine-linux*
-rw-r--r-- 1 root root     12632 Aug 16 01:54 vic-machine.log
-rwxr-xr-x 1 root root  41931264 Aug 15 08:40 vic-machine-windows.exe*
-rwxr-xr-x 1 root root  39172720 Aug 15 08:40 vic-ui-darwin*
-rwxr-xr-x 1 root root  39458184 Aug 15 08:40 vic-ui-linux*
-rwxr-xr-x 1 root root  39221248 Aug 15 08:40 vic-ui-windows.exe*
```
C) You can now just cat the two files (VCH1-cert.pem and VCH1-key.pem) and copy and paste their content respectively in the credentials window on the top and in the window at the bottom. Make sure to add the full text, including the header and footer!

D) For now, in the Resource Pool field you can select the default-resource-pool and leave all the other fields empty.

E) When you Add the VCH Admiral will inform you that the certificate isn’t trusted. Just click yes.

Congratulations! You have added your VCH to Admiral
