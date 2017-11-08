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