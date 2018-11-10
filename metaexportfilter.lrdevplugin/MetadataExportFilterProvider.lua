--[[----------------------------------------------------------------------------

ExportFilterProvider.lua
metaExportFilter Sample Plugin
ExportFilterProvider for the Metadata Export Filter sample plugin

Defines the dialog section to be displayed in the Export dialog and provides the
filter process before the photos are exported.

--------------------------------------------------------------------------------
ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

local LrView = import 'LrView'
local bind = LrView.bind

--------------------------------------------------------------------------------
-- This function will check the status of the Export Dialog to determine
-- if all required fields have been populated.

local function updateFilterStatus( propertyTable, ... )

	-- Initialise potential error message.
	local message = nil
	
	if propertyTable.metachoice == nil then
		message = LOC "$$$/SDK/MetaExportFilter/Messages/choice=Please choose which type of metadata to filter"
        elseif propertyTable.metavalue == nil then
		message = LOC "$$$/SDK/MetaExportFilter/Messages/choice=Please enter the required matching string"
	end
	
	if message then
		-- Display error.
		propertyTable.message = message
		propertyTable.hasError = true
		propertyTable.hasNoError = false
		propertyTable.LR_canExport = false

	else
		-- All required fields have been populated so enable Export button, reset message, and set error status to false.
		propertyTable.message = nil
		propertyTable.hasError = false
		propertyTable.hasNoError = true
		propertyTable.LR_canExport = true
	end
end

--------------------------------------------------------------------------------
-- This optional function adds the observers for our required fields metachoice and metavalue so we can change
-- the dialog depending on whether they have been populated.

local function startDialog( propertyTable )

	propertyTable:addObserver( 'metachoice', updateFilterStatus )
	propertyTable:addObserver( 'metavalue', updateFilterStatus )
	updateFilterStatus( propertyTable )

end

--------------------------------------------------------------------------------
-- This function will create the section displayed on the export dialog
-- when this filter is added to the export session.

local function sectionForFilterInDialog( f, propertyTable )
	
	return {
		title = LOC "$$$/SDK/MetaExportFilter/SectionTitle=Metadata Export Filter",
		f:row {
			spacing = f:control_spacing(),
			f:static_text {
				title = "Metadata Filter",
				fill_horizontal = 1,
			},

			f:popup_menu {
				value = bind 'metachoice',
				items = {
					{ title = "Title",			value = "title" },
					{ title = "Creator",			value = "creator" },
					{ title = "Copyright Status",	value = "copyright" },
					{ title = "File Name",			value = "fileName" },
					{ title = "Folder",			value = "folderName" },
				},
			},

			f:edit_field {
				value = bind 'metavalue',
			},
		}
	}
end

--------------------------------------------------------------------------------
-- We specify any presets here

local exportPresetFields = {
	{ key = 'metachoice', 	default = "Creator" },
	{ key = 'metavalue', 	default = '' },
}

--------------------------------------------------------------------------------
-- This function obtains access to the photos and removes entries that don't match the metadata filter.

local function shouldRenderPhoto( exportSettings, photo )

	-- This function should return either:
	--   true, photo gets included in export, or
	--   false, photo should be removed from the export.
	-- The photo represents an LrPhoto object.
	
	local targetField = exportSettings.metachoice
	local targetValue = exportSettings.metavalue

	-- Now that the user has filled in this section, we need to filter through the images and only
	-- choose the ones that match the required metadata.

	local sourceMetaValue = photo:getFormattedMetadata( targetField )
	
    local shouldRender = sourceMetaValue == targetValue

	return shouldRender
	
end

--------------------------------------------------------------------------------

return {

	exportPresetFields = exportPresetFields,
	startDialog = startDialog,
	sectionForFilterInDialog = sectionForFilterInDialog,
	shouldRenderPhoto = shouldRenderPhoto,
}
