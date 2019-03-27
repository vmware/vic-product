# Built-in Repositories #

The Management Portal allows you to provision containers from project registries that the DevOps administrator configures. 

You can browse repositories to see the different tags applied to images in the repository. You can also delete a repository or a tag in a repository.

To view a list of built-in images that are available in the project, navigate to **Library** > **Built-in Repositories**.

Select a repository to perform the following tasks:

* Edit description. Edit the repository description in the **Info** tab.
* Scan. vSphere Integrated Containers uses the open source project Clair to scan images for known vulnerabilities. You can run a vulnerability scan on all images, on a per-project level, or on individual images. For more information, see [Vulnerability Scanning](../vic_cloud_admin/vulnerability_scanning.md)
* Copy Digest. You can pull images via image digest. Digest is a sha256 content-addressable identifier of an image. It represents a layer or group of layers of the iamge of the image. When pulling an image by digest, you specify the version of an image to pull. You can see the digest of an image in the ouput after pulling it. For example, `sha256:5b7ecd9d3e7ae1923ad7a1861fbeecccc23ddeb209cea69ae5d823ff90f6a2c2`. When you click `Copy Digest`, you copy the layer representation of an image that you build and can reuse it while building another image.
* Copy Pull command. You can copy the `docker pull` command for the image in the **Images** tab.
* View Vulnerability Log. Consists of a list of vulnerabilities that Clair has found in your image while scanning it.