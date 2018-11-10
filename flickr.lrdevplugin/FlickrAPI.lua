--[[----------------------------------------------------------------------------

FlickrAPI.lua
Common code to initiate Flickr API requests

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

	-- Lightroom SDK
local LrBinding = import 'LrBinding'
local LrDate = import 'LrDate'
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrFunctionContext = import 'LrFunctionContext'
local LrHttp = import 'LrHttp'
local LrMD5 = import 'LrMD5'
local LrPathUtils = import 'LrPathUtils'
local LrView = import 'LrView'
local LrXml = import 'LrXml'

local prefs = import 'LrPrefs'.prefsForPlugin()

local bind = LrView.bind
local share = LrView.share

local logger = import 'LrLogger'( 'FlickrAPI' )


--============================================================================--

FlickrAPI = {}

--------------------------------------------------------------------------------

local appearsAlive

--------------------------------------------------------------------------------

local function formatError( nativeErrorCode )
	return LOC "$$$/Flickr/Error/NetworkFailure=Could not contact the Flickr web service. Please check your Internet connection."
end

--------------------------------------------------------------------------------

local simpleXmlMetatable = {
	__tostring = function( self ) return self._value end
}

--------------------------------------------------------------------------------

local function traverse( node )

	local type = string.lower( node:type() )

	if type == 'element' then

		local element = setmetatable( {}, simpleXmlMetatable )
		element._name = node:name()
		element._value = node:text()
		
		local count = node:childCount()

		for i = 1, count do
			local name, value = traverse( node:childAtIndex( i ) )
			if name and value then
				element[ name ] = value
			end
		end

		if type == 'element' then
			for k, v in pairs( node:attributes() ) do
				element[ k ] = v.value
			end
		end
		
		return element._name, element

	end

end

--------------------------------------------------------------------------------

local function xmlElementToSimpleTable( xmlString )

	local _, value = traverse( LrXml.parseXml( xmlString ) )
	return value

end

--------------------------------------------------------------------------------

local function trim( s )

	return string.gsub( s, "^%s*(.-)%s*$", "%1" )

end

--------------------------------------------------------------------------------

-- We can't include a Flickr API key with the source code for this plug-in, so
-- we require you obtain one on your own and enter it through this dialog.

--------------------------------------------------------------------------------

function FlickrAPI.showApiKeyDialog( message )

	-- A warning for the benefit of users who try to run this sample plug-in, which
	-- is obsolete now that Flickr requires OAuth authentication.
	LrErrors.throwUserError( LOC "$$$/Flickr/ApiKeyDialog/NoOauth=This sample plug-in was written for a deprecated form of Flickr authentication. Flickr now requires OAuth, which this plug-in does not support." )

	-- Leaving this code in place for sample code reference purposes, even though it will
	-- no longer ever be executed, given the above error.
	LrFunctionContext.callWithContext( 'FlickrAPI.showApiKeyDialog', function( context )

		local f = LrView.osFactory()
	
		local properties = LrBinding.makePropertyTable( context )
		properties.apiKey = prefs.apiKey
		properties.sharedSecret = prefs.sharedSecret
	
		local contents = f:column {
			bind_to_object = properties,
			spacing = f:control_spacing(),
			fill = 1,
	
			f:static_text {
				title = LOC "$$$/Flickr/ApiKeyDialog/Message=In order to use this sample plug-in, you must obtain an API key from flickr.com. Sign on to Flickr and register for a key under Explore > Flickr Services > Your API Keys.",
				fill_horizontal = 1,
				width_in_chars = 55,
				height_in_lines = 2,
				size = 'small',
			},
	
			message and f:static_text {
				title = message,
				fill_horizontal = 1,
				width_in_chars = 55,
				height_in_lines = 2,
				size = 'small',
				text_color = import 'LrColor'( 1, 0, 0 ),
			} or 'skipped item',
			
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = LOC "$$$/Flickr/ApiKeyDialog/Key=API Key:",
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field {
					fill_horizonal = 1,
					width_in_chars = 35,
					value = bind 'apiKey',
						-- TO DO: Should validate API key (16 hex digits, etc.).
				},
			},
			
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = LOC "$$$/Flickr/ApiKeyDialog/Secret=Shared Secret:",
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field {
					fill_horizonal = 1,
					width_in_chars = 19,
					value = bind 'sharedSecret',
				},
			},
		}
		
		local result = LrDialogs.presentModalDialog {
				title = LOC "$$$/Flickr/ApiKeyDialog/Title=Enter Your Flickr API Key",
				contents = contents,
				accessoryView = f:push_button {
					title = LOC "$$$/Flickr/ApiKeyDialog/GoToFlickr=Get Flickr API Key...",
					action = function()
						LrHttp.openUrlInBrowser( "http://www.flickr.com/services/api/keys/" )
					end
				},
			}
		
		if result == 'ok' then
	
			prefs.apiKey = trim ( properties.apiKey )
			prefs.sharedSecret = trim ( properties.sharedSecret )
		
		else
		
			LrErrors.throwCanceled()
		
		end
	
	end )
	
