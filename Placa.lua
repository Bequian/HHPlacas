-- HH Placas - Construcción y actualización de las placas
-- La misma "raíz" se usa en las placas del juego y en la vista previa del
-- diseñador (en ese caso con datos simulados en f.sim).

local _, HHP = ...

local Limpio, Existe, Secreto = HHP.Limpio, HHP.Existe, HHP.Secreto
local BLANCO = "Interface\\Buttons\\WHITE8X8"
local floor, max = math.floor, math.max

local COLORES = {
    hostil = { 0.85, 0.18, 0.18 },
    neutral = { 0.95, 0.80, 0.25 },
    amistoso = { 0.25, 0.75, 0.30 },
    jugadorAmigo = { 0.35, 0.55, 1.00 },
    gris = { 0.55, 0.55, 0.55 },
    aggro = { 1.00, 0.10, 0.55 },
    casiAggro = { 1.00, 0.55, 0.00 },
}
HHP.COLORES = COLORES

---------------------------------------------------------------
-- Bordes de 4 líneas
---------------------------------------------------------------
function HHP.CrearBorde(padre, capa)
    local b = {}
    for i = 1, 4 do
        local t = padre:CreateTexture(nil, capa or "OVERLAY")
        t:SetTexture(BLANCO)
        b[i] = t
    end
    return b
end

function HHP.AplicarBorde(b, region, grosor, color)
    for i = 1, 4 do b[i]:ClearAllPoints() end
    if not grosor or grosor <= 0 then
        for i = 1, 4 do b[i]:Hide() end
        return
    end
    b[1]:SetPoint("BOTTOMLEFT", region, "TOPLEFT", -grosor, 0)
    b[1]:SetPoint("BOTTOMRIGHT", region, "TOPRIGHT", grosor, 0)
    b[1]:SetHeight(grosor)
    b[2]:SetPoint("TOPLEFT", region, "BOTTOMLEFT", -grosor, 0)
    b[2]:SetPoint("TOPRIGHT", region, "BOTTOMRIGHT", grosor, 0)
    b[2]:SetHeight(grosor)
    b[3]:SetPoint("TOPRIGHT", region, "TOPLEFT", 0, 0)
    b[3]:SetPoint("BOTTOMRIGHT", region, "BOTTOMLEFT", 0, 0)
    b[3]:SetWidth(grosor)
    b[4]:SetPoint("TOPLEFT", region, "TOPRIGHT", 0, 0)
    b[4]:SetPoint("BOTTOMLEFT", region, "BOTTOMRIGHT", 0, 0)
    b[4]:SetWidth(grosor)
    local r, g, bb, a = color[1], color[2], color[3], color[4] or 1
    for i = 1, 4 do
        b[i]:SetVertexColor(r, g, bb, a)
        b[i]:Show()
    end
end
local CrearBorde, AplicarBorde = HHP.CrearBorde, HHP.AplicarBorde

local function Gradiente(tex, orientacion, r, g, b, a1, a2)
    if tex.SetGradient and CreateColor then
        pcall(tex.SetGradient, tex, orientacion, CreateColor(r, g, b, a1), CreateColor(r, g, b, a2))
    else
        tex:SetVertexColor(r, g, b, (a1 + a2) / 2)
    end
end

local function TextoNuevo(padre)
    local fs = padre:CreateFontString(nil, "OVERLAY")
    fs:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    fs:SetWordWrap(false)
    return fs
end

---------------------------------------------------------------
-- Construcción
---------------------------------------------------------------
function HHP:CrearRaiz(padre)
    local f = CreateFrame("Frame", nil, padre)
    f:SetSize(1, 1)
    f:SetPoint("CENTER", padre, "CENTER", 0, 0)
    local nivel = f:GetFrameLevel()

    -- Resaltado del objetivo (detrás de las barras)
    local r = CreateFrame("Frame", nil, f)
    r:SetFrameLevel(nivel)
    r:SetAllPoints(f)
    r.brillo = {}
    for i = 1, 4 do
        local t = r:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(BLANCO)
        t:SetBlendMode("ADD")
        r.brillo[i] = t
    end
    r.marco = CreateFrame("Frame", nil, r)
    r.borde = CrearBorde(r.marco, "BACKGROUND")
    r.flechaI = r:CreateTexture(nil, "OVERLAY")
    r.flechaI:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
    r.flechaD = r:CreateTexture(nil, "OVERLAY")
    r.flechaD:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
    r.flechaD:SetTexCoord(1, 0, 0, 1)
    r.linea = r:CreateTexture(nil, "OVERLAY")
    r.linea:SetTexture(BLANCO)
    f.resaltado = r

    -- Barra de vida
    local vida = CreateFrame("StatusBar", nil, f)
    vida:SetFrameLevel(nivel + 1)
    vida:SetMinMaxValues(0, 1)
    vida:SetValue(1)
    vida.fondo = vida:CreateTexture(nil, "BACKGROUND")
    vida.fondo:SetAllPoints()
    vida.borde = CrearBorde(vida)
    f.vida = vida

    -- Barra de lanzamiento
    local cast = CreateFrame("StatusBar", nil, f)
    cast:SetFrameLevel(nivel + 1)
    cast:SetMinMaxValues(0, 1)
    cast.fondo = cast:CreateTexture(nil, "BACKGROUND")
    cast.fondo:SetAllPoints()
    cast.borde = CrearBorde(cast)
    cast.icono = cast:CreateTexture(nil, "OVERLAY")
    cast.icono:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    cast.texto = TextoNuevo(cast)
    cast.tiempo = TextoNuevo(cast)
    cast:Hide()
    f.cast = cast

    -- Debuffs
    local auras = CreateFrame("Frame", nil, f)
    auras:SetFrameLevel(nivel + 3)
    auras:SetSize(1, 1)
    auras.iconos = {}
    f.auras = auras

    -- Capa superior con textos e iconos
    local capa = CreateFrame("Frame", nil, f)
    capa:SetFrameLevel(nivel + 6)
    capa:SetAllPoints(f)
    f.capa = capa

    f.nombre = TextoNuevo(capa)
    -- Marco invisible del tamaño real del texto (para el resaltado)
    f.anclaNombre = CreateFrame("Frame", nil, capa)
    f.anclaNombre:SetSize(1, 1)
    f.textoVida = TextoNuevo(capa)
    f.nivel = TextoNuevo(capa)
    f.hermandad = TextoNuevo(capa)

    f.marca = capa:CreateTexture(nil, "OVERLAY")
    f.marca:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    f.marca:Hide()

    f.elite = capa:CreateTexture(nil, "OVERLAY")
    f.elite:Hide()
    -- Contorno dorado detrás del icono plateado del raro élite
    f.eliteBorde = capa:CreateTexture(nil, "ARTWORK")
    f.eliteBorde:Hide()

    f.logo = capa:CreateTexture(nil, "OVERLAY")
    f.logo:SetTexture(HHP.LOGO)
    f.logo:Hide()

    local m = CreateFrame("Frame", nil, capa)
    m:SetSize(16, 16)
    m.icono = m:CreateTexture(nil, "OVERLAY")
    m.icono:SetAllPoints()
    m.texto = TextoNuevo(m)
    m:Hide()
    f.mision = m

    return f
