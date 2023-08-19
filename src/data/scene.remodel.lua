-- arguments
local ARGS = {...}
local JSON_STRING = ARGS[1]:gsub("'", "\"")
local SCENE_CONFIG = json.fromString(JSON_STRING)
local SCENE_BUILD_PATH = ARGS[2]
local SCENE_DIR_PATH = ARGS[3]

-- other constants
local ASSET_PREFIX = "http://www.roblox.com/asset/?id="
local WORKSPACE_PATH = SCENE_DIR_PATH .. "/Workspace"
local SERVER_STORAGE_PATH = SCENE_DIR_PATH .. "/ServerStorage"
local SOUND_SERVICE_PATH = SCENE_DIR_PATH .. "/SoundService"
local MATERIAL_SERVICE_PATH = SCENE_DIR_PATH .. "/MaterialService"
local REPLICATED_STORAGE_PATH = SCENE_DIR_PATH .. "/ReplicatedStorage"
local REPLICATED_FIRST_PATH = SCENE_DIR_PATH .. "/ReplicatedFirst"
local LIGHTING_PATH = SCENE_DIR_PATH .. "/Lighting"
local STATER_PACK_PATH = SCENE_DIR_PATH .. "/StarterPack"

local TERRAIN_PATH = SCENE_DIR_PATH .. "/terrain.rbxm"

-- private functions
function fromHex(hex)
	if hex == 0 then return Color3.new(0,0,0) end
	hex = tostring(hex):gsub("#","")
	local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	return Color3.fromRGB(r, g, b)
end
function clearAllChildren(inst)
	for i, child in ipairs(inst:GetChildren()) do
		if child.ClassName ~= "Camera" then
			child:Destroy()
		end
	end
end

-- Get a place file to work with
local place = remodel.readPlaceFile(SCENE_BUILD_PATH)

-- Configure HttpService
local httpService = place:GetService("HttpService")
print("configuring HttpService")
remodel.setRawProperty(
	httpService, 
	"HttpEnabled",
	"Bool",
	true
)

-- Configure workspace
print("configuring workspace")
local workspace = place:GetService("Workspace")
clearAllChildren(workspace)

remodel.setRawProperty(
	workspace, 
	"StreamingEnabled",
	"Bool",
	SCENE_CONFIG.Streaming.Enabled
)
remodel.setRawProperty(
	workspace, 
	"StreamingMinRadius",
	"Int32",
	SCENE_CONFIG.Streaming.Radius.Min
)
remodel.setRawProperty(
	workspace, 
	"StreamingTargetRadius",
	"Int32",
	SCENE_CONFIG.Streaming.Radius.Max
)
remodel.setRawProperty(
	workspace, 
	"FallenPartsDestroyHeight", 
	"Float32",
	SCENE_CONFIG.Physics.FallenPartDestroyHeight
)
remodel.setRawProperty(
	workspace, 
	"Gravity", 
	"Float32",
	SCENE_CONFIG.Physics.Gravity
)
remodel.setRawProperty(
	workspace, 
	"TouchesUseCollisionGroups", 
	"Bool",
	true
)

-- Add Terrain
print("Loading terrain")
for j, inst in ipairs(remodel.readModelFile(TERRAIN_PATH)) do

	if inst.ClassName == "Terrain" then
		print("terrain found, formatting")
		for i, child in ipairs(workspace:GetChildren()) do
			if child.ClassName == "Terrain" then
				child:Destroy()
			end
		end
		print("adding terrain under place file")
		inst.Parent = place:GetService("Workspace")
		break
	end
end


-- Configure camera
print("configuring Camera")
local camera = workspace:FindFirstChild("Camera")
if camera then
	remodel.setRawProperty(
		camera,
		"FieldOfView",
		"Float32",
		SCENE_CONFIG.Player.Camera.FieldOfView
	)
end


