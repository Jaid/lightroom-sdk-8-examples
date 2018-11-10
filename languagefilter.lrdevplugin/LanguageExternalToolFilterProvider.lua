--[[----------------------------------------------------------------------------

LanguageExternalToolFilterProvider.lua
Export service provider description for Creator external tool sample

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

-- Lightroom SDK
local LrView = import 'LrView'
local bind = LrView.bind
local LrPathUtils = import 'LrPathUtils'
local LrTasks = import "LrTasks"


--============================================================================--

local LanguageExternalToolFilterProvider = {}

-------------------------------------------------------------------------------

LanguageExternalToolFilterProvider.exportPresetFields = {
	{ key = 'language', default = 'x-default' },
	{ key = 'title', default = '' },
}

-------------------------------------------------------------------------------

function LanguageExternalToolFilterProvider.sectionForFilterInDialog( viewFactory, propertyTable )

	return {
		title = 'Language External Tool Sample',
		
		viewFactory:row {
			spacing = viewFactory:control_spacing(),
			viewFactory:static_text {
				title = "Title",
			},
			viewFactory:edit_field {
				value = bind 'title',
			},
			
			viewFactory:popup_menu {
				value = bind 'language',
				items = {
					{ title = "Default",					value = "x-default" },
					{ title = "English [US]",				value = "en-US" },
					{ title = "German [Germany]",			value = "de-DE" },
					{ title = "German [Switzerland]",		value = "de-CH" },
					{ title = "French [France]",			value = "fr-FR" },
					{ title = "Italian [Italy]",			value = "it-IT" },
					{ title = "Japanese [Japan]",			value = "jp-JP" },
					{ title = "Arabic [U.A.E.]", 			value = "ar-AE" },
					{ title = "Bulgarian [Bulgaria]",		value = "bg-BG" },
					{ title = "Czech [Czech Republic]",		value = "cs-CZ" },
					{ title = "Danish [Denmark]",			value = "da-DK" },
					{ title = "Greek [Greece]",				value = "el-GR" },
					{ title = "English [United Kingdom]",	value = "en-GB" },
					{ title = "Spanish [Spain]",			value = "es-ES" },
					{ title = "Finnish [Finland]",			value = "fi-FI" },
					{ title = "Norwegian [Norway]",			value = "no-NO" },
					{ title = "Dutch [Netherlands]",		value = "nl-NL" },
					{ title = "Romanian [Romania]",			value = "ro-RO" },
					{ title = "Polish [Poland]",			value = "pl-PL" },
				},
			},
		},
	}
end

-------------------------------------------------------------------------------

function LanguageExternalToolFilterProvider.postProcessRenderedPhotos( functionContext, filterContext )

	local lang = filterContext.propertyTable.language
	local title = filterContext.propertyTable.title
	
	local renditionOptions = {
		plugin = _PLUGIN,
		renditionsToSatisfy = filterContext.renditionsToSatisfy,
		filterSettings = function( renditionToSatisfy, exportSettings )
		
			-- This hook function gives you the opportunity to change the render
			-- settings for each photo before Lightroom renders it.
			-- For example, if you wanted Lightroom to generate TIFF files,
			-- you can add below statements:
			-- exportSettings.LR_format = TIFF
			-- return os.tmpname()
			-- By doing so, you assume responsibility for creating
			-- the file type that was originally requested and placing it
			-- in the location that was originally requested in your filter loop below.
			
		end,
	}
		
	local command
	local quotedCommand
			
	for sourceRendition, renditionToSatisfy in filterContext:renditions( renditionOptions ) do
	
		-- Wait for the upstream task to finish its work on this photo.
		
		local success, pathOrMessage = sourceRendition:waitForRender()
		if success then
		
			-- Now that the photo is completed and available to this filter,
			-- you can do your work on the photo here. This sample passes the user's settings,
			-- the title and language to an external application to update the metadata.
			
			local path = pathOrMessage
					
			if WIN_ENV == true then
	   			command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), "LightroomLanguageXMP.exe" ) .. '" ' .. '"' .. path .. '" ' .. '"' .. lang .. '" ' .. '"' .. title .. '" '
				quotedCommand = '"' .. command .. '"'
			else
				command = '"' .. LrPathUtils.child(LrPathUtils.child( _PLUGIN.path, "mac" ), "LightroomLanguageXMP" ) .. '" ' .. '"' .. path .. '" ' .. '"' .. lang .. '" ' .. '"' .. title .. '"'
				quotedCommand = command
			end
			
			if LrTasks.execute( quotedCommand ) ~= 0 then
				renditionToSatisfy:renditionIsDone( false, "Failed to contact Language XMP Application" )
			end
		
		end
	
	end

end

-------------------------------------------------------------------------------

return LanguageExternalToolFilterProvider
