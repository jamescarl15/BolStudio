--[[
 
        Free Graves With SOW and VPredicton by JamesCarl
       
        			v0.1 - 	Initial Release
							v0.2 - 	Add: Harass
				
							]]--

--Auto Update--
local sversion = "0.2"
local AUTOUPDATE = true --You can set this false if you don't want to autoupdate --
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/jamescarl15/BolStudio/master/JamesCarlGraves.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."JamesCarlGraves.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>JamesCarl Graves</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/jamescarl15/BolStudio/master/version/JamesCarlGraves.version")
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

		print("<font color=\"#00FF00\">JamesCarl Graves:</font><font color=\"#FFDFBF\"> Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		print("Download started")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
		print("Download finished")
	end
end

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#00FF00\">JamesCarl Graves:</font><font color=\"#FFDFBF\"> Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end
if DOWNLOADING_LIBS then return end
----------------
----------------
----------------
----------------
----------------
--SCRIPT--

if myHero.charName ~= "Graves" then return end

require 'VPrediction'
require 'SOW'

local ts
local Recall = false
local VP = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local DFGReady, HXGReady, BWCReady, BRKReady, HYDReady = false, false, false, false, false
local DFGSlot, HXGSlot, BWCSlot, BRKSlot, HYDSlot = nil, nil, nil, nil, nil  
local Target = nil
local qrange, wrange, erange, rrange, aarange = 935, 950, 425, 1000, 600
--thanks kain--
local qwidth, qspeed, qdelay = 70,  1.95, 265
local wwidth, wspeed, wdelay = 500, 1.65, 300
local ewidth, espeed, edelay = 200, 1.65, 250
local rwidth, rspeed, rdelay = 150, 2.10, 219
levelSequence = {
        QE = {1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2},
        EQ = {3,1,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2},
}

function OnLoad()
 VP = VPrediction()
            -- Target Selector
 ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1000, DAMAGE_PHYSICAL)
	IgniteSlot()
 SOW = SOW(VP)
                   
 Menu = scriptConfig("JamesCarl's Graves", "Graves")
 Menu:addTS(ts)
 ts.name = "Focus"

  Menu:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
    SOW:LoadToMenu(Menu.OrbWalking)
		
	Menu:addSubMenu("["..myHero.charName.." - Combo Settings]", "Combo")
		Menu.Combo:addParam("useQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true) 
		Menu.Combo:addParam("useW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("ignite", "Use Ignite if Killable", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addSubMenu("["..myHero.charName.." - Harass Settings]", "Harass")
		Menu.Harass:addParam("useQH", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("useWH", "Use W in Harass", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, sversion)

	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
		Menu.drawings:addParam("DCircleAA", "DrawCircle Attack Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleQ", "DrawCircle Q Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleE", "DrawCircle E Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleR", "DrawCircle R Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleW", "DrawCircle W Range", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addSubMenu("["..myHero.charName.." - Others]", "Others")
		Menu.Others:addParam("Autolevel", "Auto Level", SCRIPT_PARAM_LIST, 1, {"Disable", "Q>W>E>R", "E>Q>W>R"})
		
	Menu:addParam("activeCombo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu:addParam("activeHarass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))

	PrintChat("<font color = \"#33CCCC\">Graves "..sversion.." by</font> <font color = \"#fff8e7\">JamesCarl</font>")
end

function OnTick()
    if myHero.dead then return end
    Target = GetOthersTarget()
    SOW:ForceTarget(Target)
    Checks()
		if Menu.Others.Autolevel == 2 then
    autoLevelSetSequence(levelSequence.QE)
    elseif Menu.Others.Autolevel == 3 then
    autoLevelSetSequence(levelSequence.EQ) end	
		if Menu.activeCombo then activeCombo() end
		if Menu.activeHarass then activeHarass() end
end

function activeHarass() 
	if ValidTarget(Target) then
	if Menu.Harass.useQH then UseQH() end
	if Menu.Harass.useWH then UseWH() end
end
end

function activeCombo()
	if ValidTarget(Target) then if Menu.Combo.useitems then UseItems(Target) end
	if Menu.Combo.ignite then UseIgnite(Target) end
	if Menu.Combo.useQ then UseQ() end
	if Menu.Combo.useW then UseW() end
	if Menu.Combo.useE then UseE() end
	if Menu.Combo.useR then UseR() end
end
end

function UseQH()
 	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.Harass.useQH then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		if GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
end
end

function UseWH()
 	if ts.target ~= nil and ValidTarget(ts.target, wrange) and Menu.Harass.useWH then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, wrange, wwidth, wspeed, wdelay, myHero, true)
		if GetDistance(ts.target) <= wrange and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
end
end


function OnDraw()
        --> Ranges
        if not myHero.dead then
                if QREADY and Menu.drawings.DCircleQ then
                        DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x00FFFF)
                end
                if RREADY and Menu.drawings.DCircleR then
                        DrawCircle(myHero.x, myHero.y, myHero.z, rrange, 0x00FF00)
                end
								if WREADY and Menu.drawings.DCircleW then
                        DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x00FF00)
								end
								if EREADY and Menu.drawings.DCircleE then
                        DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x00FF00)
								end
								if Menu.drawings.DCircleAA then
												DrawCircle(myHero.x, myHero.y, myHero.z, aarange, 0x00FF00) end
								
        end
end

function UseQ()
 	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.Combo.useQ then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		if GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
end
end

function UseW()
 	if ts.target ~= nil and ValidTarget(ts.target, wrange) and Menu.Combo.useW then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, wrange, wwidth, wspeed, wdelay, myHero, true)
		if GetDistance(ts.target) <= wrange and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
end
end
--thanks hex--
function UseE()
        --local dashSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
        --local dashX = myHero.x + eRange*((mousePos.x - myHero.x)/dashSqr)
        --local dashZ = myHero.z + eRange*((mousePos.z - myHero.z)/dashSqr)
        CastSpell(_E, mousePos.x, mousePos.z)  
end
  
function UseR()
 	if ts.target ~= nil and ValidTarget(ts.target, rrange) and Menu.Combo.useR then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, rrange, rwidth, rspeed, rdelay, myHero, true)
		if GetDistance(ts.target) <= rrange and myHero:CanUseSpell(_R) == READY then 
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
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
