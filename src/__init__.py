import sys
import os
import multiprocessing
import yaml
import json
import shutil
import dpath
from tempfile import TemporaryDirectory
from luau.convert import from_dict
from luau.roblox import write_script

DEFAULT_SCENE_CONFIG = """
PlaceId: 0
Name: Main
Streaming:
  IntegrityMode: Default
  OutBehavior: Default
  Enabled: true
  Radius:
    Min: 256
    Max: 2048
Physics:
  Gravity:  196.2
  FallenPartDestroyHeight: -500
Terrain:
  Decoration: true
  Water:
    Transparency: 0.3
    Reflectance: 1
    Wave:
      Size: 0.15
      Speed: 10
  Color:
    Water: 0C545B
    Asphalt: 737B6B
    Basalt: 1E1E25
    Brick: 8A563E
    Cobblestone: 847B5A
    Concrete: 7F663F
    CrackedLava: E89C4A
    Glacier: 65B0EA
    Grass: 6A7F3F
    Ground: 665C3B
    Ice: 81C2E0
    LeafyGrass: 73844A
    Limestone: CEAD94
    Mud: 3A2E24
    Pavement: 94948C
    Rock: 666C6F
    Salt: C6BDB5
    Sand: 8F7E5F
    Sandstone: 895A47
    Slate: 3F7F6B
    Snow: C3C7DA
    WoodPlanks: 8B6D4F
Sky:
  StarCount: 3000
  Atmosphere:
    Density: 0.19
    Offset: 0
    Color: c7aa6b
    Decay: 5c3c0d
    Glare: 0
    Haze: 0
  DepthOfField:
    Intensity:
      Far: 0.3
      Near: 0
    Focus:
      Distance: 135
      Radius: 0
  Box:
    Back: 98202165
    Front: 98202152
    Left: 98202161
    Right: 98202146
    Up: 98202169
    Down: 98202176
  Bloom:
    Intensity: 0
    Size: 0
    Threshold: 0
  Blur: 0
  Brightness: 2
  Environment:
    Diffuse: 1
    Specular: 1
  Color:
    Saturation: 0
    Brightness: 0
    Contrast: 0
    Tint: FFFFFF
    Ambient: 
      Indoor: \"000000\"
      Outdoor: 778DB0
    Exposure: 0
    ColorShift:
      Top: D8B474
      Bottom: \"000000\"
  GlobalShadows: true
  Technology: Voxel
  Time: 14
  Latitude: 41.733
  Clouds:
    Cover: 0.5
    Density: 0.7
    Color: FFFFFF
  Moon:
    Texture: rbxassetid://1345054856
    AngularSize: 21
  Sun:
    Texture: rbxasset://sky/sun.jpg
    AngularSize: 21
    Intensity: 0.25
    Spread: 1
Material:
  Asphalt:
  Basalt:
  Brick:
  Cobblestone:
  Concrete:
  CorrodedMetal:
  CrackedLava:
  DiamondPlate:
  Fabric:
  Foil:
  Glacier:
  Granite:
  Grass:
  Ground:
  Ice:
  LeafyGrass:
  Limestone:
  Marble:
  Metal:
  Mud:
  Pavement:
  Pebble:
  Plastic:
  Rock:
  Salt:
  Sand:
  Sandstone:
  Slate:
  SmoothPlastic:
  Snow:
  Wood:
  WoodPlanks:
Player:
  RespawnTime: 5
  Camera:
    FieldOfView: 70
    Zoom:
      Min: 0.5
      Max: 400
  DisplayDistance:
    Health: 100
    Name: 100
  Character:
    AutoLoad: true
    MaxSlopeAngle: 89
    WalkSpeed: 16
    LoadCharacterAppearance: true
    EnableDynamicHeads: false
    EnableLayeredClothing: true
    UserEmotesEnabled: true
    JumpHeight: 7.2
  Controls:
    EnableMouseLock: true
    MobileAutoJumpEnabled: true
Sound:
  DistanceFactor: 3.33
  DopplerScale: 1
Chat:
  Bubble:
    Enabled: true
    Duration: 15
    Spacing: 6
    Distance:
      Max: 100
      Min: 40
    Offset: 0
    AdorneeName: HumanoidRootPart
  Default:
    Commands: true
    TextChannels: True
"""

def get_data_file_path(file_name: str) -> str:
	base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
	return os.path.join(base_path, f"data\\{file_name}").replace("\\", "/")

def run_exe_process(exe_name: str, args: list = [], silent=True):
	abs_path = get_data_file_path(exe_name)

	command = " ".join([abs_path] + args)

	if silent:
		command = command.replace("\"", "\\\"")
		bash_command = f"bash -c \"{command} > /dev/null 2>&1\""
		# print(f"bash_cmd: {bash_command}")
		os.system(bash_command)
	else:
		print("cmd: ",command)
		os.system(command)

