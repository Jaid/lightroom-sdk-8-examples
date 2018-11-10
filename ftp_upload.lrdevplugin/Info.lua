--[[----------------------------------------------------------------------------

Info.lua
Summary information for ftp_upload sample plug-in

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.


------------------------------------------------------------------------------]]

return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.adobe.lightroom.export.ftp_upload',

	LrPluginName = LOC "$$$/FTPUpload/PluginName=FTP Upload Sample",
	
	LrExportServiceProvider = {
		title = "FTP Upload",
		file = 'FtpUploadServiceProvider.lua',
	},

	VERSION = { major=8, minor=0, revision=0, build=1193777, },

}
