--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

CustomDialogWithObserver.lua
From the Hello World sample plug-in. Displays several custom dialog and writes debug info.

------------------------------------------------------------------------------]]

-- Access the Lightroom SDK namespaces.

local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrColor = import 'LrColor'

-- Create the logger and enable the print function.

local myLogger = LrLogger( 'libraryLogger' )
myLogger:enable( "print" ) -- Pass either a string or a table of actions.

-- Write trace information to the logger.

local function outputToLog( message )
	myLogger:trace( message )
end

--[[
	Demonstrates a custom dialog with a simple binding. The dialog has a text field
	that is used to update a value in an observable table.  The table has an observer
	attached that will be notified when a key value is updated.  The observer is
	only interested in the props.myObservedString.  When that value changes the
	observer will be notified.
]]
local function showCustomDialogWithObserver()

	LrFunctionContext.callWithContext( "showCustomDialogWithObserver", function( context )
	
		-- Create a bindable table.  Whenever a field in this table changes then notifications
		-- will be sent.  Note that we do NOT bind this to the UI.
		
		local props = LrBinding.makePropertyTable( context )
		props.myObservedString = "This is my string"
		
		local f = LrView.osFactory()
				
		-- Create the UI components like this so we can access the values as vars.
		
		local staticTextValue = f:static_text {
			title = props.myObservedString,
		}

		local updateField = f:edit_field {
			immediate = true,
			value = "Enter some text!!"
		}
				
		-- This is the function that will run when the value props.myString is changed.
		
		local function myCalledFunction()
			outputToLog( "props.myObservedString has been updated." )
			staticTextValue.title = updateField.value
			staticTextValue.text_color = LrColor ( 1, 0, 0 )
		end
		
		-- Add an observer to the property table.  We pass in the key and the function
		-- we want called when the value for the key changes.
		-- Note:  Only when the value changes will there be a notification sent which
		-- causes the function to be invoked.
		
		props:addObserver( "myObservedString", myCalledFunction )
				
		-- Create the contents for the dialog.
		
		local c = f:column {
			spacing = f:dialog_spacing(),
			f:row{
				fill_horizontal  = 1,
				f:static_text {
					alignment = "right",
					width = LrView.share "label_width",
					title = "Bound value: "
				},
				staticTextValue,
			}, -- end f:row
			
			f:row {
				f:static_text {
					alignment = "right",
					width = LrView.share "label_width",
					title = "New value: "
				},
				updateField,
				f:push_button {
					title = "Update",
					
					-- When the 'Update' button is clicked.
					
					action = function()
						outputToLog( "Update button clicked." )
						staticTextValue.text_color = LrColor ( 0, 0, 0)
						
						-- When this property is updated, the observer is notified.
						
						props.myObservedString = updateField.value
					end
				},
			}, -- end row
		} -- end column
		
		LrDialogs.presentModalDialog {
				title = "Custom Dialog Observer",
				contents = c
			}

	end) -- end main function


end

-- Now display the dialogs.

showCustomDialogWithObserver()
