--!nocheck
-- arguments
local ARGS = {...}
local JSON_STRING = ARGS[1]:gsub("'", "\"")
local SCENE_CONFIG = rbxmk.decodeFormat("json", JSON_STRING)
local SCENE_BUILD_PATH = ARGS[2]

-- open place
local place = fs.read(SCENE_BUILD_PATH)

-- set material overrides
local MATERIAL_CONFIG = SCENE_CONFIG.Material
local materialService = place:GetService("MaterialService")
for k, v in pairs(MATERIAL_CONFIG) do
	materialService[k.."Name"] = v
end



-- set player enums
local PLAYER_CONFIG = SCENE_CONFIG.Player
local CHARACTER_CONFIG = PLAYER_CONFIG.Character
local starterPlayer = place:GetService("StarterPlayer")
if CHARACTER_CONFIG.EnableDynamicHeads then
	starterPlayer.EnableDynamicHeads = types.token(2)
else
	starterPlayer.EnableDynamicHeads = types.token(1)
end
if CHARACTER_CONFIG.EnableLayeredClothing then
	starterPlayer.LoadCharacterLayeredClothing = types.token(2)
else
	starterPlayer.LoadCharacterLayeredClothing = types.token(1)
end

-- set lighting technology
local SKY_CONFIG = SCENE_CONFIG.Sky
local lighting = place:GetService("Lighting")
local LightingTechnology = {
	Legacy = 0,
	Voxel = 1,
	Compatibility = 2,
	ShadowMap = 3,
	Future = 4,
}
lighting.Technology = types.token(LightingTechnology[SKY_CONFIG.Technology] or 1)

-- set streaming modes
local STREAM_CONFIG = SCENE_CONFIG.Streaming
local StreamIntegrityModeValues = {
	Default = 0,
	Disabled = 1,
	MinimumRadiusPause = 2,
	PauseOutsideLoadedArea = 3,
}
local StreamOutBehaviorValues = {
	Default = 0,
	LowMemory = 1,
	Opportunistic = 2,
}
local workspace = place:GetService("Workspace")
workspace.StreamingIntegrityMode = types.token(StreamIntegrityModeValues[STREAM_CONFIG.IntegrityMode] or 0)
workspace.StreamOutBehavior = types.token(StreamOutBehaviorValues[STREAM_CONFIG.OutBehavior] or 0)

-- write to file
fs.write(SCENE_BUILD_PATH, place)
