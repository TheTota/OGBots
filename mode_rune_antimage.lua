---------------------------------
--   Rune mode for Anti-Mage   --
---------------------------------

local npcBot = GetBot()

local bountyRuneToPick = nil
local hasPickedUpFirstRune = false

----------------------------------------------------------------------------------------------------

function OnStart()
    if (npcBot:GetTeam() == TEAM_RADIANT) then
        --npcBot:ActionImmediate_Chat("I'm going to pick up bottom bounty rune.", false);
        bountyRuneToPick = RUNE_BOUNTY_3
    else
        if (npcBot:GetTeam() == TEAM_DIRE) then
            --npcBot:ActionImmediate_Chat("I'm going to pick up top bounty rune.", false);
            bountyRuneToPick = RUNE_BOUNTY_4
        end
    end
end

----------------------------------------------------------------------------------------------------

function OnEnd()
    -- Do the standard OnEnd
end

----------------------------------------------------------------------------------------------------

function Think()
    -- On vérifie la présence d'ennemis dans les alentours du héro
    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
    if (#tableNearbyEnemyHeroes >= 1) then
        -- Si on a trouvé un ennemi, on vérifie la présence d'alliés autour du héro
        local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes(1000, false, BOT_MODE_ATTACK)
        if (#tableNearbyAlliedHeroes >= 1) then
            local lessHealthOnEnemy = 10000
            local mostVulnerableEnemy = nil

            -- Si on a au moins un allié qui attaque les ennemis, on cherche le plus faible pour l'attaquer
            for _, npcEnemy in pairs(tableNearbyEnemyHeroes) do
                if (npcEnemy:GetHealth() < lessHealthOnEnemy) then
                    lessHealthOnEnemy = npcEnemy:GetHealth()
                    mostVulnerableEnemy = npcEnemy
                end
            end
            -- On attaque l'ennemi le plus vulnérable
            npcBot:Action_AttackUnit(mostVulnerableEnemy, false)
        end
    else
        -- Si aucun ennemi dans les environs, va jusqu'à la rune et on la récupère
        npcBot:Action_MoveToLocation(GetRuneSpawnLocation(bountyRuneToPick))
        if (GetRuneStatus(bountyRuneToPick) == RUNE_STATUS_AVAILABLE) then
            npcBot:Action_PickUpRune(bountyRuneToPick)
            print("Picking up rune")
            hasPickedUpFirstRune = true
        end
    end
end

----------------------------------------------------------------------------------------------------

function GetDesire()
    -- Si la rune a été prise, on abandonne
    if (DotaTime() > 0 and GetRuneStatus(bountyRuneToPick) == RUNE_STATUS_MISSING) then
        return BOT_MODE_DESIRE_NONE
    end

    if (DotaTime() < 5 or not hasPickedUpFirstRune) then
        local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
        if (#tableNearbyEnemyHeroes >= 1) then
            local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
            if (#tableNearbyAlliedHeroes >= 1) then
                return BOT_MODE_DESIRE_MODERATE
            else
                return BOT_MODE_DESIRE_NONE
            end
        else
            return BOT_MODE_DESIRE_MODERATE
        end
    else
        return BOT_MODE_DESIRE_NONE
    end
end
