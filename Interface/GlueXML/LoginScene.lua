
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                1     2  3  4  5    6      7                                                  8                                                       9          10           11         12        13				14
--modelData: { sceneID, x, y, z, o, scale, alpha, [{ enabled[,omni,dirX,dirY,dirZ,ambIntensity[,ambR,ambG,ambB[,dirIntensity[,dirR,dirG,dirB]]]] }], sequence, widthSquish, heightSquish, path [,referenceID] [,cameraModel] }
--[[ DOCUMENTATION:
	sceneID:			number	- on which scene it's supposed to show up
	x:					number	- moves the model left and right  \
	y:					number	- moves the model up and down	   |	if the model doesn't show up at all try moving it around sometimes it will show up | blue white box: wrong path | no texture: texture is set through dbc, needs to be hardcoded | green texture: no texture
	z:					number	- moves the model back and forth  /
	o:					number	- the orientation in which direction the model will face | number in radians | math.pi = 180° | math.pi * 2 = 360° | math.pi / 2 = 90°
	scale:				number	- used to scale the model | 1 = normal size | does not scale particles of flames for example on no camera models, use width/heightSquish for that
	alpha:				number  - opacity of the model | 1 = 100% , 0 = 0%
	light:				table	- table containing light data (look in light documentation for further explanation) | is optional
	sequence:			number	- the animation that should be played after the model is loaded
	widthSquish:		number	- squishes the model on the X axis | 1 = normal
	heightSquish:		number	- squishes the model on the Y axis | 1 = normal
	path:				String  - the path to the model ends with .mdx
	referenceID:		number  - mainly used for making changes while the scene is playing | example:
	
	local m = GetModel(1)	<- GetModel(referenceID) the [1] to use the first model with this referenceID without it it would be a table with all models inside
	if m then
		m = m[1]
		local x,y,z = m:GetPosition()
		m:SetPosition(x-0.1,y,z)				<- move the model -0.1 from it's current position on the x-axis
	end
	
	cameraModel:		String	- if a path to a model is set here, it will be used as the camera
]]
--[[ LIGHT:
	enabled:			number	- appears to be 1 for lit and 0 for unlit
    omni:				number	- ?? (default of 0)
    dirX, dirY, dirZ:	numbers	- vector from the origin to where the light source should face
    ambIntensity:		number	- intensity of the ambient component of the light source
    ambR, ambG, ambB:	numbers	- color of the ambient component of the light source
    dirIntensity:		number	- intensity of the direct component of the light source
    dirR, dirG, dirB:	numbers	- color of the direct component of the light source 
]]
--[[ METHODS:
	GetModelData(referenceID / sceneID, (bool) get-all-scene-models)	table									- gets the model data table out of ModelList (returns a table with all model datas that have the same referenceID) or if bool is true from the scene
	GetModel(referenceID / sceneID, (bool) get-all-scene-models)		table									- gets all models with the same referenceID or the same sceneID (if bool is true)
	SetScene(sceneID)													nil										- sets the current scene to the sceneID given to the function
	GetScene([sceneID])													sceneID, sceneData, models, modeldatas	- gets all information of the current scene [of the sceneID]

	some helpful globals:
	ModelList.sceneCount	number	- the count of how many scenes exist
	ModelList.modelCount	number	- the count of how many models exist
]]
--[[ CREDITS:
	Made by Mordred P.H.
	
	Thanks to:
	Soldan - helping me with all the model work
	Chase - finding a method to copy cameras on the fly
	Stoneharry - bringing me to the conclusion that blizzard frames are never fullscreen, so it works with every resolution
	Blizzard - for making it almost impossible to make it work properly
]]
-------------------------------------------------------------------------
--                   1                2
--sceneData: {time_in_seconds, background_path}   --> (index is scene id)

ModelList = {
	max_scenes = 1,			-- number of scenes you use to shuffle through
	fade_duration = 1,		-- fade animation duration in seconds (to next scene if more than 1 exists)
	sceneData = {
		{10,"Interface/GLUES/LOADINGSCREENS/LoadScreenDeathKnight.blp"},
		{10,"Interface/GLUES/LOADINGSCREENS/LoadScreenDeathKnight.blp"}
	},
	
	-- Scene: 1
	{1, 0, 0, 0, 0, 1, 1, _, 1, 1, 1, "World/Scale/HumanMaleScale.mdx", _, _},
	{1, 0, 0, 0, 0, 1, 1, _, 1, 1, 1, "World/Scale/HumanMaleScale.mdx", _, _}
}

