local npcBot = GetBot()

local sideShopLocation = nil
_G.NPCHasReachedSideShop = false
_G.distanceBetweenSideShopAndNPC = 0
----------------------------------------------------------------------------------------------------

function OnStart()
    npcBot:ActionImmediate_Chat("Brb, I'm going the side shop.", false)
end

----------------------------------------------------------------------------------------------------

function OnEnd()
    -- Do the standard OnEnd
end

----------------------------------------------------------------------------------------------------

function Think()
    npcBot:Action_MoveToLocation(sideShopLocation)
    if (GetUnitToLocationDistance(npcBot, sideShopLocation) < 300) then
        _G.NPCHasReachedSideShop = true
    end
end

----------------------------------------------------------------------------------------------------

function GetDesire()
    local canBePurchasedFromSideShop = IsItemPurchasedFromSideShop(_G.sNextItem)
    local hasEnoughGold = npcBot:GetGold() >= GetItemCost(_G.sNextItem)

    -- Détermination de l'échoppe la + proche
    local botTeamSideShopLocation = GetShopLocation(npcBot:GetTeam(), SHOP_SIDE)
    local botEnemySideShopLocation = GetShopLocation(npcBot:GetTeam(), SHOP_SIDE2)

    -- Détermine le shop le + près
    if
        (GetUnitToLocationDistance(npcBot, botTeamSideShopLocation) >
            GetUnitToLocationDistance(npcBot, botEnemySideShopLocation))
     then
        sideShopLocation = botEnemySideShopLocation
    else
        sideShopLocation = botTeamSideShopLocation
    end

    _G.sideShopNearby = GetUnitToLocationDistance(npcBot, sideShopLocation) <= 2750

    -- Si le prochain item peut être acheté depuis le side shop et on en est assez prêt alors go
    print("Can be purchased from side shop:", canBePurchasedFromSideShop)
    print("Has enough gold:", hasEnoughGold)
    print("Distance between bot and side shop:", _G.sideShopNearby)

    if (canBePurchasedFromSideShop and hasEnoughGold and _G.sideShopNearby) then
        return BOT_MODE_DESIRE_MODERATE
    else
        return BOT_MODE_DESIRE_NONE
    end
end
