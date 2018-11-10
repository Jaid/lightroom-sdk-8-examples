--[[----------------------------------------------------------------------------

CustomMetadataDefinition.lua
Sample custom metadata definition

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

require "PluginInit"

return {

	metadataFieldsForPhotos = {
	
		{
			id = 'siteId',
			
			-- This field will not be available in the metadata browser because
			-- it does not have a title field. You might use a field like this
			-- to store a photo ID from an external database or web service.
			
		},
		{
			id = 'randomString',
			title = LOC "$$$/CustomMetadata/Fields/RandomString=Random String",
			dataType = 'string', -- Specifies the data type for this field.
			browsable = true,
			searchable = true,
		},
		{
			id = 'readonlyString',
			title = LOC "$$$/CustomMetadata/Fields/ReadOnlyString=Another String",
			dataType = 'string', -- Specifies the data type for this field.
			searchable = true
		},

		{
			id = 'displayImage',
			title = LOC "$$$/CustomMetadata/Fields/Display=Display Image",
			dataType = 'enum',
			values = {
				{
					value = 'no',
					title = LOC "$$$/CustomMetadata/Fields/Display/No=No",
				},
				{
					value = 'yes',
					title = LOC "$$$/CustomMetadata/Fields/Display/Yes=Yes",
				},
				allowPluginToSetOtherValues = true,
			},
		},
		{
			id = 'url',
			title = LOC "$$$/CustomMetadata/Fields/Display/URL=URL",
			dataType = 'url',
		},
	},
	
	schemaVersion = 1, -- must be a number, preferably a positive integer
	
	updateFromEarlierSchemaVersion = function( catalog, previousSchemaVersion )
		-- Note: This function is called from within a catalog:withPrivateWriteAccessDo
		-- block. You should not call any of the with___Do functions yourself.

        catalog:assertHasPrivateWriteAccess( "CustomMetadataDefinition.updateFromEarlierSchemaVersion" )

        if previousSchemaVersion == 1 then
	
			-- Retrieve photos that have been used already with the custom metadata.
			
			local photosToMigrate = catalog:findPhotosWithProperty( PluginInit.pluginID, 'siteId' )
			
				-- Optional:  can add property version number here.
				
				for _, photo in ipairs( photosToMigrate ) do
					local oldSiteId = photo:getPropertyForPlugin( PluginInit.pluginID, 'siteId' ) -- add property version here if used above
                	local newSiteId = "new:" .. oldSiteId -- replace this with whatever data transformation you need to do
                	photo:setPropertyForPlugin( _PLUGIN, 'siteId', newSiteId )
				end
		elseif previousSchemaVersion == 2 then
		
			-- Optional area to do further processing etc.
        end
    end,

}
