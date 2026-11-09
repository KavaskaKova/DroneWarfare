function PLAYER_GetMoney(ply)
    if not IsValid(ply) then return 0 end
    return ply:GetNWInt("DW_Money", DW.Config.StartingMoney or 400)
end

function PLAYER_CanAfford(ply, amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    return IsValid(ply) and ply:GetMoney() >= amount
end

local meta = FindMetaTable("Player")
function meta:GetMoney()
    return PLAYER_GetMoney(self)
end

function meta:CanAfford(amount)
    return PLAYER_CanAfford(self, amount)
end
