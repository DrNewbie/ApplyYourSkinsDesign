_G.SkinEditor_Patch = _G.SkinEditor_Patch or {}
SkinEditor_Patch.Skins_Data = SkinEditor_Patch.Skins_Data or {}
SkinEditor_Patch.ModPath = ModPath
SkinEditor_Patch.SaveFile = SkinEditor_Patch.SaveFile or SavePath .. "SkinEditor_Patch.txt"
SkinEditor_Patch.ModOptions = SkinEditor_Patch.ModPath .. "menus/modoptions.txt"
SkinEditor_Patch.settings = SkinEditor_Patch.settings or {}
SkinEditor_Patch.options_menu = "SkinEditor_Patch_menu"

function SkinEditor_Patch:Load()
	local file = io.open(self.SaveFile, "r")
	if file then
		self.Skins_Data = json.decode(file:read("*all")) or {}
		file:close()
	end
end

function SkinEditor_Patch:Save()
	local file = io.open(self.SaveFile, "w+")
	if file then
		file:write(json.encode(self.Skins_Data))
		file:close()
	end
end