end

---------------------------------------------------------------
-- Estado de la unidad
---------------------------------------------------------------
function HHP:EstadoUnidad(f, unit)
    local s = f.sim
    if s then
        f.esJugador = s.jugador and true or false
        f.esAliado = s.aliado and true or false
        f.atacable = s.atacable and true or false
        f.categoria = s.categoria or "mob"
    else
        f.esJugador = Limpio(UnitIsPlayer(unit), false) and true or false
        f.esAliado = Limpio(UnitIsFriend("player", unit), false) and true or false
        f.atacable = Limpio(UnitCanAttack("player", unit), true) and true or false
        f.categoria = self:CategoriaDe(f, unit)
    end
    f.diseno = self.db.disenos[f.categoria] or self.db.disenos.mob
end

-- Decide qué diseño usa la unidad
function HHP:CategoriaDe(f, unit)
    if f.esJugador then
        if f.esAliado then
            local g = Limpio(GetGuildInfo(unit), nil)
            if g and self:EsDeMiHermandad(g) then return "hermandad" end
            return "aliado"
        end
        return "rival"
    end
    if not f.atacable then return "npc" end
    local clasif = Limpio(UnitClassification(unit), "normal")
    local nivel = Limpio(UnitLevel(unit), 1)
    local jefe = UnitIsBossMob and Limpio(UnitIsBossMob(unit), false)
    if clasif == "worldboss" or nivel == -1 or jefe then return "jefe" end
    if clasif == "elite" or clasif == "rareelite" or clasif == "rare" then return "elite" end
    return "mob"
end

function HHP:Activo(f, clave)
    local e = f.diseno.elementos[clave]
    return e and e.mostrar and true or false
end

---------------------------------------------------------------
-- Aplicar el diseño (posiciones, tamaños, fuentes, texturas)
---------------------------------------------------------------
local function Fuente(fs, e)
    local flags = e.contorno or "OUTLINE"
    fs:SetFont(HHP:Fuente(e.fuente), e.tam or 10, flags)
    if not fs:GetFont() then
        fs:SetFont("Fonts\\FRIZQT__.TTF", e.tam or 10, flags)
    end
    if flags == "" then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 1)
    else
        fs:SetShadowOffset(0, 0)
    end
end

local function ColocarTexto(fs, f, e)
    local j = e.justificar or "CENTER"
    fs:ClearAllPoints()
    fs:SetPoint(j, f, "CENTER", e.x, e.y)
    fs:SetJustifyH(j)
end

local function Centro(region, f, e)
    region:ClearAllPoints()
    region:SetPoint("CENTER", f, "CENTER", e.x, e.y)
end

