--[[----------------------------------------------------------------------------

FlickrMetadataDefinition.lua
Custom metadata definition for Flickr publish plug-in

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2009 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

return {

	metadataFieldsForPhotos = {
	
		{
			id = 'previous_tags',
			dataType = 'string',
		},

	},
	
	schemaVersion = 2, -- must be a number, preferably a positive integer
	
}
