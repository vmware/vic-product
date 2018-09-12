# Some Users Cannot Access vSphere Integrated Containers Services #

Attempts to connect to the Web-based services of the vSphere Integrated Containers appliance fail for certain users but not for others. The appliance and its services are running correctly.

## Problem ##

The appliance and its services are running correctly. Some users can access the appliance welcome page, file server, and vSphere Integrated Containers Management Portal without problems, but for other users the connections fail.

## Cause ##

Some users are attempting to access the appliance welcome page, file server, and vSphere Integrated Containers Management Portal from client systems that have IP addresses in the range 172.17.0.0-172.22.0.0/16. 

vSphere Integrated Containers appliance use the  172.17.0.0-172.22.0.0/16 networks internally. The routing table in the appliance contains routes for these subnets, which causes issues if users attempt to access vSphere Integrated Containers services from an address for which the appliance has a directly connected route. Attempts to connect to the appliance from client systems with IP addresses in the range 172.17.0.0-172.22.0.0/16 fail because the appliance routes return traffic to itself instead of to the client system. 

## Solution ##

Access the appliance welcome page, file server, and vSphere Integrated Containers Management Portal from client systems with IP addresses that are not in the 172.17.0.0-172.22.0.0/16 subnets.