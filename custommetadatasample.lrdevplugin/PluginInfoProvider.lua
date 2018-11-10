--[[----------------------------------------------------------------------------

PluginInfoProvider.lua

Responsible for managing the dialog entry in the Plugin Manager dialog window which
manages the individual plug-ins installed in the Lightroom application.

This will create a section in the Plugin Manager Dialog window.  This example creates a
label and button that when clicked launches a browser window and opens http://www.adobe.com

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

local LrHttp = import "LrHttp"

local function sectionsForTopOfDialog( f, _ )
	return {
			-- Section for the top of the dialog.
			{
				title = LOC "$$$/CustomMetadata/PluginManager=Custom Metadata Sample",
				f:row {
					spacing = f:control_spacing(),

					f:static_text {
						title = LOC "$$$/CustomMetadata/Title1=Click the button to find out more about Adobe",
						fill_horizontal = 1,
					},

					f:push_button {
						width = 150,
						title = LOC "$$$/CustomMetadata/ButtonTitle=Connect to Adobe",
						enabled = true,
						action = function()
							LrHttp.openUrlInBrowser( PluginInit.URL )
						end,
					},
				},
				f:row {
					f:static_text {
						title = LOC "$$$/CustomMetadata/Title2=Global default value for displayImage: ",
					},
					f:static_text {
						title = PluginInit.currentDisplayImage,
						fill_horizontal = 1,
					},
				},
			},
	
		}
end

return{

	sectionsForTopOfDialog = sectionsForTopOfDialog,

}
