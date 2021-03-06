--[[
 For more info. visit http://botoflegends.com/forum/topic/30053-sowfreevipusersfreescriptvladimir-by-jamescarl/
        Vladimir With SOW and VPredicton by JamesCarl
        			v0.1 - 	Initial Release
        			v0.2 -  ^_^
        			v0.3 - 	Fixbugs
]]--


--Auto Update--
local sversion = "0.3"
local AUTOUPDATE = true --You can set this false if you don't want to autoupdate --
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/jamescarl15/BolStudio/master/JamesCarlVladimir.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."JamesCarlVladimir.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>JamesCarl Vladimir</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/jamescarl15/BolStudio/master/version/JamesCarlVladimir.version")
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

		print("<font color=\"#00FF00\">JamesCarl Vladimir:</font><font color=\"#FFDFBF\"> Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		print("Download started")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
		print("Download finished")
	end
end

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#00FF00\">JamesCarl Vladimir:</font><font color=\"#FFDFBF\"> Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end
if DOWNLOADING_LIBS then return end
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
if myHero.charName ~= "Vladimir" then return end

require 'VPrediction'
require 'SOW'

local ts
local Recall = false
local VP = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local DFGReady, HXGReady, BWCReady, BRKReady, HYDReady = false, false, false, false, false
local DFGSlot, HXGSlot, BWCSlot, BRKSlot, HYDSlot = nil, nil, nil, nil, nil  
local Target = nil
local abilitySequence = {1,3,2,1,1,4,1,3,1,2,4,3,3,2,2,4,3,2}
local qrange, erange, rrange = 600, 600, 700
function OnLoad()
	  VP = VPrediction()
            -- Target Selector
    ts = TargetSelector(TARGET_LESS_CAST, 700)
		IgniteSlot()
    NSOW = SOW(VP)
    Menu = scriptConfig("Vladimir", "Vladimir")
    Menu:addTS(ts)
    ts.name = "Focus"
    Menu:addSubMenu("[Vladimir - OrbWalking]", "OrbWalking")
    NSOW:LoadToMenu(Menu.OrbWalking)
		
		Menu:addSubMenu("[JamesCarl's Vladimir "..sversion.."]", "z")
		Menu.z:addParam("sep", "--Combo Settings--", SCRIPT_PARAM_INFO, "")
		Menu.z:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("im", "Use Items", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("ig", "Use Ignite if Killable", SCRIPT_PARAM_ONOFF, true)
		
		Menu.z:addParam("sep", "--Last Hit Settings--", SCRIPT_PARAM_INFO, "")
		Menu.z:addParam("qf", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("ef", "Use E", SCRIPT_PARAM_ONOFF, true)
		
		Menu.z:addParam("sep", "--Harass Settings--", SCRIPT_PARAM_INFO, "")
		Menu.z:addParam("qh", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("eh", "Use E", SCRIPT_PARAM_ONOFF, true)
		
		Menu.z:addParam("sep", "--Killsteal Settings--", SCRIPT_PARAM_INFO, "")
		Menu.z:addParam("ksq", "Killsteal on Q", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("kse", "Killsteal on E", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("ksr", "Killsteal on R", SCRIPT_PARAM_ONOFF, true)
		
		Menu.z:addParam("sep", "--Others--", SCRIPT_PARAM_INFO, "")
		Menu.z:addParam("dq", "Draw Circle Q", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("de", "Draw Circle E", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("dr", "Draw Circle R", SCRIPT_PARAM_ONOFF, true)
		Menu.z:addParam("autolevel", "AutoLevel", SCRIPT_PARAM_ONOFF, true)
		
		PrintChat("<font color = \"#33CCCC\">Loaded: Vladimir "..sversion.." by</font> <font color = \"#fff8e7\">JamesCarl</font>")
end

function OnTick()
		if myHero.dead then return end
    Target = GetOthersTarget()
    NSOW:ForceTarget(Target)
    Checks()
      if Menu.z.autolevel then --auto level up
                if myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level < myHero.level then
                        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
                        local level = { 0, 0, 0, 0 }
                        for i = 1, myHero.level, 1 do
                                level[abilitySequence[i]] = level[abilitySequence[i]] + 1
                        end
                        for i, v in ipairs({ myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level }) do
                                if v < level[i] then LevelSpell(spellSlot[i]) end
                        end
                end
        end
		Killsteal()
 if Menu.OrbWalking.Mode0 then activecombo() end
 if Menu.OrbWalking.Mode1 then holdharass() end
 if Menu.OrbWalking.Mode3 then farm() end
end

function farm() --hold
if Menu.z.qf then qf() end
if Menu.z.ef then ef() end
end

function qf() 
if Menu.z.qf and (myHero:CanUseSpell(_Q) == READY) then
        for index, minion in pairs(minionManager(MINION_ENEMY, qrange, player, MINION_SORT_HEALTH_ASC).objects) do
                local qDmg = getDmg("Q",minion, GetMyHero()) + (myHero.ap * 0.6)
            local MinionHealth_ = minion.health
            if qDmg >= MinionHealth_ then
                    CastSpell(_Q, minion)
            end
        end
    end
end

function ef()
if Menu.z.ef and (myHero:CanUseSpell(_E) == READY) then
        for index, minion in pairs(minionManager(MINION_ENEMY, erange, player, MINION_SORT_HEALTH_ASC).objects) do
                local eDmg = getDmg("E",minion, GetMyHero()) + (myHero.ap * 0.45)
            local MinionHealth_ = minion.health
            if eDmg >= MinionHealth_ then
                    CastSpell(_E)
            end
        end
    end
end

function Killsteal()
if Menu.z.ksr and RREADY then
	    for i = 1, heroManager.iCount, 1 do
                        local Target = heroManager:getHero(i)
                        local rDamage = getDmg("R",Target,myHero)
                        if ValidTarget(Target, rrange) and Target.health < rDamage then
                                CastSpell(_R, Target)
                        end
                end
        end
if Menu.z.ksq and QREADY then 
		    for i = 1, heroManager.iCount, 1 do
                        local Target = heroManager:getHero(i)
                        local qDamage = getDmg("Q",Target,myHero)
                        if ValidTarget(Target, qrange) and Target.health < qDamage then
                                CastSpell(_Q, Target)
                        end
                end
        end	
if Menu.z.kse and EREADY then
		    for i = 1, heroManager.iCount, 1 do
                        local Target = heroManager:getHero(i)
                        local eDamage = getDmg("E",Target,myHero)
                        if ValidTarget(Target, erange) and Target.health < eDamage then
                                CastSpell(_E, Target)
                        end
                end
        end	
end

function activecombo() --Combo
	if ValidTarget(Target) then if Menu.z.im then UseItems(Target) end
	if Menu.z.ig then UseIgnite(Target) end
	if Menu.z.q then q() end
	if Menu.z.e then e() end
	if Menu.z.r then r() end
end
end

function holdharass() --Hold
	if ValidTarget(Target) then
	if Menu.z.qh then qh() end
	if Menu.z.eh then eh() end
end
end

function q()
	if Menu.z.q and ts.target and QREADY then
	if QREADY and GetDistance(ts.target) < qrange then CastSpell(_Q,ts.target) end
	end
	end

function e()
	if Menu.z.e and ts.target and EREADY then
	if EREADY and GetDistance(ts.target) < erange then CastSpell(_E) end
	end
	end

function r()
	if Menu.z.r and ts.target and RREADY then
	if RREADY and GetDistance(ts.target) < rrange then CastSpell(_R,ts.target) end
	end
	end
	
function qh() 
	if Menu.z.qh and ts.target and QREADY then
	if QREADY and GetDistance(ts.target) < qrange then CastSpell(_Q,ts.target) end
	end
	end

function eh()
	if Menu.z.eh and ts.target and EREADY then
	if EREADY and GetDistance(ts.target) < erange then CastSpell(_E) end
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
	        if Menu.z.ig then    
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
	if Menu.z.dq then DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x111111) end
	if Menu.z.de then DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x111111) end
	if Menu.z.dr then DrawCircle(myHero.x, myHero.y, myHero.z, rrange, 0x111111) end
	end

