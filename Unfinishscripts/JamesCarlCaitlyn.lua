--Dont Try this.. i didn't yet post this script.. so dont try it.. just wait.. ^_^ --

if myHero.charName ~= "Caitlyn" then return end

require 'VPrediction'
require 'SOW'

local ts
local Recall = false
local VP = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local DFGReady, HXGReady, BWCReady, BRKReady, HYDReady = false, false, false, false, false
local DFGSlot, HXGSlot, BWCSlot, BRKSlot, HYDSlot = nil, nil, nil, nil, nil  
local Target = nil
-- Spell data ~From How i Met Katarina, Thanks! --
local aarange = 650
local qrange, qwidth, qspeed, qdelay = 1250, 90, 2200, 0.25	
local wrange, wwidth, wspeed, wdelay = 800, 100, 1450, 0.5	
local erange, ewidth, espeed, edelay = 950, 80, 2000, 0.65	
local rrange, rwidth, rspeed, rdelay = 3000, 1, 1500, 0.5
levelSequence = {
        QE = {1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2},
        QW = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
}

function OnLoad()
 VP = VPrediction()
            -- Target Selector
 ts = TargetSelector(TARGET_LESS_CAST, 1000, DAMAGE_PHYSICAL)
	IgniteSlot()
 SOW = SOW(VP)
                   
 Menu = scriptConfig("JamesCarl's Caitlyn", "Caitlyn")
 Menu:addTS(ts)
 ts.name = "Focus"

  Menu:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
    SOW:LoadToMenu(Menu.OrbWalking)
	
	Menu:addSubMenu("["..myHero.charName.." - Script]", "se")
	
	Menu.se:addParam("sep", "-- Combo Settings --", SCRIPT_PARAM_INFO, "")
		Menu.se:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.se:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.se:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
		
	Menu.se:addParam("sep", "-- Harass Settings --", SCRIPT_PARAM_INFO, "")
		Menu.se:addParam("useQH", "UseQ", SCRIPT_PARAM_ONOFF, true)
		
	Menu.se:addParam("sep", "-- KillSteal Settings --", SCRIPT_PARAM_INFO, "")
		Menu.se:addParam("ksq", "UseQ", SCRIPT_PARAM_ONOFF, true)
		Menu.se:addParam("ksr", "UseR", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
		Menu.se:addParam("ksi", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	
	Menu.se:addParam("sep", "-- Draw Settings --", SCRIPT_PARAM_INFO, "")
		Menu.se:addParam("dda", "DrawCircle AA", SCRIPT_PARAM_ONOFF, true)
		Menu.se:addParam("ddq", "DrawCircle Q", SCRIPT_PARAM_ONOFF, true)
		Menu.se:addParam("ddw", "DrawCircle W", SCRIPT_PARAM_ONOFF, true)
		Menu.se:addParam("ddr", "DrawCircle R", SCRIPT_PARAM_ONOFF, true)
	
	Menu.se:addParam("sep", "-- Misc --", SCRIPT_PARAM_INFO, "")
		Menu.se:addParam("Autolevel", "Auto Level", SCRIPT_PARAM_LIST, 1, {"Disable", "Q>E>W>R", "Q>W>E>R"})
		
	Menu:addParam("activeCombo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu:addParam("activeHarass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	
	PrintChat("<font color = \"#33CCCC\">Caitlyn by</font> <font color = \"#fff8e7\">JamesCarl</font>")
	
	enemyMinion = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC)
end
		
function OnTick()
    if myHero.dead then return end
    Target = GetOthersTarget()
    SOW:ForceTarget(Target)
    Checks()
		if Menu.se.Autolevel == 2 then
    autoLevelSetSequence(levelSequence.QE)
    elseif Menu.se.Autolevel == 3 then
    autoLevelSetSequence(levelSequence.QW) end	
		if Menu.activeCombo then activeCombo() end
		if Menu.activeHarass then activeHarass() end
		if RREADY then ksr() end
		if Menu.se.ksq then ksq() end
end

function activeHarass() 
	if ValidTarget(Target) then
	if Menu.se.useQH then UseQH() end
end
end

function activeCombo()
	if ValidTarget(Target) then if Menu.se.useitems then UseItems(Target) end
	if Menu.se.ignite then UseIgnite(Target) end
	if Menu.se.useQ then UseQ() end
	if Menu.se.useW then UseW() end
	if Menu.se.useR then UseR() end
end
end

--KillSteal--
function ksq()
for i, enemy in ipairs(GetEnemyHeroes()) do
	qDmg = getDmg("Q", enemy, myHero)

		if QREADY and enemy ~= nil and ValidTarget(enemy, qrange) and enemy.health < qDmg then
			local qPosition, qChance = VP:GetLineCastPosition(enemy, qrange, qspeed, qdelay, qwidth, myhero, false)
				if qPosition ~= nil and qChance >= 2 then
					CastSpell(_Q, qPosition.x, qPosition.z)
					end
				end
			end
end

function ksr()
   if myHero:CanUseSpell(_R) == READY then
    for i, enemy in ipairs(GetEnemyHeroes()) do
        if ValidTarget(enemy, rrange) and (enemy.health < getDmg("R", enemy, myHero)) then
		PrintFloatText(myHero, 0, "Press R For Killshot")
		if Menu.se.ksr then
           CastSpell(_R, enemy)
		end
	end
	end
end
end

--Harass--	
function UseQH()
 	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.se.useQH then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		 if HitChance >= 2 and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
end
end
--Combo--
function UseQ()
 	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.se.useQ then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		if HitChance >= 2 and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
end
end

function UseW()
 	if ts.target ~= nil and ValidTarget(ts.target, wrange) and Menu.se.useW then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, wrange, wwidth, wspeed, wdelay, myHero, true)
		if HitChance >= 2 and GetDistance(ts.target) <= wrange and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
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
	        if Menu.se.ignite then    
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
		
		--R Range--
		if player:GetSpellData(_R).level == 1 then rrange = 2000
  elseif player:GetSpellData(_R).level == 2 then rrange = 2500
  elseif player:GetSpellData(_R).level == 3 then rrange = 3000
  end
end		

function OnDraw()
        --> Ranges
        if not myHero.dead then
                if QREADY and Menu.se.ddq then
                        DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x111111)
                end
                if RREADY and Menu.se.ddr then
                        DrawCircle(myHero.x, myHero.y, myHero.z, rrange, 0x111111)
                end
								if WREADY and Menu.se.ddw then
                        DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x111111)
								end
								if Menu.se.dda then
												DrawCircle(myHero.x, myHero.y, myHero.z, aarange, 0x111111) end

        end
end
