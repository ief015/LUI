local Image = { }

Image.x        = 0
Image.y        = 0
Image.width    = 100
Image.height   = 100
Image.autoSize = false
Image.file     = ""
Image.backgroundColor = lui.theme.color.paneBackground
Image.borderColor     = lui.theme.color.borderInactive
Image.borderWidth     = 0


------------------------------------------------------------------------------------------------------------------------
local function drawNiceRect( x, y, w, h, borderWidth, cornerRadius, fillColor, borderColor )
	-- Draws a nice rectangle and inside borders with support for transparent colours.
	local offset       = math.max(0, borderWidth * 0.5)
	local cornerInside = math.max(0, cornerRadius - borderWidth * 0.5)
	love.graphics.setColor(fillColor)
	love.graphics.rectangle('fill', borderWidth, borderWidth, w - borderWidth * 2, h - borderWidth * 2, cornerInside)
	love.graphics.setColor(borderColor)
	love.graphics.setLineWidth(borderWidth)
	love.graphics.rectangle('line', offset, offset, w - borderWidth, h - borderWidth, cornerRadius)
end


------------------------------------------------------------------------------------------------------------------------
function Image:init( )
	
	self._image = nil
	
	if self.file and string.len(self.file) > 0 then
		
		self:load(self.file)
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:destroyed( )
	
	if self._image then
		self._image:release()
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:update( dt )
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:draw( )
	
	if self._image then
		
		local sx = self.width  / self._image:getPixelWidth()
		local sy = self.height / self._image:getPixelHeight()
		
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(self._image, 0, 0, 0, sx, sy)
		
	else
		
		if self.borderWidth > 0 then
			
			drawNiceRect(0, 0, self.width, self.height, self.borderWidth, 0, self.backgroundColor, self.borderColor)
			
		else
			
			love.graphics.setColor(self.backgroundColor)
			love.graphics.rectangle('fill', 0, 0, self.width, self.height)
			
		end
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:load( file, useMipmaps )
	
	if useMipmaps == nil then
		useMipmaps = true
	end
	
	local success, img = pcall(love.graphics.newImage, file, { mipmaps = useMipmaps })
	
	if success then
		
		self._image = img
		self.file   = file
		
		if self.autoSize then
			self.width  = img:getPixelWidth()
			self.height = img:getPixelHeight()
		end
		
		if useMipmaps then
			self._image:setMipmapFilter('nearest')
		end
		self._image:setFilter('linear', 'linear')
		
		return true
		
	end
	
	self._image = nil
	self.file   = ""
	
	if self.autoSize then
		self.width  = 0
		self.height = 0
	end
	
	return false
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:getImageSize( )
	
	if not self._image then return 0, 0 end
	
	return self._image:getPixelWidth(), self._image:getPixelHeight()
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:getImageWidth( )
	
	if not self._image then return 0 end
	
	return self._image:getPixelWidth()
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:getImageHeight( )
	
	if not self._image then return 0 end
	
	return self._image:getPixelHeight()
	
end


------------------------------------------------------------------------------------------------------------------------
function Image:getImage( )
	
	return self._image
	
end



lui.register('Image', Image)