end

--------------------------------------------------------------------------------

function FlickrAPI.getApiKeyAndSecret()

	local apiKey, sharedSecret = prefs.apiKey, prefs.sharedSecret
	
	while not(
		type( apiKey ) == 'string' and #apiKey == 32 and
		type( sharedSecret ) == 'string' and #sharedSecret == 16
	) do
	
		local message
		if apiKey or sharedSecret then
			message = LOC "$$$/Flickr/ApiKeyDialog/Invalid=The key below is not valid."
		end

		FlickrAPI.showApiKeyDialog( message )

		apiKey, sharedSecret = prefs.apiKey, prefs.sharedSecret
	
	end
	
	return apiKey, sharedSecret

end

--------------------------------------------------------------------------------

function FlickrAPI.makeApiSignature( params )

	-- If no API key, add it in now.
	
	local apiKey, sharedSecret = FlickrAPI.getApiKeyAndSecret()
	
	if not params.api_key then
		params.api_key = apiKey
	end

	-- Get list of arguments in sorted order.

	local argNames = {}
	for name in pairs( params ) do
		table.insert( argNames, name )
	end
	
	table.sort( argNames )

	-- Build the secret string to be MD5 hashed.
	
	local allArgs = sharedSecret
	for _, name in ipairs( argNames ) do
		if params[ name ] then  -- might be false
			allArgs = string.format( '%s%s%s', allArgs, name, params[ name ] )
		end
	end
	
	-- MD5 hash this string.

	return LrMD5.digest( allArgs )

end

--------------------------------------------------------------------------------

