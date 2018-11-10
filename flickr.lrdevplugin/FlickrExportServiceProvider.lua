--[[----------------------------------------------------------------------------

FlickrExportServiceProvider.lua
Export service provider description for Lightroom Flickr uploader

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
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrView = import 'LrView'

	-- Common shortcuts
local bind = LrView.bind
local share = LrView.share

	-- Flickr plug-in
require 'FlickrAPI'
require 'FlickrPublishSupport'


--------------------------------------------------------------------------------

 -- NOTE to developers reading this sample code: This file is used to generate
 -- the documentation for the "export service provider" section of the API
 -- reference material. This means it's more verbose than it would otherwise
 -- be, but also means that you can match up the documentation with an actual
 -- working example. It is not necessary for you to preserve any of the
 -- documentation comments in your own code.


--===========================================================================--
--[[
--- The <i>service definition script</i> for an export service provider defines the hooks
 -- that your plug-in uses to extend the behavior of Lightroom's Export features.
 -- The plug-in's <code>Info.lua</code> file identifies this script in the
 -- <code>LrExportServiceProvider</code> entry.
 -- <p>The service definition script should return a table that contains:
 --   <ul><li>A pair of functions that initialize and terminate your export service. </li>
 --	<li>Settings that you define for your export service.</li>
 --	<li>One or more items that define the desired customizations for the Export dialog.
 --	    These can restrict the built-in services offered by the dialog,
 --	    or customize the dialog by defining new sections. </li>
 --	<li> A function that defines the export operation to be performed
 --	     on rendered photos (required).</li> </ul>
 -- <p>The <code>FlickrExportServiceProvider.lua</code> file of the Flickr sample plug-in provides
 -- 	examples of and documentation for the hooks that a plug-in must provide in order to
 -- 	define an export service. Lightroom expects your plug-in to define the needed callbacks
 --	and properties with the required names and syntax. </p>
 -- <p>Unless otherwise noted, all of the hooks in this section are available to
 -- both Export and Publish service provider plug-ins. If your plug-in supports
 -- Lightroom's Publish feature, you should also read the API reference section
 -- <a href="SDK%20-%20Publish%20service%20provider.html">publish service provider</a>.</p>
 -- @module_type Plug-in provided

	module 'SDK - Export service provider' -- not actually executed, but suffices to trick LuaDocs

--]]


--============================================================================--

local exportServiceProvider = {}

-- A typical service provider would probably roll all of this into one file, but
-- this approach allows us to document the publish-specific hooks separately.

for name, value in pairs( FlickrPublishSupport ) do
	exportServiceProvider[ name ] = value
end

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value declares whether this plug-in supports the Lightroom
 -- publish feature. If not present, this plug-in is available in Export only.
 -- When true, this plug-in can be used for both Export and Publish. When
 -- set to the string "only", the plug-in is visible only in Publish.
	-- @name exportServiceProvider.supportsIncrementalPublish
	-- @class property

exportServiceProvider.supportsIncrementalPublish = 'only'

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value declares which fields in your property table should
 -- be saved as part of an export preset or a publish service connection. If present,
 -- should contain an array of items with key and default values. For example:
	-- <pre>
		-- exportPresetFields = {<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'username', default = "" },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'fullname', default = "" },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'nsid', default = "" },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'privacy', default = 'public' },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'privacy_family', default = false },<br/>
			-- &nbsp;&nbsp;&nbsp;&nbsp;{ key = 'privacy_friends', default = false },<br/>
		-- }<br/>
	-- </pre>
 -- <p>The <code>key</code> item should match the values used by your user interface
 -- controls.</p>
 -- <p>The <code>default</code> item is the value to the first time
 -- your plug-in is selected in the Export or Publish dialog. On second and subsequent
 -- activations, the values chosen by the user in the previous session are used.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.exportPresetFields
 	-- @class property

