lui = require 'lui/lui'

local mui = require 'lui/lui'


local txtDebug
local updateMS = 0
local drawMS   = 0

local enableTrace     = false
local enableHover     = false
local enableProbe     = false
local enableProbeAnim = false


local tests = {
	'test/sandbox.lua',
	'test/helloworld.lua',
	'test/hierarchy.lua',
	'test/focus.lua',
	'test/textinput.lua',
	'test/animation.lua',
	'test/anchoring.lua',
}


test = { }



--#################--
--#    GENERAL    #--
--#################--


local function loadTest( testfile )
	
	lui.clear()
	test = { }
	
	if testfile then
		
		love.filesystem.load(testfile)()
		
	else
		
		local _x = 250
		local _y = 50
		local columnMax = 12
		
		for k,v in ipairs(tests) do
			
			lui.new('Button', {
				text = v,
				width = 240,
				height = 40,
				x = _x * (math.floor((k-1) / columnMax) + 1),
				y = _y * (math.floor((k-1) % columnMax) + 1),
			}).onClick = function(me, btn)
				if btn ~= 1 then return end
				loadTest(me.text)
			end
			
		end
		
	end
	
	txtDebug = lui.new('Text', {
		text = "",
		x = 2,
		y = 2,
		height = 100,
		textColor = { 1,1,1,0.5 },
	})
	
end


local function probeValue( k, v, traverseTables, newline )
	
	local sout = ""
	local t = type(v)
	
	if t == 'function' then
	elseif t == 'nil' then
	else
		
		sout = sout .. "[" .. tostring(k) .. "] = " .. tostring(v)
		
		if traverseTables and t == 'table' then
			
			if lui.isvalid(v) then
				
				sout = sout .. " Element: " .. v:getType()
				
			else
			
				sout = sout .. " [" .. #v .. "] {"
				
				for _k,_v in ipairs(v) do
					sout = sout .. "   " .. probeValue(_k, _v) -- does not traverse tables
				end
				
				sout = sout .. "  }"
				
			end
			
		end
		
		if traverseTables then
			sout = sout .. "\n"
		end
		
	end
	
	return sout
	
end


local function probe( element, skipInternal )
	
	local sout = ""
	
	if type(element) == 'table' then
		
		local ksort = { }
		for k,v in pairs(element) do
			if not skipInternal or k ~= '_' then
				table.insert(ksort, k)
			end
		end
		table.sort(ksort)
		
		for k,v in pairs(ksort) do
			sout = sout .. probeValue(v, element[v], true, true)
		end
		
	end
	
	return sout
	
end


------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.load
-- This function is called exactly once at the beginning of the game.
function love.load( arg, unfilteredArg )
	
	-- Loads empty test
	loadTest()
	
	-- Not required, but nice with textboxes (or text input elements)
	love.keyboard.setKeyRepeat(true)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.update