function FlickrAPI.callRestMethod( propertyTable, params )

	-- Automatically add API key.
	
	local apiKey = FlickrAPI.getApiKeyAndSecret()
	
	if not params.api_key then
		params.api_key = apiKey
	end
	
	-- Remove any special values from params.

	local suppressError = params.suppressError
	local suppressErrorCodes = params.suppressErrorCodes
	local skipAuthToken = params.skipAuthToken

	params.suppressError = nil
	params.suppressErrorCodes = nil
	params.skipAuthToken = nil
	
	-- Build up the URL for this function.
	
	if not skipAuthToken and propertyTable then
		params.auth_token = params.auth_token or propertyTable.auth_token
	end
	
	params.api_sig = FlickrAPI.makeApiSignature( params )
	local url = string.format( 'http://www.flickr.com/services/rest/?method=%s', assert( params.method ) )
	
	for name, value in pairs( params ) do

		if name ~= 'method' and value then  -- the 'and value' clause allows us to ignore false

			-- URL encode each of the params.

			local gsubString = '([^0-9A-Za-z])'
			
			value = tostring( value )
			
			-- 'tag_id' contains '-' symbol.
			
			if name ~= 'tag_id' then
				value = string.gsub( value, gsubString, function( c ) return string.format( '%%%02X', string.byte( c ) ) end )
			end
			
			value = string.gsub( value, ' ', '+' )
			params[ name ] = value

			url = string.format( '%s&%s=%s', url, name, value )

		end

	end

	-- Call the URL and wait for response.

	logger:info( 'calling Flickr API via URL:', url )

	local response, hdrs = LrHttp.get( url )
	
	logger:info( 'Flickr response:', response )

	if not response then

		appearsAlive = false

		if suppressError then

			return { stat = "noresponse" }

		else
		
			if hdrs and hdrs.error then
				LrErrors.throwUserError( formatError( hdrs.error.nativeCode ) )
			end
			
		end

	end
	
	-- Mac has different implementation with that on Windows when the server refuses the request.
	
	if hdrs.status ~= 200 then
		LrErrors.throwUserError( formatError( hdrs.status ) )
	end
	
	appearsAlive = true

	-- All responses are XML. Parse it now.

	local simpleXml = xmlElementToSimpleTable( response )

	if suppressErrorCodes then

		local errorCode = simpleXml and simpleXml.err and tonumber( simpleXml.err.code )
		if errorCode and suppressErrorCodes[ errorCode ] then
			suppressError = true
		end

	end

	if simpleXml.stat == 'ok' or suppressError then

		logger:info( 'Flickr API returned status ' .. simpleXml.stat )
		return simpleXml, response
	
	else

		logger:warn( 'Flickr API returned error', simpleXml.err and simpleXml.err.msg )

		LrErrors.throwUserError( LOC( "$$$/Flickr/Error/API=Flickr API returned an error message (function ^1, message ^2)",
							tostring( params.method ),
							tostring( simpleXml.err and simpleXml.err.msg ) ) )

	end

end

--------------------------------------------------------------------------------