def main():
	default_config = yaml.safe_load(DEFAULT_SCENE_CONFIG)
	is_verbose = "-verbose" in sys.argv
	if sys.argv[1] == "new":
		scene_dir_path = "scene/main"
		if len(sys.argv) > 2:
			scene_dir_path = sys.argv[2]
		assert not os.path.exists(scene_dir_path), f"a scene already exists at {scene_dir_path}"
		print(f"creating new scene at {scene_dir_path}")
		os.makedirs(scene_dir_path+"/Workspace")
		with open(scene_dir_path+"/scene.yaml", "w") as config_file:
			config_file.write(yaml.safe_dump(default_config))
		shutil.copy(get_data_file_path("terrain.rbxm"), scene_dir_path + "/terrain.rbxm")
	else:
		scene_path = sys.argv[1]

		scene_base, scene_name = os.path.split(scene_path)
		print(f"building scene {scene_name} at {scene_path}")

		# get composite scene_config
		with open(scene_path + "/scene.yaml", "r") as scene_file:
			scene_config = dpath.merge(default_config, yaml.safe_load(scene_file.read())) 

		if scene_name != "main":
			main_scene_path = scene_base + "/main"
			if os.path.exists(main_scene_path):
				with open(main_scene_path + "/scene.yaml", "r") as main_scene_file:
					main_scene_config = yaml.safe_load(main_scene_file.read())
					scene_config = dpath.merge(main_scene_config, scene_config)

		# with open("test.json", "w") as test_file:
		# 	test_file.write(json.dumps(scene_config, indent=5))

		rojo_project_path = "default.project.json"
		if len(sys.argv) > 2:
			rojo_project_path = sys.argv[2]

		json_str = json.dumps(scene_config).replace("\n", "").replace(" ", "").replace("\"", "'")

		empty_file_path = get_data_file_path("empty.rbxl")

		# create place file
		scene_place_file_path = scene_path + "/build.rbxl"
		if os.path.exists(scene_place_file_path):
			os.remove(scene_place_file_path)

		shutil.copy(empty_file_path, scene_place_file_path)

		# build roblox config script if provided out path
		if len(sys.argv) > 3:
			luau_config_script_build_path = sys.argv[3]
			content = [
				"--!strict",
				"-- do not edit, this was generated by @nightcycle/scene-clt",
				"return " + from_dict(scene_config, skip_initial_indent=True)
			]
			# print("out", luau_config_script_build_path)
			# print("content", content)
			write_script(luau_config_script_build_path, "\n".join(content), skip_source_map=False)

		# run rojo
		with TemporaryDirectory() as temp_dir_path:
			with open(rojo_project_path, "r") as rojo_file:
				if is_verbose:
					print("reading " + rojo_project_path)
				rojo_data = json.loads(rojo_file.read())
				tree_data = rojo_data["tree"]
				if not "Workspace" in tree_data:
					if is_verbose:
						print("adding workspace to rojo config file")
					tree_data["Workspace"] = {
						"$className": "Workspace",
					}
				workspace_data = tree_data["Workspace"]
				# terrain_path = scene_path+"/terrain.rbxm"
				# workspace_path = scene_path+"/Workspace"
				
				# for sub_path in os.listdir(workspace_path):
				# 	name = os.path.splitext(sub_path)[0]
				# 	if is_verbose:
				# 		print(f"adding {sub_path} to rojo config file under workspace")
				# 	workspace_data[name] = {
				# 		"$path": os.path.abspath(workspace_path + "/" + sub_path)
				# 	}

				temp_rojo_path = temp_dir_path+"/default.project.json"
				with open(temp_rojo_path, "w") as temp_rojo_file:
					if is_verbose:
						json.dumps(rojo_data, indent=5)
					temp_rojo_file.write(json.dumps(rojo_data, indent=5))
				
				run_exe_process("rojo.exe", ["build", temp_rojo_path, "-o", scene_place_file_path], silent=not is_verbose)

		# run remodel
		run_exe_process("remodel.exe", ["run", get_data_file_path("scene.remodel.lua"), f"\"{json_str}\"", scene_place_file_path, scene_path], silent=not is_verbose)

		# run rbxmk
		run_exe_process("rbxmk.exe", ["run", get_data_file_path("scene.rbxmk.lua"), f"\"{json_str}\"", scene_place_file_path], silent=not is_verbose)

# prevent from running twice
if __name__ == '__main__':
	multiprocessing.freeze_support()
	main()		
