local eliminate_varname_conflicts = true

if not e2_parse_args then include("extpp.lua") end

local readfile = readfile or function(filename)
	return file.Read("entities/gmod_wire_expression2/core/" .. filename, "LUA")
end
local writefile = writefile or function(filename, contents)
	print("--- Writing to file 'data/e2doc/" .. filename .. "' ---")
	return file.Write("e2doc/" .. filename, contents)
end
local p_typename = "[a-z][a-z0-9]*"
local p_typeid = "[a-z][a-z0-9]?[a-z0-9]?[a-z0-9]?[a-z0-9]?"
local p_argname = "[a-zA-Z][a-zA-Z0-9]*"
local p_funcname = "[a-z][a-zA-Z0-9]*"
local p_func_operator = "[-a-zA-Z0-9+*/%%^=!><&|$_%[%]]*"

local function ltrim(s)
	return string.match(s, "^%s*(.-)$")
end

local function rtrim(s)
	return string.match(s, "^(.-)%s*$")
end

local function trim(s)
	return string.match(s, "^%s*(.-)%s*$")
end

local function typeid_to_image(typeid)
    return string.format("[[Type-%s.png|alt=%s]]", typeid:upper(), E2Lib.typeName(typeid))
end

local function mess_with_args(args, desc)
	local argtable, ellipses = e2_parse_args(args)
	newargs = {}
	for i, name in ipairs(argtable.argnames) do
		local arg_img = typeid_to_image(argtable.typeids[i])
		desc = desc:gsub("<" .. name .. ">", string.format("%s `%s`", arg_img, name)) -- code tags for argument in descriptions
		table.insert(newargs,string.format("`%s `%s", arg_img, name)) -- lift code tags for image in signature
	end
	if ellipses then
		table.insert(newargs,"...")
	end
	return table.concat(newargs, ", "), desc
end

local function e2doc(filename, outfile)
	if not outfile then
		outfile = string.match(filename, "^.*%.") .. "txt"
	end
	local current = {}
	local output = { '|Function|Returns|Description|\n|:-|:-|:-|\n' }
	local section_title = nil
	for line in string.gmatch(readfile(filename), "%s*(.-)%s*\n") do
		if line:sub(1, 3) == "---" then
			if line:match("[^-%s]") then table.insert(current, ltrim(line:sub(4))) end
		elseif line:sub(1, 6) == "--[[--" then
			if line:find("^%-%-%[%[%-%-.-%-%-%]%]%-%-$") then
				section_title = line:match("^%-%-%[%[%-%-(.-)%-%-%]%]%-%-$")
			end
		elseif line:sub(1, 12) == "--[[********" then
			if line:find("^%-%-%[%[%*%*%*%*%*%*%*%*+%]%]%-%-$") then
				section_title = "DefaultSpacerTitle"
		end
		elseif line:sub(1, 10) == "e2function" then
			local ret, thistype, colon, name, args = line:match("e2function%s+(" .. p_typename .. ")%s+([a-z0-9]-)%s*(:?)%s*(" .. p_func_operator .. ")%(([^)]*)%)")
			if thistype ~= nil and colon == nil then error("E2doc syntax error: Function names may not start with a number.", 0) end
			if thistype == nil and colon ~= nil then error("E2doc syntax error: No type for 'this' given.", 0) end
			if thistype ~= nil and thistype:sub(1, 1):find("[0-9]") then error("E2doc syntax error: Type names may not start with a number.", 0) end

			desc = table.concat(current, "  \n")
			current = {}

			if name:sub(1, 8) ~= "operator" and not desc:match("@nodoc") then
				if section_title then
					table.insert(output, '|**'..section_title..'**|||')
					section_title = nil
				end

				args, desc = mess_with_args(args, desc)

				if ret==nil or ret == "void" then
					ret = ""
				else
					ret = typeid_to_image(e2_get_typeid(ret))
				end

				if thistype == "" then
					thistype = "`"
				else
					thistype = typeid_to_image(e2_get_typeid(thistype)) .. "`:"
				end
				table.insert(output, string.format("| %s%s(%s)` | %s | %s |\n", thistype, name, args, ret, desc))
			end
		end
	end -- for line
	output = table.concat(output)
	-- print(output)
	writefile(outfile, output)
end

-- Add a server-side "e2doc" console command
if SERVER then
	concommand.Add("e2doc",
		function(player, command, args)
			if not file.IsDir("e2doc", "DATA") then file.CreateDir("e2doc") end
			if not file.IsDir("e2doc/custom", "DATA") then file.CreateDir("e2doc/custom") end

			local path = string.match(args[2] or args[1], "^%s*(.+)/")
			if path and not file.IsDir("e2doc/" .. path, "DATA") then file.CreateDir("e2doc/" .. path) end

			e2doc(args[1], args[2])
		end,
		function(commandName, args) -- autocomplete function
			args = string.match(args, "^%s*(.-)%s*$")
			local path = string.match(args, "^%s*(.+/)") or ""
			local files = file.Find("entities/gmod_wire_expression2/core/" .. args .. "*", "LUA")
			local ret = {}
			for _, v in ipairs(files) do
				if string.sub(v, 1, 1) ~= "." then
					if file.IsDir("entities/gmod_wire_expression2/core/" .. path .. v, "LUA") then
						table.insert(ret, "e2doc " .. path .. v .. "/")
					else
						table.insert(ret, "e2doc " .. path .. v)
					end
				end
			end
			return ret
		end)
end