function FlickrAPI.uploadPhoto( propertyTable, params )

	-- Prepare to upload.
	
	assert( type( params ) == 'table', 'FlickrAPI.uploadPhoto: params must be a table' )
	
	local postUrl = params.photo_id and 'http://flickr.com/services/replace/' or 'http://flickr.com/services/upload/'
	local originalParams = params.photo_id and table.shallowcopy( params )

	logger:info( 'uploading photo', params.filePath )

	local filePath = assert( params.filePath )
	params.filePath = nil
	
	local fileName = LrPathUtils.leafName( filePath )
	
	params.auth_token = params.auth_token or propertyTable.auth_token
	
	params.tags = string.gsub( params.tags, ",", " " )
	
	params.api_sig = FlickrAPI.makeApiSignature( params )
	
	local mimeChunks = {}
	
	for argName, argValue in pairs( params ) do
		if argName ~= 'api_sig' then
			mimeChunks[ #mimeChunks + 1 ] = { name = argName, value = argValue }
		end
	end

	mimeChunks[ #mimeChunks + 1 ] = { name = 'api_sig', value = params.api_sig }
	mimeChunks[ #mimeChunks + 1 ] = { name = 'photo', fileName = fileName, filePath = filePath, contentType = 'application/octet-stream' }
	
	-- Post it and wait for confirmation.
	
	local result, hdrs = LrHttp.postMultipart( postUrl, mimeChunks )
	
	if not result then
	
		if hdrs and hdrs.error then
			LrErrors.throwUserError( formatError( hdrs.error.nativeCode ) )
		end
		
	end
	
	-- Parse Flickr response for photo ID.

	local simpleXml = xmlElementToSimpleTable( result )
	if simpleXml.stat == 'ok' then

		return simpleXml.photoid._value
	
	elseif params.photo_id and simpleXml.err and tonumber( simpleXml.err.code ) == 7 then
	
		-- Photo is missing. Most likely, the user deleted it outside of Lightroom. Just repost it.
		
		originalParams.photo_id = nil
		return FlickrAPI.uploadPhoto( propertyTable, originalParams )
	
	else

		LrErrors.throwUserError( LOC( "$$$/Flickr/Error/API/Upload=Flickr API returned an error message (function upload, message ^1)",
							tostring( simpleXml.err and simpleXml.err.msg ) ) )

	end

end

--------------------------------------------------------------------------------

function FlickrAPI.openAuthUrl()

	-- Request the frob that we need for authentication.

	local data = FlickrAPI.callRestMethod( nil, { method = 'flickr.auth.getFrob', skipAuthToken = true } )
	
	-- Get the frob from the response.
	
	local frob = assert( data.frob._value )

	-- Do the authentication. (This is not a standard REST call.)

	local apiKey = FlickrAPI.getApiKeyAndSecret()
	
	local authApiSig = FlickrAPI.makeApiSignature{ perms = 'delete', frob = frob }

	local authURL = string.format( 'http://flickr.com/services/auth/?api_key=%s&perms=delete&frob=%s&api_sig=%s',
						apiKey, frob, authApiSig )

	LrHttp.openUrlInBrowser( authURL )

	return frob

end

--------------------------------------------------------------------------------

local function getPhotoInfo( propertyTable, params )

	local data, response
	
	if params.is_public == 1 then
	
		data, response = FlickrAPI.callRestMethod( nil, {
									method = 'flickr.photos.getInfo',
									photo_id = params.photo_id,
									skipAuthToken = true,
								} )
	else
	
		-- http://flickr.com/services/api/flickr.photos.getFavorites.html
		
		data = FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.photos.getFavorites',
							photo_id = params.photo_id,
							per_page = 1,
							suppressError = true,
						} )
						
		if data.stat ~= "ok" then
		
			return
			
		else
			
			local secret = data.photo.secret
		
			data,response = FlickrAPI.callRestMethod( nil, {
									method = 'flickr.photos.getInfo',
									photo_id = params.photo_id,
									skipAuthToken = true,
									secret = secret,
								} )
		end
		
	end
	
	return data, response

end

--------------------------------------------------------------------------------

function FlickrAPI.constructPhotoURL( propertyTable, params )

	local data = getPhotoInfo( propertyTable, params )
							
	local photoUrl = data and data.photo and data.photo.urls and data.photo.urls.url and data.photo.urls.url._value
	
	if params.photosetId then

		if photoUrl:sub( -1 ) ~= '/' then
			photoUrl = photoUrl .. "/"
		end
	
		return photoUrl .. "in/set-" .. params.photosetId
		
	else
	
		return photoUrl
		
	end
	
end

--------------------------------------------------------------------------------

function FlickrAPI.constructPhotosetURL( propertyTable, photosetId )

	return "http://www.flickr.com/photos/" .. propertyTable.nsid .. "/sets/" .. photosetId

end


--------------------------------------------------------------------------------

function FlickrAPI.constructPhotostreamURL( propertyTable )

	return "http://www.flickr.com/photos/" .. propertyTable.nsid .. "/"

end

-------------------------------------------------------------------------------

local function traversePhotosetsForTitle( node, title )

	local nodeType = string.lower( node:type() )

	if nodeType == 'element' then
		
		if node:name() == 'photoset' then
		
			local _, photoset = traverse( node )
			
			local psTitle = photoset.title
			if type( psTitle ) == 'table' then
				psTitle = psTitle._value
			end
			
			if psTitle == title then
				return photoset.id
			end
		
		else
		
			local count = node:childCount()
			for i = 1, count do
				local photosetId = traversePhotosetsForTitle( node:childAtIndex( i ), title )
				if photosetId then
					return photosetId
				end
			end
			
		end

	end

end

--------------------------------------------------------------------------------

function FlickrAPI.createOrUpdatePhotoset( propertyTable, params )
	
	local needToCreatePhotoset = true
	local data, response
	
	if params.photosetId then

		data, response = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.getInfo',
								photoset_id = params.photosetId,
								suppressError = true,
							} )
							
		if data and data.photoset then
			needToCreatePhotoset = false
			params.primary_photo_id = params.primary_photo_id or data.photoset.primary
		end

	else

		data, response = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.getList',
							} )

		local photosetsNode = LrXml.parseXml( response )
		
		local photosetId = traversePhotosetsForTitle( photosetsNode, params.title )
		
		if photosetId then
			params.photosetId = photosetId
			needToCreatePhotoset = false
		end
	
	end
	
	if needToCreatePhotoset then
		data, response = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.create',
								title = params.title,
								description = params.description,
								primary_photo_id = params.primary_photo_id,
							} )
	else
		data, response = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.editMeta',
								photoset_id = params.photosetId,
								title = params.title,
								description = params.description,
							} )
	end
	
	if not needToCreatePhotoset then
		return params.photosetId, FlickrAPI.constructPhotosetURL( propertyTable, params.photosetId )
	else
		return data.photoset.id, data.photoset.url
	end
