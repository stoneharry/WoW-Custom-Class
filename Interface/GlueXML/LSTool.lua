
local CharacterCreate = _G["CharacterCreate"]


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
		{10,"Interface/GLUES/LOADINGSCREENS/LoadScreenDeathKnight.blp"}
	},
	
	-- Scene: 1
	{1, 0, 0, 0, 0, 1, 1, _, 1, 1, 1, "World/Scale/HumanMaleScale.mdx", _, _}
}

local use_random_starting_scene = false														-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
local shuffle_scenes_randomly = false														-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID

local login_music_path = ""		-- path to the music
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
LoginScene = CreateFrame("Frame",nil,CharacterCreate)
	LoginScene:SetSize(width, (width/16)*9)
	LoginScene:SetPoint("CENTER", CharacterCreate, "CENTER", 0,0)
	LoginScene:SetFrameStrata("LOW")

-- main background that changes according to the scene
LoginScreenBackground = LoginScene:CreateTexture(nil,"LOW")
	LoginScreenBackground:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
	LoginScreenBackground:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)

LoginScreenBlackBoarderTOP = CharacterCreate:CreateTexture(nil,"OVERLAY")
	LoginScreenBlackBoarderTOP:SetTexture(0,0,0,1)
	LoginScreenBlackBoarderTOP:SetHeight(500)
	LoginScreenBlackBoarderTOP:SetPoint("BOTTOMLEFT", LoginScene, "TOPLEFT", 0,0)
	LoginScreenBlackBoarderTOP:SetPoint("BOTTOMRIGHT", LoginScene, "TOPRIGHT", 0,0)

LoginScreenBlackBoarderBOTTOM = CharacterCreate:CreateTexture(nil,"OVERLAY")
	LoginScreenBlackBoarderBOTTOM:SetTexture(0,0,0,1)
	LoginScreenBlackBoarderBOTTOM:SetHeight(500)
	LoginScreenBlackBoarderBOTTOM:SetPoint("TOPLEFT", LoginScene, "BOTTOMLEFT", 0,0)
	LoginScreenBlackBoarderBOTTOM:SetPoint("TOPRIGHT", LoginScene, "BOTTOMRIGHT", 0,0)

LoginScreenBlend = CharacterCreate:CreateTexture(nil,"OVERLAY")
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
	message(light)
	-- temp
	light = {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8}
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


