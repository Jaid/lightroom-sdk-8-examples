# lightroom-sdk-8-examples

All content of this repository is copied from [Adobe sources](https://console.adobe.io/downloads/lr) and not created or owned by me.

### Official notice from Adobe

```
Welcome to the Adobe® Lightroom® Classic 8.0 Software Development Kit 
_____________________________________________________________________________

This file contains the latest information for the Adobe Lightroom SDK (8.0 Release). 
The information applies to Adobe Lightroom Classic and includes the following sections:

1. Introduction
2. SDK content overview
3. Development environment
4. Sample plug-ins
5. Running the plug-ins
6. Adobe Add-ons

**********************************************
1. Introduction
**********************************************

The SDK provides information and examples for the scripting interface to Adobe 
Lightroom Classic. The SDK defines a scripting interface for the Lua language.

A number of new features have been added in the 7.4 SDK release. Please see the API
Reference for more information about each of the namespaces:

1.	LrApplicationView:
	- New APIs to support Screen Modes, Grid and Loupe View Styles have been added

2. 	LrPhoto:
   	- NEW API support to change quick develop settings from Library module have been added.
   	- API support has been added for various actions to overcome locale issues.

3. 	LrDevelopController:
   	- Support added for setting Auto Tone, White Balance, Clipping is added.
   	- New API support for Radial, Spot and Graduated Filter.

Key Bug Fixes:

1. 	Incosistencies between process versions are rectified
2.	Docs have been updated to correct a number of issues.

**********************************************
3. Development environment
**********************************************

You can use any text editor to write your Lua scripts, and you can
use the LrLogger namespace to write debugging information to a console. 
See the section on "Debugging your Plug-in" in the Lightroom SDK Guide.

**********************************************
4. Sample Plugins
**********************************************

The SDK provides the following samples:

- <sdkInstall>/Sample Plugins/flickr.lrdevplugin/: 
	Sample plug-in that demonstrates creating a plug-in which allows 
	images to be directly exported to a Flickr account.

- <sdkInstall>/Sample Plugins/ftp_upload.lrdevplugin/: 
	Sample plug-in that demonstrates how to export images to an FTP server.

- <sdkInstall>/Sample Plugins/helloworld.lrdevplugin/: 
	Sample code that accompanies the Getting Started section of the 
	Lightroom SDK Guide.

  <sdkInstall>/Sample Plugins/custommetadatasample.lrdevplugin/:
	Sample code that accompanies the custommetadatasample plug-in that
	demonstrates custom metadata.

- <sdkInstall>/Sample Plugins/metaexportfilter.lrdevplugin/: 
	Sample code that demonstrates using the metadata stored in a file 
	to filter the files exported via the export dialog.

- <sdkInstall>/Sample Plugins/websample.lrwebengine/: 
	Sample code that creates a new style of web gallery template 
	using the Web SDK.

**********************************************
5. Running the plug-ins
**********************************************

To run the sample code, load the plug-ins using the Plug-in Manager
available within Lightroom. See the Lightroom SDK Guide for more information.

*********************************************************
6. Adobe Add-ons
*********************************************************

To learn more about Adobe Add-ons, point your browser to:

  https://creative.adobe.com/addons

_____________________________________________________________________________

Copyright 2018 Adobe Systems Incorporated. All rights reserved.

Adobe, Lightroom, and Photoshop are registered trademarks or trademarks of 
Adobe Systems Incorporated in the United States and/or other countries. 
Windows is either a registered trademark or a trademark of Microsoft Corporation
in the United States and/or other countries. Macintosh is a trademark of 
Apple Computer, Inc., registered in the United States and  other countries.
```