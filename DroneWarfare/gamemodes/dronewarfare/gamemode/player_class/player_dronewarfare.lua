local PLAYER = {}

PLAYER.DisplayName = "DroneWarfare Operative"
PLAYER.WalkSpeed = 220
PLAYER.RunSpeed = 320
PLAYER.CrouchedWalkSpeed = 0.3
PLAYER.DuckSpeed = 0.3
PLAYER.UnDuckSpeed = 0.3
PLAYER.JumpPower = 200
PLAYER.CanUseFlashlight = true
PLAYER.MaxHealth = 100
PLAYER.StartHealth = 100
PLAYER.StartArmor = 0
PLAYER.DropWeaponOnDie = false
PLAYER.TeammateNoCollide = false
PLAYER.AvoidPlayers = true

function PLAYER:Spawn()
    self.Player:SetMaxHealth(self.MaxHealth)
    self.Player:SetHealth(self.StartHealth)
    self.Player:GodEnable()
end

player_manager.RegisterClass("player_dronewarfare", PLAYER, "player_default")