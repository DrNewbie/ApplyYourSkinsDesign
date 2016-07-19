SkinEditor = SkinEditor or class()

_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}

SkinEditor_Patch.Skins_Data = SkinEditor_Patch.Skins_Data or {}

function SkinEditor:save_skin(skin, name, data)
	skin:config().name = name or skin:config().name
	skin:config().data = data or skin:config().data
	local tags = self:get_current_weapon_tags()
	skin:clear_tags()
	for _, tag in ipairs(tags) do
		skin:add_tag(tag)
	end
	local original = self:remove_literal_paths(skin)
	skin:save()
	skin:config().data = original
	self._unsaved = false
	for k1, v1 in pairs(original) do
		if tostring(v1):find("Vector3") then
			original[k1] = tostring(v1)
		end
		if type(v1) == "table" then
			for k2, v2 in pairs(v1) do
				if tostring(v2):find("Vector3") then
					original[k1][k2] = tostring(v2)
				end
				if type(v2) == "table" then
					for k3, v3 in pairs(v2) do
						if tostring(v3):find("Vector3") then
							original[k1][k2][k3] = tostring(v3)
						end
						if type(v3) == "table" then
							for k4, v4 in pairs(v3) do
								if tostring(v4):find("Vector3") then
									original[k1][k2][k3][k4] = tostring(v4)
								end
								if type(v4) == "table" then
									for k5, v5 in pairs(v4) do
										if tostring(v5):find("Vector3") then
											original[k1][k2][k3][k4][k5] = tostring(v5)
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
	SkinEditor_Patch.Skins_Data[original.weapon_id] = {
		cosmetics = original
	}
	SkinEditor_Patch:Save()
end