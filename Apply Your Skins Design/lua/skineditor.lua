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
	local _path = Application:nice_path(skin:path(), true)
	SkinEditor_Patch:Save(_path, original)
end

function SkinEditor:load_textures(skin, path)
	local textures = self:get_texture_list(skin, path)
	local new_textures = {}
	local type_texture_id = Idstring("texture")
	path = path or skin:path()
	for _, texture in ipairs(textures) do
		local texture_id = self:get_texture_idstring(skin, texture)
		local rel_path = Application:nice_path(path, true)
		rel_path = string.sub(rel_path, string.len(Application:base_path()) + 1)
		rel_path = string.gsub(rel_path, "\\", "/")
		log("Creating texture entry: " .. tostring(texture_id) .. " pointing at " .. rel_path .. texture)
		DB:create_entry(type_texture_id, texture_id, rel_path .. texture)
		table.insert(new_textures, texture_id)
	end
	if not table.empty(new_textures) then
		Application:reload_textures(new_textures)
	end
end