-- Move instances into relevant services
function moveIntoService(serviceDirPath, service)
	if remodel.isDir(serviceDirPath) then
		for i, dirName in ipairs(remodel.readDir(serviceDirPath)) do
			for j, inst in ipairs(remodel.readModelFile(serviceDirPath.."/"..dirName)) do
				print(" - "..inst.Name)
				inst.Parent = service
			end
		end
	end
end
moveIntoService(WORKSPACE_PATH, workspace)
moveIntoService(SERVER_STORAGE_PATH, place:GetService("ServerStorage"))
moveIntoService(SOUND_SERVICE_PATH, place:GetService("SoundService"))
moveIntoService(REPLICATED_STORAGE_PATH, place:GetService("ReplicatedStorage"))
moveIntoService(MATERIAL_SERVICE_PATH, place:GetService("MaterialService"))
moveIntoService(REPLICATED_FIRST_PATH, place:GetService("ReplicatedFirst"))
moveIntoService(LIGHTING_PATH, place:GetService("Lighting"))
moveIntoService(STATER_PACK_PATH, place:GetService("StarterPack"))

-- Configure terrain
print("configuring Terrain")
local terrain = workspace.Terrain
remodel.setRawProperty(
	terrain, 
	"Decoration", 
	"Bool",
	SCENE_CONFIG.Terrain.Decoration
)
remodel.setRawProperty(
	terrain, 
	"WaterReflectance", 
	"Float32",
	SCENE_CONFIG.Terrain.Water.Reflectance
)
remodel.setRawProperty(
	terrain, 
	"WaterTransparency", 
	"Float32",
	SCENE_CONFIG.Terrain.Water.Transparency
)
remodel.setRawProperty(
	terrain, 
	"WaterWaveSize", 
	"Float32",
	SCENE_CONFIG.Terrain.Water.Wave.Size
)
remodel.setRawProperty(
	terrain, 
	"WaterWaveSize", 
	"Float32",
	SCENE_CONFIG.Terrain.Water.Wave.Size
)
remodel.setRawProperty(
	terrain, 
	"WaterWaveSpeed", 
	"Float32",
	SCENE_CONFIG.Terrain.Water.Wave.Speed
)
remodel.setRawProperty(
	terrain, 
	"WaterColor", 
	"Color3",
	fromHex(SCENE_CONFIG.Terrain.Color.Water)
)
clearAllChildren(terrain)

-- Configure clouds
print("configuring Clouds")
local clouds = Instance.new("Clouds")
clouds.Parent = terrain
remodel.setRawProperty(
	clouds, 
	"Density", 
	"Float32",
	SCENE_CONFIG.Sky.Clouds.Density
)
remodel.setRawProperty(
	clouds, 
	"Cover", 
	"Float32",
	SCENE_CONFIG.Sky.Clouds.Cover
)
remodel.setRawProperty(
	clouds, 
	"Color", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Clouds.Color)
)

-- Configure lighting
print("configuring Lighting")
local lighting = place:GetService("Lighting")
remodel.setRawProperty(
	lighting, 
	"Ambient", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Color.Ambient.Indoor)
)
remodel.setRawProperty(
	lighting, 
	"OutdoorAmbient", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Color.Ambient.Outdoor)
)
remodel.setRawProperty(
	lighting, 
	"Brightness", 
	"Float32",
	SCENE_CONFIG.Sky.Brightness
)
remodel.setRawProperty(
	lighting, 
	"EnvironmentDiffuseScale", 
	"Float32",
	SCENE_CONFIG.Sky.Environment.Diffuse
)
remodel.setRawProperty(
	lighting, 
	"EnvironmentSpecularScale", 
	"Float32",
	SCENE_CONFIG.Sky.Environment.Specular
)
remodel.setRawProperty(
	lighting, 
	"GlobalShadows", 
	"Bool",
	SCENE_CONFIG.Sky.GlobalShadows
)
remodel.setRawProperty(
	lighting, 
	"ColorShift_Bottom", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Color.ColorShift.Bottom)
)
remodel.setRawProperty(
	lighting, 
	"ColorShift_Top", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Color.ColorShift.Top)
)
remodel.setRawProperty(
	lighting, 
	"ClockTime", 
	"Float32",
	SCENE_CONFIG.Sky.Time
)
remodel.setRawProperty(
	lighting, 
	"GeographicLatitude", 
	"Float32",
	SCENE_CONFIG.Sky.Latitude
)
remodel.setRawProperty(
	lighting, 
	"ExposureCompensation", 
	"Float32",
	SCENE_CONFIG.Sky.Color.Exposure
)
clearAllChildren(lighting)

