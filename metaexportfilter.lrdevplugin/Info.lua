--[[----------------------------------------------------------------------------

Info.lua
metaExportFilter Sample
Summary information for Metadata Export Filter plugin sample plugin
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
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plugin

	LrPluginName = LOC "$$$/SDK/MetaExportFilter/Sample=Metadata Post Process Sample",
	LrToolkitIdentifier = 'com.adobe.lightroom.sdk.export.metaexportfilter',
	
	LrExportFilterProvider = {
		title = LOC "$$$/SDK/MetaExportFilter/Sample=Metadata Post Process", -- the string that appears in the export filter section of the export dialog in LR
		file = 'MetadataExportFilterProvider.lua', -- name of the file containing the filter definition script
		id = "metadata",  -- unique identifier for export filter
	},

	VERSION = { major=8, minor=0, revision=0, build=1193777, },

}
