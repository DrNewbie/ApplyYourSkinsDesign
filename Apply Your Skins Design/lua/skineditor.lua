SkinEditor = SkinEditor or class()

_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}
SkinEditor_Patch.Skins_Data = SkinEditor_Patch.Skins_Data or {}

local _f_SkinEditor_apply_changes = SkinEditor.apply_changes

function SkinEditor:apply_changes(cosmetics_data)
	_f_SkinEditor_apply_changes(self, cosmetics_data)
	local _weapon_id
	if self:weapon_unit():base() then
		_weapon_id = self:weapon_unit():base()._factory_id
	end
	if self:second_weapon_unit() then
		_weapon_id = self:second_weapon_unit():base()._factory_id
	end
	SkinEditor_Patch.Skins_Data[_weapon_id] = {
		cosmetics = cosmetics_data			
	}
	SkinEditor_Patch:Save()
end