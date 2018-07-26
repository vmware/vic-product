# The purpose of this config is two-fold:

1. To provide flexibility for elastic/server admins to bring up additional elasticsearch container nodes on VIC dvSwitch mapped subnets. 

2. This configuration will also provide an avenue for moving from non-containerized elasticsearch clusters to a fully containerized configuration. 

---
The hosts referred to as **'log'**, **'elk-node1'**, **'elk-node2'** in this compose file are current elasticsearch nodes being prepped for containerization; Once the cluster has synchronized I will begin removing the 'old' nodes from allocation and subsequently from use for indexing/storage.


The network referred to as **'vic-elastic'** is mapped to external dvSwitch portgroup **'elasticsearch'**

_This configuration assumes that you are using static addressing and have already configured the necessary DNS entries for the elasticsearch nodes contained within this compose file._

I will also be uploading a customized config based on: [ELK-Stack Compose file](https://github.com/vmware/vic-product/tree/master/tutorials/elk) which will be customized to match this compose file, which would allow the transition to complete from the 3-node elastic cluster