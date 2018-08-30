# Pulling Images into VCHs Fails with Image Store Error #

When you attempt to pull certain container images from a registry into a vSphere Integrated Containers virtual container host (VCH), the pulls fail with an error. Pulls of other container images do not fail.

## Problem

When you attempt to pull an image, you see the following error:

<pre>Failed to write to image store: [POST /storage/{<i>image_store_name</i>}] [5000] WriteImage default &{Code: 500 Message:Failed to add disk 'scsi0:0' .}
</pre>


## Cause

When you use a standard Docker Engine, an image can have a maximum of 120 layers. When you use a vSphere Integrated Containers Engine virtual container host (VCH), an image can have a maximum of 90 layers. The image that you are pulling exceeds the limit of 90 layers.

## Solution

Reduce the number of layers in the image to less than 90.