-- Atmosphere
print("configuring Atmosphere")
local atmosphere = Instance.new("Atmosphere")
atmosphere.Parent = lighting
remodel.setRawProperty(
	atmosphere, 
	"Color", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Atmosphere.Color)
)
remodel.setRawProperty(
	atmosphere, 
	"Decay", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Atmosphere.Decay)
)
remodel.setRawProperty(
	atmosphere, 
	"Glare", 
	"Float32",
	SCENE_CONFIG.Sky.Atmosphere.Glare
)
remodel.setRawProperty(
	atmosphere, 
	"Haze", 
	"Float32",
	SCENE_CONFIG.Sky.Atmosphere.Haze
)
remodel.setRawProperty(
	atmosphere, 
	"Density", 
	"Float32",
	SCENE_CONFIG.Sky.Atmosphere.Density
)
remodel.setRawProperty(
	atmosphere, 
	"Offset", 
	"Float32",
	SCENE_CONFIG.Sky.Atmosphere.Offset
)

-- Sky
print("configuring Sky")
local sky = Instance.new("Sky")
sky.Parent = lighting
remodel.setRawProperty(
	sky, 
	"CelestialBodiesShown", 
	"Bool",
	true
)
remodel.setRawProperty(
	sky, 
	"MoonAngularSize", 
	"Float32",
	SCENE_CONFIG.Sky.Moon.AngularSize
)
remodel.setRawProperty(
	sky, 
	"MoonTextureId", 
	"String",
	SCENE_CONFIG.Sky.Moon.Texture
)
remodel.setRawProperty(
	sky, 
	"SkyboxBk", 
	"String",
	ASSET_PREFIX..tostring(SCENE_CONFIG.Sky.Box.Back)
)
remodel.setRawProperty(
	sky, 
	"SkyboxDn", 
	"String",
	ASSET_PREFIX..tostring(SCENE_CONFIG.Sky.Box.Down)
)
remodel.setRawProperty(
	sky, 
	"SkyboxFt", 
	"String",
	ASSET_PREFIX..tostring(SCENE_CONFIG.Sky.Box.Front)
)
remodel.setRawProperty(
	sky, 
	"SkyboxLf", 
	"String",
	ASSET_PREFIX..tostring(SCENE_CONFIG.Sky.Box.Left)
)
remodel.setRawProperty(
	sky, 
	"SkyboxRt", 
	"String",
	ASSET_PREFIX..tostring(SCENE_CONFIG.Sky.Box.Right)
)
remodel.setRawProperty(
	sky, 
	"SkyboxUp", 
	"String",
	ASSET_PREFIX..tostring(SCENE_CONFIG.Sky.Box.Up)
)
remodel.setRawProperty(
	sky, 
	"StarCount", 
	"Int32",
	SCENE_CONFIG.Sky.StarCount
)
remodel.setRawProperty(
	sky, 
	"SunAngularSize", 
	"Float32",
	SCENE_CONFIG.Sky.Sun.AngularSize
)
remodel.setRawProperty(
	sky, 
	"SunTextureId", 
	"String",
	SCENE_CONFIG.Sky.Sun.Texture
)