exportServiceProvider.exportPresetFields = {
	{ key = 'username', default = "" },
	{ key = 'fullname', default = "" },
	{ key = 'nsid', default = "" },
	{ key = 'isUserPro', default = false },
	{ key = 'auth_token', default = '' },
	{ key = 'privacy', default = 'public' },
	{ key = 'privacy_family', default = false },
	{ key = 'privacy_friends', default = false },
	{ key = 'safety', default = 'safe' },
	{ key = 'hideFromPublic', default = false },
	{ key = 'type', default = 'photo' },
	{ key = 'addToPhotoset', default = false },
	{ key = 'photoset', default = '' },
	{ key = 'titleFirstChoice', default = 'title' },
	{ key = 'titleSecondChoice', default = 'filename' },
	{ key = 'titleRepublishBehavior', default = 'replace' },
}

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value restricts the display of sections in the Export
 -- or Publish dialog to those named. You can use either <code>hideSections</code> or
 -- <code>showSections</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>exportLocation</li>
		-- <li>fileNaming</li>
		-- <li>fileSettings</li>
		-- <li>imageSettings</li>
		-- <li>outputSharpening</li>
		-- <li>metadata</li>
		-- <li>watermarking</li>
	-- </ul>
 -- <p>You cannot suppress display of the "Connection Name" section in the Publish Manager dialog.</p>
 -- <p>If you suppress the "exportLocation" section, the files are rendered into
 -- a temporary folder which is deleted immediately after the Export operation
 -- completes.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.showSections
	-- @class property

--exportServiceProvider.showSections = { 'fileNaming', 'fileSettings', etc... } -- not used for Flickr plug-in

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value suppresses the display of the named sections in
 -- the Export or Publish dialogs. You can use either <code>hideSections</code> or
 -- <code>showSections</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>exportLocation</li>
		-- <li>fileNaming</li>
		-- <li>fileSettings</li>
		-- <li>imageSettings</li>
		-- <li>outputSharpening</li>
		-- <li>metadata</li>
		-- <li>watermarking</li>
	-- </ul>
 -- <p>You cannot suppress display of the "Connection Name" section in the Publish Manager dialog.</p>
 -- <p>If you suppress the "exportLocation" section, the files are rendered into
 -- a temporary folder which is deleted immediately after the Export operation
 -- completes.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.hideSections
	-- @class property

exportServiceProvider.hideSections = { 'exportLocation' }

--------------------------------------------------------------------------------
--- (optional, Boolean) If your plug-in allows the display of the exportLocation section,
 -- this property controls whether the item "Temporary folder" is available.
 -- If the user selects this option, the files are rendered into a temporary location
 -- on the hard drive, which is deleted when the export finished.
 -- <p>If your plug-in hides the exportLocation section, this temporary
 -- location behavior is always used.</p>
	-- @name exportServiceProvider.canExportToTemporaryLocation
	-- @class property

-- exportServiceProvider.canExportToTemporaryLocation = true -- not used for Flickr plug-in

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value restricts the available file format choices in the
 -- Export or Publish dialogs to those named. You can use either <code>allowFileFormats</code> or
 -- <code>disallowFileFormats</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>JPEG</li>
		-- <li>PSD</li>
		-- <li>TIFF</li>
		-- <li>DNG</li>
		-- <li>ORIGINAL</li>
	-- </ul>
 -- <p>This property affects the output of still photo files only;
 -- it does not affect the output of video files.
 --  See <a href="#exportServiceProvider.canExportVideo"><code>canExportVideo</code></a>.)</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.allowFileFormats
	-- @class property

exportServiceProvider.allowFileFormats = { 'JPEG' }

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value suppresses the named file formats from the list
 -- of available file format choices in the Export or Publish dialogs.
 -- You can use either <code>allowFileFormats</code> or
 -- <code>disallowFileFormats</code>, but not both. If present,
 -- this should be an array containing one or more of the following strings:
	-- <ul>
		-- <li>JPEG</li>
		-- <li>PSD</li>
		-- <li>TIFF</li>
		-- <li>DNG</li>
		-- <li>ORIGINAL</li>
	-- </ul>
 -- <p>Affects the output of still photo files only, not video files.
 -- See <a href="#exportServiceProvider.canExportVideo"><code>canExportVideo</code></a>.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.disallowFileFormats
	-- @class property

--exportServiceProvider.disallowFileFormats = { 'PSD', 'TIFF', 'DNG', 'ORIGINAL' } -- not used for Flickr plug-in

--------------------------------------------------------------------------------
--- (optional) Plug-in defined value restricts the available color space choices in the
 -- Export or Publish dialogs to those named.  You can use either <code>allowColorSpaces</code> or
 -- <code>disallowColorSpaces</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>sRGB</li>
		-- <li>AdobeRGB</li>
		-- <li>ProPhotoRGB</li>
	-- </ul>
 -- <p>Affects the output of still photo files only, not video files.
 -- See <a href="#exportServiceProvider.canExportVideo"><code>canExportVideo</code></a>.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.allowColorSpaces
	-- @class property

exportServiceProvider.allowColorSpaces = { 'sRGB' }
	
