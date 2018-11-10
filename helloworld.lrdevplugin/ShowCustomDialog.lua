--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

ShowCustomDialog.lua
From the Hello World sample plug-in. Displays a custom dialog and writes debug info.

------------------------------------------------------------------------------]]

-- Access the Lightroom SDK namespaces.
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'

--[[
	Demonstrates a custom dialog with a simple binding. The dialog displays a
	checkbox and a text field.  When the check box is selected the text field becomes
	enabled, if the checkbox is unchecked then the text field is disabled.
	
	The check_box.value and the edit_field.enabled are bound to the same value in an
	observable table.  When the check_box is checked/unchecked the changes are reflected
	in the bound property 'isChecked'.  Because the edit_field.enabled value is also bound then
	it reflects whatever value 'isChecked' has.
]]
local function showCustomDialog()

	LrFunctionContext.callWithContext( "showCustomDialog", function( context )
	
	    local f = LrView.osFactory()

	    -- Create a bindable table.  Whenever a field in this table changes
	    -- then notifications will be sent.
	    local props = LrBinding.makePropertyTable( context )
	    props.isChecked = false

	    -- Create the contents for the dialog.
	    local c = f:row {
	
		    -- Bind the table to the view.  This enables controls to be bound
		    -- to the named field of the 'props' table.
		    
		    bind_to_object = props,
				
		    -- Add a checkbox and an edit_field.
		    
		    f:checkbox {
			    title = "Enable",
			    value = LrView.bind( "isChecked" ),
		    },
		    f:edit_field {
			    value = "Some Text",
			    enabled = LrView.bind( "isChecked" )
		    }
	    }
	
	    LrDialogs.presentModalDialog {
			    title = "Custom Dialog",
			    contents = c
		    }


	end) -- end main function

end


-- Now display the dialogs.
showCustomDialog()
