
---------------------------------
-- Ability Build & Use for Anti-Mage --
---------------------------------

-- A considérer:
--   - Ability build adaptatif.

----------------------------------------------------------------------------------------------------

-- Compétences d'antimage
local abilityManaBreak = "antimage_mana_break";
local abilityBlink = "antimage_blink";
local abilitySpellShield = "antimage_spell_shield";
local abilityManaVoid = "antimage_mana_void";

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
    abilityManaBreak, -- lvl 1
    abilityBlink, -- lvl 2
    abilityManaBreak, -- lvl 3
    abilitySpellShield, -- lvl 4
    abilityManaBreak, -- lvl 5
    abilityManaVoid, -- lvl 6
    abilityManaBreak, -- lvl 7
    abilityBlink, -- lvl 8
    abilityBlink, -- lvl 9
    talentLevel10v2, -- lvl 10
    abilityBlink, -- lvl 11
    abilityManaVoid, -- lvl 12
    abilitySpellShield, -- lvl 13
    abilitySpellShield, -- lvl 14
    talentLevel15v1, -- lvl 15
    abilitySpellShield, -- lvl 16
    abilityManaVoid, -- lvl 18
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

hasBeenCheeky = false;

function AbilityUsageThink()

    -- Le bot envoie un message à tous les joueurs en début de partie
	if not hasBeenCheeky then
		npcBot:ActionImmediate_Chat("Fuck Magic.", true);
		hasBeenCheeky = true;
	end

end