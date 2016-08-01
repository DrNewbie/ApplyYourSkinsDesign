_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}

local _f_MenuSceneManager_set_scene_template = MenuSceneManager.set_scene_template

function MenuSceneManager:set_scene_template(...)
	_f_MenuSceneManager_set_scene_template(self, ...)
	DelayedCalls:Add("DelayedModSkinsApply", 1, function()
		if SkinEditor_Patch then
			for _, weapon_units in pairs(self._weapon_units or {}) do
				for _, weapon_data in pairs(weapon_units or {}) do
					if weapon_data.unit then
						SkinEditor_Patch:Apply_Skins(weapon_data.unit)
					end
				end
			end
		end
	end)
end