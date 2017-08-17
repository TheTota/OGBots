---------------------------------
--   Farm mode for Anti-Mage   --
---------------------------------

-- A considérer:
--   - Stacker les creeps si possible.
--   - TP sur un creep près d'une lane à farm.
--   - Attendre un peu dès qu'une nouvelle lane devient farmable.
--   - Réduire progressivement le désir minimal de farm pour que AM farm la lane.

----------------------------------------------------------------------------------------------------

local npcBot = GetBot();
local npcBotTeam = npcBot:GetTeam();

local canFarmJungle = false;
local canFarmAncients = false;

-- Sûreté/désir minimal pour que la lane soit "farmable"
local minFarmDesire = BOT_ACTION_DESIRE_HIGH;

----------------------------------------------------------------------------------------------------

function OnStart()
	npcBot:ActionImmediate_Chat("I'm farming guys.", true);
end

----------------------------------------------------------------------------------------------------

function OnEnd()
	-- Do the standard OnEnd
end

----------------------------------------------------------------------------------------------------

function Think()
	-- FARM: Plusieurs cas: 
    --       - AM ne farm que les lanes.
    --       - AM farm les lanes et les jungle.

    -- Pour le farm des lanes, AM doit se rendre sur la lane là plus sûre pour la farmer (GetFarmLaneDesire( nLane )).
    -- Si la lane n'est plus sûre, il peut aller jungle si autorisé, ou change de lane (vers la prochaine lane la plus sûre).
    
    -- Pour le farm de la jungle, AM doit aller de camps en camps, en utilisant blink. Si il le peut, il doit farmer les ancients.

    
    -- On détermine les désires de farm pour chaque lane (pour la team)
    local farmTopDesire = GetFarmLaneDesire(LANE_TOP);
    local farmMidDesire = GetFarmLaneDesire(LANE_MID);
    local farmBotDesire = GetFarmLaneDesire(LANE_BOT);

    local laneToFarm = LANE_NONE;

    local isFarmingLane = false;
    local isFarmingJungle = false;

    -- On détermine quelle lane est la + sûre, si on peut farm les lanes
    if (farmTopDesire > farmMidDesire and farmTopDesire > farmBotDesire and farmTopDesire > minFarmDesire) then
        laneToFarm = LANE_TOP;
        isFarmingJungle = false;
        isFarmingLane = true;
    else
        if (farmMidDesire > farmTopDesire and farmMidDesire > farmBotDesire and farmMidDesire > minFarmDesire) then
            laneToFarm = LANE_MID;
            isFarmingJungle = false;
            isFarmingLane = true;
        else
            if (farmBotDesire > farmMidDesire and farmBotDesire > farmTopDesire and farmBotDesire > minFarmDesire) then
                laneToFarm = LANE_BOT;
                isFarmingJungle = false;
                isFarmingLane = true;
            else
                -- JUNGLE
                print("No lane is farmable, I'm going to jungle!");
                isFarmingLane = false;
                isFarmingJungle = true;
            end
        end
    end

    -- Emplacement de la vague de creep meneuse de la lane
    local frontLeadingCreepWaveLocation = GetLaneFrontLocation(npcBotTeam, laneToFarm, 150 );
    local farmableLaneAvailableTowerName = nil;

    -- Si on peut TP à la lane, on le fait    
    -- On détermine à quel tour il faut TP
    if(laneToFarm == LANE_TOP) then
        if(GetTower(npcBotTeam, TOWER_TOP_1):GetHealth() ~= 0) then
            farmableLaneAvailableTowerName = TOWER_TOP_1;
        else
            if(GetTower(npcBotTeam, TOWER_TOP_2):GetHealth() ~= 0) then
                farmableLaneAvailableTowerName = TOWER_TOP_2;
            else 
                if(GetTower(npcBotTeam, TOWER_TOP_3):GetHealth() ~= 0) then
                    farmableLaneAvailableTowerName = TOWER_TOP_3;
                end
            end
        end
    else
        if(laneToFarm == LANE_MID) then
            if(GetTower(npcBotTeam, TOWER_MID_1):GetHealth() ~= 0) then
                farmableLaneAvailableTowerName = TOWER_MID_1;
            else
                if(GetTower(npcBotTeam, TOWER_MID_2):GetHealth() ~= 0) then
                    farmableLaneAvailableTowerName = TOWER_MID_2;
                else 
                    if(GetTower(npcBotTeam, TOWER_MID_3):GetHealth() ~= 0) then
                        farmableLaneAvailableTowerName = TOWER_MID_3;
                    end
                end
            end
        else
            if(laneToFarm == LANE_BOT) then
                if(GetTower(npcBotTeam, TOWER_BOT_1):GetHealth() ~= 0) then
                    farmableLaneAvailableTowerName = TOWER_BOT_1;
                else
                    if(GetTower(npcBotTeam, TOWER_BOT_2):GetHealth() ~= 0) then
                        farmableLaneAvailableTowerName = TOWER_BOT_2;
                    else 
                        if(GetTower(npcBotTeam, TOWER_BOT_3):GetHealth() ~= 0) then
                            farmableLaneAvailableTowerName = TOWER_BOT_3;
                        end
                    end
                end
            end
        end
    end

    -- Si la distance entre le joueur et les creeps à farm est supérieure à la distance entre la tour et les creeps farm, alors on TP.
    -- Sinon on y va à pied.
    if (isFarmingLane) then
        if (GetUnitToLocationDistance(npcBot, frontLeadingCreepWaveLocation) > GetUnitToLocationDistance(GetTower(npcBot:GetTeam(), farmableLaneAvailableTowerName), frontLeadingCreepWaveLocation) and OwnsTeleportationDevice()) then
            TeleportToEntity(farmableLaneAvailableTowerName);
        else
            npcBot:Action_MoveToLocation(frontLeadingCreepWaveLocation);
        end
    end
