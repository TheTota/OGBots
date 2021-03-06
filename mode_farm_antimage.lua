---------------------------------
--   Farm mode for Anti-Mage   --
---------------------------------
-- FARM: Plusieurs cas:
--       - AM ne farm que les lanes.
--       - AM farm les lanes et les jungle.

-- Pour le farm des lanes, AM doit se rendre sur la lane là plus sûre pour la farmer (GetFarmLaneDesire( nLane )).
-- Si la lane n'est plus sûre, il peut aller jungle si autorisé, ou change de lane (vers la prochaine lane la plus sûre).
-- Pour le farm de la jungle, AM doit aller de camps en camps, en utilisant blink. Si il le peut, il doit farmer les ancients.

local npcBot = GetBot() -- AM bot
local npcBotTeam = npcBot:GetTeam() -- AM's team

local canFarmJungle = false
local canFarmAncients = false

local farmedOrEmptyCamps = {}
local isFarmingCamp = false
local minutsCounter = 0

-- Sûreté/désir minimal pour que la lane soit "farmable"
local minFarmDesire

----------------------------------------------------------------------------------------------------

function OnStart()
    npcBot:ActionImmediate_Chat("I'm farming guys.", false)
end

----------------------------------------------------------------------------------------------------

function OnEnd()
    npcBot:ActionImmediate_Chat("I stop farming for now.", false)
end

----------------------------------------------------------------------------------------------------

function Think()
    local laneToFarm = GetLaneToFarm()
    if (laneToFarm ~= LANE_NONE) then -- we're going to farm a lane
        FarmLane(laneToFarm)
    else -- we're going to farm the jungle
        FarmJungle()
    end
end

----------------------------------------------------------------------------------------------------