local use_random_starting_scene = false														-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
local shuffle_scenes_randomly = false														-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID

local login_music_path = "Sound/Music/CityMusic/Orgrimmar/orgrimmar_intro-moment.mp3"		-- path to the music
local login_music_time_in_seconds = 40														-- minutes * 60 + seconds

----------------------------------------------------------------------------- end of configuration part ----------------------------------------------------------------------------------------------
local width, height = GlueParent:GetSize()
current_scene = 1
PlayMusic(login_music_path)

function randomScene()
	return (time() % ModelList.max_scenes) + 1
end
if use_random_starting_scene then
	current_scene = randomScene()
end

-- main frame for displaying and positioning of the whole loginscreen
LoginScene = CreateFrame("Frame",nil,AccountLogin)
	LoginScene:SetSize(width, (width/16)*9)
	LoginScene:SetPoint("CENTER", AccountLogin, "CENTER", 0,0)
	LoginScene:SetFrameStrata("LOW")

-- main background that changes according to the scene
LoginScreenBackground = LoginScene:CreateTexture(nil,"LOW")
	LoginScreenBackground:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
	LoginScreenBackground:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)

LoginScreenBlackBoarderTOP = AccountLogin:CreateTexture(nil,"OVERLAY")
	LoginScreenBlackBoarderTOP:SetTexture(0,0,0,1)
	LoginScreenBlackBoarderTOP:SetHeight(500)
	LoginScreenBlackBoarderTOP:SetPoint("BOTTOMLEFT", LoginScene, "TOPLEFT", 0,0)
	LoginScreenBlackBoarderTOP:SetPoint("BOTTOMRIGHT", LoginScene, "TOPRIGHT", 0,0)

LoginScreenBlackBoarderBOTTOM = AccountLogin:CreateTexture(nil,"OVERLAY")
	LoginScreenBlackBoarderBOTTOM:SetTexture(0,0,0,1)
	LoginScreenBlackBoarderBOTTOM:SetHeight(500)
	LoginScreenBlackBoarderBOTTOM:SetPoint("TOPLEFT", LoginScene, "BOTTOMLEFT", 0,0)
	LoginScreenBlackBoarderBOTTOM:SetPoint("TOPRIGHT", LoginScene, "BOTTOMRIGHT", 0,0)

LoginScreenBlend = AccountLogin:CreateTexture(nil,"OVERLAY")
	LoginScreenBlend:SetTexture(0,0,0,1)
	LoginScreenBlend:SetHeight(500)
	LoginScreenBlend:SetAlpha(1)
	LoginScreenBlend:SetAllPoints(GlueParent)