--------------------------------------------------------------------------------
--- (optional) Plug-in defined value suppresses the named color spaces from the list
 -- of available color space choices in the Export or Publish dialogs. You can use either <code>allowColorSpaces</code> or
 -- <code>disallowColorSpaces</code>, but not both. If present, this should be an array
 -- containing one or more of the following strings:
	-- <ul>
		-- <li>sRGB</li>
		-- <li>AdobeRGB</li>
		-- <li>ProPhotoRGB</li>
	-- </ul>
 -- <p>Affects the output of still photo files only, not video files.
 -- See <a href="#exportServiceProvider.canExportVideo"><code>canExportVideo</code></a>.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.disallowColorSpaces
	-- @class property


--exportServiceProvider.disallowColorSpaces = { 'AdobeRGB', 'ProPhotoRGB' } -- not used for Flickr plug-in

--------------------------------------------------------------------------------
--- (optional, Boolean) Plug-in defined value is true to hide print resolution controls
 -- in the Image Sizing section of the Export or Publish dialog.
 -- (Recommended when uploading to most web services.)
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.hidePrintResolution
	-- @class property

exportServiceProvider.hidePrintResolution = true

--------------------------------------------------------------------------------
--- (optional, Boolean)  When plug-in defined value istrue, both video and
 -- still photos can be exported through this plug-in. If not present or set to false,
 --  video files cannot be exported through this plug-in. If set to the string "only",
 -- video files can be exported, but not still photos.
 -- <p>No conversions are available for video files. They are simply
 -- copied in the same format that was originally imported into Lightroom.</p>
 -- <p>First supported in version 3.0 of the Lightroom SDK.</p>
	-- @name exportServiceProvider.canExportVideo
	-- @class property

exportServiceProvider.canExportVideo = false -- video is not supported through this sample plug-in

--------------------------------------------------------------------------------
-- FLICKR SPECIFIC: Helper functions and tables.

local function updateCantExportBecause( propertyTable )

	if not propertyTable.validAccount then
		propertyTable.LR_cantExportBecause = LOC "$$$/Flickr/ExportDialog/NoLogin=You haven't logged in to Flickr yet."
		return
	end
	
	propertyTable.LR_cantExportBecause = nil

end

local displayNameForTitleChoice = {
	filename = LOC "$$$/Flickr/ExportDialog/Title/Filename=Filename",
	title = LOC "$$$/Flickr/ExportDialog/Title/Title=IPTC Title",
	empty = LOC "$$$/Flickr/ExportDialog/Title/Empty=Leave Blank",
}

local kSafetyTitles = {
	safe = LOC "$$$/Flickr/ExportDialog/Safety/Safe=Safe",
	moderate = LOC "$$$/Flickr/ExportDialog/Safety/Moderate=Moderate",
	restricted = LOC "$$$/Flickr/ExportDialog/Safety/Restricted=Restricted",
}

local function booleanToNumber( value )

	return value and 1 or 0

end

local privacyToNumber = {
	private = 0,
	public = 1,
}

local safetyToNumber = {
	safe = 1,
	moderate = 2,
	restricted = 3,
}

local contentTypeToNumber = {
	photo = 1,
	screenshot = 2,
	other = 3,
}

