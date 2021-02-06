local Text = { }

Text.x               = 0
Text.y               = 0
Text.width           = 100
Text.height          = lui.theme.font.default:getHeight()
Text.focusable       = false
Text.text            = "<text>"
Text.align           = 'left'
Text.font            = lui.theme.font.default
Text.textColor       = lui.theme.color.text
Text.backgroundColor = nil
Text.autoSize        = true


local utf8 = require 'utf8'


------------------------------------------------------------------------------------------------------------------------
local function invalidateSize( self )
	
	if self.autoSize then
	
		self.width  = self.font:getWidth(self.text)
		self.height = self.font:getHeight(self.text)
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:init( )
	
	invalidateSize(self)
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:destroyed( )
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:update( dt )
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:draw( )
	
	invalidateSize(self)
	
	if self.text and self.textColor and utf8.len(self.text) > 0 then
		
		love.graphics.setColor(self.textColor)
		love.graphics.printf(self.text, self.font, 0, 0, self.width, self.align)
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:getLength( )
	
	return string.len(self.text)
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:getLengthUtf8( )
	
	return utf8.len(self.text)
	
end


------------------------------------------------------------------------------------------------------------------------
function Text:sub( i, j )
	
	i = utf8.offset(self.text, i) or 0
	
	if j ~= nil then
		j = (utf8.offset(self.text, j + 1) or 0) - 1
	end
	
	return string.sub(self.text, i, j)
	
end


lui.register('Text', Text)
