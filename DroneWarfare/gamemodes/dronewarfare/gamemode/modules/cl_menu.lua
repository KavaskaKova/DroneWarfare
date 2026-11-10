local shop

local function openShop()
    if IsValid(shop) then shop:Remove() end

    shop = vgui.Create("DFrame")
    shop:SetSize(620, 440)
    shop:Center()
    shop:SetTitle("DroneWarfare — магазин дронов")
    shop:MakePopup()
    shop:SetSizable(false)
    shop:SetBackgroundBlur(true)

    local balance = vgui.Create("DLabel", shop)
    balance:SetPos(18, 36)
    balance:SetSize(580, 28)
    balance:SetFont("Trebuchet24")
    balance:SetTextColor(Color(100, 230, 140))
    balance:SetText("Ваш баланс: $" .. string.Comma(LocalPlayer():GetMoney()))

    local scroll = vgui.Create("DScrollPanel", shop)
    scroll:SetPos(14, 72)
    scroll:SetSize(592, 354)

    for index, drone in ipairs(DW.Config.Drones) do
        local panel = scroll:Add("DPanel")
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 8)
        panel:SetTall(82)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(35, 42, 53))
        end

        local title = vgui.Create("DLabel", panel)
        title:SetPos(12, 8)
        title:SetSize(390, 24)
        title:SetFont("Trebuchet18")
        title:SetTextColor(color_white)
        title:SetText(drone.name or drone.class)

        local desc = vgui.Create("DLabel", panel)
        desc:SetPos(12, 34)
        desc:SetSize(390, 38)
        desc:SetFont("DermaDefault")
        desc:SetTextColor(Color(190, 198, 210))
        desc:SetWrap(true)
        desc:SetText((drone.description or "") .. "  [" .. tostring(drone.class) .. "]")

        local price = vgui.Create("DLabel", panel)
        price:SetPos(410, 12)
        price:SetSize(165, 22)
        price:SetFont("Trebuchet18")
        price:SetTextColor(Color(110, 230, 145))
        price:SetContentAlignment(6)
        price:SetText("$" .. string.Comma(tonumber(drone.price) or 0))

        local buy = vgui.Create("DButton", panel)
        buy:SetPos(430, 42)
        buy:SetSize(145, 30)
        buy:SetText("Купить")
        buy.DoClick = function()
            net.Start("DW_BuyDrone")
                net.WriteUInt(index, 8)
            net.SendToServer()
            timer.Simple(0.15, function()
                if IsValid(balance) then
                    balance:SetText("Ваш баланс: $" .. string.Comma(LocalPlayer():GetMoney()))
                end
            end)
        end
    end

    shop.Think = function()
        if IsValid(balance) then
            balance:SetText("Ваш баланс: $" .. string.Comma(LocalPlayer():GetMoney()))
        end
    end
end

--hook.Add("ShowHelp", "DW_OpenShopF1", openShop)
--hook.Add("PlayerButtonDown", "DW_CustomShopKey", function(ply, key)
--    if ply == LocalPlayer() and key == (DW.Config.MenuKey or KEY_F1) then
--        openShop()
--    end
--end)




concommand.Add("dw_shop", openShop)


hook.Add("PlayerBindPress", "DWShop_Q_Override", function(ply, bind, pressed)
    if bind == "+menu" and pressed then
        RunConsoleCommand("dw_shop")
        return true -- блокирует стандартное меню Q
    end
end)
