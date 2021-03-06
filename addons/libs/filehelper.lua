--[[
File handler.
]]

_libs = _libs or {}
_libs.filehelper = true
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'

local file = {}
local createfile = false

-- Create a new file object. Accepts a variable number of paths, which it will
function file.new(path, create)
	create = true and (create ~= false)
	
	if path == nil then
		return setmetatable(T{}, {__index = file})
	end
	
	local f = setmetatable(T{}, {__index = file})
	f:set(path, create)

	return f
end

-- Creates a new file. Creates path, if necessary.
function file.create(f)
	local fh = io.open(lua_base_path..f.path, 'w')
	fh:write('')
	fh:close()

	return f
end

-- Sets the file to a path value.
function file.set(f, path, create)
	create = true and (create ~= false)
	createfile = create
	
	f.path = path

	return f
end

-- Check if file exists. There's no better way, it would seem.
function file.exists(f)
	local path
	
	if type(f) == 'string' then
		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot check file.'
		end

		path = f.path
	end

	local fh = io.open(lua_base_path..path, 'r')
	if fh ~= nil then
		fh:close()
		return true
	end

	return false
end

-- Checks existance of a number of paths, returns the first that exists.
function file.check(...)
	return (select(2, T{...}:find(file.exists)))
end

-- Read from file and return string of the contents.
function file.read(f)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot read.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				return ''
			else
				return nil, 'File \''..f.path..'\' not found, cannot read.'
			end
		end

		path = f.path
	end

	local fh = io.open(lua_base_path..path, 'r')
	content = fh:read('*all*')
	fh:close()

	return content
end

-- Read from file and return lines of the contents in a table.
function file.readlines(f)
	return file.read(f):split('\n')
end

-- Return an iterator over the lines of a file.
function file.it(f)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot read.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				return ''
			else
				return nil, 'File \''..f.path..'\' not found, cannot read.'
			end
		end

		path = f.path
	end

	return coroutine.wrap(function()
		for l in io.lines(lua_base_path..path) do
			coroutine.yield(l)
		end
	end)
end

-- Write to file. Overwrites everything within the file, if present.
function file.write(f, content)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot write.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				notice('New file: '..f.path)
				f:create()
			else
				return nil, 'File \''..f.path..'\' not found, cannot write.'
			end
		end

		path = f.path
	end
	
	if type(content) == 'table' then
		content = table.concat(content)
	end
	
	local fh = io.open(lua_base_path..path, 'w')
	fh:write(content)
	fh:close()

	return f
end

-- Write array to file. Overwrites everything within the file, if present
function file.writelines(f, lines)
	return file.write(f, table.concat(lines, '\n'))
end

-- Append to file. Sets a newline per default, unless newline is set to false.
function file.append(f, content, newline)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot write.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				notice('New file: '..f.path)
				f:create()
			else
				return nil, 'File \''..f.path..'\' not found, cannot write.'
			end
		end

		path = f.path
	end

	newline = true and (newline ~= false)
	local sep = newline and '\n' or ''
	
	if type(content) == 'table' then
		content = table.concat(content, sep)
	end

	content = sep..content
	local fh = io.open(lua_base_path..path, 'a')
	fh:write(content)
	fh:close()

	return f
end

-- Append an array of lines to file. Sets a newline per default, unless newline is set to false.
function file.appendlines(f, lines, newline)
	return file.append(f, table.concat(lines, '\n'), newline)
end

return file
