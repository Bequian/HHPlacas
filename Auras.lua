-- HH Placas - Debuffs sobre la placa

local _, HHP = ...

local Secreto = HHP.Secreto

local SIMULADAS = {
    { icono = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", dur = 18 },
    { icono = "Interface\\Icons\\Ability_Warrior_Rend", dur = 12, cuenta = 3 },
    { icono = "Interface\\Icons\\Spell_Frost_FrostNova", dur = 8 },
}

local function Icono(f, i)
    local lista = f.auras.iconos
    local a = lista[i]
    if a then return a end

    a = CreateFrame("Frame", nil, f.auras)
    a:SetSize(20, 20)
    a.tex = a:CreateTexture(nil, "ARTWORK")
    a.tex:SetAllPoints()
    a.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    a.borde = HHP.CrearBorde(a, "OVERLAY")
    HHP.AplicarBorde(a.borde, a, 1, { 0, 0, 0, 1 })

    a.cd = CreateFrame("Cooldown", nil, a, "CooldownFrameTemplate")
    a.cd:SetAllPoints()
    a.cd:SetReverse(true)
    if a.cd.SetDrawEdge then a.cd:SetDrawEdge(false) end
    -- Si las auras quedaron bloqueadas (combate), el icono se va solo al terminar
    a.cd:SetScript("OnCooldownDone", function()
        if f.auras.bloqueadas then a:Hide() end
    end)

    a.capa = CreateFrame("Frame", nil, a)
    a.capa:SetAllPoints()
    a.capa:SetFrameLevel(a.cd:GetFrameLevel() + 2)
    a.cuenta = a.capa:CreateFontString(nil, "OVERLAY")
    a.cuenta:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    a.cuenta:SetPoint("BOTTOMRIGHT", a, "BOTTOMRIGHT", 2, -1)

    lista[i] = a
    return a
end

-- En Forever (cliente de Midnight) las auras pueden ser "secretas" (en
-- combate, cerca de enemigos): el juego no deja que ningún addon las lea.
local function AurasBloqueadas(unit)
    local S = C_Secrets
    if S then
        if S.ShouldUnitAurasBeSecret then
            local ok, v = pcall(S.ShouldUnitAurasBeSecret, unit)
            if ok and v then return true end
        end
        if S.ShouldUnitAuraIndexBeSecret then
            local ok, v = pcall(S.ShouldUnitAuraIndexBeSecret, unit, 1, "HARMFUL")
            if ok and v then return true end
        end
    end
    return false
end

local function LimpiarCD(cd)
    if cd.Clear then cd:Clear() else cd:SetCooldown(0, 0) end
end

local function PonerAura(a, data, unit)
    a.tex:SetTexture(data.icon)

    local apps = data.applications
    if Secreto(apps) then
        local ok = pcall(function()
            a.cuenta:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(unit, data.auraInstanceID, 2, 99))
        end)
        if not ok then a.cuenta:SetText("") end
    elseif apps and apps > 1 then
        a.cuenta:SetText(apps)
    else
        a.cuenta:SetText("")
    end

    local dur, expira = data.duration, data.expirationTime
    if not Secreto(dur) and not Secreto(expira) then
        if dur and dur > 0 and expira then
            a.cd:SetCooldown(expira - dur, dur)
        else
            LimpiarCD(a.cd)
        end
    else
        local ok = pcall(function()
            local d = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
            a.cd:SetCooldownFromDurationObject(d)
        end)
        if not ok then LimpiarCD(a.cd) end
    end
end

function HHP:ActualizarAuras(f, unit)
    local cont = f.auras
    local e = f.diseno.elementos.auras
    local n = 0

    if self:Activo(f, "auras") then
        if f.sim then
            if f.sim.auras then
                local ahora = GetTime()
                for i, s in ipairs(SIMULADAS) do
                    if i > e.max then break end
                    n = i
                    local a = Icono(f, i)
                    a.tex:SetTexture(s.icono)
                    a.cuenta:SetText(s.cuenta or "")
                    -- ciclo continuo para la vista previa
                    a.cd:SetCooldown(ahora - (ahora % s.dur), s.dur)
                end
            end
        else
            local GetAura = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
            if not GetAura or AurasBloqueadas(unit) then
                -- No se pueden leer: dejamos los iconos que ya había
                -- (se ocultan al terminar su tiempo) y refrescamos al salir de combate
                cont.bloqueadas = true
                return
            end
            local filtro = e.soloMias and "HARMFUL|PLAYER" or "HARMFUL"
            for i = 1, 40 do
                if n >= e.max then break end
                local ok, data = pcall(GetAura, unit, i, filtro)
                if not ok then
                    -- El juego las bloqueó a mitad de lectura: igual que arriba
                    cont.bloqueadas = true
                    return
                end
                if not data then break end
                n = n + 1
                self:Seguro("aura", PonerAura, Icono(f, n), data, unit)
            end
            cont.bloqueadas = false
        end
    end

    for i = n + 1, #cont.iconos do cont.iconos[i]:Hide() end

    local tam, esp = e.tam, e.espacio
    cont:SetSize(n > 0 and (n * tam + (n - 1) * esp) or tam, tam)
    for i = 1, n do
        local a = cont.iconos[i]
        a:SetSize(tam, tam)
        a:ClearAllPoints()
        a:SetPoint("LEFT", cont, "LEFT", (i - 1) * (tam + esp), 0)
        a.cuenta:SetFont("Fonts\\FRIZQT__.TTF", math.max(7, math.floor(tam * 0.45)), "OUTLINE")
        a:Show()
    end
    cont:SetShown(n > 0)
end