end

--------------------------------------------------------------------------------

function FlickrAPI.listPhotosFromPhotoset( propertyTable, params )
	
	local results = {}
	local data, response
	local numPages, curPage = 1, 0
	
	while curPage < numPages do

		curPage = curPage + 1
		
		data, response = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.getPhotos',
								photoset_id = params.photosetId,
								page = curPage,
								suppressError = true,
							} )

		if data.stat ~= "ok" then
			-- Be sure to not return 'nil', because that can cause errors
			-- for the calling function if it is banking on an array being returned,
			-- which, as of right now (10/20/2010) it is.
			return {}
		end

		-- Break out the XSLT here, as the simple parser isn't going to work for us.
		-- (since we're getting multiple items back).

		local xslt = [[
					<xsl:stylesheet
						version="1.0"
						xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					>
					<xsl:output method="text"/>
					<xsl:template match="*">
						return {<xsl:apply-templates />
						}
					</xsl:template>
					<xsl:template match="photoset">
							photoset = {
								id = "<xsl:value-of select="@id"/>",
								primary = "<xsl:value-of select="@primary"/>",
								owner = "<xsl:value-of select="@owner"/>",
								ownername = "<xsl:value-of select="@ownername"/>",
								page = "<xsl:value-of select="@page"/>",
								per_page = "<xsl:value-of select="@per_page"/>",
								pages = "<xsl:value-of select="@pages"/>",
								total = "<xsl:value-of select="@total"/>",
								
								photos = {
									<xsl:for-each select="photo">
										{ id = "<xsl:value-of select="@id"/>",
											title = "<xsl:value-of select="@title"/>",
											isprimary = "<xsl:value-of select="@isprimary"/>", },
									</xsl:for-each>
								},
							},
					</xsl:template>
					</xsl:stylesheet>
				]]
				
		local resultElement = LrXml.parseXml( response )
		local luaTableString = resultElement and resultElement:transform( xslt )

		local luaTableFunction = luaTableString and loadstring( luaTableString )

		if luaTableFunction then

			local photoListTable = LrFunctionContext.callWithEmptyEnvironment( luaTableFunction )

			if photoListTable then

				for i, v in ipairs( photoListTable.photoset.photos ) do
					table.insert( results, v.id )
				end
				
				numPages = tonumber( photoListTable.photoset.pages ) or 1
				
				results.primary = photoListTable.photoset.primary

			end

		end
		
	end
	
	return results

end

--------------------------------------------------------------------------------

function FlickrAPI.setPhotosetSequence( propertyTable, params )

	local photosetId = assert( params.photosetId )
	local primary = assert( params.primary )
	local photoIds = table.concat( params.photoIds, ',' )
	
	FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.editPhotos',
								photoset_id = photosetId,
								primary_photo_id = primary,
								photo_ids = photoIds,
							} )

end

--------------------------------------------------------------------------------

function FlickrAPI.addPhotosToSet( propertyTable, params )
	
	local data, response
			
	-- http://flickr.com/services/api/flickr.photosets.addPhoto.html

	data, response = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photosets.addPhoto',
								photoset_id = params.photosetId,
								photo_id = params.photoId,
								suppressError = true,
							} )
							
	-- If there was an error, only stop if the error was not #2 or #3 (those aren't critical).

	if data.stat ~= "ok" then

		if data.err then

			local code = tonumber( data.err.code )

			if code ~= 2 and code ~= 3 then
	
				LrErrors.throwUserError( LOC( "$$$/Flickr/Error/API=Flickr API returned an error message (function ^1, message ^2)",
										'flickr.photosets.addPhoto',
										tostring( response.err and response.err.msg ) ) )

			end

		else

			return false

		end

	end
	
	return true

