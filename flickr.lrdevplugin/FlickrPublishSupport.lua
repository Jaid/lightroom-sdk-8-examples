--[[----------------------------------------------------------------------------

FlickrPublishServiceProvider.lua
Publish-specific portions of Lightroom Flickr uploader

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

	-- Lightroom SDK
local LrDialogs = import 'LrDialogs'

	-- Flickr plug-in
require 'FlickrAPI'


--------------------------------------------------------------------------------

 -- NOTE to developers reading this sample code: This file is used to generate
 -- the documentation for the "publish service provider" section of the API
 -- reference material. This means it's more verbose than it would otherwise
 -- be, but also means that you can match up the documentation with an actual
 -- working example. It is not necessary for you to preserve any of the
 -- documentation comments in your own code.


--===========================================================================--
--[[
--- The <i>service definition script</i> for a publish service provider associates
 -- the code and hooks that extend the behavior of Lightroom's Publish features
 -- with their implementation for your plug-in. The plug-in's <code>Info.lua</code> file
 -- identifies this script in the <code>LrExportServiceProvider</code> entry. The script
 -- must define the needed callback functions and properties (with the required
 -- names and syntax) and assign them to members of the table that it returns.
 -- <p>The <code>FlickrPublishSupport.lua</code> file of the Flickr sample plug-in provides
 -- 	examples of and documentation for the hooks that a plug-in must provide in order to
 -- 	define a publish service. Because much of the functionality of a publish service
 -- 	is the same as that of an export service, this example builds upon that defined in the
 -- 	<code>FlickrExportServiceProvider.lua</code> file.</p>
  -- <p>The service definition script for a publish service should return a table that contains:
 --   <ul><li>A pair of functions that initialize and terminate your publish service. </li>
 --	<li>Optional items that define the desired customizations for the Publish dialog.
 --	    These can restrict the built-in services offered by the dialog,
 --	    or customize the dialog by defining new sections. </li>
 --	<li> A function that defines the publish operation to be performed
 --	     on rendered photos (required).</li>
 --	<li> Additional functions and/or properties to customize the publish operation.</li>
 --   </ul>
 -- <p>Most of these functions are the same as those defined for an export service provider.
 -- Publish services, unlike export services, cannot create presets. (You could think of the
 -- publish service itself as an export preset.) The settings tables passed
 -- to these callback functions contain only Lightroom-defined settings, and settings that
 -- have been explicitly declared in the <code>exportPresetFields</code> list of the publish service.
 -- A callback function that you define for a publish service cannot make any changes to the
 -- settings table passed to it.</p>
 -- @module_type Plug-in provided

	module 'SDK - Publish service provider' -- not actually executed, but suffices to trick LuaDocs

--]]


--============================================================================--

local publishServiceProvider = {}

--------------------------------------------------------------------------------
--- (string) Plug-in defined value is the filename of the icon to be displayed
 -- for this publish service provider, in the Publish Services panel, the Publish
 -- Manager dialog, and in the header shown when a published collection is selected.
 -- The icon must be in PNG format and no more than 24 pixels wide or 19 pixels tall.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.small_icon
	-- @class property

publishServiceProvider.small_icon = 'small_flickr.png'

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the behavior of the
 -- Description entry in the Publish Manager dialog. If the user does not provide
 -- an explicit name choice, Lightroom can provide one based on another entry
 -- in the publishSettings property table. This entry contains the name of the
 -- property that should be used in this case.
	-- @name publishServiceProvider.publish_fallbackNameBinding
	-- @class property
	
publishServiceProvider.publish_fallbackNameBinding = 'fullname'

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the name of a published
 -- collection to match the terminology used on the service you are targeting.
 -- <p>This string is typically used in combination with verbs that take action on
 -- the published collection, such as "Create ^1" or "Rename ^1".</p>
 -- <p>If not provided, Lightroom uses the default name, "Published Collection." </p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForPublishedCollection
	-- @class property
	
publishServiceProvider.titleForPublishedCollection = LOC "$$$/Flickr/TitleForPublishedCollection=Photoset"

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the name of a published
 -- collection to match the terminology used on the service you are targeting.
 -- <p>Unlike <code>titleForPublishedCollection</code>, this string is typically
 -- used by itself. In English, these strings nay be the same, but in
 -- other languages (notably German), you may have to use a different form
 -- of the name to be gramatically correct. If you are localizing your plug-in,
 -- use a separate translation key to make this possible.</p>
 -- <p>If not provided, Lightroom uses the value of
 -- <code>titleForPublishedCollection</code> instead.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForPublishedCollection_standalone
	-- @class property

publishServiceProvider.titleForPublishedCollection_standalone = LOC "$$$/Flickr/TitleForPublishedCollection/Standalone=Photoset"

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the name of a published
 -- collection set to match the terminology used on the service you are targeting.
 -- <p>This string is typically used in combination with verbs that take action on
 -- the published collection set, such as "Create ^1" or "Rename ^1".</p>
 -- <p>If not provided, Lightroom uses the default name, "Published Collection Set." </p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForPublishedCollectionSet
	-- @class property
	
-- publishServiceProvider.titleForPublishedCollectionSet = "(something)" -- not used for Flickr plug-in

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the name of a published
 -- collection to match the terminology used on the service you are targeting.
 -- <p>Unlike <code>titleForPublishedCollectionSet</code>, this string is typically
 -- used by itself. In English, these strings may be the same, but in
 -- other languages (notably German), you may have to use a different form
 -- of the name to be gramatically correct. If you are localizing your plug-in,
 -- use a separate translation key to make this possible.</p>
 -- <p>If not provided, Lightroom uses the value of
 -- <code>titleForPublishedCollectionSet</code> instead.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForPublishedCollectionSet_standalone
	-- @class property

--publishServiceProvider.titleForPublishedCollectionSet_standalone = "(something)" -- not used for Flickr plug-in

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the name of a published
 -- smart collection to match the terminology used on the service you are targeting.
 -- <p>This string is typically used in combination with verbs that take action on
 -- the published smart collection, such as "Create ^1" or "Rename ^1".</p>
 -- <p>If not provided, Lightroom uses the default name, "Published Smart Collection." </p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
 	-- @name publishServiceProvider.titleForPublishedSmartCollection
	-- @class property

publishServiceProvider.titleForPublishedSmartCollection = LOC "$$$/Flickr/TitleForPublishedSmartCollection=Smart Photoset"

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value customizes the name of a published
 -- smart collection to match the terminology used on the service you are targeting.
 -- <p>Unlike <code>titleForPublishedSmartCollection</code>, this string is typically
 -- used by itself. In English, these strings may be the same, but in
 -- other languages (notably German), you may have to use a different form
 -- of the name to be gramatically correct. If you are localizing your plug-in,
 -- use a separate translation key to make this possible.</p>
 -- <p>If not provided, Lightroom uses the value of
 -- <code>titleForPublishedSmartCollectionSet</code> instead.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForPublishedSmartCollection_standalone
	-- @class property

publishServiceProvider.titleForPublishedSmartCollection_standalone = LOC "$$$/Flickr/TitleForPublishedSmartCollection/Standalone=Smart Photoset"

--------------------------------------------------------------------------------
--- (optional) If you provide this plug-in defined callback function, Lightroom calls it to
 -- retrieve the default collection behavior for this publish service, then use that information to create
 -- a built-in <i>default collection</i> for this service (if one does not yet exist).
 -- This special collection is marked in italics and always listed at the top of the list of published collections.
 -- <p>This callback should return a table that configures the default collection. The
 -- elements of the configuration table are optional, and default as shown.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @return (table) A table with the following fields:
	  -- <ul>
	   -- <li><b>defaultCollectionName</b>: (string) The name for the default
	   -- 	collection. If not specified, the name is "untitled" (or
	   --   a language-appropriate equivalent). </li>
	   -- <li><b>defaultCollectionCanBeDeleted</b>: (Boolean) True to allow the
	   -- 	user to delete the default collection. Default is true. </li>
	   -- <li><b>canAddCollection</b>: (Boolean)  True to allow the
	   -- 	user to add collections through the UI. Default is true. </li>
	   -- <li><b>maxCollectionSetDepth</b>: (number) A maximum depth to which
	   --  collection sets can be nested, or zero to disallow collection sets.
 	   --  If not specified, unlimited nesting is allowed. </li>
	  -- </ul>
	-- @name publishServiceProvider.getCollectionBehaviorInfo
	-- @class function

function publishServiceProvider.getCollectionBehaviorInfo( publishSettings )

	return {
		defaultCollectionName = LOC "$$$/Flickr/DefaultCollectionName/Photostream=Photostream",
		defaultCollectionCanBeDeleted = false,
		canAddCollection = true,
		maxCollectionSetDepth = 0,
			-- Collection sets are not supported through the Flickr sample plug-in.
	}
	
end

--------------------------------------------------------------------------------
--- When set to the string "disable", the "Go to Published Collection" context-menu item
 -- is disabled (dimmed) for this publish service.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForGoToPublishedCollection
	-- @class property

publishServiceProvider.titleForGoToPublishedCollection = LOC "$$$/Flickr/TitleForGoToPublishedCollection=Show in Flickr"

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user chooses
 -- the "Go to Published Collection" context-menu item.
 -- <p>If this function is not provided, Lightroom uses the URL	recorded for the published collection via
 -- <a href="LrExportSession.html#exportSession:recordRemoteCollectionUrl"><code>exportSession:recordRemoteCollectionUrl</code></a>.</p>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.goToPublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>publishedCollectionInfo</b>: (<a href="LrPublishedCollectionInfo.html"><code>LrPublishedCollectionInfo</code></a>)
	  --  	An object containing  publication information for this published collection.</li>
	  -- <li><b>photo</b>: (<a href="LrPhoto.html"><code>LrPhoto</code></a>) The photo object. </li>
	  -- <li><b>publishedPhoto</b>: (<a href="LrPublishedPhoto.html"><code>LrPublishedPhoto</code></a>)
	  -- 	The object that contains information previously recorded about this photo's publication.</li>
	  -- <li><b>remoteId</b>: (string or number) The ID for this published collection
	  -- 	that was stored via <a href="LrExportSession.html#exportSession:recordRemoteCollectionId"><code>exportSession:recordRemoteCollectionId</code></a></li>
	  -- <li><b>remoteUrl</b>: (optional, string) The URL, if any, that was recorded for the published collection via
	  -- <a href="LrExportSession.html#exportSession:recordRemoteCollectionUrl"><code>exportSession:recordRemoteCollectionUrl</code></a>.</li>
	 -- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.goToPublishedCollection( publishSettings, info )
end

--]]

