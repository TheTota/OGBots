------------------------
-- hero_selection.lua --
------------------------



function Think()

--    tableJoueursDire = GetTeamPlayers(TEAM_DIRE);
--    tableJoueursRadiant = GetTeamPlayers(TEAM_RADIANT);

--    print(tableJoueursDire[0]:GetBot());  -- marche pas

    if ( GetTeam() == TEAM_RADIANT ) then
        SelectHero( 1, "npc_dota_hero_lion" );
        SelectHero( 2, "npc_dota_hero_zuus" );
        SelectHero( 3, "npc_dota_hero_juggernaut" );
        SelectHero( 4, "npc_dota_hero_crystal_maiden" );
    elseif ( GetTeam() == TEAM_DIRE ) then
        SelectHero( 5, "npc_dota_hero_axe" );
        SelectHero( 6, "npc_dota_hero_earthshaker" );
        SelectHero( 7, "npc_dota_hero_lich" );
        SelectHero( 8, "npc_dota_hero_mirana" );
        SelectHero( 9, "npc_dota_hero_antimage" );
    end
 
end 