M = {}
function newScene()	-- creates a scene object that gets used internaly
	local s = {parent = CreateFrame("Frame",nil,LoginScene),
				background = ModelList.sceneData[#M+1 or 1][2],
				duration = ModelList.sceneData[#M+1 or 1][1]}
	s.parent:SetSize(LoginScene:GetWidth(), LoginScene:GetHeight())
	s.parent:SetPoint("CENTER")
	s.parent:SetFrameStrata("MEDIUM")
	table.insert(M, s)
	return s
end

function newModel(parent,alpha,light,wSquish,hSquish,camera)	-- creates a new model object that gets used internally but also can be altered after loading
	local mod = CreateFrame("Model",nil,parent)
	
	light = light or {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8}
	mod:SetModel(camera or "Character/Human/Male/HumanMale.mdx")
	mod:SetSize(LoginScene:GetWidth() / wSquish, LoginScene:GetHeight() / hSquish)
	mod:SetPoint("CENTER")
	mod:SetCamera(1)
	mod:SetLight(unpack(light))
	mod:SetAlpha(alpha)
	
	return mod
end

function Generate_M()	-- starts the routine for loading all models and scenes
	ModelList.sceneCount = #ModelList.sceneData
	
	local counter = 0
	for i=1, ModelList.sceneCount do
		local s = newScene()
		
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == i then
					table.insert(s, num, newModel(s.parent, m[7], m[8], m[10], m[11], m[14]))
					counter = counter + 1
					ModelList.lastModelNum = num
				end
			end
		end
		
		s.parent:Hide()
		if i == current_scene then
			LoginScreenBackground:SetTexture(s.background)
		end
	end
	ModelList.modelCount = counter
end
Generate_M()

------- updating and methods

local nextC, nextCset, blend_start
timed_update, blend_timer, music_timer = 0, 0, 0
function LoginScreen_OnUpdate(self,dt)
	if music_timer > login_music_time_in_seconds then		-- Music timer to loop the background music
		PlayMusic(login_music_path)
	else
		music_timer = music_timer + dt
	end
	
	if blend_start then				-- Start blend after the loginscreen loaded to hide the setting up frame
		if blend_start < 0.5 then
			LoginScreenBlend:SetAlpha( 1 - blend_start*2 )
			blend_start = blend_start + dt
		else
			LoginScreenBlend:SetAlpha(0)
			blend_start = false
		end
	end
	
	if timed_update and timed_update > 5 then		-- frame delayed update to hackfix some errors with blizzard masterrace code
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" and m[1] <= ModelList.max_scenes then
				local mod = M[m[1]][num]
				mod:SetModel(m[12])
				mod:SetPosition(m[4], m[2], m[3])
				mod:SetFacing(m[5])
				mod:SetModelScale(m[6])
				mod:SetSequence(m[9])
			end
		end
		
		blend_start = 0
		timed_update = false
		
		M[current_scene].parent:Show()
		Scene_OnStart(current_scene)
	elseif timed_update then
		timed_update = timed_update + 1
	end
	
	local cur = M[current_scene]
	if cur ~= nil and cur.duration < blend_timer then		-- Scene and blend timer for next scene and blends between the scenes
		if ModelList.max_scenes > 1 then
			local blend = blend_timer - cur.duration
			if blend < ModelList.fade_duration then
				LoginScreenBlend:SetAlpha( 1 - math.abs( 1 - (blend*2 / ModelList.fade_duration) ) )
				
				if blend*2 > ModelList.fade_duration and not nextCset then
					nextC = randomScene()
					if shuffle_scenes_randomly then
						if current_scene == nextC then
							nextC = ((current_scene+1 > ModelList.max_scenes) and 1) or current_scene + 1
						end
					else
						nextC = ((current_scene+1 > ModelList.max_scenes) and 1) or current_scene + 1
					end
					nextCset = true
					
					local new = M[nextC]
					cur.parent:Hide()
					new.parent:Show()
					LoginScreenBackground:SetTexture(new.background)
					Scene_OnEnd(current_scene)
					Scene_OnStart(nextC)
				end
				
				blend_timer = blend_timer + dt
			else
				current_scene = nextC
				nextCset = false
				blend_timer = 0
				LoginScreenBlend:SetAlpha(0)
			end
		else
			blend_timer = 0
			Scene_OnEnd(current_scene)
			Scene_OnStart(current_scene)
		end
	else
		blend_timer = blend_timer + dt
	end
	
	SceneUpdate(dt, current_scene, blend_timer, ModelList.sceneData[current_scene][1])
end

function SetScene(sceneID)
	M[current_scene].parent:Hide()
	M[sceneID].parent:Show()
	LoginScreenBackground:SetTexture(M[sceneID].background)
	Scene_OnEnd(current_scene)
	Scene_OnStart(sceneID)
	current_scene = sceneID
end

function GetScene(sceneID)
	local curScene = current_scene
	if sceneID then
		if sceneID <= ModelList.max_scenes and sceneID > 0 then
			curScene = sceneID
		end
	end
	return curScene, ModelList.sceneData[curScene], GetModel(curScene, true), GetModelData(curScene, true)
end

function GetModelData(refID, allSceneModels)
	local data, count = {}, 0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[13] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	end
end

function GetModel(refID, allSceneModels)
	local data, count = {} ,0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, M[m[1]][num])
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		local mData = GetModelData(refID)
		if mData then
			for num, m in pairs(mData) do
				table.insert(data, num, M[m[1]][num])
				count = count + 1
			end
			return (count > 0 and data) or false
		else
			return false
		end
	end
end

------------------------------------------------------------------------------------------------------
------									SCENE SCRIPTING PART									------
------------------------------------------------------------------------------------------------------

-- update function that gets called each frame
local anim = false
function SceneUpdate(dt, sceneID, timer, sceneTime)
	-- Scene scripts that need updates each frame (moving a model for example) go in here.
end

-- on end function that gets called when the scene ends
function Scene_OnEnd(sceneID)
	-- Scene scripts that need an update at the end of a scene (resetting the position of a moving model for example) go in here.
end

-- on start function that gets called when the scene starts
function Scene_OnStart(sceneID)
	-- Scene scripts that need an update at the start of a scene (one time spell visual for example) go in here.
end




















