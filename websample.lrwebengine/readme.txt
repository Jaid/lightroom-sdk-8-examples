--[[----------------------------------------------------------------------------

luaWebSample.lrwebengine

readme.txt

This readme file details the files that are included in this web plug-in developed
for the Lightroom CS4 SDK.

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.


------------------------------------------------------------------------------]]

To use this plug-in please copy the folder and add to the following directory

MAC: userhome/Library/Application Support/Adobe/Lightroom/Web Galleries/

WIN: LightroomRoot\shared\webengines

-------------------------------------------------------------------------------

galleryInfo.lrweb

This defines the data model using the simple Lua-table format.

The model entry in the table returned by the galleryInfo.lrweb file defines the
data model for your web gallery. The model entry contains both predefined sections
such as photoSizes, and plug-in-defined sections for local data, such as the one
named metadata in this plug-in.  Within the predefined photoSizes section, the
size-class names are defined by the plug-in, but within each size class,there are
a set of predefined properties such as width and height.Some of the parameters declared
are bounded to values that the user can modify as defined in the View entry.

The views entry in the galleryInfo.lrweb file defines the user interface for your
web gallery. It is a function that is passed two arguments, a controller (which
is an observable table that contains your model data) and a viewFactory object that
allows you to create and populate UI elements (as described in Chapter 3, “Creating
a User Interface for Your Plug-in.") The function returns a table of view descriptions
by name, with entries that correspond to the control sections at the right of the Web
Gallery page.

The view table in this sample declares entries for the following section in the
Lightroom UI:

Site Info
Color Palette
Appearance
Image Info

-------------------------------------------------------------------------------
manifest.lrweb

The manifest maps LuaPage source files and template files to Web Gallery HTML output
files using a set of commands for different kinds of pages and resource files.

This sample creates the following lua page templates

AddGridPage - This is the main page of the template which displays thumbnails and large
images
AddResources - The external CSS and Javascript files are added using this command.
These are located in the Resources folder
AddCustomCSS - This instructs the CSS referenced in the galleryInfo.lrweb to be transfered
into valid CSS and stored in content/custom.css on the published site.

The IdentityPlate can be used to store an optional image.
-------------------------------------------------------------------------------
header.html

This is an html file with some embedded Lua code and JavaScript.  There are links
to the external styles sheets referenced in the manifest.lrweb file (resources, custom.css).
The script is used to update the main image of the grid.html page.

The live_update.js script uses a JavaScript file that implements the Live Update
functionality available with Lightroom to support dynamic changes.  There are other
methods of implementing this functionality do this can be used but does not restrict the
user from using other methods.

The JavaScript before the updateImage function supports the Live_Update functionality.
In this sample you can change the title text using the panel on the right or clicking the
area on the actual template.  Such as sitetitle.

The Lua code within the body tag fixes the URL references when previewing the template
in Lightroom and then when publishing.

-------------------------------------------------------------------------------
grid.html

This is an example of a Lua Page template using the AddGridPages as declared in the
manifest.lrweb.  There is a mixture of Lua and HTML code within this file.  The
<lr:ThumbnailGrid> begins the generation of the thumbnails displayed on the left hand
side of this template.

The <span id="image_viewer"..> begins the functionality of displaying the larger Image
in the main area of the page,


-------------------------------------------------------------------------------
footer.html

This is another HTML file with embedded Lua code that displays a hyperlink, that can
be modifies dynamically by the user, and the optional Identity Plate declared in the
manifest.lrweb

-------------------------------------------------------------------------------
resources/css/stylesheet.css

This is a stylesheet used to generate the main structure of this template and is not
declared in the galleryInfo.lrweb page.

-------------------------------------------------------------------------------
resources/js/live_update.js

The file that implements the Live update functionality available in Lightroom.

-------------------------------------------------------------------------------
strings/

This folder contains all localisation strings using the format

en/TranslatedStrings.txt
jp/TranslatedStrings.txt

-------------------------------------------------------------------------------
