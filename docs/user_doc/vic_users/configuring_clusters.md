# Configuring Cluster Size and Scale #

You can create container clusters by using Containers placement settings to specify cluster size. 

When you configure a cluster, a specified number of containers is provisioned. Requests are load balanced among all containers in the cluster. You can modify the cluster size on a provisioned container or application to increase or decrease the size of the cluster by one. When you modify the cluster size at runtime, all affinity filters and placement rules are considered.