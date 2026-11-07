-- HH Placas - Módulo de misiones (antes "HH Misiones")
-- Marca en la placa los mobs de misión con un icono y el progreso.

local _, HHP = ...

local Limpio, Secreto = HHP.Limpio, HHP.Secreto
local objetivos = {}   -- { texto, actual, total }

---------------------------------------------------------------
-- 1. Leer los objetivos de "matar X" del registro de misiones
---------------------------------------------------------------
local function AgregarObjetivo(texto, tipo, terminado, actual, total)
    if texto and tipo == "monster" and not terminado then
        if not actual then
            actual, total = texto:match("(%d+)/(%d+)")
        end
        if actual then
            table.insert(objetivos, { texto = texto, actual = actual, total = total })
        end
    end
end

function HHP:LeerMisiones()
    wipe(objetivos)

    -- API moderna (Forever / Midnight)
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and not info.isHidden and info.questID then
                local lista = C_QuestLog.GetQuestObjectives(info.questID) or {}
                for _, o in ipairs(lista) do
                    AgregarObjetivo(o.text, o.type, o.finished, o.numFulfilled, o.numRequired)
                end
            end
        end
        return
    end

    -- API antigua (Classic)
    if GetNumQuestLogEntries then
        for i = 1, GetNumQuestLogEntries() do
            local _, _, _, esEncabezado = GetQuestLogTitle(i)
            if not esEncabezado then
                for j = 1, GetNumQuestLeaderBoards(i) do
                    AgregarObjetivo(GetQuestLogLeaderBoard(j, i))
                end
            end
        end
    end
end

---------------------------------------------------------------
-- 2. Leer el tooltip del mob (objetos que suelta, barras de progreso)
---------------------------------------------------------------
local function ProgresoEnTexto(texto)
    if not texto or Secreto(texto) then return end
    local actual, total = texto:match("(%d+)/(%d+)")
    if actual and tonumber(actual) < tonumber(total) then
        return actual .. "/" .. total
    end
    local pct = texto:match("%((%d+)%%%)")
    if pct and tonumber(pct) < 100 then
        return pct .. "%"
    end
end

local escaner
local function TooltipAntiguo(unit)
    if not escaner then
        escaner = CreateFrame("GameTooltip", "HHPlacasEscaner", nil, "GameTooltipTemplate")
    end
    escaner:SetOwner(WorldFrame, "ANCHOR_NONE")
    escaner:SetUnit(unit)
    for i = 2, escaner:NumLines() do
        local linea = _G["HHPlacasEscanerTextLeft" .. i]
        local p = ProgresoEnTexto(linea and linea:GetText())
        if p then return p end
    end
end

function HHP:ProgresoEnTooltip(unit)
    if C_TooltipInfo and C_TooltipInfo.GetUnit then
        local data = C_TooltipInfo.GetUnit(unit)
        if data and data.lines then
            for i = 2, #data.lines do
                local p = ProgresoEnTexto(data.lines[i].leftText)
                if p then return p end
            end
        end
    else
        return TooltipAntiguo(unit)
    end
end

function HHP:ProgresoDe(unit)
    if Limpio(UnitIsPlayer(unit), true) or Limpio(UnitIsFriend("player", unit), true) or Limpio(UnitIsDead(unit), true) then
        return nil
    end

    local nombre = UnitName(unit)
    if nombre and not Secreto(nombre) then
        for _, o in ipairs(objetivos) do
            if o.texto:find(nombre, 1, true) then
                return o.actual .. "/" .. o.total, "matar"
            end
        end
    end

    local p = self:ProgresoEnTooltip(unit)
    if p then return p, "objeto" end

    -- Sin contador, pero el juego dice que pertenece a una misión
    if C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest then
        local rel = Limpio(C_QuestLog.UnitIsRelatedToActiveQuest(unit), false)
        if rel then return "", "progreso" end
    end
end

---------------------------------------------------------------
-- 3. Dibujar el icono y el contador
---------------------------------------------------------------
function HHP:ActualizarMision(f, unit)
    local m = f.mision
    if not self:Activo(f, "mision") or not self.db.general.misiones then
        m:Hide()
        return
    end

    local texto, tipo
    if f.sim then
        if f.sim.mision then texto, tipo = f.sim.mision, "matar" end
    else
        texto, tipo = self:ProgresoDe(unit)
    end
    if not texto then
        m:Hide()
        return
    end

    m.icono:SetTexture(HHP.ICONOS_MISION[tipo] or HHP.ICONOS_MISION.matar)
    if tipo == "objeto" then
        m.icono:SetTexCoord(0.08, 0.92, 0.08, 0.92)   -- recorta el borde del icono
    else
        m.icono:SetTexCoord(0, 1, 0, 1)
    end

    local e = f.diseno.elementos.mision
    if e.contador and texto ~= "" then
        m.texto:SetText(texto)
        m.texto:Show()
    else
        m.texto:Hide()
    end
    m:Show()
end

-- Evita refrescar muchas veces seguidas
local pendiente = false
function HHP:MisionesCambiaron()
    if pendiente then return end
    pendiente = true
    C_Timer.After(0.3, function()
        pendiente = false
        HHP:Seguro("leer misiones", HHP.LeerMisiones, HHP)
        for unit, f in pairs(HHP.activas) do
            HHP:Seguro("misión", HHP.ActualizarMision, HHP, f, unit)
        end
    end)
end
