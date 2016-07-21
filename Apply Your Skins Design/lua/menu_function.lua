_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}
SkinEditor_Patch.Skins_Data = SkinEditor_Patch.Skins_Data or {}
SkinEditor_Patch.ModPath = ModPath
SkinEditor_Patch.SaveFile = SkinEditor_Patch.SaveFile or SavePath .. "SkinEditor_Patch.txt"
SkinEditor_Patch.ModOptions = SkinEditor_Patch.ModPath .. "menus/modoptions.txt"
SkinEditor_Patch.settings = SkinEditor_Patch.settings or {}
SkinEditor_Patch.options_menu = "SkinEditor_Patch_menu"

function SkinEditor_Patch:Load()
	self.Skins_Data = {}
	self.Skins_Data_List = {}
	self.Skins_Data_Name = {}
	local original = {}
	for _, name in pairs(file.GetDirectories("workshop/") or {}) do
		local files = io.open("workshop/".. name .. "/SkinEditorPatch.txt", "r")
		if files then
			local _date = files:read("*all")
			_date = _date:gsub('%b[]', '{}')
			local _sha1 = self:sha1(tostring(_date))
			original = json.decode(_date)
			local _weapon_id = original.weapon_id
			original = self:Table2Load(original)
			self.Skins_Data[_sha1] = original
			self.Skins_Data_Name[_sha1] = name
			self.Skins_Data_List[_weapon_id] = self.Skins_Data_List[_weapon_id] or {}
			table.insert(self.Skins_Data_List[_weapon_id], _sha1)
			local _load_texture_path = Application:base_path() .. "workshop/" .. name
			local _texture_list = managers.blackmarket:skin_editor():get_texture_list(nil, _load_texture_path)
			local new_textures = {}
			for _, texture_name in ipairs(_texture_list or {}) do
				local _texture_path = "workshop/" .. name .. "/" .. texture_name
				local _texture_path_lower = Idstring(string.lower(_texture_path))
				DB:create_entry(Idstring("texture"), _texture_path_lower, _texture_path)
				table.insert(new_textures, _texture_path_lower)
			end
			if not table.empty(new_textures) then
				Application:reload_textures(new_textures)
			end
			files:close()
		end		
	end
	self:Load_Settings()
end

function SkinEditor_Patch:Save(_path, original)
	original = self:Table2Save(original)
	local files = io.open(_path .. "SkinEditorPatch.txt", "w+")
	if files then
		local _data = tostring(json.encode(original))
		_data = _data:gsub('%b[]', '{}')
		files:write(_data)
		files:close()
	end
end

function SkinEditor_Patch:Reset_Settings()
	self.settings = {}
	self:Save_Settings()
end

function SkinEditor_Patch:Load_Settings()
	local files = io.open(self.SaveFile, "r")
	if files then
		local _date = files:read("*all")
		_date = _date:gsub('%b[]', '{}')
		local _date2 = json.decode(_date)
		for key, value in pairs(_date2) do
			self.settings[key] = value
		end
		files:close()
	else
		self:Reset_Settings()
	end
end

function SkinEditor_Patch:Save_Settings()
	local files = io.open(self.SaveFile, "w+")
	if files then
		files:write(json.encode(self.settings))
		files:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "SkinEditor_Patch_loc", function(loc)
	LocalizationManager:load_localization_file("mods/Apply Your Skins Design/loc/localization.txt")
end)

Hooks:Add("MenuManagerSetupCustomMenus", "SkinEditor_PatchOptions", function( menu_manager, nodes )
	MenuHelper:NewMenu( SkinEditor_Patch.options_menu )
end)