--------------------------------------------------------------------------------
--- (optional, string) Plug-in defined value overrides the label for the
 -- "Go to Published Photo" context-menu item, allowing you to use something more appropriate to
 -- your service. Set to the special value "disable" to disable (dim) the menu item for this service.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForGoToPublishedPhoto
	-- @class property

publishServiceProvider.titleForGoToPublishedPhoto = LOC "$$$/Flickr/TitleForGoToPublishedCollection=Show in Flickr"

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user chooses the
 -- "Go to Published Photo" context-menu item.
 -- <p>If this function is not provided, Lightroom invokes the URL recorded for the published photo via
 -- <a href="LrExportRendition.html#exportRendition:recordPublishedPhotoUrl"><code>exportRendition:recordPublishedPhotoUrl</code></a>.</p>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.goToPublishedPhoto
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>publishedCollectionInfo</b>: (<a href="LrPublishedCollectionInfo.html"><code>LrPublishedCollectionInfo</code></a>)
	  --  	An object containing  publication information for this published collection.</li>
	  -- <li><b>photo</b>: (<a href="LrPhoto.html"><code>LrPhoto</code></a>) The photo object. </li>
	  -- <li><b>publishedPhoto</b>: (<a href="LrPublishedPhoto.html"><code>LrPublishedPhoto</code></a>)
	  -- 	The object that contains information previously recorded about this photo's publication.</li>
	  -- <li><b>remoteId</b>: (string or number) The ID for this published photo
	  -- 	that was stored via <a href="LrExportRendition.html#exportRendition:recordPublishedPhotoId"><code>exportRendition:recordPublishedPhotoId</code></a></li>
	  -- <li><b>remoteUrl</b>: (optional, string) The URL, if any, that was recorded for the published photo via
	  -- <a href="LrExportRendition.html#exportRendition:recordPublishedPhotoUrl"><code>exportRendition:recordPublishedPhotoUrl</code></a>.</li>
	 -- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.goToPublishedPhoto( publishSettings, info )
end

]]--

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user creates
 -- a new publish service via the Publish Manager dialog. It allows your plug-in
 -- to perform additional initialization.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.didCreateNewPublishService
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>connectionName</b>: (string) the name of the newly-created service</li>
	  -- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
	  -- 	The publish service object.</li>
	 -- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.didCreateNewPublishService( publishSettings, info )
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user creates
 -- a new publish service via the Publish Manager dialog. It allows your plug-in
 -- to perform additional initialization.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.didUpdatePublishService
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>connectionName</b>: (string) the name of the newly-created service</li>
	  -- <li><b>nPublishedPhotos</b>: (number) how many photos are currently published on the service</li>
	  -- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
	  -- 	The publish service object.</li>
	  -- <li><b>changedMoreThanName</b>: (boolean) true if any setting other than the name
	  --  (description) has changed</li>
	 -- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.didUpdatePublishService( publishSettings, info )
