util.AddNetworkString("DW_Notify")
util.AddNetworkString("DW_BuyDrone")
util.AddNetworkString("DW_MoneySync")

local PLAYER = FindMetaTable("Player")

--------------------------------------------------
-- Вспомогательные функции
--------------------------------------------------

local function notify(ply, message, kind)
    if not IsValid(ply) then return end
    net.Start("DW_Notify")
        net.WriteString(tostring(message))
        net.WriteUInt(kind or 0, 3)
    net.Send(ply)
end

_G.DW_NotifyPlayer = notify

--------------------------------------------------
-- Методы игрока (деньги)
--------------------------------------------------

function PLAYER:GetMoney()
    return self:GetNWInt("DW_Money", 0)
end

function PLAYER:CanAfford(amount)
    amount = tonumber(amount) or 0
    return self:GetMoney() >= amount
end

function PLAYER:AddMoney(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end

    local newBalance = math.Clamp(self:GetMoney() + amount, 0, 2147483647)
    self:SetNWInt("DW_Money", newBalance)
    self:SaveDWMoney()

    net.Start("DW_MoneySync")
        net.WriteInt(newBalance, 32)
    net.Send(self)

    return true
end

function PLAYER:TakeMoney(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or not self:CanAfford(amount) then return false end

    local newBalance = self:GetMoney() - amount
    self:SetNWInt("DW_Money", newBalance)
    self:SaveDWMoney()

    net.Start("DW_MoneySync")
        net.WriteInt(newBalance, 32)
    net.Send(self)

    return true
end

function PLAYER:SaveDWMoney()
    if not IsValid(self) or not self:IsPlayer() then return end
    local key = (DW and DW.Config and DW.Config.MoneyDataKey) or "DW_Money"
    self:SetPData(key, tostring(self:GetMoney()))
end

function PLAYER:LoadDWMoney()
    if not IsValid(self) then return end

    local key = (DW and DW.Config and DW.Config.MoneyDataKey) or "DW_Money"
    local starting = (DW and DW.Config and DW.Config.StartingMoney) or 1000

    local saved = tonumber(self:GetPData(key, ""))
    if saved == nil then
        saved = starting
    end

    saved = math.Clamp(math.floor(saved), 0, 2147483647)
    self:SetNWInt("DW_Money", saved)
    self.DWMoneyLoaded = true
    self:SaveDWMoney()
end

--------------------------------------------------
-- Загрузка и сохранение
--------------------------------------------------

hook.Add("PlayerInitialSpawn", "DW_LoadMoney", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) and not ply.DWMoneyLoaded then
            ply:LoadDWMoney()
        end
    end)
end)

hook.Add("PlayerDisconnected", "DW_SaveMoney", function(ply)
    if IsValid(ply) then
        ply:SaveDWMoney()
    end
end)

timer.Create("DW_AutoSaveMoney", 120, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.DWMoneyLoaded then
            ply:SaveDWMoney()
        end
    end
end)

--------------------------------------------------
-- Покупка дрона
--------------------------------------------------