function SkinEditor_Patch:choose_skins_to_accept(data)
	self.settings[self.Skins_Data[data.sha1].weapon_id] = data.sha1
	self:Save_Settings()
	if managers.player and managers.player:player_unit() then
		SkinEditor_Patch:Apply_Skins(managers.player:player_unit():inventory():unit_by_selection(1))
		SkinEditor_Patch:Apply_Skins(managers.player:player_unit():inventory():unit_by_selection(2))
	end
	local _dialog_data = {
		title = managers.localization:text("SkinEditor_Patch_menu_title"),
		text = "[ ".. self.Skins_Data[data.sha1].weapon_id .." ---> ".. self.Skins_Data_Name[data.sha1] .." ]",
		button_list = {{ text = managers.localization:text("SkinEditor_Patch_use4ok"), is_cancel_button = true }},
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	managers.system_menu:show(_dialog_data)
end

function SkinEditor_Patch:choose_skins_to_preview(data)
	preview = self.Skins_Data_Name[data.sha1]
	local _url = "file:///".. Application:base_path() .."workshop/".. preview .."/screenshots/preview.png"
	Steam:overlay_activate("url", _url)
	SkinEditor_Patch:choose_skins_after_skins(data)
end

function SkinEditor_Patch:choose_skins_after_skins(data)
	local opts = {}
	opts[#opts+1] = { text = managers.localization:text("SkinEditor_Patch_use4acceptthisskins"), callback_func = callback(SkinEditor_Patch, SkinEditor_Patch, "choose_skins_to_accept", {sha1 = data.sha1}) }
	opts[#opts+1] = { text = managers.localization:text("SkinEditor_Patch_use4preview"), callback_func = callback(SkinEditor_Patch, SkinEditor_Patch, "choose_skins_to_preview", {sha1 = data.sha1}) }
	opts[#opts+1] = { text = managers.localization:text("SkinEditor_Patch_use4cancel"), is_cancel_button = true }
	local _dialog_data = {
		title = managers.localization:text("SkinEditor_Patch_menu_title"),
		text = managers.localization:text("SkinEditor_Patch_menu_change_settings_main_text"),
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	managers.system_menu:show(_dialog_data)
end

function SkinEditor_Patch:choose_skins_after_type(data)
	local opts = {}
	for k, _sha1 in pairs (self.Skins_Data_List[data.weapon_id] or {}) do
		opts[#opts+1] = { text = "[ ".. self.Skins_Data_Name[_sha1] .." ]", callback_func = callback(SkinEditor_Patch, SkinEditor_Patch, "choose_skins_after_skins", {sha1 = _sha1}) }
	end
	opts[#opts+1] = { text = managers.localization:text("SkinEditor_Patch_use4cancel"), is_cancel_button = true }
	local _dialog_data = {
		title = managers.localization:text("SkinEditor_Patch_menu_title"),
		text = managers.localization:text("SkinEditor_Patch_menu_change_settings_main_text"),
		button_list = opts,
		id = tostring(math.random(0,0xFFFFFFFF))
	}
	managers.system_menu:show(_dialog_data)
end

Hooks:Add("MenuManagerPopulateCustomMenus", "SkinEditor_PatchOptions", function( menu_manager, nodes )
	MenuCallbackHandler.SkinEditor_Patch_Change_Skins_callback = function(self, item)
		SkinEditor_Patch:Load()
		local opts = {}
		for _weapon_id, v in pairs (SkinEditor_Patch.Skins_Data_List or {}) do
			opts[#opts+1] = { text = "[ ".. _weapon_id .." ]", callback_func = callback(SkinEditor_Patch, SkinEditor_Patch, "choose_skins_after_type", {weapon_id = _weapon_id}) }
		end
		opts[#opts+1] = { text = managers.localization:text("SkinEditor_Patch_use4cancel"), is_cancel_button = true }
		local _dialog_data = {
			title = managers.localization:text("SkinEditor_Patch_menu_title"),
			text = managers.localization:text("SkinEditor_Patch_menu_change_settings_main_text"),
			button_list = opts,
			id = tostring(math.random(0,0xFFFFFFFF))
		}
		managers.system_menu:show(_dialog_data)
	end
	MenuHelper:AddButton({
		id = "SkinEditor_Patch_Change_Skins_callback",
		title = "SkinEditor_Patch_menu_change_settings_title",
		desc = "SkinEditor_Patch_menu_change_settings_desc",
		callback = "SkinEditor_Patch_Change_Skins_callback",
		menu_id = SkinEditor_Patch.options_menu
	})
end)
Hooks:Add("MenuManagerBuildCustomMenus", "SkinEditor_PatchOptions", function(menu_manager, nodes)
	nodes[SkinEditor_Patch.options_menu] = MenuHelper:BuildMenu( SkinEditor_Patch.options_menu )
	MenuHelper:AddMenuItem( MenuHelper.menus.lua_mod_options_menu, SkinEditor_Patch.options_menu, "SkinEditor_Patch_menu_title", "SkinEditor_Patch_menu_desc")
end)

function SkinEditor_Patch:Table2Load(original)
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
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return original
end

function SkinEditor_Patch:Table2Save(original)
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
							if tostring(json.encode(v3)) == "[]" then
								original[k1][k2][k3] = {}
							end
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
	return original
end

local _boo_loaded = false

function SkinEditor_Patch:Apply_Skins(weapon_unit)
	if SkinEditor_Patch and weapon_unit and alive(weapon_unit) and weapon_unit:base() then
		if not _boo_loaded then
			_boo_loaded = true
			SkinEditor_Patch:Load()
		end
		local _weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(weapon_unit:base()._factory_id) or nil
		if SkinEditor_Patch.Skins_Data and _weapon_id and SkinEditor_Patch.settings and SkinEditor_Patch.settings[_weapon_id] then
			weapon_unit:base()._cosmetics_data = SkinEditor_Patch.Skins_Data[SkinEditor_Patch.settings[_weapon_id]]
			weapon_unit:base():_apply_cosmetics(function()
			end)
		end
	end
end

function toVector3(strings)
	strings = strings:gsub("Vector3", "")
	strings = strings:gsub('%(', '')
	strings = strings:gsub('%)', '')
	strings = strings:gsub(' ', '')
	local strings2 = mysplit(strings, ",")
	local x, y, z = tonumber(strings2[1]), tonumber(strings2[2]), tonumber(strings2[3])
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