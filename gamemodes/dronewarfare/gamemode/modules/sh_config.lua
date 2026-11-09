DW = DW or {}
DW.Config = DW.Config or {}
DW.Config.StartingMoney = 400
DW.Config.Drones = {
    {
        class = "1vt40",
        name = "FPV-Дрон",
        price = 200,
        description = "FPV-Дрон"
    },
    {
        class = "2vt40",
        name = "FPV-Дрон 2",
        price = 250,
        description = "FPV-Дрон"
    },
    {
        class = "lvs_kvn2",
        name = "Оптоволоконный FPV-дрон",
        price = 550,
        description = "Дрон на оптоволокне"
    },
    {
        class = "lvs_kvn3",
        name = "Оптоволоконный FPV-дрон 2",
        price = 550,
        description = "Дрон на оптоволокне"
    },
    {
        class = "sw_molniya",
        name = "Гроза-1",
        price = 1300,
        description = "Слабый ударный БПЛА"
    },
    {
        class = "sw_lancet3",
        name = "Ланс-3",
        price = 1800,
        description = "Слабый ударный БПЛА"
    },
    {
        class = "fp1",
        name = "Ударный-1",
        price = 2200,
        description = "Средний ударный БПЛА"
    },
    {
        class = "sw_geran2",
        name = "Роза-2",
        price = 2600,
        description = "Большой ударный БПЛА"
    }
}

DW.Config.TargetRewards = {
    ["npc_metropolice"] = 250,

    ["sw_uaz469"] = 350,
    ["sw_quadbike"] = 300,
    ["gmod_sent_vehicle_fphysics_base"] = 300,

    ["sw_ural4320_troop"] = 450,
    ["sw_ural4320"] = 450,
    ["sw_leo2a4"] = 2300
}

DW.Config.MenuKey = KEY_F1
DW.Config.SpawnDistance = 140
DW.Config.NotifyDuration = 4
DW.Config.MoneyDataKey = "dronewarfare_money_v1"