net.Receive("DW_BuyDrone", function(_, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    -- Анти-спам
    if ply.DW_LastBuy and CurTime() - ply.DW_LastBuy < 1.2 then
        return
    end
    ply.DW_LastBuy = CurTime()

    if not DW or not DW.Config or not DW.Config.Drones then
        notify(ply, "Конфиг дронов не найден.", 2)
        return
    end

    local index = net.ReadUInt(8)
    local drone = DW.Config.Drones[index]

    if not drone then
        notify(ply, "Неверный дрон.", 2)
        return
    end

    local class = tostring(drone.class or "")
    local price = math.floor(tonumber(drone.price) or -1)

    if class == "" or price < 0 or price > 100000000 then
        notify(ply, "Некорректные данные дрона.", 2)
        return
    end

    if not scripted_ents.GetStored(class) then
        notify(ply, "Энтити дрона не найдена: " .. class, 2)
        return
    end

    if not ply:CanAfford(price) then
        notify(ply, "Недостаточно средств.", 2)
        return
    end

    -- Позиция спавна
    local tr = ply:GetEyeTrace()
    local spawnPos
    local spawnDist = (DW.Config.SpawnDistance) or 140

    if tr.Hit and tr.HitPos:DistToSqr(ply:GetPos()) < 1000000 then
        spawnPos = tr.HitPos + tr.HitNormal * 24
    else
        spawnPos = ply:GetPos() + ply:GetForward() * spawnDist + Vector(0, 0, 40)
    end

    if not ply:TakeMoney(price) then return end

    local ent = ents.Create(class)
    if not IsValid(ent) then
        ply:AddMoney(price)
        notify(ply, "Не удалось создать дрон. Деньги возвращены.", 2)
        return
    end

    ent:SetPos(spawnPos)
    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    ent:SetCreator(ply)
    ent:SetOwner(ply)
    ent:Spawn()
    ent:Activate()

    ent.DWOwner = ply

    if ent.CPPISetOwner then
        ent:CPPISetOwner(ply)
    end

    notify(ply, "Куплен дрон: " .. tostring(drone.name or class), 1)
end)

local KILL_CREDIT_TIME = 15   -- сколько секунд последний удар считается причиной смерти
local DEFAULT_REWARD = 0      -- награда для классов, которых нет в конфиге (0 = не платить)

local function IsLVSVehicle(ent)
    return (ent.LVS and isfunction(ent.GetHP)) or false
end

local function IsSimfphys(ent)
    return isfunction(ent.GetCurHealth)
end

local function IsRewardableVehicle(ent)
    if not IsValid(ent) then return false end

    if IsLVSVehicle(ent) then return true end
    if IsSimfphys(ent) then return true end
    if ent:IsVehicle() then return true end

    local class = ent:GetClass()
    if string.StartWith(class, "gmod_sent_vehicle") then return true end
    if string.StartWith(class, "prop_vehicle") then return true end

    return false
end

local function GetVehicleHP(ent)
    if IsLVSVehicle(ent) then return ent:GetHP() end
    if IsSimfphys(ent) then return ent:GetCurHealth() end
    return ent:Health()
end

local function GetRewardOwner(ent)
    if not IsValid(ent) then return nil end

    if IsValid(ent.DWOwner) then
        return ent.DWOwner
    end

    local owner = ent:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        return owner
    end

    if ent:IsPlayer() then
        return ent
    end

    return nil
end

local function GetTargetReward(ent)
    local rewards = DW and DW.Config and DW.Config.TargetRewards
    local class = ent:GetClass()

    local r = rewards and tonumber(rewards[class])
    if r then return math.floor(r) end

    if DEFAULT_REWARD <= 0 then
        print("[DW] Нет награды в TargetRewards для класса: " .. class)
    end
    return DEFAULT_REWARD
end

local function PayReward(killer, target)
    local reward = GetTargetReward(target)
    if reward <= 0 then return end

    killer:AddMoney(reward)
    notify(killer, "Получено " .. reward .. "$ за уничтожение цели!", 1)
end

local function GiveVehicleReward(target)
    if target.DW_Rewarded then return end

    local killer = target.DW_LastDamager
    if not IsValid(killer) or not killer:IsPlayer() then return end

    if CurTime() - (target.DW_LastDamageTime or 0) > KILL_CREDIT_TIME then return end

    if target:GetOwner() == killer then return end
    if target.DWOwner == killer then return end

    target.DW_Rewarded = true
    PayReward(killer, target)
end

hook.Add("EntityTakeDamage", "DW_RewardOnVehicleKill", function(target, dmginfo)
    if not IsRewardableVehicle(target) then return end
    if target.DW_Rewarded then return end

    if GetVehicleHP(target) <= 0 then return end

    local owner = GetRewardOwner(dmginfo:GetAttacker())
        or GetRewardOwner(dmginfo:GetInflictor())

    if IsValid(owner) and owner:IsPlayer() then
        target.DW_LastDamager = owner
        target.DW_LastDamageTime = CurTime()
    end

    if target.DW_CheckPending then return end
    target.DW_CheckPending = true

    timer.Simple(0, function()
        if not IsValid(target) then return end
        target.DW_CheckPending = nil

        if GetVehicleHP(target) > 0 then return end

        GiveVehicleReward(target)
    end)
end)

