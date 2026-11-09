AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

include("modules/sv_money.lua")
include("modules/sv_targets.lua")

AddCSLuaFile("modules/cl_money.lua")
AddCSLuaFile("modules/cl_menu.lua")

function GM:Initialize()
    self.BaseClass.Initialize(self)
end

function GM:PlayerInitialSpawn(ply)
    if not ply.DWMoneyLoaded then
        ply:LoadDWMoney()
    end
end

function GM:PlayerSpawn(ply)
    self.BaseClass.PlayerSpawn(self, ply)
    timer.Simple(0, function()
        if not IsValid(ply) then return end
        ply:GodEnable()
        ply:SetNWBool("DW_GodMode", true)
        ply:SetWalkSpeed(220)
        ply:SetRunSpeed(320)
    end)
end

function GM:PlayerLoadout(ply)
    return self.BaseClass.PlayerLoadout(self, ply)
end

hook.Add("PlayerDisconnected", "DW_SaveMoneyOnDisconnect", function(ply)
    if IsValid(ply) then ply:SaveDWMoney() end
end)

hook.Add("ShutDown", "DW_SaveAllMoney", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then ply:SaveDWMoney() end
    end
end)

hook.Add("EntityTakeDamage", "DW_PlayerImmortality", function(ent, dmg)
    if ent:IsPlayer() then
        dmg:SetDamage(0)
        return true
    end
end)

hook.Add("PlayerDeath", "DW_PreventPlayerDeath", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) and not ply:Alive() then ply:Spawn() end
    end)
end)

hook.Add("Think", "DW_KeepPlayersGodded", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and not ply:HasGodMode() then ply:GodEnable() end
    end
end)