function HHP:AplicarResaltadoDiseno(f)
    local e = f.diseno.elementos.objetivo
    local r = f.resaltado
    local conVida = self:Activo(f, "vida")
    if e.ancla == "nombre" and self:Activo(f, "nombre") then
        conVida = false
    elseif e.ancla == "vida" then
        conVida = true
    end
    local ancla = conVida and f.vida or f.anclaNombre
    local grosorVida = conVida and (HHP.BORDES[f.diseno.elementos.vida.borde] or 0) or 0
    local sep = e.separacion or 2
    local cr, cg, cb, ca = e.color[1], e.color[2], e.color[3], e.color[4] or 1
    local estilo = e.estilo

    for i = 1, 4 do r.brillo[i]:Hide() end
    for i = 1, 4 do r.borde[i]:Hide() end
    r.flechaI:Hide()
    r.flechaD:Hide()
    r.linea:Hide()
    r.estilo = estilo

    if estilo == "Brillo" then
        local g, t = grosorVida + max(0, sep - 2), 7
        local b = r.brillo
        for i = 1, 4 do b[i]:ClearAllPoints() end
        b[1]:SetPoint("BOTTOMLEFT", ancla, "TOPLEFT", -g, g)
        b[1]:SetPoint("BOTTOMRIGHT", ancla, "TOPRIGHT", g, g)
        b[1]:SetHeight(t)
        Gradiente(b[1], "VERTICAL", cr, cg, cb, ca * 0.8, 0)
        b[2]:SetPoint("TOPLEFT", ancla, "BOTTOMLEFT", -g, -g)
        b[2]:SetPoint("TOPRIGHT", ancla, "BOTTOMRIGHT", g, -g)
        b[2]:SetHeight(t)
        Gradiente(b[2], "VERTICAL", cr, cg, cb, 0, ca * 0.8)
        b[3]:SetPoint("TOPRIGHT", ancla, "TOPLEFT", -g, g)
        b[3]:SetPoint("BOTTOMRIGHT", ancla, "BOTTOMLEFT", -g, -g)
        b[3]:SetWidth(t)
        Gradiente(b[3], "HORIZONTAL", cr, cg, cb, 0, ca * 0.8)
        b[4]:SetPoint("TOPLEFT", ancla, "TOPRIGHT", g, g)
        b[4]:SetPoint("BOTTOMLEFT", ancla, "BOTTOMRIGHT", g, -g)
        b[4]:SetWidth(t)
        Gradiente(b[4], "HORIZONTAL", cr, cg, cb, ca * 0.8, 0)
    elseif estilo == "Borde" then
        local g = grosorVida + max(0, sep - 1)
        r.marco:ClearAllPoints()
        r.marco:SetPoint("TOPLEFT", ancla, "TOPLEFT", -g, g)
        r.marco:SetPoint("BOTTOMRIGHT", ancla, "BOTTOMRIGHT", g, -g)
        AplicarBorde(r.borde, r.marco, 2, e.color)
        for i = 1, 4 do r.borde[i]:Hide() end
    elseif estilo == "Flechas" then
        local alto = conVida and max(f.diseno.elementos.vida.alto + 6, 14) or 14
        r.flechaI:ClearAllPoints()
        r.flechaI:SetSize(alto * 0.75, alto)
        r.flechaI:SetPoint("RIGHT", ancla, "LEFT", -sep - grosorVida, 0)
        r.flechaI:SetVertexColor(cr, cg, cb, ca)
        r.flechaD:ClearAllPoints()
        r.flechaD:SetSize(alto * 0.75, alto)
        r.flechaD:SetPoint("LEFT", ancla, "RIGHT", sep + grosorVida, 0)
        r.flechaD:SetVertexColor(cr, cg, cb, ca)
    elseif estilo == "Subrayado" then
        r.linea:ClearAllPoints()
        r.linea:SetPoint("TOPLEFT", ancla, "BOTTOMLEFT", 0, -sep - grosorVida)
        r.linea:SetPoint("TOPRIGHT", ancla, "BOTTOMRIGHT", 0, -sep - grosorVida)
        r.linea:SetHeight(2)
        r.linea:SetVertexColor(cr, cg, cb, ca)
    end
end

function HHP:AplicarDiseno(f)
    local d = f.diseno
    local E = d.elementos
    f:SetScale(max(0.1, (d.escala or 1) * (f.zoom or 1)))

    -- Vida
    local e = E.vida
    local vida = f.vida
    Centro(vida, f, e)
    vida:SetSize(e.ancho, e.alto)
    local tex = self:Textura(e.textura)
    vida:SetStatusBarTexture(tex)
    vida.fondo:SetTexture(tex)
    AplicarBorde(vida.borde, vida, HHP.BORDES[e.borde] or 0, e.colorBorde)
    vida:SetShown(self:Activo(f, "vida"))

    -- Nombre
    e = E.nombre
    Fuente(f.nombre, e)
    ColocarTexto(f.nombre, f, e)
    f.nombre:SetWidth(e.anchoMax or 0)
    f.nombre:SetShown(self:Activo(f, "nombre"))

    -- Texto de vida
    e = E.textoVida
    Fuente(f.textoVida, e)
    ColocarTexto(f.textoVida, f, e)
    f.textoVida:SetTextColor(e.color[1], e.color[2], e.color[3])
    f.textoVida:SetShown(self:Activo(f, "textoVida"))

    -- Nivel
    e = E.nivel
    Fuente(f.nivel, e)
    ColocarTexto(f.nivel, f, e)
    f.nivel:SetShown(self:Activo(f, "nivel"))

    -- Hermandad (texto)
    e = E.hermandad
    Fuente(f.hermandad, e)
    ColocarTexto(f.hermandad, f, e)
    f.hermandad:SetTextColor(e.color[1], e.color[2], e.color[3])

    -- Lanzamiento
    e = E.lanzamiento
    local c = f.cast
    Centro(c, f, e)
    c:SetSize(e.ancho, e.alto)
    tex = self:Textura(e.textura)
    c:SetStatusBarTexture(tex)
    c.fondo:SetTexture(tex)
    c.fondo:SetVertexColor(0.05, 0.05, 0.05, 0.8)
    local grosor = HHP.BORDES[e.borde] or 0
    AplicarBorde(c.borde, c, grosor, e.colorBorde)
    c.icono:ClearAllPoints()
    c.icono:SetSize(e.tamIcono, e.tamIcono)
    c.icono:SetPoint("RIGHT", c, "LEFT", -2 - grosor, 0)
    c.icono:SetShown(e.icono)
    local fuenteCast = { fuente = E.nombre.fuente, tam = e.tamTexto, contorno = "OUTLINE" }
    Fuente(c.texto, fuenteCast)
    Fuente(c.tiempo, fuenteCast)
    c.texto:ClearAllPoints()
    c.texto:SetPoint("LEFT", c, "LEFT", 3, 0)
    c.texto:SetWidth(max(10, e.ancho - (e.tiempo and 30 or 6)))
    c.texto:SetJustifyH("LEFT")
    c.texto:SetShown(e.textoHechizo)
    c.tiempo:ClearAllPoints()
    c.tiempo:SetPoint("RIGHT", c, "RIGHT", -3, 0)
    c.tiempo:SetShown(e.tiempo)
    c.mostrarTiempo = e.tiempo
    if not self:Activo(f, "lanzamiento") then c:Hide() end

    -- Debuffs
    Centro(f.auras, f, E.auras)

    -- Marca de banda, élite y logo
    e = E.marcaBanda
    Centro(f.marca, f, e)
    f.marca:SetSize(e.tam, e.tam)
    e = E.elite
    Centro(f.elite, f, e)
    f.elite:SetSize(e.tam, e.tam)
    e = E.logo
    Centro(f.logo, f, e)
    f.logo:SetSize(e.tam, e.tam)

    -- Misión
    e = E.mision
    local m = f.mision
    Centro(m, f, e)
    m:SetSize(e.tam, e.tam)
    Fuente(m.texto, { fuente = E.nombre.fuente, tam = e.tamTexto, contorno = "OUTLINE" })
    m.texto:SetTextColor(e.color[1], e.color[2], e.color[3])
    m.texto:ClearAllPoints()
    if e.lado == "derecha" then
        m.texto:SetPoint("LEFT", m, "RIGHT", 2, 0)
    elseif e.lado == "arriba" then
        m.texto:SetPoint("BOTTOM", m, "TOP", 0, 1)
    elseif e.lado == "abajo" then
        m.texto:SetPoint("TOP", m, "BOTTOM", 0, -1)
    else
        m.texto:SetPoint("RIGHT", m, "LEFT", -2, 0)
    end

    self:AplicarResaltadoDiseno(f)
