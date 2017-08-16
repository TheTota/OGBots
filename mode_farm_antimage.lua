local npcBot = GetBot();

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
	-- Code pour le farm ? 
end

----------------------------------------------------------------------------------------------------

function GetDesire()

    if (HasReachedDominatingStage()) then 
        -- Si AM a atteint son stade de dominance, le farm à un importance moindre.
        --print("AM has reached dominating stage");
        return BOT_MODE_DESIRE_VERYLOW;
    else
        if (OwnsMantaStyle()) then 
            --print("AM owns Manta!");
            return BOT_MODE_DESIRE_LOW;
        else
            if (OwnsBattlefury()) then
                -- Si AM possède bfury, il veut farmer mais est plus enclin à agir avec l'équipe
                --print("AM owns Bfury and wants to farm lanes and jungles");
                return BOT_MODE_DESIRE_MODERATE;
            else 
                -- Si AM ne possède pas bfury, il doit à tout prix farmer l'item
                if(DotaTime() < 600) then
                    --print("AM doesnt own Bfury and first 10 minutes give priority to laning");
                    return BOT_MODE_DESIRE_VERYLOW;
                else                
                    --print("AM doesnt own Bfury but early game is over and he has to focus on it ")
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