# vSphere Integrated Containers Registry Administration #

###Managing user
Administrator can add "administrator" role to an ordinary user by toggling the switch under "Administrator". To delete a user, click on the recycle bin icon.  

![browse project](img/new_set_admin_remove_user.png)

###Managing destination
You can list, add, edit and delete destinations in the "Destination" tab. Only destinations which are not referenced by any policies can be edited.  

![browse project](img/new_manage_destination.png)

###Managing replication
You can list, edit, enable and disable policies in the "Replication" tab. Make sure the policy is disabled before you edit it.  

![browse project](img/new_manage_replication.png)

### Deleting repositories

Repository deletion runs in two steps.  

First, delete a repository in Harbor's UI. This is soft deletion. You can delete the entire repository or just a tag of it. After the soft deletion, 
the repository is no longer managed in Harbor, however, the files of the repository still remain in Harbor's storage.  

![browse project](img/new_delete_repository.png)

**CAUTION: If both tag A and tag B refer to the same image, after deleting tag A, B will also get deleted.**  

Next, set **"Garbage Collection"** to true according to the [installation guide](installation_guide_ova.md)(skip this step if this flag has already been set) and reboot the VM, Harbor will perform garbage collection when it boots up.  

For more information about garbage collection, please see Docker's document on [GC](https://github.com/docker/docker.github.io/blob/master/registry/garbage-collection.md).  