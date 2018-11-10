--[[----------------------------------------------------------------------------

DisplayMetadata.lua
Summary information for custom metadata dialog sample plugin

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local catalog = LrApplication.activeCatalog()

CMMenuItem = {}


function CMMenuItem.sortImages()

	-- Get a reference to the photos within the current catalog.
	
	local catPhotos = catalog.targetPhotos
	
	local titles = {}
	
	-- Create an array that will store strings detailing the photos.
	
	for _, photo in ipairs( catPhotos ) do
		-- Loop through each of the photos.
		
		-- We now have access to the photo so let's try and access the custom metadata.
		
		local display = photo:getPropertyForPlugin( 'com.adobe.lightroom.sdk.metadata.custommetadatasample', 'displayImage' )
		if display then
		
			-- The photo has a value for this custom metadata so let's continue.
			
			if display == 'yes' then
			
				-- We only want to display photos that have the custom metadata field displayImage set to 'yes'.
				
				local imageDetails = photo:getFormattedMetadata( 'fileName' )
				local randomString = photo:getPropertyForPlugin( 'com.adobe.lightroom.sdk.metadata.custommetadatasample', 'randomString' )
				if randomString then
					imageDetails = imageDetails .. "\t" .. randomString
				end
				
				-- The above code has checked the values of the custom metadata randomString and rating defined by the plugin
				-- customemetadatasample.  see customMetadataSample.lrdevplugin in the Lightroom SDK.
				-- If there are valid entries the values of these fields have been appended to the variable imageDetails.
				
				titles[ #titles + 1 ] = imageDetails
			end
		end
	end
	
	-- Now pass the keywords to the showModalDialog method for processing.
	
	CMMenuItem.showModalDialog( titles )

end

-- Now display a dialog with the new file entries.

function CMMenuItem.showModalDialog( keys )
	local message = "Matching Strings - " .. #keys
	
	-- We have been passed the keys so now need to loop through the items and add them to a string ready for displaying.
	
	for _, title in ipairs( keys ) do
		message = message .. "\n" .. title
	end
	
	LrDialogs.message( "Custom Metadata Dialog", message, "info" )
end

import 'LrTasks'.startAsyncTask( CMMenuItem.sortImages )
