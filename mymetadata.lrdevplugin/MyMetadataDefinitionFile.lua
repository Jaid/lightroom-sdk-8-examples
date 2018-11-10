--[[----------------------------------------------------------------------------

MyMetadataDefinitionFile.lua
MyMetadata.lrplugin

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

return {

	metadataFieldsForPhotos = {

		{
			id = 'siteId',
		},

		{
			id = 'myString',
			title = "My String",
			dataType = 'string', -- Specifies the data type for this field.
			searchable = true,
			browsable = true,
			version = 2,
		},

		{
			id = 'myboolean',
			title = "My Boolean",
			dataType = 'enum',
			searchable = true,
			browsable = true,
			version = 2,
			values = {
				{
					value = 'true',
					title = "True",
				},
				{
					value = 'false',
					title = "False",
				},
			},
		},

	},
	
	schemaVersion = 1,

}
