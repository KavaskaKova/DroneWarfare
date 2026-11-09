net.Receive("DW_Notify", function()
    local message = net.ReadString()
    local kind = net.ReadUInt(3)
    notification.AddLegacy(message, kind == 1 and NOTIFY_HINT or NOTIFY_ERROR, DW.Config.NotifyDuration or 4)
    surface.PlaySound(kind == 1 and "buttons/button14.wav" or "buttons/button10.wav")
end)

net.Receive("DW_MoneySync", function()
end)

hook.Add("HUDPaint", "DW_MoneyHUD", function()
    local money = LocalPlayer():GetMoney()
    draw.SimpleText("Баланс: $" .. string.Comma(money), "Trebuchet24",
        ScrW() - 28, 28, Color(90, 230, 130), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end)