-- Bloom
print("configuring Bloom")
local bloom = Instance.new("BloomEffect")
bloom.Parent = lighting
remodel.setRawProperty(
	bloom, 
	"Intensity", 
	"Float32",
	SCENE_CONFIG.Sky.Bloom.Intensity
)
remodel.setRawProperty(
	bloom, 
	"Size", 
	"Float32",
	SCENE_CONFIG.Sky.Bloom.Size
)
remodel.setRawProperty(
	bloom, 
	"Threshold", 
	"Float32",
	SCENE_CONFIG.Sky.Bloom.Threshold
)

-- Blur
print("configuring Blur")
local blur = Instance.new("BlurEffect")
blur.Parent = lighting
remodel.setRawProperty(
	blur, 
	"Size", 
	"Float32",
	SCENE_CONFIG.Sky.Blur
)

-- Color Correction
print("configuring Color Correction")
local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Parent = lighting
remodel.setRawProperty(
	colorCorrection, 
	"Brightness", 
	"Float32",
	SCENE_CONFIG.Sky.Color.Brightness
)
remodel.setRawProperty(
	colorCorrection, 
	"Contrast", 
	"Float32",
	SCENE_CONFIG.Sky.Color.Contrast
)
remodel.setRawProperty(
	colorCorrection, 
	"Saturation", 
	"Float32",
	SCENE_CONFIG.Sky.Color.Saturation
)
remodel.setRawProperty(
	colorCorrection, 
	"TintColor", 
	"Color3",
	fromHex(SCENE_CONFIG.Sky.Color.Tint)
)

-- Depth of Field
print("configuring Depth of Field")
local depthOfField = Instance.new("DepthOfFieldEffect")
depthOfField.Parent = lighting
remodel.setRawProperty(
	depthOfField, 
	"FarIntensity", 
	"Float32",
	SCENE_CONFIG.Sky.DepthOfField.Intensity.Far
)
remodel.setRawProperty(
	depthOfField, 
	"NearIntensity", 
	"Float32",
	SCENE_CONFIG.Sky.DepthOfField.Intensity.Near
)
remodel.setRawProperty(
	depthOfField, 
	"FocusDistance", 
	"Float32",
	SCENE_CONFIG.Sky.DepthOfField.Focus.Distance
)
remodel.setRawProperty(
	depthOfField, 
	"InFocusRadius", 
	"Float32",
	SCENE_CONFIG.Sky.DepthOfField.Focus.Radius
)

-- Sun rays
print("configuring Sun Rays")
local sunRays = Instance.new("SunRaysEffect")
sunRays.Parent = lighting
remodel.setRawProperty(
	sunRays, 
	"Intensity", 
	"Float32",
	SCENE_CONFIG.Sky.Sun.Intensity
)
remodel.setRawProperty(
	sunRays, 
	"Spread", 
	"Float32",
	SCENE_CONFIG.Sky.Sun.Spread
)

-- Players
print("configuring Players")
local Players = place:GetService("Players")
remodel.setRawProperty(
	Players, 
	"CharacterAutoLoads", 
	"Bool",
	SCENE_CONFIG.Player.Character.AutoLoad
)
remodel.setRawProperty(
	Players, 
	"RespawnTime", 
	"Float32",
	SCENE_CONFIG.Player.RespawnTime
)
remodel.setRawProperty(
	Players, 
	"UseStrafingAnimations", 
	"Bool",
	true
)