end

----------------------------------------------------------------------------------------------------

function GetDesire()

    if (HasReachedDominatingStage()) then 
        -- Si AM a atteint son stade de dominance, le farm à un importance moindre.
        --print("AM has reached dominating stage");
        minFarmDesire = BOT_ACTION_DESIRE_LOW;
        return BOT_MODE_DESIRE_VERYLOW;
    else
        if (OwnsMantaStyle()) then 
            --print("AM owns Manta!");
            minFarmDesire = BOT_ACTION_DESIRE_MODERATE;
            return BOT_MODE_DESIRE_LOW;
        else
            if (OwnsBattlefury()) then
                -- Si AM possède bfury, il veut farmer mais est plus enclin à agir avec l'équipe
                --print("AM owns Bfury and wants to farm lanes and jungles");
                minFarmDesire = BOT_ACTION_DESIRE_HIGH;
                return BOT_MODE_DESIRE_MODERATE;
            else 
                -- Si AM ne possède pas bfury, il doit à tout prix farmer l'item
                if(DotaTime() < 60) then
                    --print("AM doesnt own Bfury and first 10 minutes give priority to laning");
                    return BOT_MODE_DESIRE_VERYLOW;
                else                
                    --print("AM doesnt own Bfury but early game is over and he has to focus on it ")
                    minFarmDesire = BOT_ACTION_DESIRE_HIGH;
                    return BOT_MODE_DESIRE_HIGH;
                end
            end
        end
    end

    -- Au cas où..
    return BOT_MODE_DESIRE_MODERATE;
end

----------------------------------------------------------------------------------------------------

function OwnsBattlefury()
    if(npcBot:FindItemSlot("item_bfury") ~= -1) then
        return true;
    else
        return false;
    end
end

function OwnsMantaStyle()
    if(npcBot:FindItemSlot("item_manta") ~= -1) then
        return true;
    else
        return false;
    end
end

function HasReachedDominatingStage()
    if(OwnsBattlefury() and OwnsMantaStyle() and npcBot:FindItemSlot("item_abyssal_blade") ~= -1) then
        return true;
    else
        return false;
    end
end

function OwnsTeleportationDevice()
    if(npcBot:FindItemSlot("item_tpscroll") ~= -1 or npcBot:FindItemSlot("item_travel_boots") ~= -1 or npcBot:FindItemSlot("item_travel_boots_2") ~= -1) then
        return true;
    else
        return false;
    end
end

function TeleportToEntity(targetEntity)
    if (npcBot:FindItemSlot("item_tpscroll") ~= -1) then
        npcBot:Action_UseAbilityOnEntity(GetItemInSlot(npcBot:FindItemSlot("item_tpscroll")), targetEntity);
        return;
    else
        if (npcBot:FindItemSlot("item_travel_boots") ~= -1) then
            npcBot:Action_UseAbilityOnEntity(GetItemInSlot(npcBot:FindItemSlot("item_travel_boots")), targetEntity);
            return;
        else 
            if (npcBot:FindItemSlot("item_travel_boots_2") ~= -1) then
                npcBot:Action_UseAbilityOnEntity(GetItemInSlot(npcBot:FindItemSlot("item_travel_boots_2")), targetEntity);
                return;
            end
        end
    end
end