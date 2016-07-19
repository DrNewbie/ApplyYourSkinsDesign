_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}
SkinEditor_Patch.Skins_Data = SkinEditor_Patch.Skins_Data or {}
SkinEditor_Patch.ModPath = ModPath
SkinEditor_Patch.SaveFile = SkinEditor_Patch.SaveFile or SavePath .. "SkinEditor_Patch.txt"
SkinEditor_Patch.ModOptions = SkinEditor_Patch.ModPath .. "menus/modoptions.txt"
SkinEditor_Patch.settings = SkinEditor_Patch.settings or {}
SkinEditor_Patch.options_menu = "SkinEditor_Patch_menu"

function SkinEditor_Patch:Load()
	self.Skins_Data = {}
	local original = {}
	local file = io.open(self.SaveFile, "r")
	if file then
		original = json.decode(file:read("*all"))
		file:close()
	end
	for k1, v1 in pairs(original) do
		if type(v1) == "string" and v1:find("Vector3") then
			original[k1] = toVector3(v1)
		end
		if type(v1) == "table" then
			for k2, v2 in pairs(v1) do
				if type(v2) == "string" and v2:find("Vector3") then
					original[k1][k2] = toVector3(v2)
				end
				if type(v2) == "table" then
					for k3, v3 in pairs(v2) do
						if type(v3) == "string" and v3:find("Vector3") then
							original[k1][k2][k3] = toVector3(v3)
						end
						if type(v3) == "table" then
							for k4, v4 in pairs(v3) do
								if type(v4) == "string" and v4:find("Vector3") then
									original[k1][k2][k3][k4] = toVector3(v4)
								end
								if type(v4) == "table" then
									for k5, v5 in pairs(v4) do
										if type(v5) == "string" and v5:find("Vector3") then
											original[k1][k2][k3][k4][k5] = toVector3(v5)
										end
										if type(v5) == "table" then
											for k6, v6 in pairs(v5) do
												if type(v6) == "string" and v6:find("Vector3") then
													original[k1][k2][k3][k4][k5][k6] = toVector3(v6)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	self.Skins_Data = deep_clone(original)
end

function SkinEditor_Patch:Save()
	local file = io.open(self.SaveFile, "w+")
	if file then
		local _data = tostring(json.encode(self.Skins_Data))
		_data = _data:gsub('%b[]', '{}')
		file:write(_data)
		file:close()
	end
end

function toVector3(strings)
	strings = strings:gsub("Vector3", "")
	strings = strings:gsub('%(', '')
	strings = strings:gsub('%)', '')
	strings = strings:gsub(' ', '')
	local strings2 = mysplit(strings, ",")
	local x, y, z = tonumber(strings2[1]), tonumber(strings2[2]), tonumber(strings2[3])
	log(tostring(Vector3(x, y, z)))
	return Vector3(x, y, z)
end

function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end