end

]]--

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- has attempted to delete the publish service from Lightroom.
 -- It provides an opportunity for you to customize the confirmation dialog.
 -- <p>Do not use this hook to actually tear down the service. Instead, use
 -- <a href="#publishServiceProvider.willDeletePublishService"><code>willDeletePublishService</code></a>
 -- for that purpose.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.shouldDeletePublishService
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	  -- <ul>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object.</li>
		-- <li><b>nPhotos</b>: (number) The number of photos contained in
		-- 	published collections within this service.</li>
		-- <li><b>connectionName</b>: (string) The name assigned to this publish service connection by the user.</li>
	  -- </ul>
	-- @return (string) 'cancel', 'delete', or nil (to allow Lightroom's default
		-- dialog to be shown instead)

--[[ Not used for Flickr plug-in.

function publishServiceProvider.shouldDeletePublishService( publishSettings, info )
end

]]--

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- has confirmed the deletion of the publish service from Lightroom.
 -- It provides a final opportunity for	you to remove private data
 -- immediately before the publish service is removed from the Lightroom catalog.
 -- <p>Do not use this hook to present user interface (aside from progress,
 -- if the operation will take a long time). Instead, use
 -- <a href="#publishServiceProvider.shouldDeletePublishService"><code>shouldDeletePublishService</code></a>
 -- for that purpose.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.willDeletePublishService
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object.</li>
		-- <li><b>nPhotos</b>: (number) The number of photos contained in
		-- 	published collections within this service.</li>
		-- <li><b>connectionName</b>: (string) The name assigned to this publish service connection by the user.</li>
	-- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.willDeletePublishService( publishSettings, info )
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- has attempted to delete one or more published collections defined by your
 -- plug-in from Lightroom. It provides an opportunity for you to customize the
 -- confirmation dialog.
 -- <p>Do not use this hook to actually tear down the collection(s). Instead, use
 -- <a href="#publishServiceProvider.deletePublishedCollection"><code>deletePublishedCollection</code></a>
 -- for that purpose.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.shouldDeletePublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collections</b>: (array of <a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>
		--  or <a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
		-- 	The published collection objects.</li>
		-- <li><b>nPhotos</b>: (number) The number of photos contained in the
		-- 	published collection. Only present if there is a single published collection
		--  to be deleted.</li>
		-- <li><b>nChildren</b>: (number) The number of child collections contained within the
		-- 	published collection set. Only present if there is a single published collection set
		--  to be deleted.</li>
		-- <li><b>hasItemsOnService</b>: (boolean) True if one or more photos have been
		--  published through the collection(s) to be deleted.</li>
	-- </ul>
	-- @return (string) "ignore", "cancel", "delete", or nil
	 -- (If you return nil, Lightroom's default dialog will be displayed.)

--[[ Not used for Flickr plug-in.

function publishServiceProvider.shouldDeletePublishedCollection( publishSettings, info )
end

]]--

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- has attempted to delete one or more photos from the Lightroom catalog that are
 -- published through your service. It provides an opportunity for you to customize
 -- the confirmation dialog.
 -- <p>Do not use this hook to actually delete photo(s). Instead, if the user
 -- confirms the deletion for all relevant services. Lightroom will call
 -- <a href="#publishServiceProvider.deletePhotosFromPublishedCollection"><code>deletePhotosFromPublishedCollection</code></a>
 -- for that purpose.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.shouldDeletePhotosFromServiceOnDeleteFromCatalog
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param nPhotos (number) The number of photos that are being deleted. At least
		-- one of these photos is published through this service; some may only be published
		-- on other services or not published at all.
	-- @return (string) What action should Lightroom take?
		-- <ul>
			-- <li><b>"ignore"</b>: Leave the photos on the service and simply forget about them.</li>
			-- <li><b>"cancel"</b>: Stop the attempt to delete the photos.
			-- <li><b>"delete"</b>: Have Lightroom delete the photos immediately from the service.
				-- (Your plug-in will receive a call to its
				-- <a href="#publishServiceProvider.deletePhotosFromPublishedCollection"><code>deletePhotosFromPublishedCollection</code></a>
				-- in this case.)</li>
			-- <li><b>nil</b>: Allow Lightroom's built-in confirmation dialog to be displayed.</li>
		-- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.shouldDeletePhotosFromServiceOnDeleteFromCatalog( publishSettings, nPhotos )
end

]]--

--------------------------------------------------------------------------------
--- This plug-in defined callback function is called when one or more photos
 -- have been removed from a published collection and need to be removed from
 -- the service. If the service you are supporting allows photos to be deleted
 -- via its API, you should do that from this function.
 -- <p>As each photo is deleted, you should call the <code>deletedCallback</code>
 -- function to inform Lightroom that the deletion was successful. This will cause
 -- Lightroom to remove the photo from the "Delete Photos to Remove" group in the
 -- Library grid.</p>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.deletePhotosFromPublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param arrayOfPhotoIds (table) The remote photo IDs that were declared by this plug-in
		-- when they were published.
	-- @param deletedCallback (function) This function must be called for each photo ID
		-- as soon as the deletion is confirmed by the remote service. It takes a single
		-- argument: the photo ID from the arrayOfPhotoIds array.
	-- @param localCollectionId (number) The local identifier for the collection for which
		-- photos are being removed.

function publishServiceProvider.deletePhotosFromPublishedCollection( publishSettings, arrayOfPhotoIds, deletedCallback )

	for i, photoId in ipairs( arrayOfPhotoIds ) do

		FlickrAPI.deletePhoto( publishSettings, { photoId = photoId, suppressErrorCodes = { [ 1 ] = true } } )
							-- If Flickr says photo not found, ignore that.

		deletedCallback( photoId )

	end
	
end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called whenever a new
 -- publish service is created and whenever the settings for a publish service
 -- are changed. It allows the plug-in to specify which metadata should be
 -- considered when Lightroom determines whether an existing photo should be
 -- moved to the "Modified Photos to Re-Publish" status.
 -- <p>This is a blocking call.</p>
	-- @name publishServiceProvider.metadataThatTriggersRepublish
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @return (table) A table containing one or more of the following elements
		-- as key, Boolean true or false as a value, where true means that a change
		-- to the value does trigger republish status, and false means changes to the
		-- value are ignored:
		-- <ul>
		  -- <li><b>default</b>: All built-in metadata that appears in XMP for the file.
		  -- You can override this default behavior by explicitly naming any of these
		  -- specific fields:
		    -- <ul>
			-- <li><b>rating</b></li>
			-- <li><b>label</b></li>
			-- <li><b>title</b></li>
			-- <li><b>caption</b></li>
			-- <li><b>gps</b></li>
			-- <li><b>gpsAltitude</b></li>
			-- <li><b>creator</b></li>
			-- <li><b>creatorJobTitle</b></li>
			-- <li><b>creatorAddress</b></li>
			-- <li><b>creatorCity</b></li>
			-- <li><b>creatorStateProvince</b></li>
			-- <li><b>creatorPostalCode</b></li>
			-- <li><b>creatorCountry</b></li>
			-- <li><b>creatorPhone</b></li>
			-- <li><b>creatorEmail</b></li>
			-- <li><b>creatorUrl</b></li>
			-- <li><b>headline</b></li>
			-- <li><b>iptcSubjectCode</b></li>
			-- <li><b>descriptionWriter</b></li>
			-- <li><b>iptcCategory</b></li>
			-- <li><b>iptcOtherCategories</b></li>
			-- <li><b>dateCreated</b></li>
			-- <li><b>intellectualGenre</b></li>
			-- <li><b>scene</b></li>
			-- <li><b>location</b></li>
			-- <li><b>city</b></li>
			-- <li><b>stateProvince</b></li>
			-- <li><b>country</b></li>
			-- <li><b>isoCountryCode</b></li>
			-- <li><b>jobIdentifier</b></li>
			-- <li><b>instructions</b></li>
			-- <li><b>provider</b></li>
			-- <li><b>source</b></li>
			-- <li><b>copyright</b></li>
			-- <li><b>rightsUsageTerms</b></li>
			-- <li><b>copyrightInfoUrl</b></li>
			-- <li><b>copyrightStatus</b></li>
			-- <li><b>keywords</b></li>
		    -- </ul>
		  -- <li><b>customMetadata</b>: All plug-in defined custom metadata (defined by any plug-in).</li>
		  -- <li><b><i>(plug-in ID)</i>.*</b>: All custom metadata defined by the plug-in with the specified ID.</li>
		  -- <li><b><i>(plug-in ID).(field ID)</i></b>: One specific custom metadata field defined by the plug-in with the specified ID.</li>
		-- </ul>

