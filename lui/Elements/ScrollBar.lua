local ScrollBar = { }

ScrollBar.x         = 0
ScrollBar.y         = 0
ScrollBar.width     = 32
ScrollBar.height    = 32
ScrollBar.locked               = false
ScrollBar.orientation          = 'horizontal' -- Scroll bar orientation: 'horizontal' or 'vertical'
ScrollBar.backgroundColor      = { 0.30, 0.30, 0.30, 1 }
ScrollBar.backgroundColorHover = { 0.30, 0.30, 0.30, 1 }
ScrollBar.backgroundColorLock  = { 0.30, 0.30, 0.30, 1 }
ScrollBar.backgroundColorDown  = { 0.30, 0.30, 0.30, 1 }
ScrollBar.barColor             = { 0.40, 0.40, 0.40, 1 }
ScrollBar.barColorHover        = { 0.50, 0.50, 0.50, 1 }
ScrollBar.barColorDown         = { 0.20, 0.20, 0.20, 1 }
ScrollBar.barColorLock         = { 0.50, 0.50, 0.50, 1 }

local sHoriz = 'horizontal'
local sVert  = 'vertical'


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
function ScrollBar:init( )
	
	
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:destroyed( )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:update( dt )
	
	self:invalidate()
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:draw( )
	
	
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:keypressed( key, scancode, isrepeat )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:keyreleased( key, scancode )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:textedited( text, start, length )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:textinput( text )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:mousemoved( x, y, dx, dy, istouch )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:mousepressed( x, y, button, istouch, presses )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:mousereleased( x, y, button, istouch, presses )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:wheelmoved( x, y )
	
end


------------------------------------------------------------------------------------------------------------------------
function ScrollBar:invalidate( )
	
	
	
end


lui.register('ScrollBar', ScrollBar)