local function getFlickrTitle( photo, exportSettings, pathOrMessage )

	local title
			
	-- Get title according to the options in Flickr Title section.

	if exportSettings.titleFirstChoice == 'filename' then
				
		title = LrPathUtils.leafName( pathOrMessage )
				
	elseif exportSettings.titleFirstChoice == 'title' then
				
		title = photo:getFormattedMetadata 'title'
				
		if ( not title or #title == 0 ) and exportSettings.titleSecondChoice == 'filename' then
			title = LrPathUtils.leafName( pathOrMessage )
		end

	end
				
	return title

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the
 -- user chooses this export service provider in the Export or Publish dialog,
 -- or when the destination is already selected when the dialog is invoked,
 -- (remembered from the previous export operation).
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
	-- @name exportServiceProvider.startDialog
	-- @class function

function exportServiceProvider.startDialog( propertyTable )

	-- Clear login if it's a new connection.
	
	if not propertyTable.LR_editingExistingPublishConnection then
		propertyTable.username = nil
		propertyTable.nsid = nil
		propertyTable.auth_token = nil
	end

	-- Can't export until we've validated the login.

	propertyTable:addObserver( 'validAccount', function() updateCantExportBecause( propertyTable ) end )
	updateCantExportBecause( propertyTable )

	-- Make sure we're logged in.

	require 'FlickrUser'
	FlickrUser.verifyLogin( propertyTable )

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- chooses a different export service provider in the Export or Publish dialog
 --  or closes the dialog.
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
	-- @param why (string) The reason this function was called. One of
		-- 'ok', 'cancel', or 'changedServiceProvider'
	-- @name exportServiceProvider.endDialog
	-- @class function

--function exportServiceProvider.endDialog( propertyTable )
	-- not used for Flickr plug-in
--end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- chooses this export service provider in the Export or Publish dialog.
 -- It can create new sections that appear above all of the built-in sections
 -- in the dialog (except for the Publish Service section in the Publish dialog,
 -- which always appears at the very top).
 -- <p>Your plug-in's <a href="#exportServiceProvider.startDialog"><code>startDialog</code></a>
 -- function, if any, is called before this function is called.</p>
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @param f (<a href="LrView.html#LrView.osFactory"><code>LrView.osFactory</code> object)
		-- A view factory object.
	-- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
	-- @return (table) An array of dialog sections (see example code for details)
	-- @name exportServiceProvider.sectionsForTopOfDialog
	-- @class function

function exportServiceProvider.sectionsForTopOfDialog( f, propertyTable )

	return {
	
		{
			title = LOC "$$$/Flickr/ExportDialog/Account=Flickr Account",
			
			synopsis = bind 'accountStatus',

			f:row {
				spacing = f:control_spacing(),

				f:static_text {
					title = bind 'accountStatus',
					alignment = 'right',
					fill_horizontal = 1,
				},

				f:push_button {
					width = tonumber( LOC "$$$/locale_metric/Flickr/ExportDialog/LoginButton/Width=90" ),
					title = bind 'loginButtonTitle',
					enabled = bind 'loginButtonEnabled',
					action = function()
					require 'FlickrUser'
					FlickrUser.login( propertyTable )
					end,
				},

			},
		},
	
		{
			title = LOC "$$$/Flickr/ExportDialog/Title=Flickr Title",
			
			synopsis = function( props )
				if props.titleFirstChoice == 'title' then
					return LOC( "$$$/Flickr/ExportDialog/Synopsis/TitleWithFallback=IPTC Title or ^1", displayNameForTitleChoice[ props.titleSecondChoice ] )
				else
					return props.titleFirstChoice and displayNameForTitleChoice[ props.titleFirstChoice ] or ''
				end
			end,
			
			f:column {
				spacing = f:control_spacing(),

				f:row {
					spacing = f:label_spacing(),
	
					f:static_text {
						title = LOC "$$$/Flickr/ExportDialog/ChooseTitleBy=Set Flickr Title Using:",
						alignment = 'right',
						width = share 'flickrTitleSectionLabel',
					},
					
					f:popup_menu {
						value = bind 'titleFirstChoice',
						width = share 'flickrTitleLeftPopup',
						items = {
							{ value = 'filename', title = displayNameForTitleChoice.filename },
							{ value = 'title', title = displayNameForTitleChoice.title },
							{ value = 'empty', title = displayNameForTitleChoice.empty },
						},
					},

					f:spacer { width = 20 },
	
					f:static_text {
						title = LOC "$$$/Flickr/ExportDialog/ChooseTitleBySecondChoice=If Empty, Use:",
						enabled = LrBinding.keyEquals( 'titleFirstChoice', 'title', propertyTable ),
					},
					
					f:popup_menu {
						value = bind 'titleSecondChoice',
						enabled = LrBinding.keyEquals( 'titleFirstChoice', 'title', propertyTable ),
						items = {
							{ value = 'filename', title = displayNameForTitleChoice.filename },
							{ value = 'empty', title = displayNameForTitleChoice.empty },
						},
					},
				},
				
				f:row {
					spacing = f:label_spacing(),
					
					f:static_text {
						title = LOC "$$$/Flickr/ExportDialog/OnUpdate=When Updating Photos:",
						alignment = 'right',
						width = share 'flickrTitleSectionLabel',
					},
					
					f:popup_menu {
						value = bind 'titleRepublishBehavior',
						width = share 'flickrTitleLeftPopup',
						items = {
							{ value = 'replace', title = LOC "$$$/Flickr/ExportDialog/ReplaceExistingTitle=Replace Existing Title" },
							{ value = 'leaveAsIs', title = LOC "$$$/Flickr/ExportDialog/LeaveAsIs=Leave Existing Title" },
						},
					},
				},
			},
		},
	}

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called when the user
 -- chooses this export service provider in the Export or Publish dialog.
 -- It can create new sections that appear below all of the built-in sections in the dialog.
 -- <p>Your plug-in's <a href="#exportServiceProvider.startDialog"><code>startDialog</code></a>
 -- function, if any, is called before this function is called.</p>
 -- <p>This is a blocking call. If you need to start a long-running task (such as
 -- network access), create a task using the <a href="LrTasks.html"><code>LrTasks</code></a>
 -- namespace.</p>
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @param f (<a href="LrView.html#LrView.osFactory"><code>LrView.osFactory</code> object)
		-- A view factory object
	-- @param propertyTable (table) An observable table that contains the most
		-- recent settings for your export or publish plug-in, including both
		-- settings that you have defined and Lightroom-defined export settings
	-- @return (table) An array of dialog sections (see example code for details)
	-- @name exportServiceProvider.sectionsForBottomOfDialog
	-- @class function

function exportServiceProvider.sectionsForBottomOfDialog( f, propertyTable )

	return {
	
		{
			title = LOC "$$$/Flickr/ExportDialog/PrivacyAndSafety=Privacy and Safety",
			synopsis = function( props )
				
				local summary = {}
				
				local function add( x )
					if x then
						summary[ #summary + 1 ] = x
					end
				end
				
				if props.privacy == 'private' then
					add( LOC "$$$/Flickr/ExportDialog/Private=Private" )
					if props.privacy_family then
						add( LOC "$$$/Flickr/ExportDialog/Family=Family" )
					end
					if props.privacy_friends then
						add( LOC "$$$/Flickr/ExportDialog/Friends=Friends" )
					end
				else
					add( LOC "$$$/Flickr/ExportDialog/Public=Public" )
				end
				
				local safetyStr = kSafetyTitles[ props.safety ]
				if safetyStr then
					add( safetyStr )
				end
				
				return table.concat( summary, " / " )
				
			end,
			
			place = 'horizontal',

			f:column {
				spacing = f:control_spacing() / 2,
				fill_horizontal = 1,

				f:row {
					f:static_text {
						title = LOC "$$$/Flickr/ExportDialog/Privacy=Privacy:",
						alignment = 'right',
						width = share 'labelWidth',
					},
	
					f:radio_button {
						title = LOC "$$$/Flickr/ExportDialog/Private=Private",
						checked_value = 'private',
						value = bind 'privacy',
					},
				},

				f:row {
					f:spacer {
						width = share 'labelWidth',
					},
	
					f:column {
						spacing = f:control_spacing() / 2,
						margin_left = 15,
						margin_bottom = f:control_spacing() / 2,
		
						f:checkbox {
							title = LOC "$$$/Flickr/ExportDialog/Family=Family",
							value = bind 'privacy_family',
							enabled = LrBinding.keyEquals( 'privacy', 'private' ),
						},
		
						f:checkbox {
							title = LOC "$$$/Flickr/ExportDialog/Friends=Friends",
							value = bind 'privacy_friends',
							enabled = LrBinding.keyEquals( 'privacy', 'private' ),
						},
					},
				},

				f:row {
					f:spacer {
						width = share 'labelWidth',
					},
	
					f:radio_button {
						title = LOC "$$$/Flickr/ExportDialog/Public=Public",
						checked_value = 'public',
						value = bind 'privacy',
					},
				},
			},

			f:column {
				spacing = f:control_spacing() / 2,

				fill_horizontal = 1,

				f:row {
					f:static_text {
						title = LOC "$$$/Flickr/ExportDialog/Safety=Safety:",
						alignment = 'right',
						width = share 'flickr_col2_label_width',
					},
	
					f:popup_menu {
						value = bind 'safety',
						width = share 'flickr_col2_popup_width',
						items = {
							{ title = kSafetyTitles.safe, value = 'safe' },
							{ title = kSafetyTitles.moderate, value = 'moderate' },
							{ title = kSafetyTitles.restricted, value = 'restricted' },
						},
					},
				},

				f:row {
					margin_bottom = f:control_spacing() / 2,
					
					f:spacer {
						width = share 'flickr_col2_label_width',
					},
	
					f:checkbox {
						title = LOC "$$$/Flickr/ExportDialog/HideFromPublicSite=Hide from public site areas",
						value = bind 'hideFromPublic',
					},
				},

				f:row {
					f:static_text {
						title = LOC "$$$/Flickr/ExportDialog/Type=Type:",
						alignment = 'right',
						width = share 'flickr_col2_label_width',
					},
	
					f:popup_menu {
						width = share 'flickr_col2_popup_width',
						value = bind 'type',
						items = {
							{ title = LOC "$$$/Flickr/ExportDialog/Type/Photo=Photo", value = 'photo' },
							{ title = LOC "$$$/Flickr/ExportDialog/Type/Screenshot=Screenshot", value = 'screenshot' },
							{ title = LOC "$$$/Flickr/ExportDialog/Type/Other=Other", value = 'other' },
						},
					},
				},
			},
		},
	}

end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called at the beginning
 -- of each export and publish session before the rendition objects are generated.
 -- It provides an opportunity for your plug-in to modify the export settings.
 -- <p>First supported in version 2.0 of the Lightroom SDK.</p>
	-- @param exportSettings (table) The current export settings.
	-- @name exportServiceProvider.updateExportSettings
	-- @class function

-- function exportServiceProvider.updateExportSettings( exportSettings ) -- not used for the Flickr sample plug-in

	-- This example would cause the export to generate very low-quality JPEG files.

	-- exportSettings.LR_format = 'JPEG'
	-- exportSettings.LR_jpeg_quality = 0

-- end

--------------------------------------------------------------------------------
--- (optional) This plug-in defined callback function is called for each exported photo
 -- after it is rendered by Lightroom and after all post-process actions have been
 -- applied to it. This function is responsible for transferring the image file
 -- to its destination, as defined by your plug-in. The function that
 -- you define is launched within a cooperative task that Lightroom provides. You
 -- do not need to start your own task to run this function; and in general, you
 -- should not need to start another task from within your processing function.
 -- <p>First supported in version 1.3 of the Lightroom SDK.</p>
	-- @param functionContext (<a href="LrFunctionContext.html"><code>LrFunctionContext</code></a>)
		-- function context that you can use to attach clean-up behaviors to this
		-- process; this function context terminates as soon as your function exits.
	-- @param exportContext (<a href="LrExportContext.html"><code>LrExportContext</code></a>)
		-- Information about your export settings and the photos to be published.

function exportServiceProvider.processRenderedPhotos( functionContext, exportContext )
	
	local exportSession = exportContext.exportSession

	-- Make a local reference to the export parameters.
	
	local exportSettings = assert( exportContext.propertyTable )
		
	-- Get the # of photos.
	
	local nPhotos = exportSession:countRenditions()
	
	-- Set progress title.
	
	local progressScope = exportContext:configureProgress {
						title = nPhotos > 1
									and LOC( "$$$/Flickr/Publish/Progress=Publishing ^1 photos to Flickr", nPhotos )
									or LOC "$$$/Flickr/Publish/Progress/One=Publishing one photo to Flickr",
					}

	-- Save off uploaded photo IDs so we can take user to those photos later.
	
	local uploadedPhotoIds = {}
	
	local publishedCollectionInfo = exportContext.publishedCollectionInfo

	local isDefaultCollection = publishedCollectionInfo.isDefaultCollection

	-- Look for a photoset id for this collection.

	local photosetId = publishedCollectionInfo.remoteId

	-- Get a list of photos already in this photoset so we know which ones we can replace and which have
	-- to be re-uploaded entirely.

	local photosetPhotoIds = photosetId and FlickrAPI.listPhotosFromPhotoset( exportSettings, { photosetId = photosetId } )
	
	local photosetPhotosSet = {}
	
	-- Turn it into a set for quicker access later.

	if photosetPhotoIds then
		for _, id in ipairs( photosetPhotoIds ) do
			photosetPhotosSet[ id ] = true
		end
	end
	
	local couldNotPublishBecauseFreeAccount = {}
	local flickrPhotoIdsForRenditions = {}
	
	local cannotRepublishCount = 0
	
	-- Gather flickr photo IDs, and if we're on a free account, remember the renditions that
	-- had been previously published.

	for i, rendition in exportContext.exportSession:renditions() do
	
		local flickrPhotoId = rendition.publishedPhotoId
			
		if flickrPhotoId then
		
			-- Check to see if the photo is still on Flickr.

			if not photosetPhotosSet[ flickrPhotoId ] and not isDefaultCollection then
				flickrPhotoId = nil
			end
			
		end
		
		if flickrPhotoId and not exportSettings.isUserPro then
			couldNotPublishBecauseFreeAccount[ rendition ] = true
			cannotRepublishCount = cannotRepublishCount + 1
		end
			
		flickrPhotoIdsForRenditions[ rendition ] = flickrPhotoId
	
	end
	
	-- If we're on a free account, see which photos are being republished and give a warning.
	
	if cannotRepublishCount	> 0 then

		local message = ( cannotRepublishCount == 1 ) and
							LOC( "$$$/Flickr/FreeAccountErr/Singular/ThereIsAPhotoToUpdateOnFlickr=There is one photo to update on Flickr" )
							or LOC( "$$$/Flickr/FreeAccountErr/Plural/ThereIsAPhotoToUpdateOnFlickr=There are ^1 photos to update on Flickr", cannotRepublishCount )

		local messageInfo = LOC( "$$$/Flickr/FreeAccountErr/Singular/CommentsAndRatingsWillBeLostWarning=With a free (non-Pro) Flickr account, all comments and ratings will be lost on updated photos. Are you sure you want to do this?" )
		
		local action = LrDialogs.promptForActionWithDoNotShow {
									message = message,
									info = messageInfo,
									actionPrefKey = "nonProRepublishWarning",
									verbBtns = {
										{ label = LOC( "$$$/Flickr/Dialog/Buttons/FreeAccountErr/Skip=Skip" ), verb = "skip", },
										{ label = LOC( "$$$/Flickr/Dialog/Buttons/FreeAccountErr/Replace=Replace" ), verb = "replace", },
									}
                                }

		if action == "skip" then
			
			local skipRendition = next( couldNotPublishBecauseFreeAccount )
			
			while skipRendition ~= nil do
				skipRendition:skipRender()
				skipRendition = next( couldNotPublishBecauseFreeAccount, skipRendition )
			end
			
		elseif action == "replace" then

			-- We will publish as usual, replacing these photos.

			couldNotPublishBecauseFreeAccount = {}

		else

			-- User canceled

			progressScope:done()
			return

		end

	end
	
	-- Iterate through photo renditions.
	
	local photosetUrl

	for i, rendition in exportContext:renditions { stopIfCanceled = true } do
	
		-- Update progress scope.
		
		progressScope:setPortionComplete( ( i - 1 ) / nPhotos )
		
		-- Get next photo.

		local photo = rendition.photo

		-- See if we previously uploaded this photo.

		local flickrPhotoId = flickrPhotoIdsForRenditions[ rendition ]
		
		if not rendition.wasSkipped then

			local success, pathOrMessage = rendition:waitForRender()
			
			-- Update progress scope again once we've got rendered photo.
			
			progressScope:setPortionComplete( ( i - 0.5 ) / nPhotos )
			
			-- Check for cancellation again after photo has been rendered.
			
			if progressScope:isCanceled() then break end
			
			if success then
	
				-- Build up common metadata for this photo.
				
				local title = getFlickrTitle( photo, exportSettings, pathOrMessage )
		
				local description = photo:getFormattedMetadata( 'caption' )
				local keywordTags = photo:getFormattedMetadata( 'keywordTagsForExport' )
				
				local tags
				
				if keywordTags then

					tags = {}

					local keywordIter = string.gfind( keywordTags, "[^,]+" )

					for keyword in keywordIter do
					
						if string.sub( keyword, 1, 1 ) == ' ' then
							keyword = string.sub( keyword, 2, -1 )
						end
						
						if string.find( keyword, ' ' ) ~= nil then
							keyword = '"' .. keyword .. '"'
						end
						
						tags[ #tags + 1 ] = keyword

					end

				end
				
				-- Flickr will pick up LR keywords from XMP, so we don't need to merge them here.
				
				local is_public = privacyToNumber[ exportSettings.privacy ]
				local is_friend = booleanToNumber( exportSettings.privacy_friends )
				local is_family = booleanToNumber( exportSettings.privacy_family )
				local safety_level = safetyToNumber[ exportSettings.safety ]
				local content_type = contentTypeToNumber[ exportSettings.type ]
				local hidden = exportSettings.hideFromPublic and 2 or 1
				
				-- Because it is common for Flickr users (even viewers) to add additional tags via
				-- the Flickr web site, so we should not remove extra keywords that do not correspond
				-- to keywords in Lightroom. In order to do so, we record the tags that we uploaded
				-- this time. Next time, we will compare the previous tags with these current tags.
				-- We use the difference between tag sets to determine if we should remove a tag (i.e.
				-- it was one we uploaded and is no longer present in Lightroom) or not (i.e. it was
				-- added by user on Flickr and never was present in Lightroom).
				
				local previous_tags = photo:getPropertyForPlugin( _PLUGIN, 'previous_tags' )
	
				-- If on a free account and this photo already exists, delete it from Flickr.

				if flickrPhotoId and not exportSettings.isUserPro then

					FlickrAPI.deletePhoto( exportSettings, { photoId = flickrPhotoId, suppressError = true } )
					flickrPhotoId = nil

				end
				
				-- Upload or replace the photo.
				
				local didReplace = not not flickrPhotoId
				
				flickrPhotoId = FlickrAPI.uploadPhoto( exportSettings, {
										photo_id = flickrPhotoId,
										filePath = pathOrMessage,
										title = title or '',
										description = description,
										tags = table.concat( tags, ',' ),
										is_public = is_public,
										is_friend = is_friend,
										is_family = is_family,
										safety_level = safety_level,
										content_type = content_type,
										hidden = hidden,
									} )
				
				if didReplace then
				
					-- The replace call used by FlickrAPI.uploadPhoto ignores all of the metadata that is passed
					-- in above. We have to manually upload that info after the fact in this case.
					
					if exportSettings.titleRepublishBehavior == 'replace' then
						
						FlickrAPI.callRestMethod( exportSettings, {
												method = 'flickr.photos.setMeta',
												photo_id = flickrPhotoId,
												title = title or '',
												description = description or '',
											} )
											
					end
	
					FlickrAPI.callRestMethod( exportSettings, {
											method = 'flickr.photos.setPerms',
											photo_id = flickrPhotoId,
											is_public = is_public,
											is_friend = is_friend,
											is_family = is_family,
											perm_comment = 3, -- everybody
											perm_addmeta = 3, -- everybody
										} )
	
					FlickrAPI.callRestMethod( exportSettings, {
											method = 'flickr.photos.setSafetyLevel',
											photo_id = flickrPhotoId,
											safety_level = safety_level,
											hidden = (hidden == 2) and 1 or 0,
										} )
	
					FlickrAPI.callRestMethod( exportSettings, {
											method = 'flickr.photos.setContentType',
											photo_id = flickrPhotoId,
											content_type = content_type,
										} )
		
				end
	
				FlickrAPI.setImageTags( exportSettings, {
											photo_id = flickrPhotoId,
											tags = table.concat( tags, ',' ),
											previous_tags = previous_tags,
											is_public = is_public,
										} )
				
				-- When done with photo, delete temp file. There is a cleanup step that happens later,
				-- but this will help manage space in the event of a large upload.
					
				LrFileUtils.delete( pathOrMessage )
	
				-- Remember this in the list of photos we uploaded.
	
				uploadedPhotoIds[ #uploadedPhotoIds + 1 ] = flickrPhotoId
				
				-- If this isn't the Photostream, set up the photoset.
				
				if not photosetUrl then
	
					if not isDefaultCollection then
	
						-- Create or update this photoset.
	
						photosetId, photosetUrl = FlickrAPI.createOrUpdatePhotoset( exportSettings, {
													photosetId = photosetId,
													title = publishedCollectionInfo.name,
													--		description = ??,
													primary_photo_id = uploadedPhotoIds[ 1 ],
												} )
				
					else
	
						-- Photostream: find the URL.
	
						photosetUrl = FlickrAPI.constructPhotostreamURL( exportSettings )
	
					end
					
				end
				
				-- Record this Flickr ID with the photo so we know to replace instead of upload.
					
				rendition:recordPublishedPhotoId( flickrPhotoId )
				
				local photoUrl
							
				if ( not isDefaultCollection ) then
					
					photoUrl = FlickrAPI.constructPhotoURL( exportSettings, {
											photo_id = flickrPhotoId,
											photosetId = photosetId,
											is_public = is_public,
										} )
										
					-- Add the uploaded photos to the correct photoset.

					FlickrAPI.addPhotosToSet( exportSettings, {
									photoId = flickrPhotoId,
									photosetId = photosetId,
								} )
					
				else
					
					photoUrl = FlickrAPI.constructPhotoURL( exportSettings, {
											photo_id = flickrPhotoId,
											is_public = is_public,
										} )
										
				end
					
				rendition:recordPublishedPhotoUrl( photoUrl )
						
				-- Because it is common for Flickr users (even viewers) to add additional tags
				-- via the Flickr web site, so we can avoid removing those user-added tags that
				-- were never in Lightroom to begin with. See earlier comment.
				
				photo.catalog:withPrivateWriteAccessDo( function()
										photo:setPropertyForPlugin( _PLUGIN, 'previous_tags', table.concat( tags, ',' ) )
									end )
			
			end
		
		else
		
			-- To get the skipped photo out of the to-republish bin.
			rendition:recordPublishedPhotoId(rendition.publishedPhotoId)
			
		end

	end
	
	if #uploadedPhotoIds > 0 then
	
		if ( not isDefaultCollection ) then
			
			exportSession:recordRemoteCollectionId( photosetId )
					
		end
	
		-- Set up some additional metadata for this collection.

		exportSession:recordRemoteCollectionUrl( photosetUrl )
		
	end

	progressScope:done()
	
end

--------------------------------------------------------------------------------

return exportServiceProvider
