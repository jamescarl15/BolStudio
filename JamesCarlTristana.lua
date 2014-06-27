--[[
 
        Free Tristana With SOW by JamesCarl
       
        			v0.1 - 	Initial Release
							v0.2 - 	Fix Fix Fix
							v0.3 - Fix Ks
							v0.4 - Add UpdateRange E and Escape Key]]--
        			
		
--[[		Auto Update		]]
local sversion = "0.4"
local AUTOUPDATE = true --You can set this false if you don't want to autoupdate --
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/jamescarl15/BolStudio/master/JamesCarlTristana.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."JamesCarlTristana.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>JamesCarl Tristana:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/jamescarl15/BolStudio/master/version/JamesCarlTristana.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(sversion) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..sversion.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

local REQUIRED_LIBS = 
	{
		["VPrediction"] = "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua",
		["SOW"] = "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua",
	}		
local DOWNLOADING_LIBS = false
local DOWNLOAD_COUNT = 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1

		print("<font color=\"#00FF00\">JamesCarl Tristana:</font><font color=\"#FFDFBF\"> Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		print("Download started")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
		print("Download finished")
	end
end

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#00FF00\">JamesCarl Tristana:</font><font color=\"#FFDFBF\"> Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end
if DOWNLOADING_LIBS then return end



------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------

if myHero.charName ~= "Tristana" then return end

require 'VPrediction'
require 'SOW'

local ts
local Recall = false
local VP = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local DFGReady, HXGReady, BWCReady, BRKReady, HYDReady = false, false, false, false, false
local DFGSlot, HXGSlot, BWCSlot, BRKSlot, HYDSlot = nil, nil, nil, nil, nil  
local Target = nil

function OnLoad()
    VP = VPrediction()
            -- Target Selector
    ts = TargetSelector(TARGET_LESS_CAST, 590)
		IgniteSlot()
    NSOW = SOW(VP)
                   
    Menu = scriptConfig("JamesCarl's Tristana", "Tristana")
    Menu:addTS(ts)
    ts.name = "Focus"

    Menu:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
    NSOW:LoadToMenu(Menu.OrbWalking)
		
	Menu:addSubMenu("["..myHero.charName.." - Combo Settings]", "Combo")
		Menu.Combo:addParam("useQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true) 
		Menu.Combo:addParam("useE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("ignite", "Use Ignite if Killable", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, sversion)
		
	Menu:addSubMenu("["..myHero.charName.." - UltiOption]", "Ulti")
		Menu.Ulti:addParam("Ksr", "KillSteal on Ultimate", SCRIPT_PARAM_ONOFF, true)
		Menu.Ulti:addParam("Silence", "Silence on Ultimate", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
		Menu.drawings:addParam("DCircleAA", "DrawCircle Attack Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleE", "DrawCircle E Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleR", "DrawCircle R Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleW", "DrawCircle W Range", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addSubMenu("["..myHero.charName.." - Escape]", "Esp")
		Menu.Esp:addParam("Esp", "W on Mouse Pos.", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
		
	Menu:addSubMenu("["..myHero.charName.." - Others]", "Others")
		Menu.Others:addParam("Autolevel", "Auto Level", SCRIPT_PARAM_LIST, 1, {"Disable", "W>E>Q>R", "E>W>Q>R", "Q>W>E>R",})
			
	Menu:addParam("activeCombo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	
	PrintChat("<font color = \"#33CCCC\">Tristana "..sversion.." by</font> <font color = \"#fff8e7\">JamesCarl</font>")
end

local aarange, erange, rrange, irange, wrange = 590, 600, 645, 600, 900
qReady, wReady, eReady, rReady = false, false, false, false, false

levelSequence = {
        WE = {2,3,1,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1},
        EW = {3,2,1,3,3,4,3,2,3,2,4,2,2,1,1,4,1,1},
				QW = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
				
}

function OnTick()
    if myHero.dead then return end
    Target = GetOthersTarget()
    NSOW:ForceTarget(Target)
    Checks()
		UpdateRange()
		if Menu.Others.Autolevel == 2 then
        autoLevelSetSequence(levelSequence.WE)
    elseif Menu.Others.Autolevel == 3 then
        autoLevelSetSequence(levelSequence.EW)
		elseif Menu.Others.AutoLevel == 4 then
				autoLevelSetSequence(levelSequence.QW)
    end
		if Menu.Ulti.Ksr then KillSteal() end
		if Menu.Ulti.Silence then Silence() end
	  if Menu.activeCombo then activeCombo() end
		if Menu.Esp.Esp then Escape() end
end

function UpdateRange()
	erange = (((myHero.level * 9) - 9) + 600)
end 

--thanks hex--
function Escape()
        --local dashSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
        --local dashX = myHero.x + wrange*((mousePos.x - myHero.x)/dashSqr)
        --local dashZ = myHero.z + wrange*((mousePos.z - myHero.z)/dashSqr)
        CastSpell(_W, mousePos.x, mousePos.z)  
end

function Silence()
        if Menu.Ulti.Silence and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) <= rrange then
                if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel"
                or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp"
                or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole"
                or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" or spell.name=="Meditate" then
                        CastSpell(_R, ts.target)
end
end
end

function activeCombo()
	if ValidTarget(Target) then if Menu.Combo.useitems then UseItems(Target) end
	if Menu.Combo.ignite then UseIgnite(Target) end
	if Menu.Combo.useQ then UseQ() end
	if Menu.Combo.useE then UseE() end
	if Menu.Combo.useR then UseR() end
end
end

function UseQ()
	if Menu.Combo.useQ and ts.target and QREADY then
	if QREADY and GetDistance(ts.target) < aarange then CastSpell(_Q) end
	end
	end

function UseE()
	if Menu.Combo.useE and ts.target and EREADY then
	if EREADY and GetDistance(ts.target) < erange then CastSpell(_E,ts.target) end
	end
	end

function UseR()
	if Menu.Combo.useR and RREADY then
	if RREADY and GetDistance(ts.target) < rrange then CastSpell(_R,ts.target) end
	end
	end

function OnCreateObj(obj)
    if obj ~= nil then
        if obj.name:find("TeleportHome.troy") then
            if GetDistance(obj) <= 70 then
                Recall = true
            end
        end 
    end
end

function OnDeleteObj(obj)
if obj ~= nil then
        
        if obj.name:find("TeleportHome.troy") then
            if GetDistance(obj) <= 70 then
                Recall = false
            end
        end 
        
    end
end

function KillSteal()
        if  Menu.Ulti.Ksr and RREADY then
                for i = 1, heroManager.iCount, 1 do
                        local Target = heroManager:getHero(i)
                        local rDamage = getDmg("R",Target,myHero)
                        if ValidTarget(Target, rrange) and Target.health < rDamage then
                                CastSpell(_R, Target)
                        end
                end
        end
			end

-- isFacing by Feez--
function isFacing(source, ourtarget, lineLength)
	local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(ourtarget, source)))
	return GetDistanceSqr(ourtarget, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end



function GetOthersTarget()
    ts:update()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    return ts.target
end

function IgniteSlot()
    if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
            ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
            ignite = SUMMONER_2
    end
end

function OnRecall(hero, channelTimeInMs)
    if hero.networkID == player.networkID then
        Recall = true
    end
end
function OnAbortRecall(hero)
    if hero.networkID == player.networkID
        then Recall = false
    end
end
function OnFinishRecall(hero)
    if hero.networkID == player.networkID
        then Recall = false
    end
end
--By Feez
function isFacing(source, ourtarget, lineLength)
local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
local sourcePos = Vector(source.x, source.z)
sourceVector = (sourceVector-sourcePos):normalized()
sourceVector = sourcePos + (sourceVector*(GetDistance(ourtarget, source)))
return GetDistanceSqr(ourtarget, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end
local function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)
end

function UseItems(enemy)
    if not enemy then enemy = Target end
    if ValidTarget(enemy) then
        if DFGReady and GetDistance(enemy) <= 750 then CastSpell(DFGSlot, enemy) end
        if BWCReady and GetDistance(enemy) <= 450 then CastSpell(BWCSlot, enemy) end
        if BRKReady and GetDistance(enemy) <= 450 then CastSpell(BRKSlot, enemy) end
        if HXGReady and GetDistance(enemy) <= 700 then CastSpell(HXGSlot, enemy) end
        if HYDReady and GetDistance(enemy) <= 185 then CastSpell(HYDSlot, enemy) end
    end
end

function UseIgnite(enemy)
	        if Menu.Combo.ignite then    
                if IREADY then
                        local ignitedmg = 0    
                        for j = 1, heroManager.iCount, 1 do
                                local enemyhero = heroManager:getHero(j)
                                if ValidTarget(enemyhero,600) then
                                        ignitedmg = 50 + 20 * myHero.level
                                        if enemyhero.health <= ignitedmg then
                                                        CastSpell(ignite, enemyhero)
end
end
end     
end
end
end

function Checks()	
	    --Spells 
    QREADY = (myHero:CanUseSpell(_Q) == READY)
    WREADY = (myHero:CanUseSpell(_W) == READY)
    EREADY = (myHero:CanUseSpell(_E) == READY)
    RREADY = (myHero:CanUseSpell(_R) == READY)
    IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

    --Items
    DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
    BRKReady = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
    BWCReady = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
    HXGReady = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
    HYDReady = (HYDSlot ~= nil and myHero:CanUseSpell(HYDSlot) == READY)

    --Items slot
    DFGSlot = GetInventorySlotItem(3128)
    BRKSlot = GetInventorySlotItem(3153)
    BWCSlot = GetInventorySlotItem(3144)
    HXGSlot = GetInventorySlotItem(3146)
    HYDSlot = GetInventorySlotItem(3074)
end			

function OnDraw()
	if Menu.drawings.DCircleAA then DrawCircle(myHero.x, myHero.y, myHero.z, aarange, 0x111111) end
	if Menu.drawings.DCircleE then DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x111111) end
	if Menu.drawings.DCircleR then DrawCircle(myHero.x, myHero.y, myHero.z, rrange, 0x111111) end
	if Menu.drawings.DCricleW then DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x111111) end
	end
		
		
		
		