function GetDesire()
    -- Reset l'état des camps dans la tête d'AM
    if (Round(DotaTime(), 0) == minutsCounter + 60) then
        print("Reset la liste des camps de jungle farmés ou trouvés vides!")
        minutsCounter = Round(DotaTime(), 0)
        for k in pairs(farmedOrEmptyCamps) do
            farmedOrEmptyCamps[k] = nil
        end
    end

    -- Determination du désir de farm d'antimage
    if (HasReachedDominatingStage()) then
        -- Si AM a atteint son stade de dominance, le farm à un importance moindre.
        --print("AM has reached dominating stage");
        minFarmDesire = 0.3
        return BOT_MODE_DESIRE_LOW
    else
        if (OwnsMantaStyle()) then
            --print("AM owns Manta!");
            minFarmDesire = 0.4
            return 0.4
        else
            if (OwnsBattlefury()) then
                -- Si AM possède bfury, il veut farmer mais est plus enclin à agir avec l'équipe
                --print("AM owns Bfury and wants to farm lanes and jungles");
                minFarmDesire = 0.625
                return 0.625
            else
                -- Si AM ne possède pas bfury, il doit à tout prix farmer l'item
                if (DotaTime() < 600) then
                    minFarmDesire = BOT_MODE_DESIRE_HIGH
                    return BOT_MODE_DESIRE_NONE
                else
                    minFarmDesire = BOT_MODE_DESIRE_HIGH
                    -- On vérifie qu'aucun héro ennemi n'est présent pdt le farm
                    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
                    if (#tableNearbyEnemyHeroes >= 1 or npcBot:GetHealth() <= 300) then
                        return BOT_MODE_DESIRE_LOW
                    else
                        return BOT_MODE_DESIRE_HIGH
                    end
                end
            end
        end
    end

    -- Au cas où..
    return BOT_MODE_DESIRE_MODERATE
end

----------------------------------------------------------------------------------------------------

function FarmLane(laneToFarm)
    isFarmingCamp = false -- stop farming camp

    -- Get front leading creep wave location on the lane to farm
    local frontLeadingCreepWaveLocation = GetLaneFrontLocation(npcBotTeam, laneToFarm, -200)

    if
        -- If we have a TP and lane to farm is far, TP to lane
        (GetLaneFrontAmount(GetEnemyTeam(), laneToFarm, false) < 0.55 and
            GetUnitToLocationDistance(npcBot, frontLeadingCreepWaveLocation) > 3000 and
            OwnsTeleportationDevice())
     then
        --and GetTeleportationDevice():isCooldownReady())
        TeleportToLocation(frontLeadingCreepWaveLocation)
    else -- Else just walk towards the creep wave
        local tableNearbyLaneCreeps = npcBot:GetNearbyLaneCreeps(800, true)

        if (#tableNearbyLaneCreeps ~= 0) then
            for _, enemyCreep in pairs(tableNearbyLaneCreeps) do
                -- Si un creep peut être last hit alors last hit, sinon reste autour de zone de creeps
                if (enemyCreep:GetHealth() <= npcBot:GetAttackDamage()) then
                    npcBot:Action_AttackUnit(enemyCreep, true)
                else
                    npcBot:Action_MoveToLocation(frontLeadingCreepWaveLocation)
                end
            end
        else
            npcBot:Action_MoveToLocation(frontLeadingCreepWaveLocation)
        end
    end
end

function GetLaneToFarm()
    -- Récupération du désir de farm relatif à chaque lane
    local farmTopDesire = GetFarmLaneDesire(LANE_TOP)
    local farmMidDesire = GetFarmLaneDesire(LANE_MID)
    local farmBotDesire = GetFarmLaneDesire(LANE_BOT)

    -- On détermine quelle lane est la + sûre, si on peut farm les lanes
    if (farmTopDesire > farmMidDesire and farmTopDesire > farmBotDesire and farmTopDesire > minFarmDesire) then
        -- print("La lane à farm est TOP.")
        return LANE_TOP
    else
        if (farmMidDesire > farmTopDesire and farmMidDesire > farmBotDesire and farmMidDesire > minFarmDesire) then
            -- print("La lane à farm est MID.")
            return LANE_MID
        else
            if (farmBotDesire > farmMidDesire and farmBotDesire > farmTopDesire and farmBotDesire > minFarmDesire) then
                -- print("La lane à farm est BOT.")
                return LANE_BOT
            else
                -- print("Aucune lane à farm.")
                return LANE_NONE
            end
        end
    end
end

----------------------------------------------------------------------------------------------------

function FarmJungle()
    local campToFarmLocation = GetCampToFarmLocation()
    MoveTowardsCamp(campToFarmLocation)
    FarmCamp(campToFarmLocation)
end

function GetCampToFarmLocation()
    local campToFarmLocation = nil
    local distanceBetweenCampToFarmAndNpc = 1000000

    -- On parcours les camps de neutrals pour trouver celui à farmer
    local neutralSpawners = GetNeutralSpawners()
    for _, neutralCamp in pairs(neutralSpawners) do
        -- Si on a battlefury, on peut aller farm n'importe quel camp de jungle
        if (not TableContains(farmedOrEmptyCamps, neutralCamp["location"])) then
            if (OwnsBattlefury()) then
                if (GetUnitToLocationDistance(npcBot, neutralCamp["location"]) < distanceBetweenCampToFarmAndNpc) then
                    distanceBetweenCampToFarmAndNpc = GetUnitToLocationDistance(npcBot, neutralCamp["location"])
                    campToFarmLocation = neutralCamp["location"]
                end
            else
                -- Si on ne possède pas de battlefury, on ne peut farmer que les camps de la jungle alliée
                if (neutralCamp["team"] == npcBotTeam) then
                    if (GetUnitToLocationDistance(npcBot, neutralCamp["location"]) < distanceBetweenCampToFarmAndNpc) then
                        distanceBetweenCampToFarmAndNpc = GetUnitToLocationDistance(npcBot, neutralCamp["location"])
                        campToFarmLocation = neutralCamp["location"]
                    end
                end
            end
        end
    end

    return campToFarmLocation
end

function MoveTowardsCamp(campToFarmLocation)
    -- On va au camp et on le tue les creeps ou attaque ce qui est en chemin (provisoire)
    if (not isFarmingCamp) then
        -- Déplacement jusqu'au camp à farm
        npcBot:Action_MoveToLocation(campToFarmLocation)

        -- On récupère les informations relatives à blink d'anti-mage
        abilityBlink = npcBot:GetAbilityByName("antimage_blink")
        local nCastRange = abilityBlink:GetSpecialValueInt("blink_range")

        if
            (abilityBlink:IsFullyCastable() and GetUnitToLocationDistance(npcBot, campToFarmLocation) <= nCastRange and
                GetUnitToLocationDistance(npcBot, campToFarmLocation) > 300)
         then
            -- Blink avec treads switching si treads
            -- TODO: Treads switching
            --    if (OwnsPowerTreads()) then
            --        npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
            --        npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
            --    end
            npcBot:Action_UseAbilityOnLocation(abilityBlink, campToFarmLocation)
        --    if (OwnsPowerTreads()) then
        --        npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
        --    end
        end
    end
end

function FarmCamp(campToFarmLocation)
    local creepsNeutresAuxAlentours = npcBot:GetNearbyNeutralCreeps(750)

    -- Si on est près du camp à farmer et que des creeps neutres sont dans les parages on les attaque
    if (GetUnitToLocationDistance(npcBot, campToFarmLocation) < 750 and #creepsNeutresAuxAlentours ~= 0) then
        npcBot:Action_AttackMove(campToFarmLocation)
        isFarmingCamp = true
    end

    -- Si on farm le camp et que aucun creep neutre
    if
        ((isFarmingCamp and #creepsNeutresAuxAlentours == 0) or
            (#creepsNeutresAuxAlentours == 0 and GetUnitToLocationDistance(npcBot, campToFarmLocation) < 70))
     then
        table.insert(farmedOrEmptyCamps, campToFarmLocation)
        print("Farmed or empty camp here!")
        isFarmingCamp = false
    end
end

----------------------------------------------------------------------------------------------------

function OwnsBattlefury()
    if (npcBot:FindItemSlot("item_bfury") ~= -1) then
        return true
    else
        return false
    end
end

function OwnsMantaStyle()
    if (npcBot:FindItemSlot("item_manta") ~= -1) then
        return true
    else
        return false
    end
end

function HasReachedDominatingStage()
    if (OwnsBattlefury() and OwnsMantaStyle() and npcBot:FindItemSlot("item_abyssal_blade") ~= -1) then
        return true
    else
        return false
    end
end

function OwnsTeleportationDevice()
    if
        ((npcBot:FindItemSlot("item_tpscroll") >= 1 and npcBot:FindItemSlot("item_tpscroll") <= 6) or
            (npcBot:FindItemSlot("item_travel_boots") >= 1 and npcBot:FindItemSlot("item_travel_boots") <= 6) or
            (npcBot:FindItemSlot("item_travel_boots_2") >= 1 and npcBot:FindItemSlot("item_travel_boots_2") <= 6))
     then
        return true
    else
        return false
    end
end

function OwnsPowerTreads()
    if (npcBot:FindItemSlot("item_power_treads") ~= -1) then
        return true
    else
        return false
    end
end

function GetTeleportationDevice()
    if (npcBot:FindItemSlot("item_tpscroll") ~= -1) then
        return npcBot:GetItemInSlot(npcBot:FindItemSlot("item_tpscroll"))
    else
        if (npcBot:FindItemSlot("item_travel_boots") ~= -1) then
            return npcBot:GetItemInSlot(npcBot:FindItemSlot("item_travel_boots"))
        else
            if (npcBot:FindItemSlot("item_travel_boots_2") ~= -1) then
                return npcBot:GetItemInSlot(npcBot:FindItemSlot("item_travel_boots_2"))
            end
        end
    end
end

function TeleportToLocation(targetLocation)
    npcBot:Action_UseAbilityOnLocation(GetTeleportationDevice(), targetLocation)
end

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GetEnemyTeam()
    if (npcBotTeam == TEAM_RADIANT) then
        return TEAM_DIRE
    end
    if (npcBotTeam == TEAM_DIRE) then
        return TEAM_RADIANT
    end
end

function TableContains(table, val)
    for _, value in pairs(table) do
        if value == val then
            return true
        end
    end

    return false
end
