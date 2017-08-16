local npcBot = GetBot();

----------------------------------------------------------------------------------------------------

function OnStart()
	npcBot:ActionImmediate_Chat("Brb, I'm going the side shop.", true);
end

----------------------------------------------------------------------------------------------------

function OnEnd()
	-- Do the standard OnEnd
end

----------------------------------------------------------------------------------------------------

--function Think()
	-- Do the standard Think
--end

----------------------------------------------------------------------------------------------------

function GetDesire()

    -- TODO: Si prochain item à acheter peut être acheté au side shop et le héro a assez d'argent pour acheter, alors désire medium
    -- Sinon désir nul. 

    return BOT_MODE_DESIRE_NONE;

end