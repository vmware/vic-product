# VIC Appliance UI Plugin Automated Installation Technical Design Document

## Objectives

- Detail ui changes needed to the vic appliance getting started page.
- Detail changes needed to the vic appliance register api.
- Detail additional fileserver api's needed to support vc thumbprint verification

## Fileserver Design

The current getting started page is hosted as the index route on the vic-appliance fileserver.

- `https://1.2.3.4/` --- index route
- `https://1.2.3.4/files/` --- fileserver route serving the /opt/vmware/fileserver directory
- `https://1.2.3.4/register` --- The psc registration api, the underlying action for the getting started page.

The [index page](../fileserver/html/index.html) is designed as a single page application. The http index route
renders this page as a golang template, changing it's output based on a number of booleans. These include:

- InitErrorFeedback --- Feedback is displayed in a red error box after the login modal completes.
- InitSuccessFeedback string --- Feedback is displayed in a red error box after the login modal completes.
- NeedLogin --- displays the login modal. Default true, false after first registration.

This single page design based off of a single form's post request poses some challenges when adding
functionality, such as thumbprint verification.

- Additions to the registration process can only occur on a HTTP POST to the index route.

## Purposed Design

### Getting Started Page Proposal

Due to the limitations of the initial fileserver design, the following approach can be taken:

- Intercept the onsubmit action of the login form.
- Using the input vc ip address from the form, make an ajax get request to `https://1.2.3.4/thumbprint?ip=5.6.7.8`
- Present a new modal to the user, using the thumbprint received from the request above.
- - On click to the `cancel` button, redirect to `https://1.2.3.4/`, which will bring up a blank login page.
- - On click to the `continue` button, add the thumbprint to original form data payload.
- - - Submit the login form payload, now including the thumbprint, which will result in a post to `https://1.2.3.4/`

In general, since we will have functional apis for /register and /plugin/{operation}, the entire fileserver ui could be changed to a background request architecture using ajax or a larger ui framework.

#### Note

An alternative approach is to use a session-based approach on the fileserver. The first form can post to
/thumbprint, and the second can post back to the getting started page.

The server session would be used to store all information needed to preform the plugin install. However, this approach
introduces a variety of changes to the current fileserver design. It would need a very large refactor.

## Required API Changes

Because the `register` api is used by upgrade automation and integration tests, it *should not* perform a
plugin install. It's current functionality for psc registration should be preserved.

A new api should be created to handle vic ui plugin install. This new api should mimic the current install script
functionality, ie:

- `https://1.2.3.4/plugin/install` should receive a json payload on HTTP POST, similar to /register, to install the plugin.
- `https://1.2.3.4/plugin/remove` should receive a json payload on HTTP POST to remove the plugin.
- `https://1.2.3.4/plugin/upgrade` do a force install on HTTP POST or a removal and reinstall of the plugin.

The above plugin lifecycle apis should be present for manual interaction with the plugin. If needed, the current
plugin modification scripts can be changed to use the apis.

## References

[VIC UI Automated Install workflow](https://vmware.invisionapp.com/share/T2D63MPMR)