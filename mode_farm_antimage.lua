---------------------------------
--   Farm mode for Anti-Mage   --
---------------------------------

-- A considérer:
--   - Stacker les creeps si possible.
--   - TP sur un creep près d'une lane à farm.
--   - Attendre un peu dès qu'une nouvelle lane devient farmable.
--   - Réduire progressivement le désir minimal de farm pour que AM farm la lane.
--   - Meilleur farm de la jungle (remplace le AttackMove de camps en camps).
--   - Si on farm la lane mais qu'on a tué tous les lane creeps et qu'un camp de neutrals est pas loin, aller le farm.

----------------------------------------------------------------------------------------------------

local npcBot = GetBot();
local npcBotTeam = npcBot:GetTeam();

local canFarmJungle = false;
local canFarmAncients = false;

local farmedOrEmptyCamps = { };
local isFarmingCamp = false;
local minutsCounter = 0;

-- Sûreté/désir minimal pour que la lane soit "farmable"
local minFarmDesire;

local isFarmingLane = false;
local isFarmingJungle = false;

----------------------------------------------------------------------------------------------------

function OnStart()
	npcBot:ActionImmediate_Chat("I'm farming guys.", false);    
end

----------------------------------------------------------------------------------------------------

function OnEnd()
    -- ...
end

----------------------------------------------------------------------------------------------------