end

---------------------------------------------------------------
-- Colores
---------------------------------------------------------------
function HHP:ColorClase(f, unit)
    local clase
    if f.sim then
        clase = f.sim.clase
    else
        local _, c = UnitClass(unit)
        clase = Limpio(c, nil)
    end
    if clase then
        local c = (C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(clase))
            or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[clase])
        if c then return c.r, c.g, c.b end
    end
end

function HHP:ColorReaccion(f, unit)
    local reac, tapeado
    if f.sim then
        reac, tapeado = f.sim.reaccion, f.sim.tapeado
    else
        tapeado = Limpio(UnitIsTapDenied(unit), false)
        reac = Limpio(UnitReaction(unit, "player"), nil)
    end
    local c
    if tapeado then
        c = COLORES.gris
    elseif f.esJugador and f.esAliado then
        c = COLORES.jugadorAmigo
    elseif reac then
        if reac <= 3 then c = COLORES.hostil
        elseif reac == 4 then c = COLORES.neutral
        else c = COLORES.amistoso end
    else
        c = f.atacable and COLORES.hostil or COLORES.amistoso
    end
    return c[1], c[2], c[3]
end

function HHP:ColorVida(f, unit)
    local e = f.diseno.elementos.vida
    if e.modoColor == "personal" then
        return e.color[1], e.color[2], e.color[3]
    end
    if e.amenaza and not f.sim and not f.esAliado then
        local s = Limpio(UnitThreatSituation("player", unit), nil)
        if s == 3 then
            return COLORES.aggro[1], COLORES.aggro[2], COLORES.aggro[3]
        elseif s == 1 or s == 2 then
            return COLORES.casiAggro[1], COLORES.casiAggro[2], COLORES.casiAggro[3]
        end
    end
    if e.modoColor == "clase" and f.esJugador then
        local r, g, b = self:ColorClase(f, unit)
        if r then return r, g, b end
    end
    return self:ColorReaccion(f, unit)
end

function HHP:ActualizarColorVida(f, unit)
    local r, g, b = self:ColorVida(f, unit)
    f.vida:SetStatusBarColor(r, g, b)
    f.vida.fondo:SetVertexColor(r * 0.2, g * 0.2, b * 0.2, f.diseno.elementos.vida.fondo)
end

---------------------------------------------------------------
-- Nombre, vida, nivel
---------------------------------------------------------------
function HHP:ActualizarNombre(f, unit)
    if not self:Activo(f, "nombre") then return end
    local fs = f.nombre
    local e = f.diseno.elementos.nombre
    if f.sim then
        fs:SetText(f.sim.nombre or "")
    else
        -- En Forever UnitName devuelve nombre y apellido por separado
        local nombre, apellido = UnitName(unit)
        if f.esJugador and e.apellido and Existe(apellido) then
            if Secreto(nombre) or Secreto(apellido) then
                local completo = GetUnitName and GetUnitName(unit, true)
                if Existe(completo) then nombre = completo end
            elseif apellido ~= "" then
                nombre = nombre .. " " .. apellido
            end
        end
        if Existe(nombre) then fs:SetText(nombre) else fs:SetText("") end
    end

    local r, g, b = 1, 1, 1
    if e.modoColor == "personal" then
        r, g, b = e.color[1], e.color[2], e.color[3]
    elseif e.modoColor == "clase" then
        if f.esJugador then
            local cr, cg, cb = self:ColorClase(f, unit)
            if cr then r, g, b = cr, cg, cb end
        else
            r, g, b = self:ColorReaccion(f, unit)
        end
    elseif e.modoColor == "reaccion" then
        r, g, b = self:ColorReaccion(f, unit)
    end
    fs:SetTextColor(r, g, b)
    self:AjustarAnclaNombre(f)
