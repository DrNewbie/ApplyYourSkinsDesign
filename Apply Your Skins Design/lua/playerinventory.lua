_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}

local _f_PlayerInventory_add_unit = PlayerInventory.add_unit

function PlayerInventory:add_unit(new_unit, ...)
	_f_PlayerInventory_add_unit(self, new_unit, ...)
	SkinEditor_Patch:Apply_Skins(new_unit)
end