-- StarterPlayer
print("configuring StarterPlayer")
local StarterPlayer = place:GetService("StarterPlayer")
remodel.setRawProperty(
	StarterPlayer, 
	"HealthDisplayDistance", 
	"Float32",
	SCENE_CONFIG.Player.DisplayDistance.Health
)
remodel.setRawProperty(
	StarterPlayer, 
	"NameDisplayDistance", 
	"Float32",
	SCENE_CONFIG.Player.DisplayDistance.Name
)
remodel.setRawProperty(
	StarterPlayer, 
	"CameraMaxZoomDistance", 
	"Float32",
	SCENE_CONFIG.Player.Camera.Zoom.Max
)
remodel.setRawProperty(
	StarterPlayer, 
	"CameraMinZoomDistance", 
	"Float32",
	SCENE_CONFIG.Player.Camera.Zoom.Min
)
remodel.setRawProperty(
	StarterPlayer, 
	"CharacterMaxSlopeAngle", 
	"Float32",
	SCENE_CONFIG.Player.Character.MaxSlopeAngle
)
remodel.setRawProperty(
	StarterPlayer, 
	"CharacterWalkSpeed", 
	"Float32",
	SCENE_CONFIG.Player.Character.WalkSpeed
)
remodel.setRawProperty(
	StarterPlayer, 
	"LoadCharacterAppearance", 
	"Bool",
	SCENE_CONFIG.Player.Character.LoadCharacterAppearance
)
remodel.setRawProperty(
	StarterPlayer, 
	"UserEmotesEnabled", 
	"Bool",
	SCENE_CONFIG.Player.Character.UserEmotesEnabled
)
remodel.setRawProperty(
	StarterPlayer, 
	"CharacterUseJumpPower", 
	"Bool",
	false
)
remodel.setRawProperty(
	StarterPlayer, 
	"CharacterJumpHeight", 
	"Float32",
	SCENE_CONFIG.Player.Character.JumpHeight
)
remodel.setRawProperty(
	StarterPlayer, 
	"EnableMouseLock", 
	"Bool",
	SCENE_CONFIG.Player.Controls.EnableMouseLock
)
remodel.setRawProperty(
	StarterPlayer, 
	"AutoJumpEnabled", 
	"Bool",
	SCENE_CONFIG.Player.Controls.MobileAutoJumpEnabled
)

-- SoundService
print("configuring SoundService")
local SoundService = place:GetService("SoundService")
remodel.setRawProperty(
	SoundService, 
	"DistanceFactor", 
	"Float32",
	SCENE_CONFIG.Sound.DistanceFactor
)
remodel.setRawProperty(
	SoundService, 
	"DopplerScale", 
	"Float32",
	SCENE_CONFIG.Sound.DopplerScale
)

-- Chat
print("configuring Chat")
local chat = place:GetService("Chat")
remodel.setRawProperty(
	chat, 
	"BubbleChatEnabled", 
	"Bool",
	SCENE_CONFIG.Chat.Bubble.Enabled
)

-- TextChat
print("configuring TextChat")
local textChatService = place:GetService("TextChatService")
remodel.setRawProperty(
	textChatService, 
	"CreateDefaultCommands", 
	"Bool",
	SCENE_CONFIG.Chat.Default.Commands
)
remodel.setRawProperty(
	textChatService, 
	"CreateDefaultTextChannels", 
	"Bool",
	SCENE_CONFIG.Chat.Default.TextChannels
)

-- BubbleChatConfiguration
print("configuring BubbleChat")
local bubbleChatConfiguration = textChatService:FindFirstChild("BubbleChatConfiguration")
if bubbleChatConfiguration then
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"AdorneeName", 
		"String",
		SCENE_CONFIG.Chat.Bubble.AdorneeName
	)
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"BubbleDuration", 
		"Float32",
		SCENE_CONFIG.Chat.Bubble.Duration
	)
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"BubbleSpacing", 
		"Float32",
		SCENE_CONFIG.Chat.Bubble.Spacing
	)
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"Enabled", 
		"Bool",
		SCENE_CONFIG.Chat.Bubble.Enabled
	)
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"MaxDistance", 
		"Float32",
		SCENE_CONFIG.Chat.Bubble.Distance.Max
	)
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"MinimizeDistance", 
		"Float32",
		SCENE_CONFIG.Chat.Bubble.Distance.Min
	)
	remodel.setRawProperty(
		bubbleChatConfiguration, 
		"VerticalStudsOffset", 
		"Float32",
		SCENE_CONFIG.Chat.Bubble.Offset
	)
end

-- Write changes to file
print("Writing to final file")
remodel.writePlaceFile(SCENE_BUILD_PATH, place)