end

-- Ajusta el marco invisible al ancho real del nombre (sin pasar el ancho máximo)
function HHP:AjustarAnclaNombre(f)
    local fs, a = f.nombre, f.anclaNombre
    local e = f.diseno.elementos.nombre
    local maximo = (e.anchoMax and e.anchoMax > 0) and e.anchoMax or nil
    local ok, ancho, alto = pcall(function()
        local w = fs.GetUnboundedStringWidth and fs:GetUnboundedStringWidth() or fs:GetStringWidth()
        local h = fs:GetStringHeight()
        if maximo and w > maximo then w = maximo end
        return w, h
    end)
    if not ok or type(ancho) ~= "number" or ancho <= 0 then
        ancho = maximo or 100   -- texto secreto en combate: usamos el ancho máximo
    end
    if not ok or type(alto) ~= "number" or alto <= 0 then alto = e.tam or 11 end
    local j = e.justificar or "CENTER"
    a:ClearAllPoints()
    a:SetPoint(j, f, "CENTER", e.x, e.y)
    a:SetSize(ancho, alto)
end

local function Abreviar(n)
    if n >= 1e6 then
        return string.format("%.1fM", n / 1e6)
    elseif n >= 1e4 then
        return string.format("%.0fK", n / 1e3)
    elseif n >= 1e3 then
        return string.format("%.1fK", n / 1e3)
    end
    return tostring(floor(n))
end

function HHP:ActualizarTextoVida(f, unit, actual, maximo)
    if not self:Activo(f, "textoVida") then return end
    local fs = f.textoVida
    local e = f.diseno.elementos.textoVida
    local formato = e.formato

    if not Secreto(actual) and not Secreto(maximo) then
        actual, maximo = actual or 0, maximo or 0
        local pct = maximo > 0 and (actual / maximo * 100) or 0
        if e.ocultarLleno and actual >= maximo then
            fs:SetText("")
        elseif formato == "valor" then
            fs:SetText(Abreviar(actual))
        elseif formato == "ambos" then
            fs:SetFormattedText("%s - %d%%", Abreviar(actual), floor(pct + 0.5))
        elseif formato == "actualMax" then
            fs:SetFormattedText("%s / %s", Abreviar(actual), Abreviar(maximo))
        elseif formato == "faltante" then
            if actual < maximo then fs:SetText("-" .. Abreviar(maximo - actual)) else fs:SetText("") end
        else
            fs:SetFormattedText("%d%%", floor(pct + 0.5))
        end
        return
    end

    -- Valores secretos (en combate): lo que el juego permita mostrar
    local ok = false
    if (formato == "porcentaje" or formato == "ambos") and UnitHealthPercent then
        ok = pcall(function()
            local curva = CurveConstants and CurveConstants.ScaleTo100
            local pct = UnitHealthPercent(unit, true, curva)
            if formato == "ambos" and AbbreviateNumbers then
                fs:SetFormattedText("%s - %.0f%%", AbbreviateNumbers(actual), pct)
            else
                fs:SetFormattedText("%.0f%%", pct)
            end
        end)
    end
    if not ok and AbbreviateNumbers then
        ok = pcall(function() fs:SetText(AbbreviateNumbers(actual)) end)
    end
    if not ok then fs:SetText("") end
end

function HHP:ActualizarVida(f, unit)
    local actual, maximo
    if f.sim then
        maximo = f.sim.max
        actual = floor(maximo * f.sim.vida)
    else
        actual, maximo = UnitHealth(unit), UnitHealthMax(unit)
    end
    f.vida:SetMinMaxValues(0, maximo)
    f.vida:SetValue(actual)
    self:ActualizarTextoVida(f, unit, actual, maximo)
end

local function ColorNivel(nivel)
    if GetCreatureDifficultyColor then
        local c = GetCreatureDifficultyColor(nivel)
        if c then return c.r, c.g, c.b end
    end
    if GetQuestDifficultyColor then
        local c = GetQuestDifficultyColor(nivel)
        if c then return c.r, c.g, c.b end
    end
    return 1, 0.82, 0
end

local function Clasificacion(f, unit)
    if f.sim then return f.sim.clasif or "normal" end
    return Limpio(UnitClassification(unit), "normal") or "normal"
end

function HHP:ActualizarNivel(f, unit)
    local fs = f.nivel
    if not self:Activo(f, "nivel") then fs:Hide() return end
    local nivel
    if f.sim then nivel = f.sim.nivel else nivel = Limpio(UnitLevel(unit), 0) end
    nivel = nivel or 0
    local clasif = Clasificacion(f, unit)
    local texto
    if nivel <= 0 then
        texto = "??"
        fs:SetTextColor(1, 0.15, 0.15)
    else
        texto = tostring(nivel)
        fs:SetTextColor(ColorNivel(nivel))
    end
    if clasif == "elite" or clasif == "rareelite" then texto = texto .. "+" end
    fs:SetText(texto)
    fs:Show()
end

---------------------------------------------------------------
-- Élite / raro y marca de banda
---------------------------------------------------------------
local function PonerAtlas(tex, atlas, respaldo)
    if tex.SetAtlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        tex:SetAtlas(atlas, false)
        tex:SetTexCoord(0, 1, 0, 1)
        return true
    end
    tex:SetTexture(respaldo)
    tex:SetTexCoord(0, 1, 0, 1)
    return false
end

