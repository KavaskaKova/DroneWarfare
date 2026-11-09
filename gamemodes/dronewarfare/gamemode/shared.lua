DeriveGamemode("sandbox")

GM.Name = "DroneWarfare"
GM.Author = "Kavaska"
GM.Email = ""
GM.Website = ""

GM.TeamBased = false
GM.AllowAutoTeam = true
GM.SelectClass = false

include("modules/sh_config.lua")
include("modules/sh_money.lua")

if SERVER then
    AddCSLuaFile("cl_init.lua")
    AddCSLuaFile("shared.lua")
    AddCSLuaFile("player_class/player_dronewarfare.lua")
    AddCSLuaFile("modules/sh_config.lua")
    AddCSLuaFile("modules/sh_money.lua")
    AddCSLuaFile("modules/cl_money.lua")
    AddCSLuaFile("modules/cl_menu.lua")
end