end

--------------------------------------------------------------------------------

function FlickrAPI.deletePhoto( propertyTable, params )
	
	-- http://flickr.com/services/api/flickr.photos.delete.html

	FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.photos.delete',
							photo_id = params.photoId,
							suppressError = params.suppressError,
							suppressErrorCodes = params.suppressErrorCodes,
						} )
	
	return true

end

--------------------------------------------------------------------------------

function FlickrAPI.deletePhotoset( propertyTable, params )
	
	-- http://flickr.com/services/api/flickr.photosets.delete.html

	FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.photosets.delete',
							photoset_id = params.photosetId,
							suppressError = params.suppressError,
						} )
	
	return true

end

--------------------------------------------------------------------------------

local function removePhotoTags( propertyTable, node, previous_tag )

	local nodeType = string.lower( node:type() )
	
	if nodeType == 'element' then
		
		if node:name() == 'tag' then
		
			local _, tag = traverse( node )
			
			local rawtag = tag.raw
			
			if string.find( rawtag, ' ' ) ~= nil then
				rawtag = '"' .. rawtag .. '"'
			end
			
			if rawtag == previous_tag then
			
				-- http://www.flickr.com/services/api/flickr.photos.removeTag.html
					
				FlickrAPI.callRestMethod( propertyTable, {
											method = 'flickr.photos.removeTag',
											tag_id = tag.id,
											suppressError = true,
										} )
				return true

			end
			
		else
		
			local result
			local count = node:childCount()
			
			for i = 1, count do

				result = removePhotoTags( propertyTable, node:childAtIndex( i ), previous_tag )
				
				if result then
					break
				end

			end

		end
			
	end
	
	return false
	
end

--------------------------------------------------------------------------------

function FlickrAPI.setImageTags( propertyTable, params )
	
	-- http://www.flickr.com/services/api/flickr.photos.addTags.html
	
	if not params.previous_tags then
	
		local tags = string.gsub( params.tags, ",", " " )
		FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.photos.addTags',
								photo_id = params.photo_id,
								tags = tags,
								suppressError = true,
							} )

	else

		local data, response = getPhotoInfo( propertyTable, params )
		
		if data.stat == "ok" then
		
			for w in string.gfind( params.previous_tags, "[^,]+" ) do
			
				local result = false

				for v in string.gfind( params.tags, "[^,]+" ) do
					if w == v then
						result = true
						break
					end
				end
				
				if result == false then
					removePhotoTags( propertyTable, LrXml.parseXml( response ), w )
				end

			end

		end
		
		local tags = string.gsub( params.tags, ",", " " )
		
		FlickrAPI.callRestMethod( propertyTable, {
									method = 'flickr.photos.addTags',
									photo_id = params.photo_id,
									tags = tags,
									suppressError = true,
								} )

	end
	
	return true

end

--------------------------------------------------------------------------------

function FlickrAPI.getUserInfo( propertyTable, params )
	
	-- http://flickr.com/services/api/flickr.people.getInfo.html

	local data = FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.people.getInfo',
							user_id = params.userId,
						} )
	
	return {
		nsid = data.person.nsid,
		isadmin = tonumber( data.person.isadmin ) ~= 0,
		ispro = tonumber( data.person.ispro ) ~= 0,
		
		username = data.person.username and data.person.username._value,
		realname = data.person.realname and data.person.realname._value,
		location = data.person.location and data.person.location._value,
		photourl = data.person.photourl and data.person.photourl._value,
		profileurl = data.person.profileurl and data.person.profileurl._value,
		photos = data.person.photos and {
			firstdate = data.person.photos.firstdate and data.person.photos.firstdate._value,
			firstdatetaken = data.person.photos.firstdatetaken and data.person.photos.firstdatetaken._value,
			count = data.person.photos.count and tonumber( data.person.photos.count._value ) or 0,
		},
	}

end

--------------------------------------------------------------------------------

