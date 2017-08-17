---------------------------------
-- Item Purchase for Anti-Mage --
---------------------------------

-- A considérer:
--   - Moonshard à consommer.
--   - Achat d'item en fonction des items des autres. (ex: pas de butterfly si ennemis ont mkb).
--   - Achat de TP scrolls afin de toujours en avoir un sur soi.
--   - Ne pas appeller le courier pour des items insignifiants (exemple un Slipper of Agility seul).
--   - Achat d'items aux échoppes spécifique quand possibilité.
--   - Acheter des items de régénération quand a perdu de la vie.

-- Remarques:
--   - AM monopolise le coursier en appellant des petits items ou/et des items qu'il pourrait acquérir au side shop.

----------------------------------------------------------------------------------------------------

-- Récupération du bot sur lequel le script est exécuté
local npcBot = GetBot();

local tableItemsToBuy = { 
                -- start items
				"item_tango",
				"item_stout_shield",
				"item_quelling_blade",
                -- upgrading start items
				---- poor mans shield
                "item_slippers",
                "item_slippers",
                ---- power treads
                "item_boots",
                "item_boots_of_elves",
                "item_gloves",
                -- go battlefury
                ---- perseverance
				"item_ring_of_health",
                "item_void_stone",
                ---- remaining items
                "item_broadsword",
                "item_claymore",
				-- go manta
                ---- yasha
                "item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				---- remaining items
                "item_ultimate_orb",
				"item_recipe_manta",
                -- go aghs
                "item_blade_of_alacrity",
                "item_staff_of_wizardry",
                "item_ogre_axe",
                "item_point_booster",
                -- go abyssal
                ---- basher
                "item_javelin",
                "item_belt_of_strength",
                "item_recipe_basher",
                ---- vanguard
                "item_ring_of_health",
                "item_stout_shield",
                "item_vitality_booster",
                ---- recipe
                "item_recipe_abyssal_blade",
                -- go butterfly
                "item_talisman_of_evasion",
                "item_eagle",
                "item_quarterstaff",
                -- go tp boots
                "item_boots",
                "item_recipe_travel_boots",
                "item_recipe_travel_boots",
                -- HERE, CONSIDER A MOONSHARD TO CONSUME?
			};


----------------------------------------------------------------------------------------------------

function ItemPurchaseThink()

    -- Si tous les items ont été achetés, on ne dépense plus d'argent
	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

    -- Le prochain item à acheter est le prochain item de la liste (la liste rétrécit au fur et à mesure que les items sont achetés)
	local sNextItem = nil;
    if (OwnsTeleportationDevice() or DotaTime() < 420) then
        sNextItem = tableItemsToBuy[1];
    else 
        sNextItem = "item_tpscroll";   
    end

    -- On définit la valeur du prochain item à acheter au bot
	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

    -- Si le bot a assez d'argent, ...
	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
        -- ... on achète l'item
		npcBot:ActionImmediate_PurchaseItem( sNextItem );
        -- On enlève l'item acheté de la liste des items à acheter
		if (sNextItem ~= "item_tpscroll") then
            table.remove( tableItemsToBuy, 1 );
        end
	end

end

----------------------------------------------------------------------------------------------------

function OwnsTeleportationDevice()
    if(npcBot:FindItemSlot("item_tpscroll") ~= -1 or npcBot:FindItemSlot("item_recipe_travel_boots") ~= -1 or npcBot:FindItemSlot("item_recipe_travel_boots_2") ~= -1) then
        return true;
    else
        return false;
    end
end