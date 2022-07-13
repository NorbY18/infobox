
function addInfoBoxS(player, message, itype)
    triggerClientEvent(player, "addInfoBox", player, message, itype)
end 
addEvent("addInfoBox", true)
addEventHandler("addInfoBox", root, addInfoBoxS)