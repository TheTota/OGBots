
---------------------------------
-- Ability Build & Use for Anti-Mage --
---------------------------------

-- A considérer:
--   - Ability build adaptatif.
--   - Utilisation des items!
--   - Attention quand il se coince avec Blink.
--   - Meilleur blink d'évasion.

----------------------------------------------------------------------------------------------------

-- Compétences d'antimage
local SKILL_Q = "antimage_mana_break";
local SKILL_W = "antimage_blink";
local SKILL_E = "antimage_spell_shield";
local SKILL_ULT = "antimage_mana_void";

-- Talents d'antimage
local talentLevel10v1 = "special_bonus_hp_150";
local talentLevel10v2 = "special_bonus_attack_damage_20";
local talentLevel15v1 = "special_bonus_attack_speed_20";
local talentLevel15v2 = "special_bonus_unique_antimage";
local talentLevel20v1 = "special_bonus_evasion_15";
local talentLevel20v2 = "special_bonus_all_stats_10";
local talentLevel25v1 = "special_bonus_agility_25";
local talentLevel25v2 = "special_bonus_unique_antimage_2";

-- Liste des compétences/talents d'Anti-Mage à levelup dans l'ordre
local tableAbilitiesLevelUp = {
    SKILL_Q, -- lvl 1
    SKILL_W, -- lvl 2
    SKILL_Q, -- lvl 3
    SKILL_E, -- lvl 4
    SKILL_Q, -- lvl 5
    SKILL_ULT, -- lvl 6
    SKILL_Q, -- lvl 7
    SKILL_W, -- lvl 8
    SKILL_W, -- lvl 9
    talentLevel10v2, -- lvl 10
    SKILL_W, -- lvl 11
    SKILL_ULT, -- lvl 12
    SKILL_E, -- lvl 13
    SKILL_E, -- lvl 14
    talentLevel15v1, -- lvl 15
    SKILL_E, -- lvl 16
    SKILL_ULT, -- lvl 18
    talentLevel20v2, -- lvl 20
    talentLevel25v1, -- lvl 25          
};

-- Récupération du bot sur lequel est exécuté le script
local npcBot = GetBot();

-- Levelup des compétences
----------------------------------------------------------------------------------------------------

function AbilityLevelUpThink() 

    -- Si il y a encore des capacités à levelup
	if ( #tableAbilitiesLevelUp ~= 0 ) then
		
        -- On détermine la prochaine compétence à levelup
        local nextAbilityToLevelUp = tableAbilitiesLevelUp[1];

        -- Si on a des points de compétence disponibles alors, ...
        if (npcBot:GetAbilityPoints() ~= 0) then
            -- ... on levelup la compétence
            npcBot:ActionImmediate_LevelAbility ( nextAbilityToLevelUp ); 
            -- Et on la retire de la liste des compétences à améliorer
            table.remove( tableAbilitiesLevelUp, 1 );
        end

	end

end

-- Utilisation des compétences
----------------------------------------------------------------------------------------------------

castBlinkDesire = 0;
castManaVoidDesire = 0;

hasBeenCheeky = false;

-- Fonction principale pour l'utilisation des 
function AbilityUsageThink()

    -- Le bot envoie un message à tous les joueurs en début de partie
	if not hasBeenCheeky then
		npcBot:ActionImmediate_Chat("Fuck Magic.", true);
		hasBeenCheeky = true;
	end

    -- Récupération des compétences avec leur nom
    abilityBlink = npcBot:GetAbilityByName(SKILL_W);
	abilityManaVoid = npcBot:GetAbilityByName(SKILL_ULT);
    
    -- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() ) then return end;

    -- On détermine les désires de blink ou d'ulti du héro
    castBlinkDesire, castBlinkLocation = ConsiderBlink();
	castManaVoidDesire, castManaVoidTarget = ConsiderManaVoid();

    -- Si bot désire ulti, alors ulti
    if (castManaVoidDesire > castBlinkDesire) then 
        npcBot:Action_UseAbilityOnEntity(abilityManaVoid, castManaVoidTarget);
        return;
    end

    -- Si bot désire blink, alors blink
    if (castBlinkDesire > 0) then
        npcBot:Action_UseAbilityOnLocation(abilityBlink, castBlinkLocation);
        return;
    end

