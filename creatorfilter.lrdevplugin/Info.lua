--[[----------------------------------------------------------------------------

Info.lua
Summary information for creator filter plug-in

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

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 2.0,

	LrPluginName = "Creator External Tool",
	LrToolkitIdentifier = 'com.adobe.lightroom.sdk.export.creator',
	
	LrExportFilterProvider = {
		title = "Creator External Tool",
		file = 'CreatorExternalToolFilterProvider.lua',
	},

	VERSION = { major=8, minor=0, revision=0, build=1193777, },

}
