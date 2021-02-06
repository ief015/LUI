local Panel = { }

Panel.x        = 0
Panel.y        = 0
Panel.width    = 100
Panel.height   = 100
Panel.backgroundColor = lui.theme.color.paneBackground
Panel.borderColor     = lui.theme.color.borderInactive
Panel.borderWidth     = 1
Panel.cornerRadius    = 2


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
function Panel:init( )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:destroyed( )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:update( dt )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:draw( )
	
	--[[ OLD DRAW CODE (Feb 3)
	if self.borderWidth > 0 then
		love.graphics.setColor(self.borderColor)
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
	end
	
	if self.backgroundColor then
		love.graphics.setColor(self.backgroundColor)
		if self.borderWidth > 0 then
			local bw2 = self.borderWidth + self.borderWidth
			love.graphics.rectangle('fill',
				self.borderWidth, self.borderWidth, self.width - bw2, self.height - bw2, self.cornerRadius)
		else
			love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
		end
	end
	]]
	
	if self.borderWidth > 0 then
		
		drawNiceRect(0, 0, self.width, self.height,
			self.borderWidth, self.cornerRadius, self.backgroundColor, self.borderColor)
		
	else
		
		love.graphics.setColor(self.backgroundColor)
		love.graphics.rectangle('fill', 0, 0, self.width, self.height, self.cornerRadius)
		
	end
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:keypressed( key, scancode, isrepeat )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:keyreleased( key, scancode )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:textedited( text, start, length )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:textinput( text )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:mousemoved( x, y, dx, dy, istouch )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:mousepressed( x, y, button, istouch, presses )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:mousereleased( x, y, button, istouch, presses )
	
end


------------------------------------------------------------------------------------------------------------------------
function Panel:wheelmoved( x, y )
	
end


lui.register('Panel', Panel)