--[[############### defining variables ###############]] do
	CurrentModelSelected = false
	nM = false
	scrollOffset = 0
	LSmodels = GetModel(current_scene,true)
	mData = GetModelData(current_scene,true)
	currentSaveText = ""
	cbMax = (GlueParent:GetHeight()/3 - 35) / 26
	LSCButtons = {}
--[[##################################################]] end

--[[############### defining backdrops ###############]] do
	backdropColor = DEFAULT_TOOLTIP_COLOR;
	backdropTF = {		-- TOOLS FRAME BACKDROP
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = {
			left = 11,
			right = 12,
			top = 12,
			bottom = 11
		}
	}
	backdropST = {		-- NEW EDITBOX BACKDROP
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Glues\\Common\\Glue-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {
			left = 10,
			right = 5,
			top = 4,
			bottom = 9
		}
	}
--[[##################################################]] end

--[[################ defining methods ################]] do
	function round_after(num)
		return string.format("%.3f", num)
	end
	
	function newEditBox()
		eb = CreateFrame("EditBox",nil,LoginScene)
		eb:SetSize(GlueParent:GetWidth()/2, 30)
		eb:SetPoint("CENTER")
		eb:SetBackdrop(backdropST)
		eb:SetFrameStrata("TOOLTIP")
		eb:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
		eb:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])
		eb:SetFontObject("GlueEditBoxFont")
		eb:SetTextInsets(12,5,5,12)
		eb:Hide()
		
		return eb
	end
	
	function getSaveString(sceneID)
		local TEXT = "	-- Scene: "..(sceneID).."\n"
		local sceneID, sceneData, models, modeldatas = GetScene(sceneID)
		
		for num,data in pairs(modeldatas) do
			local m = models[num]
			local z,x,y = m:GetPosition()
			local width,height = m:GetSize()
			TEXT = TEXT.."	{"..
				sceneID..", "..
				round_after(x)..", "..
				round_after(y)..", "..
				round_after(z)..", "..
				round_after(m:GetFacing())..", "..
				round_after(m:GetModelScale())..", "..
				round_after(m:GetAlpha())..", "..
				(data[8] or "_")..", "..
				data[9]..", "..
				(LoginScene:GetWidth() / width)..", "..
				(LoginScene:GetHeight() / height)..", "..
				( (data[12] and '"'..data[12]..'"') or "_")..", "..
				(data[13] or "_")..", "..
				( (data[14] and '"'..data[14]..'"') or "_").."},\n"
		end
		
		return TEXT
	end
	
	function updateStatsText()
		local m = LSmodels[buttonData[CurrentModelSelected][2]]
		local z,x,y = m:GetPosition()
		LSEFText:SetText(""..
			"X: ".. round_after(x) .."\n"..
			"Y: ".. round_after(y) .."\n"..
			"Z: ".. round_after(z) .."\n"..
			"O: ".. round_after(m:GetFacing()) .."\n"..
			"Alpha: ".. round_after(m:GetAlpha()) .."\n"..
			"Scale: ".. round_after(m:GetModelScale()))
	end
	
	function updateScrollFrame(delta)
		if #buttonData > cbMax then
			if delta < 0 then
				if scrollOffset + cbMax <= #buttonData then
					scrollOffset = scrollOffset + 1
					
					for i=1,cbMax do
						if buttonData[i+scrollOffset] then
							LSCButtons[i]:Show()
							_G[LSCButtons[i]:GetName().."Text"]:SetText(buttonData[i+scrollOffset][1])
						else
							LSCButtons[i]:Hide()
						end
					end
					
					LSScrollBarKnob:SetPoint("RIGHT", LSToolsFrame, "LEFT", 10, 60 - scrollParts * scrollOffset)
				end
			else
				if scrollOffset - 1 >= 0 then
					scrollOffset = scrollOffset - 1
					
					for i=1,cbMax do
						if buttonData[i+scrollOffset] then
							LSCButtons[i]:Show()
							_G[LSCButtons[i]:GetName().."Text"]:SetText(buttonData[i+scrollOffset][1])
						else
							LSCButtons[i]:Hide()
						end
					end
					
					LSScrollBarKnob:SetPoint("RIGHT", LSToolsFrame, "LEFT", 10, 60 - scrollParts * scrollOffset)
				end
			end
			for i=1,cbMax do
				if buttonData[i+scrollOffset][3] then
					LSCButtons[i]:SetChecked(1)
				else
					LSCButtons[i]:SetChecked(0)
				end
			end
		end
	end
--[[##################################################]] end

--[[################ defining objects ################]] do

	--[[## creating TOOLFRAME frame ##]] do
		LSToolsFrame = CreateFrame("Frame",nil,LoginScene)
			LSToolsFrame:SetBackdrop(backdropTF)
			LSToolsFrame:SetSize(200, GlueParent:GetHeight()/3)
			LSToolsFrame:SetFrameStrata("HIGH")
			LSToolsFrame:SetPoint("BOTTOM", OptionsButton, "TOP", -15, 50)
			LSToolsFrame:EnableMouseWheel(true)
			LSToolsFrame:Hide()

		--[[SCROLL]]--
		LSToolsFrame:SetScript("OnMouseWheel", function(self, delta)
				updateScrollFrame(delta)
			end)
	--[[########################]] end

	--[[## creating SCROLLBAR frame ##]] do
		LSScrollBar = CreateFrame("Frame",nil,LSToolsFrame)
		
		--[[SHOW]]--
		LSScrollBar:SetScript("OnShow", function()
				LSScrollBarKnob:SetPoint("RIGHT", LSToolsFrame, "LEFT", 10, 60)
			end)
	--[[############################]] end

	--[[## creating SCROLLUP button ##]] do
		LSScrollUp = CreateFrame("Button",nil,LSScrollBar,"GlueScrollUpButtonTemplate")
			LSScrollUp:SetPoint("TOPRIGHT", LSToolsFrame, "TOPLEFT", 10, -40)
			
		--[[CLICK]]--
		LSScrollUp:SetScript("OnClick", function()
				updateScrollFrame(1)
			end)
	--[[############################]] end

	--[[## creating SCROLLKNOB texture ##]] do
		LSScrollBarKnob = LSScrollBar:CreateTexture(nil,"OVERLAY")
			LSScrollBarKnob:SetTexture("Interface/Buttons/UI-ScrollBar-Knob")
			LSScrollBarKnob:SetSize(18,24)
			LSScrollBarKnob:SetTexCoord(0.20, 0.80, 0.125, 0.875)
	--[[#####################################]] end

	--[[## creating SCROLLDOWN button ##]] do
		LSScrollDown = CreateFrame("Button",nil,LSScrollBar,"GlueScrollDownButtonTemplate")
			LSScrollDown:SetPoint("BOTTOMRIGHT", LSToolsFrame, "BOTTOMLEFT", 10, 10)

		--[[CLICK]]--
		LSScrollDown:SetScript("OnClick", function()
				updateScrollFrame(-1)
			end)
	--[[############################]] end

	--[[## creating TOOL button ##]] do
		LSToolsButton = CreateFrame("Button",nil,LoginScene,"GlueButtonSmallTemplate")
			LSToolsButton:SetText("TOOLBAR")
			LSToolsButton:SetPoint("BOTTOM", OptionsButton, "TOP", 0, 0)
			LSToolsButton:SetFrameStrata("HIGH")

		--[[CLICK]]--
		LSToolsButton:SetScript("OnClick", function()
				if LSToolsFrame:IsVisible() then LSToolsFrame:Hide() else LSToolsFrame:Show() end
			end)
	--[[##########################]] end

	--[[## creating SAVE button ##]] do
		LSSave = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplate")
			LSSave:SetText("Save")
			LSSave:SetPoint("TOPLEFT", LSToolsFrame, "TOPLEFT", 12, -5)
			LSSave:SetWidth(50)

		--[[CLICK]]--
		LSSave:SetScript("OnClick", function(self, button, down)
				if not down then
					LSSaveText:Show()
					LSSaveDone:Show()
					LSSaveFrame:Show()
				end
			end)
	--[[##########################]] end

	--[[## creating SAVETEXT editbox ##]] do
		LSSaveText = newEditBox()
			LSSaveText:SetMultiLine(true)
			
		--[[SHOW]]--
		LSSaveText:SetScript("OnShow", function()
				local sText = ""
				for i=1,ModelList.sceneCount do
					local TEXT = getSaveString(i)
					sText = sText.."\n"..TEXT
				end
				sText = string.sub(sText,1,string.len(sText)-2)
				LSSaveText:SetText(sText)
				currentSaveText = sText
				LSSaveText:HighlightText()
			end)

		--[[ENTERPRESSED]]--
		LSSaveText:SetScript("OnEnterPressed", function()
				LSSaveDone:Hide()
				LSSaveText:Hide()
				LSSaveFrame:Hide()
			end)

		--[[CHAR]]--
		LSSaveText:SetScript("OnChar", function()
				LSSaveText:SetText(currentSaveText)
				LSSaveText:HighlightText()
			end)

		--[[MOUSEUP]]--
		LSSaveText:SetScript("OnMouseUp", function()
				LSSaveText:HighlightText()
			end)
	--[[###########################]] end
	
	--[[## creating SAVEDONE button ##]] do
		LSSaveDone = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplate")
			LSSaveDone:SetText("Done")
			LSSaveDone:SetWidth(50)
			LSSaveDone:SetPoint("LEFT", LSSaveText, "RIGHT", -5, 0)
			LSSaveDone:SetFrameStrata("TOOLTIP")
			LSSaveDone:Hide()
			
		--[[CLICK]]--
		LSSaveDone:SetScript("OnClick", function()
				LSSaveDone:Hide()
				LSSaveText:Hide()
				LSSaveFrame:Hide()
			end)
	--[[##############################]] end
	
	--[[## creating SAVEFRAME frame ##]] do
		LSSaveFrame = CreateFrame("Frame",nil,GlueParent)
			LSSaveFrame:SetFrameStrata("DIALOG")
			LSSaveFrame:SetAllPoints(GlueParent)
			LSSaveFrame:EnableMouse(true)
			LSSaveFrame:EnableKeyboard(true)
			LSSaveFrame:Hide()
	--[[##############################]] end
	
	--[[## creating SAVEBACKGROUND texture ##]] do
		LSSaveBackground = LSSaveFrame:CreateTexture(nil,"OVERLAY")
			LSSaveBackground:SetAllPoints(GlueParent)
			LSSaveBackground:SetTexture(0,0,0,0.75)
	--[[#####################################]] end

	--[[## creating NEW button ##]] do
		LSNew = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplate")
			LSNew:SetText("New")
			LSNew:SetPoint("LEFT", LSSave, "RIGHT", -2, 0)
			LSNew:SetWidth(40)

		--[[CLICK]]--
		LSNew:SetScript("OnClick", function()
				LSNewCameraText:Show()
				LSNewDone:Show()
				LSNewCancel:Show()
				LSSaveFrame:Show()
			end)

		--[[UPDATE]]--
		LSNew:SetScript("OnUpdate", function()
				if CurrentModelSelected then
					LSDelete:Show()
					LSEditingFrame:Show()
					updateStatsText()
				else
					LSDelete:Hide()
					LSEditingFrame:Hide()
				end
			end)
	--[[#########################]] end

	--[[## creating NEWCAMERATEXT editbox ##]] do
		LSNewCameraText = newEditBox()
			local LSNCTText = LSNewCameraText:CreateFontString("LSNCTText", "OVERLAY", "GlueEditBoxFont")
			LSNCTText:SetPoint("RIGHT", LSNewCameraText, "LEFT", 0, 3)
			LSNCTText:SetText("(Optional)Camera Path:")

		--[[SHOW]]--
		LSNewCameraText:SetScript("OnShow", function(self)
				self:SetText("")
			end)
			
		--[[ENTERPRESSED]]--
		LSNewCameraText:SetScript("OnEnterPressed", function()
				if LSNewCameraText:GetText()~="" then
					nM = newModel(M[current_scene].parent,1,_,1,1,LSNewCameraText:GetText())
				else
					nM = newModel(M[current_scene].parent,1,_,1,1)
				end
				nM:Hide()
				
				LSNewText:Hide()
				LSNewCameraText:Hide()
				LSNewText:Show()
			end)
			
		--[[ESCAPEPRESSED]]--
		LSNewCameraText:SetScript("OnEscapePressed", function()
				LSNewCameraText:Hide()
				LSNewDone:Hide()
				LSNewCancel:Hide()
				LSSaveFrame:Hide()
			end)
	--[[##################################]] end
	
	--[[## creating NEWTEXT editbox ##]] do
		LSNewText = newEditBox()
			local LSNTText = LSNewText:CreateFontString("LSNTText", "OVERLAY", "GlueEditBoxFont")
			LSNTText:SetPoint("RIGHT", LSNewText, "LEFT", 0, 3)
			LSNTText:SetText("Model Path:")

		--[[SHOW]]--
		LSNewText:SetScript("OnShow", function(self)
				self:SetText("")
			end)

		--[[ENTERPRESSED]]--
		LSNewText:SetScript("OnEnterPressed", function()
				if LSNewText:GetText() ~= "" then
					if nM:GetModel() == "character/human/male/humanmale.m2" then
						ModelList[ModelList.modelCount+1] = {current_scene,0,0,0,0,1,1,_,1,1,1,LSNewText:GetText(),_,_}
					else
						ModelList[ModelList.modelCount+1] = {current_scene,0,0,0,0,1,1,_,1,1,1,LSNewText:GetText(),_,nM:GetModel()}
					end
					nM:SetModel(LSNewText:GetText())
					nM:Show()
					M[current_scene][ModelList.modelCount+1] = nM
					nM = nil
					
					ModelList.modelCount = ModelList.modelCount + 1
					
					LSNewText:Hide()
					LSNewDone:Hide()
					LSNewCancel:Hide()
					LSSaveFrame:Hide()
					
					Scene_OnStart(current_scene, true)
					CurrentModelSelected = false
				end
			end)
			
		--[[ESCAPEPRESSED]]--
		LSNewText:SetScript("OnEscapePressed", function()
				LSNewText:Hide()
				LSNewDone:Hide()
				LSNewCancel:Hide()
				LSSaveFrame:Hide()
			end)
	--[[##############################]] end

	--[[## creating NEWDONE button ##]] do
		LSNewDone = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplate")
			LSNewDone:SetText("Done")
			LSNewDone:SetWidth(50)
			LSNewDone:SetFrameStrata("TOOLTIP")
			LSNewDone:SetPoint("TOP", LSNewCameraText, "BOTTOM", -65, 0)
			LSNewDone:Hide()
			
		--[[CLICK]]--
		LSNewDone:SetScript("OnClick", function()
				if LSNewCameraText:IsShown() then
					if LSNewCameraText:GetText()~="" then
						nM = newModel(M[current_scene].parent,1,_,1,1,LSNewCameraText:GetText())
					else
						nM = newModel(M[current_scene].parent,1,_,1,1)
					end
					nM:Hide()
					
					LSNewText:Hide()
					LSNewCameraText:Hide()
					LSNewText:Show()
				elseif LSNewText:IsShown() then
					if LSNewText:GetText() ~= "" then
						if nM:GetModel() == "character/human/male/humanmale.m2" then
							ModelList[ModelList.modelCount+1] = {current_scene,0,0,0,0,1,1,_,1,1,1,LSNewText:GetText(),_,_}
						else
							ModelList[ModelList.modelCount+1] = {current_scene,0,0,0,0,1,1,_,1,1,1,LSNewText:GetText(),_,nM:GetModel()}
						end
						nM:SetModel(LSNewText:GetText())
						nM:Show()
						M[current_scene][ModelList.modelCount+1] = nM
						nM = nil
						
						ModelList.modelCount = ModelList.modelCount + 1
						
						LSNewText:Hide()
						LSNewDone:Hide()
						LSNewCancel:Hide()
						LSSaveFrame:Hide()
						
						Scene_OnStart(current_scene, true)
						CurrentModelSelected = false
					end
				end
			end)
	--[[#############################]] end

	--[[## creating NEWCANCEL button ##]] do
		LSNewCancel = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplate")
			LSNewCancel:SetText("Cancel")
			LSNewCancel:SetWidth(70)
			LSNewCancel:SetFrameStrata("TOOLTIP")
			LSNewCancel:SetPoint("LEFT", LSNewDone, "RIGHT", 5, 0)
			LSNewCancel:Hide()
			
		--[[CLICK]]--
		LSNewCancel:SetScript("OnClick", function()
				LSNewCameraText:Hide()
				LSNewText:Hide()
				LSNewDone:Hide()
				LSNewCancel:Hide()
				LSSaveFrame:Hide()
			end)
	--[[#############################]] end

	--[[## creating DELETE button ##]] do
		LSDelete = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplate")
			LSDelete:SetText("Delete")
			LSDelete:SetPoint("LEFT", LSNew, "RIGHT", -2, 0)
			LSDelete:SetWidth(60)
			
		--[[CLICK]]--
		LSDelete:SetScript("OnClick", function()
				if CurrentModelSelected then
					local num = buttonData[CurrentModelSelected][2]
					LSmodels[num]:SetAlpha(0)
					ModelList[num] = nil
					
					for i=1,cbMax do
						LSCButtons[i]:SetChecked(0)
					end
					
					Scene_OnStart(current_scene, true)
					CurrentModelSelected = false
				end
			end)
	--[[############################]] end

	--[[## creating SCENES button ##]] do
		LSScenes = CreateFrame("Button",nil,LSToolsFrame,"GlueButtonSmallTemplateBlue")
			LSScenes:SetText("NS")
			LSScenes:SetPoint("TOPRIGHT", LSToolsFrame, "TOPRIGHT", -8, -5)
			LSScenes:SetWidth(35)

		--[[CLICK]]--
		LSScenes:SetScript("OnClick", function()
				if ModelList.sceneCount > 1 then
					CurrentModelSelected = false
				end
				local newScene = ((current_scene+1 > ModelList.max_scenes) and 1) or current_scene + 1
				SetScene(newScene)
				LSScenes:SetText(newScene)
			end)

		--[[SHOW]]--
		LSScenes:SetScript("OnShow", function()
				LSScenes:SetText(current_scene)
			end)

		--[[UPDATE]]--
		LSScenes:SetScript("OnUpdate", function()
				blend_timer = 0
				LoginScreenBlend:SetAlpha(0)
			end)
	--[[############################]] end

	--[[## creating EDITFRAME frame ##]] do
		LSEditingFrame = CreateFrame("Frame",nil,LoginScene)
			LSEditingFrame:SetBackdrop(backdropTF)
			LSEditingFrame:SetHeight(130)
			LSEditingFrame:SetFrameStrata("HIGH")
			LSEditingFrame:SetPoint("BOTTOMRIGHT", LSToolsFrame, "TOPRIGHT", 0, -7)
			LSEditingFrame:SetPoint("LEFT", LSToolsFrame, "LEFT", 0, 0)
			LSEditingFrame:EnableMouse(true)
			LSEditingFrame:Hide()
			
		--[[ENTER]]--
		LSEditingFrame:SetScript("OnEnter", function()
			LSEFControls:Show()
		end)
		
		--[[LEAVE]]--
		LSEditingFrame:SetScript("OnLeave", function()
			LSEFControls:Hide()
		end)
		
		--[[UPDATE]]--
		LSEditingFrame:SetScript("OnUpdate", function()
			overwriteFunction_MoveModel()
		end)
	--[[########################]] end
	
	--[[## creating INTENSITY slider ##]] do
		LSIntensity = CreateFrame("Button",nil,LSEditingFrame,"GlueButtonSmallTemplate")
			LSIntensity:SetText("100%")
			LSIntensity:SetPoint("TOP", LSEditingFrame, "TOP", 0, -25)
			LSIntensity:SetSize(40,15)
			LSIntensity:RegisterForDrag("LeftButton")
			LSIntensity:SetID(100)
			local LSILine = LSIntensity:CreateTexture(nil,"BACKGROUND")
				LSILine:SetTexture(0,0,0,0.75)
				LSILine:SetHeight(2)
				LSILine:SetPoint("TOP", LSIntensity, "TOP", 0, -5)
				LSILine:SetPoint("LEFT", LSEditingFrame, "LEFT", 20, 0)
				LSILine:SetPoint("RIGHT", LSEditingFrame, "RIGHT", -20, 0)
			local LSIText = LSIntensity:CreateFontString("LSIText", "OVERLAY", "GlueFontNormalSmall")
				LSIText:SetPoint("BOTTOM", LSIntensity, "TOP", 0, 5)
				LSIText:SetPoint("LEFT", LSEditingFrame, "LEFT", 12, 0)
				LSIText:SetText("Modify Intensity:")
			
		local Ix,Iy = LSIntensity:GetCenter()
		local draging = false
		--[[DOUBLECLICK]]--
		LSIntensity:SetScript("OnDoubleClick", function()
				LSIntensity:SetPoint("TOP", LSEditingFrame, "TOP", 0, -25)
				LSIntensity:SetText("100%")
				LSIntensity:SetID(100)
			end)
			
		--[[MOUSEDOWN]]--
		LSIntensity:SetScript("OnMouseDown", function()
				draging = true
			end)
			
		--[[MOUSEUP]]--
		LSIntensity:SetScript("OnMouseUp", function()
				draging = false
			end)
			
		--[[DRAGSTOP]]--
		LSIntensity:SetScript("OnDragStop", function()
				draging = false
			end)
			
		--[[UPDATE]]--
		LSIntensity:SetScript("OnUpdate", function()
				if draging then
					local mx,my = GetCursorPosition()
					if mx - Ix < 70 and mx - Ix > -69 then
						local number = math.floor((100/70) * (mx - Ix) + 100)
						LSIntensity:SetPoint("TOP", LSEditingFrame, "TOP", mx - Ix, -25)
						LSIntensity:SetText(number.."%")
						LSIntensity:SetID(number)
					elseif mx - Ix < 70 then
						LSIntensity:SetPoint("TOP", LSEditingFrame, "TOP", -70, -25)
						LSIntensity:SetText("1%")
						LSIntensity:SetID(1)
					elseif mx - Ix > -70 then
						LSIntensity:SetPoint("TOP", LSEditingFrame, "TOP", 70, -25)
						LSIntensity:SetText("200%")
						LSIntensity:SetID(200)
					end
				end
			end)
	--[[############################]] end

	--[[## creating STATS text ##]] do
		LSEFText = LSEditingFrame:CreateFontString("LSEFText", "OVERLAY", "GlueFontNormalSmall")
			LSEFText:SetPoint("TOP", LSEditingFrame, "TOP", 0, -42)
			LSEFText:SetPoint("LEFT", LSEditingFrame, "LEFT", 12, 0)
			LSEFText:SetPoint("RIGHT", LSEditingFrame, "CENTER", 0, 0)
			LSEFText:SetPoint("BOTTOM", LSEditingFrame, "BOTTOM", 0, 10)
			LSEFText:SetJustifyH("LEFT")
			LSEFText:SetJustifyV("TOP")
	--[[############################]] end

	--[[## creating ANIMATIONDOWN button ##]] do
		LSAnimationDown = CreateFrame("Button",nil,LSEditingFrame,"GlueScrollDownButtonTemplate")
			LSAnimationDown:SetPoint("BOTTOMRIGHT", LSEditingFrame, "BOTTOMRIGHT", -10, 10)

		--[[CLICK]]--
		LSAnimationDown:SetScript("OnClick", function()
				if mData[buttonData[CurrentModelSelected][2]][9] > 1 then
					mData[buttonData[CurrentModelSelected][2]][9] = mData[buttonData[CurrentModelSelected][2]][9] - 1
				end
				LSAnimation:SetText(mData[buttonData[CurrentModelSelected][2]][9])
				LSmodels[buttonData[CurrentModelSelected][2]]:SetSequence(mData[buttonData[CurrentModelSelected][2]][9])
			end)
	--[[############################]] end

	--[[## creating ANIMATION text ##]] do
		LSAnimation = LSEditingFrame:CreateFontString("LSEFText", "OVERLAY", "GlueFontNormalSmall")
			LSAnimation:SetPoint("BOTTOM", LSAnimationDown, "TOP", 0, 2)
			LSAnimation:SetText(1)
	--[[############################]] end

	--[[## creating ANIMATIONUP button ##]] do
		LSAnimationUp = CreateFrame("Button",nil,LSEditingFrame,"GlueScrollUpButtonTemplate")
			LSAnimationUp:SetPoint("BOTTOM", LSAnimation, "TOP", 0, 1)

		--[[SHOW]]--
		LSAnimationUp:SetScript("OnShow", function()
				LSAnimation:SetText(mData[buttonData[CurrentModelSelected][2]][9])
			end)

		--[[CLICK]]--
		LSAnimationUp:SetScript("OnClick", function()
				mData[buttonData[CurrentModelSelected][2]][9] = mData[buttonData[CurrentModelSelected][2]][9] + 1
				LSAnimation:SetText(mData[buttonData[CurrentModelSelected][2]][9])
				LSmodels[buttonData[CurrentModelSelected][2]]:SetSequence(mData[buttonData[CurrentModelSelected][2]][9])
			end)
	--[[############################]] end

	--[[## creating CONTROLS text ##]] do
		LSEFControls = LSEditingFrame:CreateFontString("LSEFText", "OVERLAY", "GlueFontNormalSmall")
			LSEFControls:SetPoint("BOTTOMRIGHT", LSEditingFrame, "BOTTOMLEFT", 0, 15)
			LSEFControls:SetJustifyH("RIGHT")
			LSEFControls:SetJustifyV("BOTTOM")
			LSEFControls:Hide()
		
		LSEFControls:SetText(""..
			"Hold left Shift / Ctrl / Alt for mouse controls\n\n"..
			"left / right  -->  A / D\n"..
			"up / down  -->  W / S\n"..
			"further / nearer  -->  X / C\n"..
			"turn left / right  -->  Q / E\n"..
			"alpha more / few  -->  T / G\n"..
			"bigger / smaller  -->  R / F\n")
	--[[############################]] end

--[[##################################################]] end

--[[############### defining overwrite ###############]] do
	CharacterCreate:EnableMouse(true)

	function CharacterCreate_OnKeyDown(key)
		if CurrentModelSelected and not LSNewDone:IsShown() then
			local m = LSmodels[buttonData[CurrentModelSelected][2]]
			local x,y,z = m:GetPosition()
			local move = 0.1 * LSIntensity:GetID()/100
			if key=="LSHIFT" then
				SHIFT_MODIFIER = true
				LSEFControls:SetText(""..
					"Hold left Shift / Ctrl / Alt for mouse controls\n\n\n\n"..
					"left-mousebutton --> X&Y\n"..
					"right-mousebutton --> O\n\n\n")
			elseif key=="LCTRL" or key=="STRG" then
				CTRL_MODIFIER = true
				LSEFControls:SetText(""..
					"Hold left Shift / Ctrl / Alt for mouse controls\n\n\n\n"..
					"left-mousebutton --> Scale\n"..
					"right-mousebutton --> Z\n\n\n")
			elseif key=="LALT" then
				ALT_MODIFIER = true
				LSEFControls:SetText(""..
					"Hold left Shift / Ctrl / Alt for mouse controls\n\n\n\n"..
					"left-mousebutton --> X\n"..
					"right-mousebutton --> Y\n\n\n")
			elseif key=="W" then
				m:SetPosition(x,y,z + move)
			elseif key=="S" then
				m:SetPosition(x,y,z - move)
			elseif key=="A" then
				m:SetPosition(x,y - move,z)
			elseif key=="D" then
				m:SetPosition(x,y + move,z)
			elseif key=="Q" then
				local o = m:GetFacing()
				o = (o + move) % (math.pi*2)
				m:SetFacing(o)
			elseif key=="E" then
				local o = m:GetFacing()
				o = o - move
				if o < 0 then
					o = math.pi*2 + o
				end
				m:SetFacing(o)
			elseif key=="R" then
				m:SetModelScale(m:GetModelScale() + move)
			elseif key=="F" then
				m:SetModelScale(m:GetModelScale() - move)
			elseif key=="X" then
				m:SetPosition(x - move,y,z)
			elseif key=="C" then
				m:SetPosition(x + move,y,z)
			elseif key=="T" then
				m:SetAlpha(m:GetAlpha() + move)
			elseif key=="G" then
				m:SetAlpha(m:GetAlpha() - move)
			end
		end
	end
	
	CharacterCreate:SetScript("OnKeyUp", function(self, key)
			if key=="LSHIFT" then
				SHIFT_MODIFIER = false
				mouse_Editing_Models = false
				LSEFControls:SetText(""..
					"Hold left Shift / Ctrl / Alt for mouse controls\n\n"..
					"left / right  -->  A / D\n"..
					"up / down  -->  W / S\n"..
					"further / nearer  -->  X / C\n"..
					"turn left / right  -->  Q / E\n"..
					"alpha more / few  -->  T / G\n"..
					"bigger / smaller  -->  R / F\n")
			elseif key=="LCTRL" or key=="STRG" then
				CTRL_MODIFIER = false
				mouse_Editing_Models = false
				LSEFControls:SetText(""..
					"Hold left Shift / Ctrl / Alt for mouse controls\n\n"..
					"left / right  -->  A / D\n"..
					"up / down  -->  W / S\n"..
					"further / nearer  -->  X / C\n"..
					"turn left / right  -->  Q / E\n"..
					"alpha more / few  -->  T / G\n"..
					"bigger / smaller  -->  R / F\n")
			elseif key=="LALT" then
				ALT_MODIFIER = false
				mouse_Editing_Models = false
				LSEFControls:SetText(""..
					"Hold left Shift / Ctrl / Alt for mouse controls\n\n"..
					"left / right  -->  A / D\n"..
					"up / down  -->  W / S\n"..
					"further / nearer  -->  X / C\n"..
					"turn left / right  -->  Q / E\n"..
					"alpha more / few  -->  T / G\n"..
					"bigger / smaller  -->  R / F\n")
			end
		end)
	
	CharacterCreate:SetScript("OnMouseDown", function(self, button)
			if SHIFT_MODIFIER then
				local m = LSmodels[buttonData[CurrentModelSelected][2]]
				if button=="LeftButton" then
					mouse_Editing_Models = "XY"
					sMouse_X, sMouse_Y = GetCursorPosition()
					sModel_X, sModel_Y, sModel_Z = m:GetPosition()
				elseif button=="RightButton" then
					mouse_Editing_Models = "O"
					sMouse_X, sMouse_Y = GetCursorPosition()
					sModel_O = m:GetFacing()
				end
			elseif CTRL_MODIFIER then
				local m = LSmodels[buttonData[CurrentModelSelected][2]]
				if button=="LeftButton" then
					mouse_Editing_Models = "Scale"
					sMouse_X, sMouse_Y = GetCursorPosition()
					sModel_Scale = m:GetModelScale()
				elseif button=="RightButton" then
					mouse_Editing_Models = "Z"
					sMouse_X, sMouse_Y = GetCursorPosition()
					sModel_X, sModel_Y, sModel_Z = m:GetPosition()
				end
			elseif ALT_MODIFIER then
				local m = LSmodels[buttonData[CurrentModelSelected][2]]
				if button=="LeftButton" then
					mouse_Editing_Models = "X"
					sMouse_X, sMouse_Y = GetCursorPosition()
					sModel_X, sModel_Y, sModel_Z = m:GetPosition()
				elseif button=="RightButton" then
					mouse_Editing_Models = "Y"
					sMouse_X, sMouse_Y = GetCursorPosition()
					sModel_X, sModel_Y, sModel_Z = m:GetPosition()
				end
			end
		end)
	
	CharacterCreate:SetScript("OnMouseUp", function(self, button)
			if button=="LeftButton" then
				mouse_Editing_Models = false
			elseif button=="RightButton" then
				mouse_Editing_Models = false
			end
		end)
		
	function overwriteFunction_MoveModel()
		if mouse_Editing_Models then
			local move = 0.003 * LSIntensity:GetID()/100
			local m = LSmodels[buttonData[CurrentModelSelected][2]]
			local mx,my = GetCursorPosition()
			if mouse_Editing_Models == "XY" then
				m:SetPosition( sModel_X, sModel_Y + ( (mx - sMouse_X) * move ), sModel_Z + ( (my - sMouse_Y) * move ) )
			elseif mouse_Editing_Models == "O" then
				local nFac = sModel_O + ( (mx - sMouse_X) * move )
				if nFac > math.pi*2 then
					nFac = nFac - math.pi*2
				elseif nFac < 0 then
					nFac = math.pi*2 + nFac
				end
				m:SetFacing( nFac )
			elseif mouse_Editing_Models == "Scale" then
				m:SetModelScale( sModel_Scale + ( (my - sMouse_Y) * move ) )
			elseif mouse_Editing_Models == "Z" then
				m:SetPosition( sModel_X + ( (my - sMouse_Y) * move ), sModel_Y, sModel_Z)
			elseif mouse_Editing_Models == "X" then
				m:SetPosition( sModel_X, sModel_Y + ( (mx - sMouse_X) * move ), sModel_Z)
			elseif mouse_Editing_Models == "Y" then
				m:SetPosition( sModel_X, sModel_Y, sModel_Z + ( (my - sMouse_Y) * move ))
			end
		end
	end
	
	function SceneUpdate() end
	function Scene_OnEnd() end
	function Scene_OnStart(sceneID, maybeCheck)
		if LSLastScene ~= sceneID or maybeCheck then
			buttonData = {}
			LSmodels = GetModel(sceneID,true)
			mData = GetModelData(sceneID,true)
			scrollOffset = 0
			if mData then
				for num,m in pairs(mData) do
					local str = m[12]
					local startingSTR = strlen(str)-18
					local startingDOT = ".."
					if startingSTR < 1 then
						startingSTR = 1
						startingDOT = ""
					end
					str = startingDOT..strsub(str, startingSTR, strlen(str))
					table.insert(buttonData, { str , num, false } )
				end
			end
			
			for i=1,cbMax do
				if buttonData[i] then
					LSCButtons[i]:Show()
					_G[LSCButtons[i]:GetName().."Text"]:SetText(buttonData[i][1])
					LSCButtons[i]:SetChecked(0)
				else
					LSCButtons[i]:Hide()
				end
			end
			
			if #buttonData > cbMax then
				LSScrollBar:Show()
				scrollParts = 150 / (#buttonData - cbMax + 0.5)
				LSScrollBarKnob:SetPoint("RIGHT", LSToolsFrame, "LEFT", 10, 60)
			else
				LSScrollBar:Hide()
			end
			
			LSLastScene = sceneID
		end
	end
	
	for i=1,cbMax do	-- BUTTON ADDING LOOP
		local b = CreateFrame("CheckButton", "LSModelCheckButton"..i, LSToolsFrame, "GlueCheckButtonTemplate")
			_G[b:GetName().."Text"]:SetText("")
			_G[b:GetName().."Text"]:SetPoint("LEFT",b,"LEFT",17,8)
			_G[b:GetName().."Text"]:SetDrawLayer("OVERLAY")
			b:SetNormalTexture("Interface/Glues/Common/Glue-Panel-Button-Up")
			b:SetPushedTexture("Interface/Glues/Common/Glue-Panel-Button-Down")
			b:SetHighlightTexture("Interface/Glues/Common/Glue-Panel-Button-Highlight")
			b:SetCheckedTexture("Interface/Glues/Common/Glue-Panel-Button-Down-Blue")
			b:SetWidth(360)
			b:SetHeight(45)
			b:SetPoint("CENTER")
			b:SetFrameStrata("HIGH")
			b:SetHitRectInsets(0,b:GetWidth()/3,-5,b:GetHeight()/3)
			if i < 2 then
				b:SetPoint("TOPLEFT", LSToolsFrame, "TOPLEFT", 0,-35)
			else
				b:SetPoint("TOPLEFT", LSCButtons[i-1], "TOPLEFT", 0,-26)
			end
		
		b:SetScript("OnLeave", function()
				for num,m in pairs(LSmodels) do
					m:SetAlpha(mData[num][7])
				end
			end)
		
		b:SetScript("OnEnter", function()
				for num,m in pairs(LSmodels) do
					mData[num][7] = m:GetAlpha()
					if buttonData and buttonData[i+scrollOffset][2] == num then
						m:SetAlpha(1)
					else
						m:SetAlpha(0.2)
					end
				end
			end)
		
		b:SetScript("OnClick", function()
				if not buttonData then return end
				if b:GetChecked() then
					for j=1,cbMax do
						if i~=j then
							LSCButtons[j]:SetChecked(0)
						end
					end
					for j=1,#buttonData do
						buttonData[j][3] = false
					end
					CurrentModelSelected = i+scrollOffset
					buttonData[i+scrollOffset][3] = true
				else
					CurrentModelSelected = false
					buttonData[i+scrollOffset][3] = false
				end
			end)
		
		LSCButtons[i] = b
	end
--[[##################################################]] end






