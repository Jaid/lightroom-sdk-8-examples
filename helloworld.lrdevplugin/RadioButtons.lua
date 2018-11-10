--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

RadioButton.lua
From the Hello World sample plug-in. Displays several custom dialogs and writes debug info.

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
myLogger:enable( "print" ) -- Pass either a string or a table of actions

-- Write trace information to the logger.

local function outputToLog( message )
	myLogger:trace( message )
end


--[[
	Demonstrates a custom dialog with a complex binding. The dialog displays two
	radio buttons and a label.  The contents of the label are updated depending on
	which button is selected.
	
	All three controls are bound to the same value in an observed table.  Whenever
	the property 'selectedButton' is modified then changes are reflected in the radio
	buttons and the label.
	
	The static_text.title value uses a binding with a transform function.  The value retuned
	from the transform function is a string of our choosing, rather than the value of the
	bound property.  In this case the label simply updates to whichever button is selected.
		
]]
local function showCustomDialogWithTransform()

	LrFunctionContext.callWithContext( "RadioButtons", function( context )
	
		-- Create a bindable table.  Whenever a field in this table changes
		-- then notifications will be sent.
		
		local props = LrBinding.makePropertyTable( context )
		props.selectedButton = "one"
				
		local f = LrView.osFactory()
		
		local c = f:column {
			bindToObject = props,
			spacing = f:control_spacing(),
			
			f:row{
				f:column {
			
					spacing = f:control_spacing(),
					
					-- A radio button is selected when its value is equal to its checked_value.
					
					f:radio_button {
						title = "Button one",
						value = LrView.bind( "selectedButton" ),
						checked_value = "one",
					},
					
					f:radio_button {
						title = "Button two",
						value = LrView.bind( "selectedButton" ),
						checked_value = "two",
					},
				},
			},
			
			f:row {
	
				f:static_text {
					text_color = LrColor( 1, 0, 0 ),
					title = LrView.bind(
					{
						key = "selectedButton", -- the key value to bind to.  The property table (props) is already bound
						transform = function( value, _ )
							outputToLog( "showCustomDialogWithTransform" .. value )
							if value == "one" then
								return "Button one selected"
							else
								return "Button two selected"
							end
						end
					}),
				}
			},
		}
		
		LrDialogs.presentModalDialog {
			title = "Custom Dialog Transform",
			contents = c
		}
	
	end) -- end callWithContext
	
end


-- Now display the dialogs
showCustomDialogWithTransform()