function publishServiceProvider.metadataThatTriggersRepublish( publishSettings )

	return {

		default = false,
		title = true,
		caption = true,
		keywords = true,
		gps = true,
		dateCreated = true,

		-- also (not used by Flickr sample plug-in):
			-- customMetadata = true,
			-- com.whoever.plugin_name.* = true,
			-- com.whoever.plugin_name.field_name = true,

	}

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- creates a new published collection or edits an existing one. It can add
 -- additional controls to the dialog box for editing this collection. These controls
 -- can be used to configure behaviors specific to this collection (such as
 -- privacy or appearance on a web service).
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.viewForCollectionSettings
	-- @class function
	-- @param f (<a href="LrView.html#LrView.osFactory"><code>LrView.osFactory</code></a> object)
		-- A view factory object.
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- Plug-in specific settings for this collection. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection. These settings can be accessed via
			-- <a href="LrPublishedCollection.html#pubCollection:getCollectionInfoSummary"><code>LrPublishedCollection:getCollectionInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.
			-- There are some special properties in this table:
			-- <p><code>LR_canSaveCollection</code>,
			-- which allows you to disable the Edit or Create button in the collection dialog.
			-- (If set to true, the Edit / Create button is enabled; if false, it is disabled.)</p>
			-- <p><code>LR_liveName</code> will be kept current with the value displayed
			-- in the name field of the dialog during the life span of the dialog. This enables
			-- a plug-in to add an observer to monitor name changes performed in the dialog.</p>
			-- <p><code>LR_canEditName</code> allows the plug-in
			-- to control whether the edit field containing the collection name in the dialog is enabled.
			-- In the case of new creation, the value defaults to true, meaning that the collection name is
			-- editable via the UI, while in the case of a collection being edited, the value defaults in accordance with
			-- what the plug-in specifies (or doesn't specify) via 'publishServiceProvider.disableRenamePublishedCollection'.</p></li>
		-- <li><b>collectionType</b>: (string) Either "collection" or "smartCollection"
			-- (see also: <code>viewForCollectionSetSettings</code>)</li>
		-- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
		-- <li><b>name</b>: (string) In the case of editing, the name of this collection (at the time when the edit operation was initiated),
		-- otherwise nil.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul>
		-- This field is only present when editing an existing published collection.
		-- </li>
		-- <li><b>pluginContext</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- This is a place for your plug-in to store transient state while the collection
			-- settings dialog is running. It is passed to your plug-in's
			-- <code>endDialogForCollectionSettings</code> callback, and then discarded.</li>
		-- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>)
			-- The published collection object being edited, or nil when creating a new
			-- collection.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object to which this collection belongs.</li>
	-- </ul>
	-- @return (table) A single view description created from one of the methods in
		-- the view factory. (We recommend that <code>f:groupBox</code> be the outermost view.)
 
