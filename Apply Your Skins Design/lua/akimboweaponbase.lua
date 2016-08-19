local _f_AkimboWeaponBase_1_create_second_gun = AkimboWeaponBase._create_second_gun
function AkimboWeaponBase:_create_second_gun()
	_f_AkimboWeaponBase_1_create_second_gun(self)
	SkinEditor_Patch:Apply_Skins(self._second_gun)
end