-- Callback function used to update the state of the game every frame.
function love.update( dt )
	
	if txtDebug.enabled then
		
		local str =
			">>>[~] DEBUG" ..
			"\n[Esc] Leave test" ..
			"\n" ..
			"\nFPS:\t         " .. math.floor(1 / love.timer.getDelta()) ..
			"\nUpdate (ms): " .. (math.floor(updateMS * 1000 * 100) / 100) ..
			"\nDraw (ms):   " .. (math.floor(drawMS * 1000 * 100) / 100)
		
		str = str .. "\n\n>>>[F1] HOVER"
		if enableHover then
			
			for i,elem in ipairs(lui._.hoverElements) do
				str = str .. "\n[" .. i .. "] " .. elem:getType() .. " (" .. tostring(elem) .. ")"
			end
			
		else
			str = str .. " (disabled)"
		end
		
		local mx, my = love.mouse.getPosition()
		str = str .. "\n\n>>>[F2] TRACE"
		if enableTrace then
			
			str = str .. " ("..mx..","..my..")"
			for i,elem in ipairs(lui.trace(mx, my)) do
				str = str .. "\n[" .. i .. "] " .. elem:getType() .. " (" .. tostring(elem) .. ")"
			end
			
		else
			str = str .. " (disabled)"
		end
		
		str = str .. "\n\n>>>[F3] PROBE"
		if enableProbe then
			
			local focused = lui.getfocuselement()
			if focused and lui.isvalid(focused) then
				str = str .. " (" .. focused:getType() .. ")\n"
				str = str .. probe(focused, true)
			end
			
		else
			str = str .. " (disabled)"
		end
		
		str = str .. "\n\n>>>[F4] PROBE ANIMATOR"
		if enableProbe then
			
			local focused = lui.getfocuselement()
			if focused and lui.isvalid(focused) then
				str = str .. " (" .. focused:getType() .. ")\n"
				str = str .. probe(focused._.anims, true)
			end
			
		else
			str = str .. " (disabled)"
		end
		
		txtDebug.text = str
		
	end
	
	local timestamp = love.timer.getTime()
	
	if test.update then
		test.update(dt)
	end
	
	lui.update(dt)
	
	updateMS = love.timer.getTime() - timestamp
	
	txtDebug:bringToFront()
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.draw
-- Callback function used to draw on the screen every frame.
function love.draw( )
	
	love.graphics.clear(0.15, 0.15, 0.15)
	
	local timestamp = love.timer.getTime()
	
	if test.draw then
		test.draw()
	end
	
	lui.draw()
	
	drawMS = love.timer.getTime() - timestamp
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.lowmemory
-- Callback function triggered when the system is running out of memory on  mobile devices.
-- Mobile operating systems may forcefully kill the game if it uses too much memory, so any non-critical resource
-- should be removed if possible (by setting all variables referencing the resources to nil), when this event is
-- triggered.
-- Sounds and images in particular tend to use the most memory.
function love.lowmemory( )
	
	collectgarbage()
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.threaderror
-- Callback function triggered when a Thread encounters an error.
function love.threaderror( thread, errorstr )
	
	print("Thread error (" .. thread .. "): " .. errorstr)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.quit
-- Callback function triggered when the game is closed.
-- Returns boolean r : Abort quitting. If true, do not close the game.
function love.quit( )
	
end


--#################--
--#     WINDOW    #--
--#################--
--[[

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.directorydropped
-- Callback function triggered when a directory is dragged and dropped onto the window.
function love.directorydropped( path )
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.filedropped
-- Callback function triggered when a file is dragged and dropped onto the window.
function love.filedropped( file )
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.focus
-- Callback function triggered when window receives or loses focus.
function love.focus( focus )
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.mousefocus
-- Callback function triggered when window receives or loses mouse focus.
function love.mousefocus( focus )
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.resize
-- Called when the window is resized, for example if the user resizes the window, or if love.window.setMode is
-- called with an unsupported width or height in fullscreen and the window chooses the closest appropriate size.
function love.resize( w, h )
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.visible
-- Callback function triggered when window is minimized/hidden or unminimized by the user.
function love.visible( visible )
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.displayrotated
-- Called when the device display orientation changed, for example, user rotated their phone 180 degrees.
function love.displayrotated( index, orientation )
	
end
]]


--#################--
--#    KEYBOARD   #--
--#################--


------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.keypressed
-- Callback function triggered when a key is pressed.
function love.keypressed( key, scancode, isrepeat )
	
	if (key == 'escape') then
		
		loadTest()
		
	elseif key == '`' then
		
		txtDebug.enabled = not txtDebug.enabled
		
	elseif key == 'f1' then
		
		enableHover = not enableHover
		
	elseif key == 'f2' then
		
		enableTrace = not enableTrace
		
	elseif key == 'f3' then
		
		enableProbe = not enableProbe
		
	elseif key == 'f4' then
		
		enableProbeAnim = not enableProbeAnim
		
	end
	
	lui.keypressed(key, scancode, isrepeat)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.keyreleased
-- Callback function triggered when a keyboard key is released.
function love.keyreleased( key, scancode )
	
	lui.keyreleased(key, scancode)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.textedited
