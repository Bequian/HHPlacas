-- HH Placas - Módulo de hermandad (antes "HHLogo")
-- Muestra el logo de HustlinHitmans sobre las placas de sus miembros.

local _, HHP = ...

local Limpio = HHP.Limpio

local function Normalizar(s)
    if type(s) ~= "string" then return nil end
    return (s:gsub("^%s+", ""):gsub("%s+$", "")):lower()
end

-- Título de un NPC ("Suministros generales"): 2ª línea de su tooltip,
-- salvo que sea la línea de nivel ("Nivel 20 Humanoide")
local function TituloNPC(unit)
    if not (C_TooltipInfo and C_TooltipInfo.GetUnit) then return nil end
    local data = C_TooltipInfo.GetUnit(unit)
    local linea = data and data.lines and data.lines[2]
    local t = linea and Limpio(linea.leftText, nil)
    if type(t) ~= "string" or t == "" then return nil end
    if t:find("%d") or t:find("%?%?") then return nil end
    return t
end

function HHP:HermandadDe(f, unit)
    if f.sim then return f.sim.hermandad end
    if not f.esJugador then
        if f.diseno.elementos.hermandad.tituloNPC then
            local ok, t = pcall(TituloNPC, unit)
            if ok then return t end
        end
        return nil
    end
    return Limpio(GetGuildInfo(unit), nil)
end

function HHP:EsDeMiHermandad(nombreHermandad)
    local buscada = Normalizar(self.db.general.hermandad)
    return buscada ~= nil and buscada ~= "" and Normalizar(nombreHermandad) == buscada
end

function HHP:ActualizarHermandad(f, unit)
    local g = self:HermandadDe(f, unit)
    f.logo:SetShown(self:Activo(f, "logo") and f.esJugador and g ~= nil and self:EsDeMiHermandad(g))
    if self:Activo(f, "hermandad") and g and g ~= "" then
        f.hermandad:SetText("<" .. g .. ">")
        f.hermandad:Show()
    else
        f.hermandad:Hide()
    end
end

---------------------------------------------------------------
-- Diagnóstico: /hhp logo
---------------------------------------------------------------
local logoPrueba

function HHP:DiagnosticoLogo()
    local mia = GetGuildInfo("player")
    self:Print("tu hermandad es: " .. tostring(mia))
    self:Print("el addon busca: " .. tostring(self.db.general.hermandad))
    if mia and self:EsDeMiHermandad(mia) then
        print("|cff00ff00Coinciden.|r Los miembros mostrarán el logo en su placa.")
    else
        print("|cffff4444No coinciden:|r cambia el nombre en /hhp general > Nombre de la hermandad.")
    end

    -- Muestra el logo sobre tu retrato para comprobar que la imagen carga
    if not logoPrueba then
        logoPrueba = UIParent:CreateTexture(nil, "OVERLAY")
        logoPrueba:SetTexture(HHP.LOGO)
        logoPrueba:SetSize(32, 32)
        if PlayerFrame then
            logoPrueba:SetPoint("BOTTOM", PlayerFrame, "TOP", -40, -18)
        else
            logoPrueba:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
        end
        logoPrueba:Hide()
    end
    logoPrueba:SetShown(not logoPrueba:IsShown())
    if logoPrueba:IsShown() then
        print("Logo de prueba visible sobre tu retrato (escribe /hhp logo otra vez para ocultarlo).")
    end
end