function Think()
	-- FARM: Plusieurs cas: 
    --       - AM ne farm que les lanes.
    --       - AM farm les lanes et les jungle.

    -- Pour le farm des lanes, AM doit se rendre sur la lane là plus sûre pour la farmer (GetFarmLaneDesire( nLane )).
    -- Si la lane n'est plus sûre, il peut aller jungle si autorisé, ou change de lane (vers la prochaine lane la plus sûre).
    
    -- Pour le farm de la jungle, AM doit aller de camps en camps, en utilisant blink. Si il le peut, il doit farmer les ancients.

    -- Récupération du désir de farm relatif à chaque lane
    local farmTopDesire = GetFarmLaneDesire(LANE_TOP);
    local farmMidDesire = GetFarmLaneDesire(LANE_MID);
    local farmBotDesire = GetFarmLaneDesire(LANE_BOT);

    local laneToFarm = LANE_NONE;

    -- On détermine quelle lane est la + sûre, si on peut farm les lanes
    if (farmTopDesire > farmMidDesire and farmTopDesire > farmBotDesire and farmTopDesire > minFarmDesire) then
        print("La lane à farm est TOP.");
        laneToFarm = LANE_TOP;
        isFarmingJungle = false;
        isFarmingLane = true;
    else
        if (farmMidDesire > farmTopDesire and farmMidDesire > farmBotDesire and farmMidDesire > minFarmDesire) then
            print("La lane à farm est MID.");
            laneToFarm = LANE_MID;
            isFarmingJungle = false;
            isFarmingLane = true;
        else
            if (farmBotDesire > farmMidDesire and farmBotDesire > farmTopDesire and farmBotDesire > minFarmDesire) then
                print("La lane à farm est BOT.");
                laneToFarm = LANE_BOT;
                isFarmingJungle = false;
                isFarmingLane = true;
            else
                print("Aucune lane à farm donc -> JUNGLE.");
                laneToFarm = LANE_NONE;
                isFarmingLane = false;
                isFarmingJungle = true;
            end
        end
    end

    -- FARM DE LANE
    if (isFarmingLane) then
        isFarmingCamp = false;

        -- Emplacement de la vague de creep meneuse de la lane
        local frontLeadingCreepWaveLocation = GetLaneFrontLocation(npcBotTeam, laneToFarm, -50 );

        -- Si la distance entre le joueur et les creeps à farm est supérieure à la distance entre la tour et les creeps farm, alors on TP.
        -- Sinon on y va à pied.
        if (isFarmingLane) then
            if (GetLaneFrontAmount(GetEnemyTeam(), laneToFarm, false) < 0.55 or GetUnitToLocationDistance(npcBot, frontLeadingCreepWaveLocation) > 3000 and OwnsTeleportationDevice()) 
            --and GetTeleportationDevice():isCooldownReady())
            then
                TeleportToLocation(frontLeadingCreepWaveLocation);
            else
                npcBot:Action_MoveToLocation(frontLeadingCreepWaveLocation);
            end
            -- Farming/last hitting code here.
        end
    else
        -- FARM DE JUNGLE
        if(isFarmingJungle) then
            local campToFarmLocation = nil;
            local distanceBetweenCampToFarmAndNpc = 1000000;            

            -- On parcours les camps de neutrals pour trouver celui à farmer
            local neutralSpawners = GetNeutralSpawners();
            for _,neutralCamp in pairs( neutralSpawners )
            do
                -- Si on a battlefury, on peut aller farm n'importe quel camp de jungle
                if(not TableContains(farmedOrEmptyCamps, neutralCamp["location"])) then
                    if (OwnsBattlefury()) then
                        if (GetUnitToLocationDistance(npcBot, neutralCamp["location"]) < distanceBetweenCampToFarmAndNpc) then
                            distanceBetweenCampToFarmAndNpc = GetUnitToLocationDistance(npcBot, neutralCamp["location"]);
                            campToFarmLocation = neutralCamp["location"];
                        end
                    else
                        -- Si on ne possède pas de battlefury, on ne peut farmer que les camps de la jungle alliée
                        if (neutralCamp["team"] == npcBotTeam) then
                            if (GetUnitToLocationDistance(npcBot, neutralCamp["location"]) < distanceBetweenCampToFarmAndNpc) then
                                distanceBetweenCampToFarmAndNpc = GetUnitToLocationDistance(npcBot, neutralCamp["location"]);
                                campToFarmLocation = neutralCamp["location"];
                            end
                        end
                    end
                end
            end

            -- On va au camp et on le tue les creeps ou attaque ce qui est en chemin (provisoire)            
            if (not isFarmingCamp) then

                -- Déplacement jusqu'au camp à farm
                npcBot:Action_MoveToLocation(campToFarmLocation);
                
                -- On récupère les informations relatives à blink d'anti-mage
                abilityBlink = npcBot:GetAbilityByName("antimage_blink");
                local nCastRange = abilityBlink:GetSpecialValueInt("blink_range");
                
                if(abilityBlink:IsFullyCastable() and GetUnitToLocationDistance(npcBot, campToFarmLocation) <= nCastRange and GetUnitToLocationDistance(npcBot, campToFarmLocation) > 300) then
                    -- Blink avec treads switching si treads
                    if (OwnsPowerTreads()) then
                        npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
                        npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
                    end
                    npcBot:Action_UseAbilityOnLocation(abilityBlink, campToFarmLocation);
                    if (OwnsPowerTreads()) then
                        npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
                    end
                end
            end

            local creepsNeutresAuxAlentours = npcBot:GetNearbyNeutralCreeps(750);

            -- Si on est près du camp à farmer et que des creeps neutres sont dans les parages on les attaque
            if(GetUnitToLocationDistance(npcBot, campToFarmLocation) < 750 and #creepsNeutresAuxAlentours ~= 0) then
                npcBot:Action_AttackMove(campToFarmLocation);
                isFarmingCamp = true;
            end           

            -- Si on farm le camp et que aucun creep neutre  
            if((isFarmingCamp and #creepsNeutresAuxAlentours == 0) or (#creepsNeutresAuxAlentours == 0 and GetUnitToLocationDistance(npcBot, campToFarmLocation) < 70)) then
                table.insert(farmedOrEmptyCamps, campToFarmLocation);
                print("Farmed or empty camp here!");
                isFarmingCamp = false;
            end            
        end
    end
end

function TableContains (table, val)
    for _,value in pairs(table) do
        if value == val then
            return true
        end
    end

    return false
end

----------------------------------------------------------------------------------------------------

function GetDesire()

    -- Reset l'état des camps dans la tête d'AM
    if(Round(DotaTime(), 0) == minutsCounter + 60) then 
        print("Reset la liste des camps de jungle farmés ou trouvés vides!");
        minutsCounter = Round(DotaTime(), 0);
        for k in pairs (farmedOrEmptyCamps) do
            farmedOrEmptyCamps[k] = nil;
        end
    end

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
                minFarmDesire = 1.1;                                                                                                -- TODO: passer à HIGH!
                return BOT_MODE_DESIRE_HIGH;                                                                                        -- TODO: Passer à moderate!
            else 
                -- Si AM ne possède pas bfury, il doit à tout prix farmer l'item
                if(DotaTime() < 60) then                                                                                            -- TODO: Passer à 600 !
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

function OwnsPowerTreads()
    if(npcBot:FindItemSlot("item_power_treads") ~= -1) then
        return true;
    else
        return false;
    end
end

function GetTeleportationDevice()
    if (npcBot:FindItemSlot("item_tpscroll") ~= -1) then
        return npcBot:GetItemInSlot(npcBot:FindItemSlot("item_tpscroll"));
    else
        if (npcBot:FindItemSlot("item_travel_boots") ~= -1) then
            return npcBot:GetItemInSlot(npcBot:FindItemSlot("item_travel_boots"));
        else 
            if (npcBot:FindItemSlot("item_travel_boots_2") ~= -1) then
                return npcBot:GetItemInSlot(npcBot:FindItemSlot("item_travel_boots_2"));
            end
        end
    end
end

function TeleportToLocation(targetLocation)
    npcBot:Action_UseAbilityOnLocation(GetTeleportationDevice(), targetLocation);
end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GetEnemyTeam() 
    if (npcBotTeam == TEAM_RADIANT) then 
        return TEAM_DIRE;
    end
    if (npcBotTeam == TEAM_DIRE) then
        return TEAM_RADIANT;
    end
end