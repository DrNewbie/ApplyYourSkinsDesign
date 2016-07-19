_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}

local _f_PlayerInventory_add_unit = PlayerInventory.add_unit

function PlayerInventory:add_unit(new_unit, ...)
	_f_PlayerInventory_add_unit(self, new_unit, ...)
	if SkinEditor_Patch and new_unit and alive(new_unit) and new_unit:base() then
		SkinEditor_Patch:Load()
		if SkinEditor_Patch.Skins_Data and SkinEditor_Patch.Skins_Data[new_unit:base()._factory_id] then
			new_unit:base()._cosmetics_data = SkinEditor_Patch.Skins_Data[new_unit:base()._factory_id].cosmetics
			new_unit:base():_apply_cosmetics(function()
			end)
		end
	end
end