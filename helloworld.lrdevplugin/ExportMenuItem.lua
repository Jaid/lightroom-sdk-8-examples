--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

ExportMenuItem.lua
From the Hello World sample plug-in. Displays a modal dialog and writes debug info.

------------------------------------------------------------------------------]]

-- Access the Lightroom SDK namespaces.
local LrDialogs = import 'LrDialogs'
local LrLogger = import 'LrLogger'

-- Create the logger and enable the print function.
local myLogger = LrLogger( 'exportLogger' )
myLogger:enable( "print" ) -- Pass either a string or a table of actions.

--------------------------------------------------------------------------------
-- Write trace information to the logger.

local function outputToLog( message )
	myLogger:trace( message )
end

--------------------------------------------------------------------------------
-- Display a modal information dialog.

local function showModalDialog()

	outputToLog( "MyHWExportItem.showModalMessage function entered." )
	LrDialogs.message( "ExportMenuItem Selected", "Hello World!", "info" );
	outputToLog( "MyHWExportItem.showModalMessage function exiting." )
	
end

--------------------------------------------------------------------------------
-- Display a dialog.
showModalDialog()