end

----------------------------------------------------------------------------------------------------

function CanCastOffensiveBlink( npcTarget )
    -- TODO: ajouter d'autres conditions telles que la présence de tour, d'ennemis, d'alliés
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable() and npcBot:GetHealth() > npcBot:GetMaxHealth() / 2;
end

function CanCastManaVoidOnTarget( npcTarget )
    -- TODO: ajouter d'autres conditions telles que la présence de tour, d'ennemis, d'alliés
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderBlink()

    -- Make sure it's castable
	if (not abilityBlink:IsFullyCastable()) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

    -- If we want to cast Ulti at all, bail
	if ( castManaVoidDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

    -- Get some of its values
    local nCastRange = abilityBlink:GetSpecialValueInt("blink_range");

    --------------------------------------
	-- Global high-priorty usage
	--------------------------------------

    -- Récupération des héros 
    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
    for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if (npcEnemy:IsChanneling() and npcEnemy:GetHealth() < npcEnemy:GetMaxHealth() / 2 and CanCastOffensiveBlink() and not npcBot:IsSilenced()) 
		then
            -- Action_AttackUnit(npcEnemy, false);
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end

    --------------------------------------
	-- Mode based usage
	--------------------------------------

    -- Mode FARM
    if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		
	end

    -- Mode RETREAT
    if (npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE) then
        if (npcBot:DistanceFromFountain() > 2000 and not npcBot:IsSilenced()) then
            return BOT_ACTION_DESIRE_VERYHIGH, GetAncient(npcBot:GetTeam()):GetLocation();
        end
    end

    -- Mode ATTACK
    if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) then
        
        local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
        
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if (npcEnemy:GetHealth() < npcEnemy:GetMaxHealth() / 2 and CanCastOffensiveBlink(npcEnemy) and not npcBot:IsSilenced()) 
            then
                return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
            end
        end
    end

    -- TODO: Voir autres modes


    return BOT_ACTION_DESIRE_NONE, 0;

end

----------------------------------------------------------------------------------------------------

function ConsiderManaVoid()

    -- Make sure it's castable
	if ( not abilityManaVoid:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

    -- Récupération de données concernant l'ulti
    local nCastRange = abilityManaVoid:GetCastRange();
    local nDmgPerMana = abilityManaVoid:GetSpecialValueFloat( "mana_void_damage_per_mana" );

    -- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastManaVoidOnTarget(npcTarget) and npcTarget:GetHealth() < (npcTarget:GetMaxMana() - npcTarget:GetMana()) * 1.1 * (1 - npcTarget:GetMagicResist()) )
	then
        print("Mana perdu de la cible: ", npcTarget:GetMaxMana() - npcTarget:GetMana());
        print("Santé de la cible: ", npcTarget:GetHealth());
        print("Dégats de l'ulti: ", (npcTarget:GetMaxMana() - npcTarget:GetMana()) * nDmgPerMana * (1 - npcTarget:GetMagicResist()));
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end

    -- Quand teamfight, utiliser sur l'ennemi ayant le plus de mana manquant
    local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
        print("ALERTE TEAMFIGHT!");
        local mostDamageableEnemy = nil;
        local mostManaPointsLost = 0;

        -- On cherche l'ennemi ayant perdu le plus de mana
        local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if (CanCastManaVoidOnTarget(npcEnemy)) then
                print("On examine un ennemi!");
                lostManaForCurrentEnemy = npcEnemy:GetMaxMana() - npcEnemy:GetMana();
                if (lostManaForCurrentEnemy > mostManaPointsLost and lostManaForCurrentEnemy > npcEnemy:GetMaxMana() / 2) then
                    mostDamageableEnemy = npcEnemy;
                    print("On a une cible!");
                end
            end
        end

        -- On va utiliser l'ulti sur l'ennemi ayant le plus de mana manquant et étant tuable avec l'ulti
        if ( mostDamageableEnemy ~= nil )
        then
            print("AM a trouvé l'homme à abattre! ULTI!!!")
            return BOT_ACTION_DESIRE_HIGH, mostDamageableEnemy;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;

end

-- Utilisation des items
----------------------------------------------------------------------------------------------------

-- function ItemUsageThink()

-- end