-- Called when the candidate text for an IME (Input Method Editor) has changed.
-- The candidate text is not the final text that the user will eventually choose. Use love.textinput for that.
function love.textedited( text, start, length )
	
	lui.textedited(text, start, length)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.textinput
-- Called when text has been entered by the user. For example if shift-2 is pressed on an American keyboard layout,
-- the text "@" will be generated.
function love.textinput( text )
	
	lui.textinput(text)
	
end


--#################--
--#     MOUSE     #--
--#################--


------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.mousemoved
-- Callback function triggered when the mouse is moved.
function love.mousemoved( x, y, dx, dy, istouch )
	
	lui.mousemoved(x, y, dx, dy, istouch)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.mousepressed
-- Callback function triggered when a mouse button is pressed.
function love.mousepressed( x, y, button, istouch, presses )
	
	lui.mousepressed(x, y, button, istouch, presses)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.mousereleased
-- Callback function triggered when a mouse button is released.
function love.mousereleased( x, y, button, istouch, presses )
	
	lui.mousereleased(x, y, button, istouch, presses)
	
end

------------------------------------------------------------------------------------------------------------------------
-- https://love2d.org/wiki/love.wheelmoved
-- Callback function triggered when the mouse wheel is moved.
function love.wheelmoved( x, y )
	
	lui.wheelmoved(x, y)
	
end


--#################--
--#    JOYSTICK   #--
--#################--
--[[

------------------------------------------------------------------------------------------------------------------------
function love.gamepadaxis( joystick, axis, value )
	-- https://love2d.org/wiki/love.gamepadaxis
	-- Called when a Joystick's virtual gamepad axis is moved.
end

------------------------------------------------------------------------------------------------------------------------
function love.gamepadpressed( joystick, button )
	-- https://love2d.org/wiki/love.gamepadpressed
	-- Called when a Joystick's virtual gamepad button is pressed.
end

------------------------------------------------------------------------------------------------------------------------
function love.gamepadreleased( joystick, button )
	-- https://love2d.org/wiki/love.gamepadreleased
	-- Called when a Joystick's virtual gamepad button is released.
end

------------------------------------------------------------------------------------------------------------------------
function love.joystickadded( joystick )
	-- https://love2d.org/wiki/love.joystickadded
	-- Called when a Joystick is connected.
end

------------------------------------------------------------------------------------------------------------------------
function love.joystickaxis( joystick, axis, value )
	-- https://love2d.org/wiki/love.joystickaxis
	-- Called when a joystick axis moves.
end

------------------------------------------------------------------------------------------------------------------------
function love.joystickhat( joystick, hat, direction )
	-- https://love2d.org/wiki/love.joystickhat
	-- Called when a joystick hat direction changes.
end

------------------------------------------------------------------------------------------------------------------------
function love.joystickpressed( joystick, button )
	-- https://love2d.org/wiki/love.joystickpressed
	-- Called when a joystick button is pressed.
end

------------------------------------------------------------------------------------------------------------------------
function love.joystickreleased( joystick, button )
	-- https://love2d.org/wiki/love.joystickreleased
	-- Called when a joystick button is released.
end

------------------------------------------------------------------------------------------------------------------------
function love.joystickremoved( joystick )
	-- https://love2d.org/wiki/love.joystickremoved
	-- Called when a Joystick is disconnected.
end
--]]


--#################--
--#     TOUCH     #--
--#################--
--[[

------------------------------------------------------------------------------------------------------------------------
function love.touchmoved( id, x, y, dx, dy, pressure )
	-- https://love2d.org/wiki/love.touchmoved
	-- Callback function triggered when a touch press moves inside the touch screen.
end

------------------------------------------------------------------------------------------------------------------------
function love.touchpressed( id, x, y, dx, dy, pressure )
	-- https://love2d.org/wiki/love.touchpressed
	-- Callback function triggered when the touch screen is touched.
end

------------------------------------------------------------------------------------------------------------------------
function love.touchreleased( id, x, y, dx, dy, pressure )
	-- https://love2d.org/wiki/love.touchreleased
	-- Callback function triggered when the touch screen stops being touched.
end
--]]