function FlickrAPI.getComments( propertyTable, params )

	local data, response
	local minCommentDate = params.minCommentDate and LrDate.timeToPosixDate( params.minCommentDate )
	local maxCommentDate = params.maxCommentDate and LrDate.timeToPosixDate( params.maxCommentDate )
	
	-- http://flickr.com/services/api/flickr.photos.comments.getList.html

	data, response = FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.photos.comments.getList',
							photo_id = params.photoId,
							min_comment_date = minCommentDate,
							max_comment_date = maxCommentDate,
							suppressError = true,
						} )
	
	if data.stat ~= "ok" then
		return
	end
	
	local commentHeadElement = LrXml.parseXml( response )

	if commentHeadElement:childCount() > 0 then

		local commentsElement = commentHeadElement:childAtIndex( 1 )
		local numOfComments = commentsElement:childCount()
		local commentList = {}

		for i = 1, numOfComments do

			local commentElement = commentsElement:childAtIndex( i )

			if commentElement then

				local comment = {}
				for k,v in pairs( commentElement:attributes() ) do
					comment[ k ] = v.value
				end
				
				if comment.datecreate then
					comment.datecreate = LrDate.timeFromPosixDate( comment.datecreate )
				end
				
				local commentText = commentElement.text and commentElement:text()

				-- Flickr's API returns double-escaped XML characters.

				commentText = commentText and commentText:gsub( '&quot;', '"' )	--"
				commentText = commentText and commentText:gsub( '&amp;', '&' )
				commentText = commentText and commentText:gsub( '&lt;', '<' )
				commentText = commentText and commentText:gsub( '&gt;', '>' )
				
				comment.commentText = commentText
				
				commentList[ #commentList + 1 ] = comment

			end

		end
		
		if #commentList > 0 then
			return commentList
		else
			return nil
		end

	end
	
end

--------------------------------------------------------------------------------

function FlickrAPI.addComment( propertyTable, params )
	
	-- http://flickr.com/services/api/flickr.photos.comments.addComment.html

	local data = FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.photos.comments.addComment',
							photo_id = params.photoId,
							comment_text = params.commentText,
							suppressError = true,
						} )
	
	local errCode = data.stat ~= "ok" and data.err and tonumber( data.err.code )
	return ( data.stat == "ok" and true ) or nil, errCode

end

--------------------------------------------------------------------------------

function FlickrAPI.getNumOfFavorites( propertyTable, params )

	local data, response
	
	-- http://flickr.com/services/api/flickr.photos.getFavorites.html

	data, response = FlickrAPI.callRestMethod( propertyTable, {
							method = 'flickr.photos.getFavorites',
							photo_id = params.photoId,
							per_page = 1,
							suppressError = true,
						} )
	
	logger:trace( 'getNumOfFavorites - response from Flickr: ', response )
	
	if data.stat ~= "ok" then
		return
	end
	
	-- Parse the results with XSLT.

	local xslt = [[
				<xsl:stylesheet
					version="1.0"
					xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				>
				<xsl:output method="text"/>
				<xsl:template match="*">
					return {<xsl:apply-templates />
					}
				</xsl:template>
				<xsl:template match="photo">
					photoId = "<xsl:value-of select="@id"/>",
					total = "<xsl:value-of select="@total"/>",
				</xsl:template>
				</xsl:stylesheet>
			]]

	local resultElement = LrXml.parseXml( response )
	local luaTableString = resultElement and resultElement:transform( xslt )
	local luaTableFunction = luaTableString and loadstring( luaTableString )

	if luaTableFunction then
	
		local _, resultTable = LrFunctionContext.pcallWithEmptyEnvironment( luaTableFunction )
		
		if resultTable then
			return resultTable.total
		end

	end

end

--------------------------------------------------------------------------------

function FlickrAPI.testFlickrConnection( propertyTable )
	
	if appearsAlive == nil then
		local data = FlickrAPI.callRestMethod( propertyTable, {
								method = 'flickr.test.echo',
								suppressError = true,
							} )
		appearsAlive = data.stat == "ok"
	end
	
	return appearsAlive

end