function HHP:ActualizarElite(f, unit)
    local t, borde = f.elite, f.eliteBorde
    local clasif = Clasificacion(f, unit)
    borde:Hide()
    if not self:Activo(f, "elite") or not (clasif == "elite" or clasif == "rare" or clasif == "rareelite" or clasif == "worldboss") then
        t:Hide()
        return
    end
    local e = f.diseno.elementos.elite
    local color
    if clasif == "worldboss" then
        t:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
        t:SetTexCoord(0, 1, 0, 1)
        color = e.colorJefe
    elseif clasif == "rare" or clasif == "rareelite" then
        if not PonerAtlas(t, "nameplates-icon-elite-silver", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1") then
            t:SetDesaturated(true)
        else
            t:SetDesaturated(false)
        end
        color = (clasif == "rareelite") and e.colorRaroElite or e.colorRaro
    else
        PonerAtlas(t, "nameplates-icon-elite-gold", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
        t:SetDesaturated(false)
        color = e.colorElite
    end
    if clasif ~= "rare" and clasif ~= "rareelite" then t:SetDesaturated(false) end
    t:SetVertexColor(color[1], color[2], color[3])
    t:SetSize(e.tam, e.tam)
    t:Show()

    -- Raro élite: el mismo icono plateado con un contorno dorado detrás
    if clasif == "rareelite" and e.bordeRaroElite then
        PonerAtlas(borde, "nameplates-icon-elite-gold", "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
        borde:SetDesaturated(true)
        borde:SetVertexColor(e.colorBorde[1], e.colorBorde[2], e.colorBorde[3])
        borde:ClearAllPoints()
        borde:SetPoint("CENTER", t, "CENTER", 0, 0)
        borde:SetSize(e.tam * 1.4, e.tam * 1.4)
        borde:Show()
    end
end

function HHP:ActualizarMarca(f, unit)
    local idx
    if f.sim then
        idx = f.sim.marca
    else
        idx = Limpio(GetRaidTargetIndex(unit), nil)
    end
    if self:Activo(f, "marcaBanda") and idx and idx > 0 then
        SetRaidTargetIconTexture(f.marca, idx)
        f.marca:Show()
    else
        f.marca:Hide()
    end
end

---------------------------------------------------------------
-- Lanzamiento de hechizos
---------------------------------------------------------------
local function CastOnUpdate(c)
    local ahora = GetTime()
    if c.modo == "tiempo" then
        local total = c.fin - c.ini
        local pasado = ahora - c.ini
        if pasado > total + 0.5 then
            -- Seguridad por si se perdió el evento de fin
            c:SetScript("OnUpdate", nil)
            c:Hide()
            return
        end
        if pasado > total then pasado = total end
        c:SetValue(c.canal and (total - pasado) or pasado)
        if c.mostrarTiempo then c.tiempo:SetFormattedText("%.1f", total - pasado) end
    elseif c.modo == "duracion" then
        if c.mostrarTiempo and c.dur and not c.sinTiempo then
            local ok = pcall(function() c.tiempo:SetFormattedText("%.1f", c.dur:GetRemainingDuration()) end)
            if not ok then
                c.sinTiempo = true
                c.tiempo:SetText("")
            end
        end
    elseif c.modo == "sim" then
        local t = ahora % 2.5
        c:SetValue(t)
        if c.mostrarTiempo then c.tiempo:SetFormattedText("%.1f", 2.5 - t) end
    end
end

function HHP:ColorLanzamiento(f, noInterrumpible)
    local e = f.diseno.elementos.lanzamiento
    local c = f.cast
    if Secreto(noInterrumpible) then
        c:SetStatusBarColor(e.color[1], e.color[2], e.color[3])
        pcall(function()
            local tex = c:GetStatusBarTexture()
            local ni, n = e.colorNoInterrumpible, e.color
            tex:SetVertexColorFromBoolean(noInterrumpible, CreateColor(ni[1], ni[2], ni[3], 1), CreateColor(n[1], n[2], n[3], 1))
        end)
        c.icono:SetDesaturated(false)
    else
        local col = noInterrumpible and e.colorNoInterrumpible or e.color
        c:SetStatusBarColor(col[1], col[2], col[3])
        c.icono:SetDesaturated(noInterrumpible and true or false)
    end
end

function HHP:OcultarLanzamiento(f)
    local c = f.cast
    c.desvaneciendo = nil
    c.modo = nil
    c:SetScript("OnUpdate", nil)
    c:Hide()
end

function HHP:ActualizarLanzamiento(f, unit)
    local c = f.cast
    if not self:Activo(f, "lanzamiento") then
        self:OcultarLanzamiento(f)
        return
    end

    if f.sim then
        if f.sim.lanzando then
            c.desvaneciendo = nil
            c.modo = "sim"
            c.canal = false
            c.texto:SetText("Bola de Fuego")
            c.icono:SetTexture("Interface\\Icons\\Spell_Fire_FlameBolt")
            c:SetMinMaxValues(0, 2.5)
            self:ColorLanzamiento(f, f.sim.noInterrumpible and true or false)
            c:SetScript("OnUpdate", CastOnUpdate)
            c:Show()
        else
            self:OcultarLanzamiento(f)
        end
        return
    end

    local canal = false
    local nombre, _, textura, ini, fin, _, _, noInt = UnitCastingInfo(unit)
    if not Existe(nombre) then
        nombre, _, textura, ini, fin, _, noInt = UnitChannelInfo(unit)
        canal = true
    end
    if not Existe(nombre) then
        if not c.desvaneciendo then self:OcultarLanzamiento(f) end
        return
    end

    c.desvaneciendo = nil
    c.canal = canal
    c.sinTiempo = nil
    c.texto:SetText(nombre)
    c.icono:SetTexture(textura)
    self:ColorLanzamiento(f, noInt)

    if not Secreto(ini) and not Secreto(fin) and ini and fin then
        c.modo = "tiempo"
        c.ini, c.fin = ini / 1000, fin / 1000
        c:SetMinMaxValues(0, max(0.01, c.fin - c.ini))
    else
        c.modo = "duracion"
        c.dur = nil
        local ok = pcall(function()
            local dur
            if canal then dur = UnitChannelDuration(unit) else dur = UnitCastingDuration(unit) end
            local dir
            if Enum and Enum.StatusBarTimerDirection then
                dir = canal and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime
            end
            c:SetTimerDuration(dur, nil, dir)
            c.dur = dur
        end)
        if not ok then
            c:SetMinMaxValues(0, 1)
            c:SetValue(1)
            c.tiempo:SetText("")
        end
    end
    c:SetScript("OnUpdate", CastOnUpdate)
    c:SetAlpha(1)
    c:Show()
end

function HHP:LanzamientoInterrumpido(f)
    local c = f.cast
    if not c:IsShown() then return end
    c:SetScript("OnUpdate", nil)
    c.modo = nil
    c:SetMinMaxValues(0, 1)
    c:SetValue(1)
    c:SetStatusBarColor(0.9, 0.1, 0.1)
    c.texto:SetText("Interrumpido")
    c.tiempo:SetText("")
    c.desvaneciendo = true
    C_Timer.After(0.7, function()
        if c.desvaneciendo then
            c.desvaneciendo = nil
            c:Hide()
        end
    end)
end

---------------------------------------------------------------
-- Objetivo actual: resaltado y transparencia del resto
---------------------------------------------------------------
function HHP:EsObjetivo(f)
    if f.sim then return f.sim.objetivo and true or false end
    local p = C_NamePlate.GetNamePlateForUnit("target")
    return p ~= nil and p == f.plate
end

function HHP:ActualizarObjetivo(f)
    local e = f.diseno.elementos.objetivo
    local r = f.resaltado
    local es = self:EsObjetivo(f)
    local mostrar = es and e.mostrar
    local estilo = r.estilo
    for i = 1, 4 do r.brillo[i]:SetShown(mostrar and estilo == "Brillo") end
    for i = 1, 4 do r.borde[i]:SetShown(mostrar and estilo == "Borde") end
    r.flechaI:SetShown(mostrar and estilo == "Flechas")
    r.flechaD:SetShown(mostrar and estilo == "Flechas")
    r.linea:SetShown(mostrar and estilo == "Subrayado")

    local alfa = 1
    if not f.sim and not es and UnitExists("target") then
        alfa = self.db.general.alfaSinObjetivo
    end
    f:SetAlpha(alfa)
end

---------------------------------------------------------------
-- Actualización completa
---------------------------------------------------------------
function HHP:ActualizarTodo(f, unit)
    self:Seguro("estado", self.EstadoUnidad, self, f, unit)
    self:Seguro("diseño", self.AplicarDiseno, self, f)
    self:Seguro("nombre", self.ActualizarNombre, self, f, unit)
    self:Seguro("color", self.ActualizarColorVida, self, f, unit)
    self:Seguro("vida", self.ActualizarVida, self, f, unit)
    self:Seguro("nivel", self.ActualizarNivel, self, f, unit)
    self:Seguro("élite", self.ActualizarElite, self, f, unit)
    self:Seguro("marca", self.ActualizarMarca, self, f, unit)
    self:Seguro("hermandad", self.ActualizarHermandad, self, f, unit)
    self:Seguro("misión", self.ActualizarMision, self, f, unit)
    self:Seguro("auras", self.ActualizarAuras, self, f, unit)
    self:Seguro("lanzamiento", self.ActualizarLanzamiento, self, f, unit)
    self:Seguro("objetivo", self.ActualizarObjetivo, self, f)
end

---------------------------------------------------------------
-- Placas del juego
---------------------------------------------------------------
local activas = {}                                    -- unidad -> raíz
local porPlaca = {}                                   -- placa -> raíz
local ocultas = setmetatable({}, { __mode = "k" })    -- UnitFrames de Blizzard ocultos
local enganchados = setmetatable({}, { __mode = "k" })
HHP.activas = activas

local function OcultarBlizzard(placa)
    local uf = placa.UnitFrame
    if not uf then return end
    if not enganchados[uf] then
        enganchados[uf] = true
        local ocupado = false
        hooksecurefunc(uf, "SetAlpha", function(self, a)
            if ocultas[self] and not ocupado and (Secreto(a) or a ~= 0) then
                ocupado = true
                self:SetAlpha(0)
                ocupado = false
            end
        end)
    end
    ocultas[uf] = true
    uf:SetAlpha(0)
end

local function RestaurarBlizzard(placa)
    local uf = placa.UnitFrame
    if uf and ocultas[uf] then
        ocultas[uf] = nil
        uf:SetAlpha(1)
    end
end

function HHP:PlacaAgregada(unit)
    local placa = C_NamePlate.GetNamePlateForUnit(unit)
    if not placa then return end   -- placa protegida (aliados dentro de instancias)
    if not self.db.general.activo then return end
    if Limpio(UnitIsUnit(unit, "player"), false) then return end   -- barra personal

    local f = porPlaca[placa]
    if not f then
        f = self:CrearRaiz(placa)
        f.plate = placa
        porPlaca[placa] = f
    end
    f.unit = unit
    activas[unit] = f
    OcultarBlizzard(placa)
    self:ActualizarTodo(f, unit)
    f:Show()
end

function HHP:PlacaQuitada(unit)
    local f = activas[unit]
    if not f then return end
    activas[unit] = nil
    f.unit = nil
    self:OcultarLanzamiento(f)
    -- La placa se recicla: que no arrastre los debuffs de la unidad anterior
    for _, a in ipairs(f.auras.iconos) do a:Hide() end
    f.auras:Hide()
    f:Hide()
end

function HHP:ReconstruirTodas()
    for unit in pairs(activas) do self:PlacaQuitada(unit) end
    for _, placa in ipairs(C_NamePlate.GetNamePlates()) do
        if self.db.general.activo then
            local unit = placa.namePlateUnitToken
            if unit then self:PlacaAgregada(unit) end
        else
            RestaurarBlizzard(placa)
        end
    end
end

function HHP:RefrescarDatos()
    for unit, f in pairs(activas) do self:ActualizarTodo(f, unit) end
end

-- Llamar cuando cambia el diseño: la vista previa al instante y las
-- placas reales agrupadas para no recalcular en cada píxel de arrastre.
local refrescoPendiente = false
function HHP:DisenoCambiado()
    if self.Disenador and self.Disenador.RefrescarPrevia then
        self.Disenador:RefrescarPrevia()
    end
    if refrescoPendiente then return end
    refrescoPendiente = true
    C_Timer.After(0.15, function()
        refrescoPendiente = false
        HHP:RefrescarDatos()
    end)
end

---------------------------------------------------------------
-- Eventos
---------------------------------------------------------------
local POR_UNIDAD = {
    UNIT_HEALTH = function(f, u) HHP:ActualizarVida(f, u) end,
    UNIT_MAXHEALTH = function(f, u) HHP:ActualizarVida(f, u) end,
    UNIT_NAME_UPDATE = function(f, u)
        -- La hermandad puede llegar tarde y cambiar el tipo de placa
        local antes = f.categoria
        HHP:EstadoUnidad(f, u)
        if f.categoria ~= antes then
            HHP:ActualizarTodo(f, u)
        else
            HHP:ActualizarNombre(f, u)
            HHP:ActualizarHermandad(f, u)
        end
    end,
    UNIT_FACTION = function(f, u) HHP:ActualizarTodo(f, u) end,
    UNIT_LEVEL = function(f, u) HHP:ActualizarNivel(f, u) end,
    UNIT_CLASSIFICATION_CHANGED = function(f, u) HHP:ActualizarTodo(f, u) end,
    UNIT_THREAT_LIST_UPDATE = function(f, u) HHP:ActualizarColorVida(f, u) end,
    UNIT_THREAT_SITUATION_UPDATE = function(f, u) HHP:ActualizarColorVida(f, u) end,
    UNIT_AURA = function(f, u) HHP:ActualizarAuras(f, u) end,
    UNIT_SPELLCAST_START = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_DELAYED = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_CHANNEL_START = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_CHANNEL_UPDATE = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_EMPOWER_START = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_EMPOWER_UPDATE = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_STOP = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_FAILED = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_CHANNEL_STOP = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_EMPOWER_STOP = function(f, u) HHP:ActualizarLanzamiento(f, u) end,
    UNIT_SPELLCAST_INTERRUPTED = function(f) HHP:LanzamientoInterrumpido(f) end,
    UNIT_SPELLCAST_INTERRUPTIBLE = function(f) HHP:ColorLanzamiento(f, false) end,
    UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(f) HHP:ColorLanzamiento(f, true) end,
}

local function ParaTodas(origen, fn)
    for unit, f in pairs(activas) do HHP:Seguro(origen, fn, f, unit) end
end

local GLOBALES = {
    NAME_PLATE_UNIT_ADDED = function(unit) HHP:PlacaAgregada(unit) end,
    NAME_PLATE_UNIT_REMOVED = function(unit) HHP:PlacaQuitada(unit) end,
    PLAYER_TARGET_CHANGED = function()
        ParaTodas("objetivo", function(f) HHP:ActualizarObjetivo(f) end)
    end,
    RAID_TARGET_UPDATE = function()
        ParaTodas("marca", function(f, u) HHP:ActualizarMarca(f, u) end)
    end,
    PLAYER_REGEN_ENABLED = function()
        -- Al salir de combate los datos dejan de ser secretos: refrescamos todo
        HHP:RefrescarDatos()
    end,
    PLAYER_GUILD_UPDATE = function() HHP:RefrescarDatos() end,
    QUEST_LOG_UPDATE = function() HHP:MisionesCambiaron() end,
    UNIT_QUEST_LOG_CHANGED = function() HHP:MisionesCambiaron() end,
    QUEST_ACCEPTED = function() HHP:MisionesCambiaron() end,
    QUEST_REMOVED = function() HHP:MisionesCambiaron() end,
}

function HHP:IniciarPlacas()
    local ev = CreateFrame("Frame")
    for evento in pairs(GLOBALES) do pcall(ev.RegisterEvent, ev, evento) end
    for evento in pairs(POR_UNIDAD) do pcall(ev.RegisterEvent, ev, evento) end
    ev:SetScript("OnEvent", function(_, evento, unit, ...)
        local g = GLOBALES[evento]
        if g then
            HHP:Seguro(evento, g, unit, ...)
            return
        end
        local f = unit and activas[unit]
        if f then
            HHP:Seguro(evento, POR_UNIDAD[evento], f, unit)
        end
    end)
    self:LeerMisiones()
    self:ReconstruirTodas()
end