--[[ Not used for Flickr plug-in. This is an example of how this function might work.

function publishServiceProvider.viewForCollectionSettings( f, publishSettings, info )

	local collectionSettings = assert( info.collectionSettings )
	
	-- Fill in default parameters. This code sample targets a hypothetical service
	-- that allows users to enable or disable ratings and comments on a per-collection
	-- basis.

	if collectionSettings.enableRating == nil then
		collectionSettings.enableRating = false
	end

	if collectionSettings.enableComments == nil then
		collectionSettings.enableComments = false
	end
	
	local bind = import 'LrView'.bind

	return f:group_box {
		title = "Sample Plug-in Collection Settings",  -- this should be localized via LOC
		size = 'small',
		fill_horizontal = 1,
		bind_to_object = assert( collectionSettings ),
		
		f:column {
			fill_horizontal = 1,
			spacing = f:label_spacing(),

			f:checkbox {
				title = "Enable Rating",  -- this should be localized via LOC
				value = bind 'enableRating',
			},

			f:checkbox {
				title = "Enable Comments",  -- this should be localized via LOC
				value = bind 'enableComments',
			},
		},
		
	}

end
--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- creates a new published collection set or edits an existing one. It can add
 -- additional controls to the dialog box for editing this collection set. These controls
 -- can be used to configure behaviors specific to this collection set (such as
 -- privacy or appearance on a web service).
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.viewForCollectionSetSettings
	-- @class function
	-- @param f (<a href="LrView.html#LrView.osFactory"><code>LrView.osFactory</code></a> object)
		-- A view factory object.
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- plug-in specific settings for this collection set. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection set. These settings can be accessed via
			-- <a href="LrPublishedCollectionSet.html#pubCollectionSet:getCollectionSetInfoSummary"><code>LrPublishedCollection:getCollectionSetInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.
			-- There are some special properties in this table:
			-- <p><code>LR_canSaveCollection</code>,
			-- which allows you to disable the Edit or Create button in the collection set dialog.
			-- (If set to true, the Edit / Create button is enabled; if false, it is disabled.)</p>
			-- <p><code>LR_liveName</code> will be kept current with the value displayed
			-- in the name field of the dialog during the life span of the dialog. This enables
			-- a plug-in to add an observer to monitor name changes performed in the dialog.</p>
			-- <p><code>LR_canEditName</code> allows the plug-in
			-- to control whether the edit field containing the collection set name in the dialog is enabled.
			-- In the case of new creation, the value defaults to true, meaning that the collection set name is
			-- editable via the UI, while in the case of a collection being edited, the value defaults in accordance with
			-- what the plug-in specifies (or doesn't specify) via 'publishServiceProvider.disableRenamePublishedCollection'.</p></li>
		-- <li><b>collectionType</b>: (string) "collectionSet"</li>
		-- <li><b>isDefaultCollection</b>: (Boolean) true if this is the default collection (will always be false)</li>
		-- <li><b>name</b>: (string) In the case of edit, the name of this collection set (at the time when the edit operation was initiated),
		-- otherwise nil.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul>
		-- This field is only present when editing an existing published collection set. </li>
		-- <li><b>pluginContext</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- This is a place for your plug-in to store transient state while the collection set
			-- settings dialog is running. It will be passed to your plug-in during the
			-- <code>endDialogForCollectionSettings</code> and then discarded.</li>
		-- <li><b>publishedCollection</b>: (<a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
			-- The published collection set object being edited. Will be nil when creating a new
			-- collection Set.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object.</li>
	-- </ul>
	-- @return (table) A single view description created from one of the methods in
		-- the view factory. (We recommend that <code>f:groupBox</code> be the outermost view.)

--[[ Not used for Flickr plug-in.

function publishServiceProvider.viewForCollectionSetSettings( f, publishSettings, info )
	-- See viewForCollectionSettings example above.
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- closes the dialog for creating a new published collection or editing an existing
 -- one. It is only called if you have also provided the <code>viewForCollectionSettings</code>
 -- callback, and is your opportunity to clean up any tasks or processes you may
 -- have started while the dialog was running.
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>Your code should <b>not</b> update the server from here. That should be done
 -- via the <code>updateCollectionSettings</code> callback. (If, for instance, the
 -- settings changes are later undone; this callback is not called again, but
 -- <code>updateCollectionSettings</code> is.)</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.endDialogForCollectionSettings
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- Plug-in specific settings for this collection. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection. These settings can be accessed via
			-- <a href="LrPublishedCollection.html#pubCollection:getCollectionInfoSummary"><code>LrPublishedCollection:getCollectionInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.</li>
		-- <li><b>collectionType</b>: (string) Either "collection" or "smartCollection"</li>
		-- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
		-- <li><b>name</b>: (string) If the dialog was canceled, the name of the collection (or collection set) which was selected when the create or
		-- edit operation was initiated. If no published collection or collection set was selected, the name of the publish service it
		-- belongs to. If the dialog was dismissed with Edit or Create, the name of the collection when the dialog was dismissed.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
		   -- <ul>
			-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
			-- <li><b>name</b>: (string) Name of the collection set.</li>
			-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
		   -- </ul>
		-- This field is only present when editing an existing published collection.
		-- </li>
		-- <li><b>pluginContext</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
		-- 	This is a place for your plug-in to store transient state while the collection
		-- 	settings dialog is running. It is passed to your plug-in's
		-- 	<code>endDialogForCollectionSettings</code> callback, and then discarded.</li>
		-- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>)
		-- 	The published collection object being edited.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object to which this collection belongs.</li>
		-- <li><b>why</b>: (string) The button that was used to close the dialog, one of "ok" or "cancel".
	-- </ul>

--[[ Not used for Flickr plug-in. This is an example of how this function might work.

function publishServiceProvider.endDialogForCollectionSettings( publishSettings, info )
	-- not used for Flickr plug-in
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- closes the dialog for creating a new published collection set or editing an existing
 -- one. It is only called if you have also provided the <code>viewForCollectionSetSettings</code>
 -- callback, and is your opportunity to clean up any tasks or processes you may
 -- have started while the dialog was running.
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>Your code should <b>not</b> update the server from here. That should be done
 -- via the <code>updateCollectionSetSettings</code> callback. (If, for instance, the
 -- settings changes are later undone; this callback will not be called again;
 -- <code>updateCollectionSetSettings</code> will be.)</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.endDialogForCollectionSetSettings
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- plug-in specific settings for this collection set. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection set. These settings can be accessed via
			-- <a href="LrPublishedCollectionSet.html#pubCollectionSet:getCollectionSetInfoSummary"><code>LrPublishedCollectionSet:getCollectionSetInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.</li>
		-- <li><b>collectionType</b>: (string) "collectionSet"</li>
		-- <li><b>isDefaultCollection</b>: (boolean) true if this is the default collection (will always be false)</li>
		-- <li><b>name</b>: (string) If the dialog was canceled, the name of the collection (or collection set) which was selected when the create or
		-- edit operation was initiated. If no published collection or collection set was selected, the name of the publish service it
		-- belongs to. If the dialog was dismissed with Edit or Create, the name of the collection set when the dialog was dismissed.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
		   -- <ul>
			-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
			-- <li><b>name</b>: (string) Name of the collection set.</li>
			-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
		   -- </ul>
			-- This field is only present when editing an existing published collection set.
			-- </li>
		-- <li><b>pluginContext</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- This is a place for your plug-in to store transient state while the collection set
			-- settings dialog is running. It will be passed to your plug-in during the
			-- <code>endDialogForCollectionSettings</code> and then discarded.</li>
		-- <li><b>publishedCollectionSet</b>: (<a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
		-- 	The published collection set object being edited.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object.</li>
		-- <li><b>why</b>: (string) Why the dialog was closed. Either "ok" or "cancel".
	-- </ul>

--[[ Not used for Flickr plug-in. This is an example of how this function might work.

function publishServiceProvider.endDialogForCollectionSetSettings( publishSettings, info )
	-- not used for Flickr plug-in
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- has changed the per-collection settings defined via the <code>viewForCollectionSettings</code>
 -- callback. It is your opportunity to update settings on your web service to
 -- match the new settings.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>Your code should <b>not</b> use this callback function to clean up from the
 -- dialog. This callback is not be called if the user cancels the dialog.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.updateCollectionSettings
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- Plug-in specific settings for this collection. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection. These settings can be accessed via
			-- <a href="LrPublishedCollection.html#pubCollection:getCollectionInfoSummary"><code>LrPublishedCollection:getCollectionInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.
		-- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
		-- <li><b>name</b>: (string) The name of this collection.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul> </li>
		-- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>
			-- or <a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
		-- 	The published collection object being edited.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object to which this collection belongs.</li>
	-- </ul>
 
--[[ Not used for Flickr plug-in.

function publishServiceProvider.updateCollectionSettings( publishSettings, info )
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- has changed the per-collection set settings defined via the <code>viewForCollectionSetSettings</code>
 -- callback. It is your opportunity to update settings on your web service to
 -- match the new settings.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>Your code should <b>not</b> use this callback function to clean up from the
 -- dialog. This callback will not be called if the user cancels the dialog.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.updateCollectionSetSettings
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
	-- 	by the user in the Publish Manager dialog. Any changes that you make in
	-- 	this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
		-- 	Plug-in specific settings for this collection set. The settings in this table
		-- 	are not interpreted by Lightroom in any way, except that they are stored
		--  with the collection set. These settings can be accessed via
		--  <a href="LrPublishedCollectionSet.html#pubCollectionSet:getCollectionSetInfoSummary"><code>LrPublishedCollectionSet:getCollectionSetInfoSummary</code></a>.
		--  The values in this table must be numbers, strings, or Booleans.
		-- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection (always false in this case).</li>
		-- <li><b>name</b>: (string) The name of this collection set.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul>
		-- </li>
		-- <li><b>publishedCollection</b>: (<a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
		-- 	The published collection set object being edited.</li>
		-- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
		-- 	The publish service object.</li>
	-- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.updateCollectionSetSettings( publishSettings, info )
end

--]]

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when new or updated
 -- photos are about to be published to the service. It allows you to specify whether
 -- the user-specified sort order should be followed as-is or reversed. The Flickr
 -- sample plug-in uses this to reverse the order on the Photostream so that photos
 -- appear in the Flickr web interface in the same sequence as they are shown in the
 -- library grid.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
	-- @param collectionInfo
	-- @name publishServiceProvider.shouldReverseSequenceForPublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param publishedCollectionInfo (<a href="LrPublishedCollectionInfo.html"><code>LrPublishedCollectionInfo</code></a>) an object containing publication information for this published collection.
	-- @return (boolean) true to reverse the sequence when publishing new photos

function publishServiceProvider.shouldReverseSequenceForPublishedCollection( publishSettings, collectionInfo )

	return false

end

--------------------------------------------------------------------------------
--- (Boolean) If this plug-in defined property is set to true, Lightroom will
 -- enable collections from this service to be sorted manually and will call
 -- the <a href="#publishServiceProvider.imposeSortOrderOnPublishedCollection"><code>imposeSortOrderOnPublishedCollection</code></a>
 -- callback to cause photos to be sorted on the service after each Publish
 -- cycle.
	-- @name publishServiceProvider.supportsCustomSortOrder
	-- @class property

publishServiceProvider.supportsCustomSortOrder = true
	
--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called after each time
 -- that photos are published via this service assuming the published collection
 -- is set to "User Order." Your plug-in should ensure that the photos are displayed
 -- in the designated sequence on the service.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
	-- @name publishServiceProvider.imposeSortOrderOnPublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
		-- <li><b>collectionSettings</b>: (<a href="LrObservableTable.html"><code>LrObservableTable</code></a>)
			-- plug-in specific settings for this collection set. The settings in this table
			-- are not interpreted by Lightroom in any way, except that they are stored
			-- with the collection set. These settings can be accessed via
			-- <a href="LrPublishedCollectionSet.html#pubCollectionSet:getCollectionSetInfoSummary"><code>LrPublishedCollectionSet:getCollectionSetInfoSummary</code></a>.
			-- The values in this table must be numbers, strings, or Booleans.
		-- <li><b>isDefaultCollection</b>: (boolean) true if this is the default collection (will always be false)</li>
		-- <li><b>name</b>: (string) the name of this collection set</li>
		-- <li><b>parents</b>: (table) array of information about parents of this collection set;
			-- each element of the array will contain:
				-- <ul>
					-- <li><b>localCollectionId</b>: (number) local collection ID</li>
					-- <li><b>name</b>: (string) name of the collection set</li>
					-- <li><b>remoteCollectionId</b>: (number of string) remote collection ID</li>
				-- </ul>
			-- </li>
		-- <li><b>remoteCollectionId</b>: (string or number) The ID for this published collection
		-- 	that was stored via <a href="LrExportSession.html#exportSession:recordRemoteCollectionId"><code>exportSession:recordRemoteCollectionId</code></a></li>
		-- <li><b>publishedUrl</b>: (optional, string) The URL, if any, that was recorded for the published collection via
		-- <a href="LrExportSession.html#exportSession:recordRemoteCollectionUrl"><code>exportSession:recordRemoteCollectionUrl</code></a>.</li>
	 -- <ul>
	-- @param remoteIdSequence (array of string or number) The IDs for each published photo
		-- 	that was stored via <a href="LrExportRendition.html#exportRendition:recordPublishedPhotoId"><code>exportRendition:recordPublishedPhotoId</code></a>
	-- @return (boolean) true to reverse the sequence when publishing new photos

function publishServiceProvider.imposeSortOrderOnPublishedCollection( publishSettings, info, remoteIdSequence )

	local photosetId = info.remoteCollectionId

	if photosetId then

		-- Get existing list of photos from the photoset. We want to be sure that we don't
		-- remove photos that were posted to this photoset by some other means by doing
		-- this call, so we look for photos that were missed and reinsert them at the end.

		local existingPhotoSequence = FlickrAPI.listPhotosFromPhotoset( publishSettings, { photosetId = photosetId } )

		-- Make a copy of the remote sequence from LR and then tack on any photos we didn't see earlier.
		
		local combinedRemoteSequence = {}
		local remoteIdsInSequence = {}
		
		for i, id in ipairs( remoteIdSequence ) do
			combinedRemoteSequence[ i ] = id
			remoteIdsInSequence[ id ] = true
		end
		
		for _, id in ipairs( existingPhotoSequence ) do
			if not remoteIdsInSequence[ id ] then
				combinedRemoteSequence[ #combinedRemoteSequence + 1 ] = id
			end
		end
		
		-- There may be no photos left in the set, so check for that before trying
		-- to set the sequence.
		if existingPhotoSequence and existingPhotoSequence.primary then
			FlickrAPI.setPhotosetSequence( publishSettings, {
									photosetId = photosetId,
									primary = existingPhotoSequence.primary,
									photoIds = combinedRemoteSequence } )
		end
								
	end

end

-------------------------------------------------------------------------------
--- This plug-in defined callback function is called when the user attempts to change the name
 -- of a collection, to validate that the new name is acceptable for this service.
 -- <p>This is a blocking call. You should use it only to validate easily-verified
 -- characteristics of the name, such as illegal characters in the name. For
 -- characteristics that require validation against a server (such as duplicate
 -- names), you should accept the name here and reject the name when the server-side operation
 -- is attempted.</p>
	-- @name publishServiceProvider.validatePublishedCollectionName
	-- @class function
 	-- @param proposedName (string) The name as currently typed in the new/rename/edit
		-- collection dialog.
	-- @return (Boolean) True if the name is acceptable, false if not
	-- @return (string) If the name is not acceptable, a string that describes the reason, suitable for display.

--[[ Not used for Flickr plug-in.

function publishServiceProvider.validatePublishedCollectionName( proposedName )
	return true
end

--]]

-------------------------------------------------------------------------------
--- (Boolean) This plug-in defined value, when true, disables (dims) the Rename Published
 -- Collection command in the context menu of the Publish Services panel
 -- for all published collections created by this service.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.disableRenamePublishedCollection
	-- @class property

-- publishServiceProvider.disableRenamePublishedCollection = true -- not used for Flickr sample plug-in

-------------------------------------------------------------------------------
--- (Boolean) This plug-in defined value, when true, disables (dims) the Rename Published
 -- Collection Set command in the context menu of the Publish Services panel
 -- for all published collection sets created by this service.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.disableRenamePublishedCollectionSet
	-- @class property

-- publishServiceProvider.disableRenamePublishedCollectionSet = true -- not used for Flickr sample plug-in

-------------------------------------------------------------------------------
--- This plug-in callback function is called when the user has renamed a
 -- published collection via the Publish Services panel user interface. This is
 -- your plug-in's opportunity to make the corresponding change on the service.
 -- <p>If your plug-in is unable to update the remote service for any reason,
 -- you should throw a Lua error from this function; this causes Lightroom to revert the change.</p>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.renamePublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
	  -- <li><b>name</b>: (string) The new name being assigned to this collection.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul> </li>
 	  -- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
	  -- 	The publish service object.</li>
	  -- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>
		-- or <a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
	  -- 	The published collection object being renamed.</li>
	  -- <li><b>remoteId</b>: (string or number) The ID for this published collection
	  -- 	that was stored via <a href="LrExportSession.html#exportSession:recordRemoteCollectionId"><code>exportSession:recordRemoteCollectionId</code></a></li>
	  -- <li><b>remoteUrl</b>: (optional, string) The URL, if any, that was recorded for the published collection via
	  -- <a href="LrExportSession.html#exportSession:recordRemoteCollectionUrl"><code>exportSession:recordRemoteCollectionUrl</code></a>.</li>
	 -- </ul>

function publishServiceProvider.renamePublishedCollection( publishSettings, info )

	if info.remoteId then

		FlickrAPI.createOrUpdatePhotoset( publishSettings, {
							photosetId = info.remoteId,
							title = info.name,
						} )

	end
		
end

-------------------------------------------------------------------------------
--- This plug-in callback function is called when the user has reparented a
 -- published collection via the Publish Services panel user interface. This is
 -- your plug-in's opportunity to make the corresponding change on the service.
 -- <p>If your plug-in is unable to update the remote service for any reason,
 -- you should throw a Lua error from this function; this causes Lightroom to revert the change.</p>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.reparentPublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
	  -- <li><b>name</b>: (string) The new name being assigned to this collection.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul> </li>
 	  -- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
	  -- 	The publish service object.</li>
	  -- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>
		-- or <a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
	  -- 	The published collection object being renamed.</li>
	  -- <li><b>remoteId</b>: (string or number) The ID for this published collection
	  -- 	that was stored via <a href="LrExportSession.html#exportSession:recordRemoteCollectionId"><code>exportSession:recordRemoteCollectionId</code></a></li>
	  -- <li><b>remoteUrl</b>: (optional, string) The URL, if any, that was recorded for the published collection via
	  -- <a href="LrExportSession.html#exportSession:recordRemoteCollectionUrl"><code>exportSession:recordRemoteCollectionUrl</code></a>.</li>
	 -- </ul>

--[[ Not used for Flickr plug-in.

function publishServiceProvider.reparentPublishedCollection( publishSettings, info )
end

]]--

-------------------------------------------------------------------------------
--- This plug-in callback function is called when the user has deleted a
 -- published collection via the Publish Services panel user interface. This is
 -- your plug-in's opportunity to make the corresponding change on the service.
 -- <p>If your plug-in is unable to update the remote service for any reason,
 -- you should throw a Lua error from this function; this causes Lightroom to revert the change.</p>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.deletePublishedCollection
	-- @class function
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param info (table) A table with these fields:
	 -- <ul>
	  -- <li><b>isDefaultCollection</b>: (Boolean) True if this is the default collection.</li>
	  -- <li><b>name</b>: (string) The new name being assigned to this collection.</li>
		-- <li><b>parents</b>: (table) An array of information about parents of this collection, in which each element contains:
			-- <ul>
				-- <li><b>localCollectionId</b>: (number) The local collection ID.</li>
				-- <li><b>name</b>: (string) Name of the collection set.</li>
				-- <li><b>remoteCollectionId</b>: (number or string) The remote collection ID assigned by the server.</li>
			-- </ul> </li>
 	  -- <li><b>publishService</b>: (<a href="LrPublishService.html"><code>LrPublishService</code></a>)
	  -- 	The publish service object.</li>
	  -- <li><b>publishedCollection</b>: (<a href="LrPublishedCollection.html"><code>LrPublishedCollection</code></a>
		-- or <a href="LrPublishedCollectionSet.html"><code>LrPublishedCollectionSet</code></a>)
	  -- 	The published collection object being renamed.</li>
	  -- <li><b>remoteId</b>: (string or number) The ID for this published collection
	  -- 	that was stored via <a href="LrExportSession.html#exportSession:recordRemoteCollectionId"><code>exportSession:recordRemoteCollectionId</code></a></li>
	  -- <li><b>remoteUrl</b>: (optional, string) The URL, if any, that was recorded for the published collection via
	  -- <a href="LrExportSession.html#exportSession:recordRemoteCollectionUrl"><code>exportSession:recordRemoteCollectionUrl</code></a>.</li>
	 -- </ul>

function publishServiceProvider.deletePublishedCollection( publishSettings, info )

	import 'LrFunctionContext'.callWithContext( 'publishServiceProvider.deletePublishedCollection', function( context )
	
		local progressScope = LrDialogs.showModalProgressDialog {
							title = LOC( "$$$/Flickr/DeletingCollectionAndContents=Deleting photoset ^[^1^]", info.name ),
							functionContext = context }
	
		if info and info.photoIds then
		
			for i, photoId in ipairs( info.photoIds ) do
			
				if progressScope:isCanceled() then break end
			
				progressScope:setPortionComplete( i - 1, #info.photoIds )
				FlickrAPI.deletePhoto( publishSettings, { photoId = photoId } )
			
			end
		
		end
	
		if info and info.remoteId then
	
			FlickrAPI.deletePhotoset( publishSettings, {
								photosetId = info.remoteId,
								suppressError = true,
									-- Flickr has probably already deleted the photoset
									-- when the last photo was deleted.
							} )
	
		end
			
	end )

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called (if supplied)
 -- to retrieve comments from the remote service, for a single collection of photos
 -- that have been published through this service. This function is called:
  -- <ul>
    -- <li>For every photo in the published collection each time <i>any</i> photo
	-- in the collection is published or re-published.</li>
 	-- <li>When the user clicks the Refresh button in the Library module's Comments panel.</li>
	-- <li>After the user adds a new comment to a photo in the Library module's Comments panel.</li>
  -- </ul>
 -- <p>This function is not called for unpublished photos or collections that do not contain any published photos.</p>
 -- <p>The body of this function should have a loop that looks like this:</p>
	-- <pre>
		-- function publishServiceProvider.getCommentsFromPublishedCollection( settings, arrayOfPhotoInfo, commentCallback )<br/>
			--<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;for i, photoInfo in ipairs( arrayOfPhotoInfo ) do<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- Get comments from service.<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;local comments = (depends on your plug-in's service)<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- Convert comments to Lightroom's format.<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;local commentList = {}<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for i, comment in ipairs( comments ) do<br/>
					-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;table.insert( commentList, {<br/>
						-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;commentId = (comment ID, if any, from service),<br/>
						-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;commentText = (text of user comment),<br/>
						-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dateCreated = (date comment was created, if available; Cocoa date format),<br/>
						-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;username = (user ID, if any, from service),<br/>
						-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;realname = (user's actual name, if available),<br/>
					-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;} )<br/>
					--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- Call Lightroom's callback function to register comments.<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;commentCallback { publishedPhoto = photoInfo, comments = commentList }<br/>
			--<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;end<br/>
			--<br/>
		-- end
	-- </pre>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param arrayOfPhotoInfo (table) An array of tables with a member table for each photo.
		-- Each member table has these fields:
		-- <ul>
			-- <li><b>photo</b>: (<a href="LrPhoto.html"><code>LrPhoto</code></a>) The photo object.</li>
			-- <li><b>publishedPhoto</b>: (<a href="LrPublishedPhoto.html"><code>LrPublishedPhoto</code></a>)
			--	The publishing data for that photo.</li>
			-- <li><b>remoteId</b>: (string or number) The remote systems unique identifier
			-- 	for the photo, as previously recorded by the plug-in.</li>
			-- <li><b>url</b>: (string, optional) The URL for the photo, as assigned by the
			--	remote service and previously recorded by the plug-in.</li>
			-- <li><b>commentCount</b>: (number) The number of existing comments
			-- 	for this photo in Lightroom's catalog database.</li>
		-- </ul>
	-- @param commentCallback (function) A callback function that your implementation should call to record
		-- new comments for each photo; see example.

function publishServiceProvider.getCommentsFromPublishedCollection( publishSettings, arrayOfPhotoInfo, commentCallback )

	for i, photoInfo in ipairs( arrayOfPhotoInfo ) do

		local comments = FlickrAPI.getComments( publishSettings, {
								photoId = photoInfo.remoteId,
							} )
		
		local commentList = {}
		
		if comments and #comments > 0 then

			for _, comment in ipairs( comments ) do

				table.insert( commentList, {
								commentId = comment.id,
								commentText = comment.commentText,
								dateCreated = comment.datecreate,
								username = comment.author,
								realname = comment.authorname,
								url = comment.permalink
							} )

			end

		end

		commentCallback{ publishedPhoto = photoInfo, comments = commentList }

	end

end

--------------------------------------------------------------------------------
--- (optional, string) This plug-in defined property allows you to customize the
 -- name of the viewer-defined ratings that are obtained from the service via
 -- <a href="#publishServiceProvider.getRatingsFromPublishedCollection"><code>getRatingsFromPublishedCollection</code></a>.
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name publishServiceProvider.titleForPhotoRating
	-- @class property

publishServiceProvider.titleForPhotoRating = LOC "$$$/Flickr/TitleForPhotoRating=Favorite Count"

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called (if supplied)
 -- to retrieve ratings from the remote service, for a single collection of photos
 -- that have been published through this service. This function is called:
  -- <ul>
    -- <li>For every photo in the published collection each time <i>any</i> photo
	-- in the collection is published or re-published.</li>
 	-- <li>When the user clicks the Refresh button in the Library module's Comments panel.</li>
	-- <li>After the user adds a new comment to a photo in the Library module's Comments panel.</li>
  -- </ul>
  -- <p>The body of this function should have a loop that looks like this:</p>
	-- <pre>
		-- function publishServiceProvider.getRatingsFromPublishedCollection( settings, arrayOfPhotoInfo, ratingCallback )<br/>
			--<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;for i, photoInfo in ipairs( arrayOfPhotoInfo ) do<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- Get ratings from service.<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;local ratings = (depends on your plug-in's service)<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- WARNING: The value for ratings must be a single number.<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- This number is displayed in the Comments panel, but is not<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- otherwise parsed by Lightroom.<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- Call Lightroom's callback function to register rating.<br/>
				--<br/>
				-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ratingCallback { publishedPhoto = photoInfo, rating = rating }<br/>
			--<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;end<br/>
			--<br/>
		-- end
	-- </pre>
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param arrayOfPhotoInfo (table) An array of tables with a member table for each photo.
		-- Each member table has these fields:
		-- <ul>
			-- <li><b>photo</b>: (<a href="LrPhoto.html"><code>LrPhoto</code></a>) The photo object.</li>
			-- <li><b>publishedPhoto</b>: (<a href="LrPublishedPhoto.html"><code>LrPublishedPhoto</code></a>)
			--	The publishing data for that photo.</li>
			-- <li><b>remoteId</b>: (string or number) The remote systems unique identifier
			-- 	for the photo, as previously recorded by the plug-in.</li>
			-- <li><b>url</b>: (string, optional) The URL for the photo, as assigned by the
			--	remote service and previously recorded by the plug-in.</li>
		-- </ul>
	-- @param ratingCallback (function) A callback function that your implementation should call to record
		-- new ratings for each photo; see example.

function publishServiceProvider.getRatingsFromPublishedCollection( publishSettings, arrayOfPhotoInfo, ratingCallback )

	for i, photoInfo in ipairs( arrayOfPhotoInfo ) do

		local rating = FlickrAPI.getNumOfFavorites( publishSettings, { photoId = photoInfo.remoteId } )
		if type( rating ) == 'string' then rating = tonumber( rating ) end

		ratingCallback{ publishedPhoto = photoInfo, rating = rating or 0 }

	end
	
end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called whenever a
 -- published photo is selected in the Library module. Your implementation should
 -- return true if there is a viable connection to the publish service and
 -- comments can be added at this time. If this function is not implemented,
 -- the new comment section of the Comments panel in the Library is left enabled
 -- at all times for photos published by this service. If you implement this function,
 -- it allows you to disable the Comments panel temporarily if, for example,
 -- the connection to your server is down.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @return (Boolean) True if comments can be added at this time.

function publishServiceProvider.canAddCommentsToService( publishSettings )

	return FlickrAPI.testFlickrConnection( publishSettings )

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user adds
 -- a new comment to a published photo in the Library module's Comments panel.
 -- Your implementation should publish the comment to the service.
 -- <p>This is not a blocking call. It is called from within a task created
 -- using the <a href="LrTasks.html"><code>LrTasks</code></a> namespace. In most
 -- cases, you should not need to start your own task within this function.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @param publishSettings (table) The settings for this publish service, as specified
		-- by the user in the Publish Manager dialog. Any changes that you make in
		-- this table do not persist beyond the scope of this function call.
	-- @param remotePhotoId (string or number) The remote ID of the photo as previously assigned
		-- via a call to <code>exportRendition:recordRemotePhotoId()</code>.
	-- @param commentText (string) The text of the new comment.
	-- @return (Boolean) True if comment was successfully added to service.

function publishServiceProvider.addCommentToPublishedPhoto( publishSettings, remotePhotoId, commentText )

	local success = FlickrAPI.addComment( publishSettings, {
							photoId = remotePhotoId,
							commentText = commentText,
						} )
	
	return success

end

--------------------------------------------------------------------------------

FlickrPublishSupport = publishServiceProvider
