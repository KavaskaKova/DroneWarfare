local rewarded = setmetatable({}, { __mode = "k" })

local function resolvePlayer(attacker, inflictor)
    local candidates = { attacker, inflictor }
    for _, candidate in ipairs(candidates) do
        if IsValid(candidate) then
            if candidate:IsPlayer() then return candidate end
            if IsValid(candidate.DWOwner) and candidate.DWOwner:IsPlayer() then return candidate.DWOwner end
            if IsValid(candidate:GetOwner()) and candidate:GetOwner():IsPlayer() then return candidate:GetOwner() end
            if IsValid(candidate:GetCreator()) and candidate:GetCreator():IsPlayer() then return candidate:GetCreator() end
        end
    end
    return nil
end

local function rewardTarget(ent, ply)
    if not IsValid(ent) or rewarded[ent] then return end
    local class = ent:GetClass()
    local amount = DW.Config.TargetRewards[class]
    if not amount or amount <= 0 then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end

    rewarded[ent] = true
    ply:AddMoney(amount)
    if _G.DW_NotifyPlayer then
        _G.DW_NotifyPlayer(ply, "Цель уничтожена: +" .. amount .. "$ (" .. class .. ")", 1)
    end
end

hook.Add("EntityTakeDamage", "DW_TrackTargetDamage", function(ent, dmg)
    if not IsValid(ent) or ent:IsPlayer() then return end
    local class = ent:GetClass()
    if not DW.Config.TargetRewards[class] then return end

    local attacker = resolvePlayer(dmg:GetAttacker(), dmg:GetInflictor())
    if IsValid(attacker) then
        ent.DWLastAttacker = attacker
        ent.DWLastDamageTime = CurTime()
    end

    ent.DWWasDamagedByPlayer = true
    local health = ent:Health()
    local damage = dmg:GetDamage()
    if health <= 0 or damage >= health then
        ent.DWMarkedDestroyed = true
        ent.DWLastAttacker = attacker or ent.DWLastAttacker
    end
end)

hook.Add("OnNPCKilled", "DW_RewardNPC", function(npc, attacker, inflictor)
    rewardTarget(npc, resolvePlayer(attacker, inflictor) or npc.DWLastAttacker)
end)

hook.Add("EntityRemoved", "DW_RewardRemovedTargets", function(ent)
    if not ent or rewarded[ent] then return end
    if not DW.Config.TargetRewards[ent:GetClass()] then return end
    if ent.DWMarkedDestroyed or ent.DWWasDamagedByPlayer then
        rewardTarget(ent, ent.DWLastAttacker)
    end
end)

function DW_RewardEntity(ent, attacker)
    rewardTarget(ent, resolvePlayer(attacker) or (IsValid(ent) and ent.DWLastAttacker))
end