---------------------------------
-- Item Purchase for Anti-Mage --
---------------------------------

-- A considérer:
--   - Moonshard à consommer.
--   - Achat d'item en fonction des items des autres. (ex: pas de butterfly si ennemis ont mkb).
--   - Ne pas appeller le courier pour des items insignifiants (exemple un Slipper of Agility seul).
--   - Achat d'items aux échoppes spécifique quand possibilité.
--   - Acheter des items de régénération quand a perdu de la vie.

-- Remarques:
--   - AM monopolise le coursier en appellant des petits items ou/et des items qu'il pourrait acquérir au side shop.

----------------------------------------------------------------------------------------------------

-- Récupération du bot sur lequel le script est exécuté
local npcBot = GetBot();

_G.sNextItem = nil;
canBePurchasedFromSideShop = false;
mustBePurchaseFromSecretShop = false;

local hasSetTreadsToAgi = false;

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
    if (OwnsTeleportationDevice() or DotaTime() < 420) then
        _G.sNextItem = tableItemsToBuy[1];
    else 
        _G.sNextItem = "item_tpscroll";   
    end

    -- On définit la valeur du prochain item à acheter au bot
	npcBot:SetNextItemPurchaseValue( GetItemCost( _G.sNextItem ) );

    local canBePurchasedFromSideShop = IsItemPurchasedFromSideShop(_G.sNextItem);

    local goldBeforePotentialPurchase = npcBot:GetGold();
        
    -- Si le bot a assez d'argent, ...
	if (npcBot:GetGold() >= GetItemCost( _G.sNextItem )) then
        if (npcBot:GetActiveMode() == BOT_MODE_SIDE_SHOP and _G.NPCHasReachedSideShop) then 
            npcBot:ActionImmediate_PurchaseItem( _G.sNextItem );
        else 
            if (npcBot:GetActiveMode() == BOT_MODE_SECRET_SHOP) then -- and _G.NPCHasReachedSecretShop) then 
                npcBot:ActionImmediate_PurchaseItem( _G.sNextItem );
            else
                if ((canBePurchasedFromSideShop and not _G.sideShopNearby) or (not canBePurchasedFromSideShop)) then -- do same for secret shop
                    npcBot:ActionImmediate_PurchaseItem( _G.sNextItem );
                end
            end
        end
    
        local goldAfterPotentialPurchase = npcBot:GetGold();
        
        -- TODO: Switch to agi treads
--        if (OwnsPowerTreads() and not hasSetTreadsToAgi) then
            -- Passage des power treads en mode agilité
--            npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
--            npcBot:Action_UseAbility(npcBot:GetItemInSlot(npcBot:FindItemSlot("item_power_treads")));
--            hasSetTreadsToAgi = true;
--        end

        -- On enlève l'item acheté de la liste des items à acheter sauf si l'item acheté est un TP ou de la regen
        if (_G.sNextItem ~= "item_tpscroll" and goldAfterPotentialPurchase ~= goldBeforePotentialPurchase) then
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

function OwnsPowerTreads()
    if(npcBot:FindItemSlot("item_power_treads") ~= -1) then
        return true;
    else
        return false;
    end
end