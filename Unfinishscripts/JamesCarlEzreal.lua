if myHero.charName ~= "Ezreal" then return end

require 'VPrediction'
require 'SOW'

local ts
local Recall = false
local VP = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local DFGReady, HXGReady, BWCReady, BRKReady, HYDReady = false, false, false, false, false
local DFGSlot, HXGSlot, BWCSlot, BRKSlot, HYDSlot = nil, nil, nil, nil, nil  
local Target = nil
local qrange, wrange, rrange = 1200, 1050, 4000
local qdelay, wdelay, rdelay = .250, .250, 1.0
local qwidth, wwidth, rwidth = 60, 80, 160
local qspeed, wspeed, rspeed = 2000, 1600, 2000
local combo = 32
local harass = string.byte("X")
local lasthit = string.byte("C")
local laneclear = string.byte("Z")
levelSequence = {
        QE = {1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2},
        QW = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
}

function OnLoad()
    VP = VPrediction()
    ts = TargetSelector(TARGET_LESS_CAST, 1200)
		IgniteSlot()
    NSOW = SOW(VP)
    Menu = scriptConfig("JamesCarl's Ezreal", "Ezreal")
    Menu:addTS(ts)
    ts.name = "Focus"
    Menu:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
    NSOW:LoadToMenu(Menu.OrbWalking)
		
		Menu:addSubMenu("[Ezreal - Combo Settings]", "c")
		Menu.c:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, combo)
		Menu.c:addParam("qc", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.c:addParam("wc", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.c:addParam("rc", "Use R", SCRIPT_PARAM_ONOFF, true)
		Menu.c:addParam("im", "Use Items", SCRIPT_PARAM_ONOFF, true)
		Menu.c:addParam("ig", "Use Ignite if Killable", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("[Ezreal - Harass Settings]", "h")
		Menu.h:addParam("harasskey", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, harass)
		Menu.h:addParam("qh", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.h:addParam("wh", "Use W", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("[Ezreal - Last Hit Settings]", "lh")
		Menu.lh:addParam("lasthitkey", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, lasthit)
		Menu.lh:addParam("qlh", "Use Q", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("[Ezreal - Lane Clear Settings]", "lc")
		Menu.lc:addParam("laneclearkey", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, laneclear)
		Menu.lc:addParam("qlc", "Use Q", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("[Ezreal - Additionals]", "add")
		Menu.add:addSubMenu("[Ezreal - KillSteal Settings", "ks")
		Menu.add.ks:addParam("qk", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.add.ks:addParam("wk", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.add.ks:addParam("rk", "Use R", SCRIPT_PARAM_ONOFF, true)
		Menu.add:addSubMenu("[Ezreal - Auto Level]", "au")
		Menu.add.au:addParam("autolevel", "Auto Level", SCRIPT_PARAM_LIST, 1, {"Disable", "Max Q then E", "Max Q then W"})
		Menu.add:addSubMenu("[Ezreal - Drawings]", "d")
		Menu.add.d:addparam("dda", "Draw Circle AA", SCRIPT_PARAM_ONOFF, true)
		Menu.add.d:addparam("ddq", "Draw Circle Q", SCRIPT_PARAM_ONOFF, true)
		Menu.add.d:addparam("ddw", "Draw Circle W", SCRIPT_PARAM_ONOFF, true)
		Menu.add.d:addparam("ddr", "Draw Circle R", SCRIPT_PARAM_ONOFF, true)
								
		
		enemyMinion = minionManager(MINION_ENEMY, 1200, myHero, MINION_SORT_HEALTH_ASC)

		PrintChat("<font color = \"#33CCCC\">Ezreal 1.0 With VPrediction & SOW by</font> <font color = \"#fff8e7\">JamesCarl</font>")
end

function OnTick()
	   if myHero.dead then return end
    Target = GetOthersTarget()
    NSOW:ForceTarget(Target)
    Checks()
		if Menu.add.au.autolevel == 2 then autoLevelSetSequence(levelSequence.QE)
		elseif Menu.add.au.autolevel == 3 then autoLevelSetSequence(levelSequence.QW)
		if Menu.c.combokey then combo() end
		if Menu.h.harasskey then harass() end
		if Menu.lh.lasthitkey then lasthit() end
		if Menu.lc.laneclearkey then laneclear() end
		KillSteal()
end
end

function combo()
if ValidTarget(Target) then if Menu.c.im then UseItems(Target) end
if Menu.c.ig then UseIgnite(Target) end
if Menu.c.qc then qc() end
if Menu.c.wc then wc() end
if Menu.c.rc then rc() end
end
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
	        if Menu.c.ig then    
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

function IgniteSlot()
    if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
            ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
            ignite = SUMMONER_2
    end
end

function qc()
	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.c.qc then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qdelay, qwidth, qrange, qspeed, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
end
end

function wc()
	if ts.target ~= nil and ValidTarget(ts.target, wrange) and Menu.c.wc then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, wdelay, wwidth, wrange, wspeed, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= wrange and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
end
end

function rc()
	if ts.target ~= nil and ValidTarget(ts.target, rrange) and Menu.c.rc then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, rdelay, rwidth, rrange, rspeed, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= rrange and myHero:CanUseSpell(_R) == READY then 
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
end
end

function harass()
if ValidTarget(Target) then
if Menu.h.qh then qh() end
if Menu.h.wh then wh() end
end
end

function qh()
	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.c.qh then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qdelay, qwidth, qrange, qspeed, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
end
end

function wh()
	if ts.target ~= nil and ValidTarget(ts.target, wrange) and Menu.c.wh then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, wdelay, wwidth, wrange, wspeed, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= wrange and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
end
end

function lasthit()
if Menu.lh.qlh and (myHero:CanUseSpell(_Q) == READY) then
        for index, minion in pairs(minionManager(MINION_ENEMY, qrange, player, MINION_SORT_HEALTH_ASC).objects) do
                local qDmg = getDmg("Q",minion, GetMyHero())
            local MinionHealth_ = minion.health
            if qDmg >= MinionHealth_ then
                    CastSpell(_Q, minion)
            end
        end
    end
end

function laneclear()
for i, targetMinion in pairs(targetMinions.objects) do
		if targetMinion ~= nil then
		if WREADY and Menu.lc.qlc and ValidTarget(jungleMinion, qrange) then
		CastSpell(_Q, targetMinion.x, targetMinion.z)
		end
		end
end
end

function KillSteal()
if Menu.add.ks.rk and RREADY then
	for i, target in ipairs(GetEnemyHeroes()) do
		rDmg = getDmg("R", target, myHero)
		if RREADY and target ~= nil and ValidTarget(target, rrange) and target.health < rDmg then
			local rPosition, rChance = VP:GetLineCastPosition(target, rdelay, rwidth, rrange, rspeed, myHero, true)
		    if rPosition ~= nil and rChance >= 2 then
		      CastSpell(_R, rPosition.x, rPosition.z)
		    end
		end
	end
if Menu.add.ks.qk and QREADY then
		for i, target in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", target, myHero)
		if QREADY and target ~= nil and ValidTarget(target, qrange) and target.health < qDmg then
			local qPosition, qChance = VP:GetLineCastPosition(target, qdelay, qwidth, qrange, qspeed, myHero, true)
		    if qPosition ~= nil and qChance >= 2 then
		      CastSpell(_Q, qPosition.x, qPosition.z)
		    end
		end
	end
if Menu.add.ks.wk and WREADY then
		for i, target in ipairs(GetEnemyHeroes()) do
		wDmg = getDmg("W", target, myHero)
		if WREADY and target ~= nil and ValidTarget(target, wrange) and target.health < wDmg then
			local wPosition, wChance = VP:GetLineCastPosition(target, wdelay, wwidth, wrange, wspeed, myHero, true)
		    if WPosition ~= nil and wChance >= 2 then
		      CastSpell(_W, wPosition.x, wPosition.z)
		    end
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
if Menu.add.d.dda then DrawCircle(myHero.x, myHero.y, myHero.z, 450, 0x111111) end
if Menu.add.d.ddq then DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x111111) end
if Menu.add.d.ddw then DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x111111) end
if Menu.add.d.ddr then DrawCircle(myHero.x, myHero.y, myHero.z, rrange, 0x111111) end
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

local function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)
end
