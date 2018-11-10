--[[----------------------------------------------------------------------------

AllMetadataTagset.lua
This tagset shows examples of displaying different types of metadata available within Lightroom
When in Lightroom choose "All Metadata" from the drop down menu in the Metadata panel.

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

	title = LOC "$$$/CustomMetadata/Fields/AllPreset=All Metadata",
	id = "all",
	
	items = {
		"com.adobe.filename",
		"com.adobe.originalFilename.ifDiffers",
		"com.adobe.sidecars",
		"com.adobe.copyname",
		"com.adobe.folder",
		"com.adobe.filesize",
		"com.adobe.fileFormat",
		"com.adobe.metadataStatus",
		"com.adobe.metadataDate",
		"com.adobe.audioAnnotation",
		
		"com.adobe.allPluginMetadata",

		"com.adobe.separator",
		
		"com.adobe.rating",
		
		"com.adobe.separator",
		
		"com.adobe.colorLabels",
		
		"com.adobe.separator",
		
		"com.adobe.title",
	  {	"com.adobe.caption", height_in_lines = 3 },

		"com.adobe.separator",
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/CustomMetadata/Fields/ExifLabel=EXIF",
		},

		"com.adobe.imageFileDimensions",		-- dimensions
		"com.adobe.imageCroppedDimensions",

		"com.adobe.exposure",					-- exposure factors
		"com.adobe.brightnessValue",
		"com.adobe.exposureBiasValue",
		"com.adobe.flash",
		"com.adobe.exposureProgram",
		"com.adobe.meteringMode",
		"com.adobe.ISOSpeedRating",
		
		"com.adobe.focalLength",				-- lens info
		"com.adobe.focalLength35mm",
		"com.adobe.lens",
		"com.adobe.subjectDistance",

		"com.adobe.dateTimeOriginal",
		"com.adobe.dateTimeDigitized",
		"com.adobe.dateTime",

		"com.adobe.make",						-- camera
		"com.adobe.model",
		"com.adobe.serialNumber",
		
		"com.adobe.userComment",
		
		"com.adobe.artist",
		"com.adobe.software",

		"com.adobe.GPS",						-- gps
		"com.adobe.GPSAltitude",
		"com.adobe.GPSImgDirection",

		"com.adobe.separator",
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/CustomMetadata/Fields/CreatorInfoLabel=Contact",
		},
		
		"com.adobe.creator",
		{ formatter = "com.adobe.creatorJobTitle", form = "shortTitle" },
		{ formatter = "com.adobe.creatorAddress", form = "shortTitle" },
		{ formatter = "com.adobe.creatorCity", form = "shortTitle" },
		{ formatter = "com.adobe.creatorState", form = "shortTitle" },
		{ formatter = "com.adobe.creatorZip", form = "shortTitle" },
		{ formatter = "com.adobe.creatorCountry", form = "shortTitle" },
		{ formatter = "com.adobe.creatorWorkPhone", form = "shortTitle" },
		{ formatter = "com.adobe.creatorWorkEmail", form = "shortTitle" },
		{ formatter = "com.adobe.creatorWorkWebsite", form = "shortTitle" },
		
		"com.adobe.separator",
		{
			formatter = "com.adobe.label",
		  	label = LOC "$$$/CustomMetadata/Fields/IPTCLabel=IPTC",
		},

		"com.adobe.headline",
		"com.adobe.iptcSubjectCode",
		"com.adobe.descriptionWriter",
		"com.adobe.category",
		"com.adobe.supplementalCategories",
		
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/CustomMetadata/Fields/FormalDescriptiveInfo=Image",
		},
		"com.adobe.dateCreated",
		"com.adobe.intellectualGenre",
		"com.adobe.scene",
		"com.adobe.location",
		"com.adobe.city",
		"com.adobe.state",
		"com.adobe.country",
		"com.adobe.isoCountryCode",
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/CustomMetadata/Fields/Workflow=Workflow",
		},
		"com.adobe.jobIdentifier",
		"com.adobe.instructions",
		"com.adobe.provider",
		"com.adobe.source",
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/CustomMetadata/Fields/Copyright=Copyright",
		},
	  { "com.adobe.copyrightState", pruneRedundantFields = false },
		"com.adobe.copyright",
		"com.adobe.rightsUsageTerms",
		"com.adobe.copyrightInfoURL",
		
	},
	
}
