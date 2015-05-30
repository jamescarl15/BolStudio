if myHero.charName ~= "Thresh" then return end
     
require 'VPrediction'
require 'HPrediction'
require 'SOW'

if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
	require "DivinePred" 
	dp = DivinePred()
	qpred = LineSS(1200, 1000, 80, 0.5, 0)
end
--Credits to Zopper
Interrupt = {
	["Katarina"] = {charName = "Katarina", stop = {["KatarinaR"] = {name = "Death lotus", spellName = "KatarinaR", ult = true }}},
	["Nunu"] = {charName = "Nunu", stop = {["AbsoluteZero"] = {name = "Absolute Zero", spellName = "AbsoluteZero", ult = true }}},
	["Malzahar"] = {charName = "Malzahar", stop = {["AlZaharNetherGrasp"] = {name = "Nether Grasp", spellName = "AlZaharNetherGrasp", ult = true}}},
	["Caitlyn"] = {charName = "Caitlyn", stop = {["CaitlynAceintheHole"] = {name = "Ace in the hole", spellName = "CaitlynAceintheHole", ult = true, projectileName = "caitlyn_ult_mis.troy"}}},
	["FiddleSticks"] = {charName = "FiddleSticks", stop = {["Crowstorm"] = {name = "Crowstorm", spellName = "Crowstorm", ult = true}}},
	["Galio"] = {charName = "Galio", stop = {["GalioIdolOfDurand"] = {name = "Idole of Durand", spellName = "GalioIdolOfDurand", ult = true}}},
	["Janna"] = {charName = "Janna", stop = {["ReapTheWhirlwind"] = {name = "Monsoon", spellName = "ReapTheWhirlwind", ult = true}}},
	["MissFortune"] = {charName = "MissFortune", stop = {["MissFortune"] = {name = "Bullet time", spellName = "MissFortuneBulletTime", ult = true}}},
	["MasterYi"] = {charName = "MasterYi", stop = {["MasterYi"] = {name = "Meditate", spellName = "Meditate", ult = false}}},
	["Pantheon"] = {charName = "Pantheon", stop = {["PantheonRJump"] = {name = "Skyfall", spellName = "PantheonRJump", ult = true}}},
	["Shen"] = {charName = "Shen", stop = {["ShenStandUnited"] = {name = "Stand united", spellName = "ShenStandUnited", ult = true}}},
	["Urgot"] = {charName = "Urgot", stop = {["UrgotSwap2"] = {name = "Position Reverser", spellName = "UrgotSwap2", ult = true}}},
	["Varus"] = {charName = "Varus", stop = {["VarusQ"] = {name = "Piercing Arrow", spellName = "Varus", ult = false}}},
	["Warwick"] = {charName = "Warwick", stop = {["InfiniteDuress"] = {name = "Infinite Duress", spellName = "InfiniteDuress", ult = true}}},
}
AntiGapcloserUnit = {
	['Ahri']        = {true, spell = _R, 		      range = 450,   projSpeed = 2200, },
	['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
	['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, },
	['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, },
	['Amumu']       = {true, spell = _Q,                  range = 1100,  projSpeed = 1800, },
	['Corki']       = {true, spell = _W,                  range = 800,   projSpeed = 650,  },
	['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, },
	['Darius']      = {true, spell = _R,                  range = 460,   projSpeed = math.huge, },
	['Fiora']       = {true, spell = _Q,                  range = 600,   projSpeed = 2000, },
	['Fizz']        = {true, spell = _Q,                  range = 550,   projSpeed = 2000, },
	['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
	['Graves']      = {true, spell = _E,                  range = 425,   projSpeed = 2000, exeption = true },
	['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
	['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, },
	['JarvanIV']    = {true, spell = _Q,                  range = 770,   projSpeed = 2000, },
	['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, },
	['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, },
	['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
	['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
	['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
	['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
	['Lucian']      = {true, spell = _E,                  range = 425,   projSpeed = 2000, },
	['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500, },
	['Maokai']      = {true, spell = _W,                  range = 525,   projSpeed = 2000, },
	['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, },
	['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
	['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, },
	['Riven']       = {true, spell = _E,                  range = 150,   projSpeed = 2000, },
	['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
	['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
	['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
	['Shyvana']     = {true, spell = _R,                  range = 1000,  projSpeed = 2000, },
	['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
	['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
	['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, },
	['Yasuo']       = {true, spell = _E,                  range = 475,   projSpeed = 1000, },
	['Vayne']       = {true, spell = _Q,                  range = 300,   projSpeed = 1000, },
}


local ts
local Recall = false
local VP = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local DFGReady, HXGReady, BWCReady, BRKReady, HYDReady = false, false, false, false, false
local DFGSlot, HXGSlot, BWCSlot, BRKSlot, HYDSlot = nil, nil, nil, nil, nil  
local Target = nil
informationTable = {}
loaded = false
pred = nil
qLast = 0

function OnLoad()
    VP = VPrediction()
            -- Target Selector
    ts = TargetSelector(TARGET_LESS_CAST, 1075)
		IgniteSlot()
    NSOW = SOW(VP)
                   
    Menu = scriptConfig("JamesCarl's Thresh", "Thresh")
    Menu:addTS(ts)
    ts.name = "Focus"
		   
    Menu:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
    NSOW:LoadToMenu(Menu.OrbWalking)
		
Menu:addSubMenu("["..myHero.charName.." - Combo Settings]", "Combo")
    Menu.Combo:addParam("sep", "---Settings in Combo---", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("useQ2", "Use Q2 in Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("useW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("useE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("emode", "Use E mode", SCRIPT_PARAM_LIST, 1, {"Pull", "Push"})
    Menu.Combo:addParam("useR", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("rcount", "Use R if enemies inside:", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
Menu:addSubMenu("["..myHero.charName.." - Prediction]", "Predict") 
    Menu.Predict:addParam("pred", "Prediction Type", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePred", "HPred"})
Menu:addSubMenu("["..myHero.charName.." - Interrupt]", "Inter")
		for i, a in pairs(GetEnemyHeroes()) do
			if Interrupt[a.charName] ~= nil then
				for i, spell in pairs(Interrupt[a.charName].stop) do
					Menu.Inter:addParam(spell.spellName, a.charName.." - "..spell.name, SCRIPT_PARAM_ONOFF, true)
				end
			end
		end
Menu:addSubMenu("["..myHero.charName.." - Anti Gap Close]", "Gap")
    	for _, enemy in pairs(GetEnemyHeroes()) do
			if AntiGapCloserUnit[enemy.charName] ~= nil then
			Menu.Gap:addParam(enemy.charName, enemy.charName .. " - " .. enemy:GetSpellData(AntiGapCloserUnit[enemy.charName].spell).name, SCRIPT_PARAM_ONOFF, true)
			end
		end
Menu:addSubMenu("["..myHero.charName.." - Drawings]", "Draw")
    Menu.Draw:addParam("drawings", "Disable all Drawings", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
   
		enemyMinion = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC)
		Menu:addParam("activeCombo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		PrintChat("<font color = \"#33CCCC\">Thresh by</font> <font color = \"#fff8e7\">JamesCarl</font>")
end

local qrange, qwidth, qspeed, qdelay = 1000, 80, 1200, 0.5
local wrange, wwidth, wspeed, wdelay = 950, 315, math.huge, 0.5
local erange, ewidth, espeed, edelay = 515, 160, math.huge, 0.3
local rrange, rwidth, rspeed, rdelay = 420, 420, math.huge, 0.3

function OnTick()
    if myHero.dead then return end
    Target = GetOthersTarget()
    NSOW:ForceTarget(Target)
    Checks()
		if Menu.activeCombo then activeCombo() end

end
		

function activeCombo()
	if Menu.Combo.ignite then UseIgnite(Target) end
	if Menu.Combo.useQ then UseQ() end
end

function UseQ()
	if ValidTarget(unit) and GetDistance(unit) <= qrange and myHero:GetSpellData(_Q).name ~= "threshqleap" then
			if settings.pred == 1 then
				local castPos, chance, pos = pred:GetLineCastPosition(unit, qdelay, qwidth, qrange, qspeed, myHero, true)
				if  QREADY and chance >= 2 then
					CastSpell(_Q, castPos.x, castPos.z)
				end
			elseif settings.pred == 2 and VIP_USER and os.clock() - qLast > 0.2 then
				qLast = os.clock()
				local targ = DPTarget(unit)
				local state,hitPos,perc = dp:predict(targ, qpred)
				if QREADY and state == SkillShot.STATUS.SUCCESS_HIT then
					CastSpell(_Q, hitPos.x, hitPos.z)
				end
			elseif settings.pred == 3 then
				local pos, chance = HPred:GetPredict("Q", unit, myHero) 
				if chance > 0 and spells.q.ready then
					CastSpell(_Q, pos.x, pos.z)
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
