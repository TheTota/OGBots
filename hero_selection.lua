------------------------
-- hero_selection.lua --
------------------------

local heroes = {
    "npc_dota_hero_axe",
    "npc_dota_hero_bane",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_bristleback",
    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_dazzle",
    "npc_dota_hero_death_prophet",
    "npc_dota_hero_dragon_knight",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_jakiro",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_kunkka",
    "npc_dota_hero_lich",
    "npc_dota_hero_lina",
    "npc_dota_hero_lion",
    "npc_dota_hero_luna",
    "npc_dota_hero_necrolyte",
    "npc_dota_hero_omniknight",
    "npc_dota_hero_oracle",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_pudge",
    "npc_dota_hero_razor",
    "npc_dota_hero_sand_king",
    "npc_dota_hero_nevermore",
    "npc_dota_hero_skywrath_mage",
    "npc_dota_hero_sniper",
    "npc_dota_hero_sven",
    "npc_dota_hero_tidehunter",
    "npc_dota_hero_tiny",
    "npc_dota_hero_vengefulspirit",
    "npc_dota_hero_viper",
    "npc_dota_hero_warlock",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_witch_doctor",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_zuus"
}

function Think()
    if (GetTeam() == TEAM_RADIANT) then
        SelectHero(2, "npc_dota_hero_axe")
        SelectHero(3, "npc_dota_hero_witch_doctor")
        SelectHero(4, "npc_dota_hero_skywrath_mage")
        SelectHero(5, "npc_dota_hero_sniper")
        SelectHero(6, "npc_dota_hero_skeleton_king")
    elseif (GetTeam() == TEAM_DIRE) then
        SelectHero(7, "npc_dota_hero_tidehunter")
        SelectHero(8, "npc_dota_hero_witch_doctor")
        SelectHero(9, "npc_dota_hero_viper")
        SelectHero(10, "npc_dota_hero_antimage")
        SelectHero(11, "npc_dota_hero_lion")
    end
end

--
-- Récupère un héro aléatoire au format string
--
function GetRandomHero()
    print(table.getn(heroes))
    -- Get random index in heroes table
    local randInt = RandomInt(1, table.getn(heroes))

    -- Store hero
    local hero = heroes[randInt]

    -- Remove the hero from the table
    table.remove(heroes, randInt)

    return hero
end
