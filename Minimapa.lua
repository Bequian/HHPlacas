-- HH Placas - Botón del minimapa con el logo de HH

local _, HHP = ...

local boton

local function Posicionar()
    local g = HHP.db.general.minimapa
    local ang = math.rad(g.angulo or 215)
    local radio = (Minimap:GetWidth() / 2) + 10
    boton:ClearAllPoints()
    boton:SetPoint("CENTER", Minimap, "CENTER", math.cos(ang) * radio, math.sin(ang) * radio)
end

function HHP:IniciarMinimapa()
    if boton or not Minimap then return end
    boton = CreateFrame("Button", "HHPlacasBotonMinimapa", Minimap)
    boton:SetSize(31, 31)
    boton:SetFrameStrata("MEDIUM")
    boton:SetFrameLevel(8)
    boton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    boton:RegisterForDrag("LeftButton")
    boton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- El logo es la única imagen "normal" del botón: así los gestores de
    -- addons (Good Addons, etc.) lo usan como icono del addon.
    local icono = boton:CreateTexture(nil, "ARTWORK")
    icono:SetTexture(HHP.LOGO .. ".tga")
    icono:SetSize(22, 22)
    icono:SetPoint("TOPLEFT", 5, -4)
    boton.icon = icono

    local borde = boton:CreateTexture(nil, "OVERLAY")
    borde:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    borde:SetSize(53, 53)
    borde:SetPoint("TOPLEFT")

    boton:SetScript("OnClick", function(_, b)
        if b == "RightButton" then
            HHP:AbrirDisenador("general")
        else
            HHP:AlternarDisenador()
        end
    end)
    boton:SetScript("OnDragStart", function(s)
        s:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local esc = Minimap:GetEffectiveScale()
            cx, cy = cx / esc, cy / esc
            HHP.db.general.minimapa.angulo = math.deg(math.atan2(cy - my, cx - mx))
            Posicionar()
        end)
    end)
    boton:SetScript("OnDragStop", function(s) s:SetScript("OnUpdate", nil) end)
    boton:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_LEFT")
        GameTooltip:SetText("HH Placas", 1, 0.82, 0)
        GameTooltip:AddLine("Clic: abrir el diseñador", 1, 1, 1)
        GameTooltip:AddLine("Clic derecho: opciones generales", 1, 1, 1)
        GameTooltip:AddLine("Arrastrar: mover el botón", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    boton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    Posicionar()
    self:ActualizarMinimapa()
end

function HHP:ActualizarMinimapa()
    if boton then boton:SetShown(self.db.general.minimapa.mostrar) end
end
