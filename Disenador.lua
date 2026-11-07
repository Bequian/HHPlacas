-- HH Placas - Diseñador visual
-- Vista previa con elementos arrastrables, panel de propiedades,
-- opciones generales y gestor de estilos (guardar, importar, exportar).

local _, HHP = ...
local UI = HHP.UI
local C = UI.C

local D = { paneles = {}, filas = {}, overlays = {}, tipo = "mob", zoom = 2 }
HHP.Disenador = D

D.flags = { lanzando = true, noInterrumpible = false, objetivo = true, conMision = true, conAuras = true, conMarca = false, raro = false }

local floor = math.floor

---------------------------------------------------------------
-- Elementos y sus propiedades
---------------------------------------------------------------
local ORDEN = { "vida", "nombre", "textoVida", "nivel", "lanzamiento", "auras", "objetivo", "marcaBanda", "elite", "mision", "logo", "hermandad" }

local NOMBRES = {
    vida = "Barra de vida",
    nombre = "Nombre",
    textoVida = "Texto de vida",
    nivel = "Nivel",
    lanzamiento = "Barra de lanzamiento",
    auras = "Debuffs",
    objetivo = "Resaltado de objetivo",
    marcaBanda = "Marca de banda",
    elite = "Icono tipo Mob",
    mision = "Misión (HH Misiones)",
    logo = "Logo Hermandad",
    hermandad = "Hermandad / título",
}

local DESC = {
    vida = "La barra principal. Elige textura, borde y cómo se colorea.",
    nombre = "Nombre de la unidad. Colorealo por clase, reacción o con tu propio color.",
    textoVida = "Porcentaje o valor de vida dibujado sobre la barra.",
    nivel = "Nivel coloreado por dificultad. '??' para jefes, '+' para élites.",
    lanzamiento = "Hechizo que está lanzando la unidad. Se pone gris si no se puede interrumpir.",
    auras = "Tus debuffs sobre la unidad, con su tiempo restante.",
    objetivo = "Cómo se marca la placa de tu objetivo actual.",
    marcaBanda = "Calavera, cruz, estrella... las marcas de banda.",
    elite = "Icono para élites (dorado), raros (plateado) y jefes (calavera).",
    mision = "Icono y progreso para mobs de misión: calavera = matar, bolsa = objeto.",
    logo = "Logo de tu hermandad sobre la placa de sus miembros.",
    hermandad = "Muestra <Hermandad> en jugadores y el título en NPC (<Suministros generales>).",
}

local OPC_TEXTURAS = function() return HHP:ListaTexturas() end
local OPC_FUENTES = function() return HHP:ListaFuentes() end

local TEXTO = function(rx, ry)
    return {
        { "mostrar", "check", "Mostrar" },
        { "x", "slider", "Posición X", -rx, rx, 1 },
        { "y", "slider", "Posición Y", -ry, ry, 1 },
        { "fuente", "lista", "Fuente", OPC_FUENTES },
        { "tam", "slider", "Tamaño de letra", 6, 30, 1 },
        { "contorno", "lista", "Contorno", HHP.CONTORNOS },
        { "justificar", "lista", "Alineación", HHP.JUSTIFICADO },
    }
end

local function Mas(t, ...)
    for i = 1, select("#", ...) do t[#t + 1] = (select(i, ...)) end
    return t
end

local ESQUEMA = {
    vida = {
        { "mostrar", "check", "Mostrar" },
        { "ancho", "slider", "Ancho", 40, 300, 1 },
        { "alto", "slider", "Alto", 2, 40, 1 },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "textura", "lista", "Textura", OPC_TEXTURAS },
        { "borde", "lista", "Borde", HHP.LISTA_BORDES },
        { "colorBorde", "color", "Color del borde" },
        { "fondo", "slider", "Opacidad del fondo", 0, 1, 0.05 },
        { "modoColor", "lista", "Color de la barra", {
            { "clase", "Clase (jugadores) / reacción" },
            { "reaccion", "Reacción (hostil, neutral, amistoso)" },
            { "personal", "Color personalizado" },
        } },
        { "color", "color", "Color personalizado" },
        { "amenaza", "check", "Avisar con color si tienes aggro", "Rosa: tienes el aggro. Naranja: estás por quitarlo o perderlo. Puede no funcionar en combate en Forever." },
    },
    nombre = Mas(TEXTO(150, 100),
        { "apellido", "check", "Mostrar apellido de los jugadores" },
        { "anchoMax", "slider", "Ancho máximo (0 = sin límite)", 0, 300, 5 },
        { "modoColor", "lista", "Color", {
            { "blanco", "Blanco" },
            { "clase", "Clase / reacción" },
            { "reaccion", "Reacción" },
            { "personal", "Personalizado" },
        } },
        { "color", "color", "Color personalizado" }),
    textoVida = Mas(TEXTO(150, 100),
        { "formato", "lista", "Formato", {
            { "porcentaje", "Porcentaje (65%)" },
            { "valor", "Valor (1.2K)" },
            { "ambos", "Valor y porcentaje" },
            { "actualMax", "Actual / máximo" },
            { "faltante", "Vida que falta (-430)" },
        } },
        { "ocultarLleno", "check", "Ocultar con la vida completa" },
        { "color", "color", "Color" }),
    nivel = TEXTO(150, 100),
    lanzamiento = {
        { "mostrar", "check", "Mostrar" },
        { "ancho", "slider", "Ancho", 40, 300, 1 },
        { "alto", "slider", "Alto", 2, 30, 1 },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "textura", "lista", "Textura", OPC_TEXTURAS },
        { "borde", "lista", "Borde", HHP.LISTA_BORDES },
        { "colorBorde", "color", "Color del borde" },
        { "color", "color", "Color (interrumpible)" },
        { "colorNoInterrumpible", "color", "Color (no interrumpible)" },
        { "icono", "check", "Mostrar icono del hechizo" },
        { "tamIcono", "slider", "Tamaño del icono", 8, 40, 1 },
        { "textoHechizo", "check", "Mostrar nombre del hechizo" },
        { "tiempo", "check", "Mostrar tiempo restante" },
        { "tamTexto", "slider", "Tamaño de letra", 6, 20, 1 },
    },
    auras = {
        { "mostrar", "check", "Mostrar" },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "tam", "slider", "Tamaño de icono", 10, 40, 1 },
        { "espacio", "slider", "Separación", 0, 10, 1 },
        { "max", "slider", "Máximo de iconos", 1, 10, 1 },
        { "soloMias", "check", "Solo mis debuffs" },
    },
    objetivo = {
        { "mostrar", "check", "Mostrar" },
        { "estilo", "lista", "Estilo", { "Brillo", "Borde", "Flechas", "Subrayado" } },
        { "ancla", "lista", "Rodear a", {
            { "auto", "Automático (barra si se muestra, si no el nombre)" },
            { "vida", "Barra de vida" },
            { "nombre", "Nombre (se ajusta a su ancho)" },
        } },
        { "separacion", "slider", "Separación", 0, 20, 1 },
        { "color", "color", "Color" },
    },
    marcaBanda = {
        { "mostrar", "check", "Mostrar" },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "tam", "slider", "Tamaño", 8, 48, 1 },
    },
    elite = {
        { "mostrar", "check", "Mostrar" },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "tam", "slider", "Tamaño", 8, 40, 1 },
        { "colorElite", "color", "Color: élite (dorado)" },
        { "colorRaro", "color", "Color: raro (plateado)" },
        { "colorRaroElite", "color", "Color: raro élite" },
        { "colorJefe", "color", "Color: jefe (calavera)" },
        { "bordeRaroElite", "check", "Raro élite: contorno detrás del icono" },
        { "colorBorde", "color", "Color del contorno del raro élite" },
    },
    mision = {
        { "mostrar", "check", "Mostrar" },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "tam", "slider", "Tamaño del icono", 8, 40, 1 },
        { "contador", "check", "Mostrar contador (3/8)" },
        { "lado", "lista", "Lado del contador", {
            { "izquierda", "Izquierda" }, { "derecha", "Derecha" }, { "arriba", "Arriba" }, { "abajo", "Abajo" },
        } },
        { "tamTexto", "slider", "Tamaño del contador", 6, 24, 1 },
        { "color", "color", "Color del contador" },
    },
    logo = {
        { "mostrar", "check", "Mostrar" },
        { "x", "slider", "Posición X", -150, 150, 1 },
        { "y", "slider", "Posición Y", -100, 100, 1 },
        { "tam", "slider", "Tamaño", 8, 64, 1 },
    },
    hermandad = Mas(TEXTO(150, 100),
        { "tituloNPC", "check", "En NPC: mostrar su título (<Suministros generales>)" },
        { "color", "color", "Color" }),
}

---------------------------------------------------------------
-- Unidades de prueba para la vista previa
---------------------------------------------------------------
local SIMS = {
    mob = { nombre = "Matón Defias", nivel = 14, clasif = "normal", reaccion = 2, vida = 0.62, max = 1350, atacable = true },
    elite = { nombre = "Capataz Gorroñoso", nivel = 18, clasif = "elite", reaccion = 2, vida = 0.8, max = 5200, atacable = true },
    jefe = { nombre = "Edwin VanCleef", nivel = -1, clasif = "worldboss", reaccion = 2, vida = 0.35, max = 48000, atacable = true },
    npc = { nombre = "Sra. Winters", nivel = 20, clasif = "normal", reaccion = 5, vida = 1, max = 900, aliado = true, hermandad = "Suministros generales" },
    aliado = { nombre = "Norgannon Forever", nivel = 60, clasif = "normal", reaccion = 5, vida = 0.75, max = 3800, aliado = true, jugador = true, clase = "PRIEST", hermandad = "Los Vigilantes" },
    rival = { nombre = "Norgannon Forever", nivel = 60, clasif = "normal", reaccion = 2, vida = 0.5, max = 5100, atacable = true, jugador = true, clase = "SHAMAN", hermandad = "La Horda Eterna" },
    hermandad = { nombre = "Norgannon Forever", nivel = 60, clasif = "normal", reaccion = 5, vida = 0.9, max = 4200, aliado = true, jugador = true, clase = "PALADIN" },
}

local function ConstruirSim()
    local s = HHP.Copiar(SIMS[D.tipo])
    local fl = D.flags
    s.categoria = D.tipo
    if D.tipo == "hermandad" then s.hermandad = HHP.db.general.hermandad end
    s.lanzando = fl.lanzando
    s.noInterrumpible = fl.noInterrumpible
    s.objetivo = fl.objetivo
    s.mision = (fl.conMision and s.atacable and not s.jugador) and "3/8" or nil
    s.auras = fl.conAuras and s.atacable
    s.marca = fl.conMarca and 8 or nil
    if fl.raro then
        if s.clasif == "elite" then s.clasif = "rareelite"
        elseif s.clasif == "normal" then s.clasif = "rare" end
    end
    return s
end

---------------------------------------------------------------
-- Utilidades de construcción
---------------------------------------------------------------
local function Elemento(clave) return HHP.db.disenos[D.tipo].elementos[clave] end

local function Titulo(padre, texto)
    local fs = UI.Texto(padre, "GameFontNormal", texto)
    local l = UI.Linea(padre)
    l:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -3)
    l:SetWidth(400)
    fs.linea = l
    return fs
end

-- Apila controles verticalmente dentro de 'padre'
local function Pila(padre, x, y)
    local p = { padre = padre, x = x, y = y, controles = {} }
    function p:Agregar(ctrl, espacioExtra)
        ctrl:ClearAllPoints()
        ctrl:SetPoint("TOPLEFT", self.padre, "TOPLEFT", self.x, -self.y)
        self.y = self.y + (ctrl.alto or ctrl:GetHeight() or 20) + 4 + (espacioExtra or 0)
        if ctrl.Refrescar then table.insert(self.controles, ctrl) end
        return ctrl
    end
    function p:Titulo(texto)
        self.y = self.y + 6
        local t = Titulo(self.padre, texto)
        t:SetPoint("TOPLEFT", self.padre, "TOPLEFT", self.x, -self.y)
        self.y = self.y + 24
        return t
    end
    function p:Refrescar()
        for _, c in ipairs(self.controles) do c:Refrescar() end
    end
    return p
end

---------------------------------------------------------------
-- Panel de propiedades de un elemento
---------------------------------------------------------------
function D:Cambio(clave, campo)
    HHP:DisenoCambiado()
    if campo == "mostrar" then self:RefrescarLista() end
end

function D:CrearControl(padre, clave, def)
    local campo, tipo, etiqueta = def[1], def[2], def[3]
    local function obtener() return Elemento(clave)[campo] end
    local function poner(v)
        Elemento(clave)[campo] = v
        D:Cambio(clave, campo)
    end
    local ctrl
    if tipo == "check" then
        ctrl = UI.Check(padre, etiqueta, obtener, poner, def[4])
    elseif tipo == "slider" then
        ctrl = UI.Deslizador(padre, etiqueta, def[4], def[5], def[6], obtener, poner, 270)
    elseif tipo == "lista" then
        ctrl = UI.Lista(padre, etiqueta, def[4], obtener, poner, 270)
    elseif tipo == "color" then
        ctrl = UI.Color(padre, etiqueta, obtener, function(r, g, b, a)
            local t = { r, g, b }
            if a then t[4] = a end
            Elemento(clave)[campo] = t
            D:Cambio(clave, campo)
        end)
    end
    ctrl.campo = campo
    return ctrl
end

function D:Mover(clave, dx, dy)
    local e = Elemento(clave)
    if e.x == nil then return end
    e.x, e.y = e.x + dx, e.y + dy
    HHP:DisenoCambiado()
    self:RefrescarPosicion()
end

function D:Panel(clave)
    local p = self.paneles[clave]
    if p then return p end

    p = CreateFrame("Frame", nil, self.prop.hijo)
    p:SetPoint("TOPLEFT")
    p:SetSize(286, 10)
    local pila = Pila(p, 4, 4)

    for _, def in ipairs(ESQUEMA[clave]) do
        pila:Agregar(self:CrearControl(p, clave, def))
    end

    if Elemento(clave).x ~= nil then
        pila.y = pila.y + 6
        local et = UI.Texto(p, "GameFontNormalSmall", "Mover 1 píxel:")
        et:SetPoint("TOPLEFT", p, "TOPLEFT", 4, -pila.y - 4)
        local flechas = { { "<", -1, 0 }, { ">", 1, 0 }, { "Arriba", 0, 1 }, { "Abajo", 0, -1 } }
        local x = 96
        for _, f in ipairs(flechas) do
            local ancho = #f[1] > 1 and 50 or 24
            local b = UI.Boton(p, f[1], ancho, 20, function() D:Mover(clave, f[2], f[3]) end)
            b:SetPoint("TOPLEFT", p, "TOPLEFT", x, -pila.y)
            x = x + ancho + 4
        end
        pila.y = pila.y + 28
        local centrar = UI.Boton(p, "Centrar horizontalmente", 170, 20, function()
            Elemento(clave).x = 0
            HHP:DisenoCambiado()
            D:RefrescarPosicion()
        end)
        pila:Agregar(centrar)
    end

    p:SetHeight(pila.y + 10)
    p.pila = pila
    self.paneles[clave] = p
    return p
end

function D:RefrescarPosicion()
    local p = self.sel and self.paneles[self.sel]
    if not p then return end
    for _, c in ipairs(p.pila.controles) do
        if c.campo == "x" or c.campo == "y" then c:Refrescar() end
    end
end

function D:Seleccionar(clave)
    self.sel = clave
    for k, fila in pairs(self.filas) do fila:SetActivo(k == clave) end
    for k, p in pairs(self.paneles) do p:SetShown(k == clave) end
    local p = self:Panel(clave)
    p:Show()
    p.pila:Refrescar()
    self.prop.hijo:SetHeight(p:GetHeight())
    self.prop:SetVerticalScroll(0)
    self.propTitulo:SetText(NOMBRES[clave])
    self.propDesc:SetText(DESC[clave])
    self:ActualizarSeleccion()
end

---------------------------------------------------------------
-- Lista de elementos
---------------------------------------------------------------
function D:RefrescarLista()
    for clave, fila in pairs(self.filas) do
        local e = Elemento(clave)
        fila.check:SetChecked(e.mostrar)
        fila.texto:SetTextColor(e.mostrar and 1 or 0.5, e.mostrar and 1 or 0.5, e.mostrar and 1 or 0.5)
    end
end

function D:CrearLista(p)
    local marco = CreateFrame("Frame", nil, p, "BackdropTemplate")
    marco:SetPoint("TOPLEFT", 10, -8)
    marco:SetSize(172, 538)
    UI.Fondo(marco, C.panel)
    local t = UI.Texto(marco, "GameFontNormal", "Elementos")
    t:SetPoint("TOPLEFT", 8, -8)

    for i, clave in ipairs(ORDEN) do
        local fila = UI.Boton(marco, "", 160, 30, function() D:Seleccionar(clave) end)
        fila:SetPoint("TOPLEFT", 6, -28 - (i - 1) * 33)
        fila.texto:ClearAllPoints()
        fila.texto:SetPoint("LEFT", 30, 0)
        fila.texto:SetPoint("RIGHT", -4, 0)
        fila.texto:SetJustifyH("LEFT")
        fila.texto:SetText(NOMBRES[clave])

        local c = CreateFrame("CheckButton", nil, fila)
        c:SetSize(20, 20)
        c:SetPoint("LEFT", 5, 0)
        c:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        c:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
        c:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        c:SetScript("OnClick", function(s)
            Elemento(clave).mostrar = s:GetChecked() and true or false
            D:Cambio(clave, "mostrar")
            if D.sel == clave then D.paneles[clave].pila:Refrescar() end
        end)
        fila.check = c
        self.filas[clave] = fila
    end

    local ayuda = UI.Texto(marco, "GameFontDisableSmall", "La casilla muestra u oculta el elemento.")
    ayuda:SetPoint("BOTTOMLEFT", 8, 8)
    ayuda:SetPoint("BOTTOMRIGHT", -8, 8)
    ayuda:SetJustifyH("LEFT")
end

---------------------------------------------------------------
-- Vista previa con arrastre
---------------------------------------------------------------
local REGIONES = {
    vida = "vida", nombre = "nombre", textoVida = "textoVida", nivel = "nivel",
    lanzamiento = "cast", auras = "auras", marcaBanda = "marca", elite = "elite",
    mision = "mision", logo = "logo", hermandad = "hermandad",
}

function D:IniciarArrastre(clave)
    local e = Elemento(clave)
    if e.x == nil then return end
    local cx, cy = GetCursorPosition()
    self.arrastre = { clave = clave, cx = cx, cy = cy, x = e.x, y = e.y }
    self.escenario:SetScript("OnUpdate", function() D:Arrastrando() end)
end

function D:TerminarArrastre()
    self.arrastre = nil
    if self.escenario then self.escenario:SetScript("OnUpdate", nil) end
end

function D:Arrastrando()
    local a = self.arrastre
    if not a then return end
    if not IsMouseButtonDown("LeftButton") then
        self:TerminarArrastre()
        return
    end
    local cx, cy = GetCursorPosition()
    local escala = self.raiz:GetEffectiveScale()
    local nx = a.x + (cx - a.cx) / escala
    local ny = a.y + (cy - a.cy) / escala
    if IsShiftKeyDown() then
        nx = floor(nx / 5 + 0.5) * 5
        ny = floor(ny / 5 + 0.5) * 5
    else
        nx = floor(nx + 0.5)
        ny = floor(ny + 0.5)
    end
    local e = Elemento(a.clave)
    if e.x ~= nx or e.y ~= ny then
        e.x, e.y = nx, ny
        HHP:DisenoCambiado()
        self:RefrescarPosicion()
    end
end

function D:ActualizarSeleccion()
    local m = self.marcoSel
    if not m then return end
    local ov = self.sel and self.overlays[self.sel]
    if ov and ov:IsShown() then
        m:ClearAllPoints()
        m:SetPoint("TOPLEFT", ov, "TOPLEFT", -2, 2)
        m:SetPoint("BOTTOMRIGHT", ov, "BOTTOMRIGHT", 2, -2)
        m.etiqueta:SetText(NOMBRES[self.sel])
        m:Show()
    else
        m:Hide()
    end
end

function D:RefrescarPrevia()
    local r = self.raiz
    if not r or not self.marco or not self.marco:IsShown() then return end
    r.zoom = self.zoom
    r.sim = ConstruirSim()
    HHP:ActualizarTodo(r, nil)
    for clave, ov in pairs(self.overlays) do
        local region = r[REGIONES[clave]]
        ov:SetShown(region:IsShown() and Elemento(clave).mostrar)
    end
    self:ActualizarSeleccion()
    if self.etiquetaZoom then
        self.etiquetaZoom:SetText(string.format("Editando: |cffffffff%s|r  |cff888888(zoom x%.1f)|r",
            HHP.NOMBRE_CATEGORIA[self.tipo] or self.tipo, self.zoom))
    end
end

function D:CrearEscenario(p)
    local esc = CreateFrame("Frame", nil, p, "BackdropTemplate")
    esc:SetPoint("TOPLEFT", 192, -8)
    esc:SetSize(420, 300)
    UI.Fondo(esc, { 0.02, 0.02, 0.03, 1 })
    if esc.SetClipsChildren then esc:SetClipsChildren(true) end
    self.escenario = esc

    local cielo = esc:CreateTexture(nil, "BACKGROUND", nil, 1)
    cielo:SetPoint("TOPLEFT", 1, -1)
    cielo:SetPoint("BOTTOMRIGHT", -1, 1)
    cielo:SetTexture("Interface\\Buttons\\WHITE8X8")
    if cielo.SetGradient and CreateColor then
        pcall(cielo.SetGradient, cielo, "VERTICAL", CreateColor(0.13, 0.10, 0.07, 1), CreateColor(0.03, 0.04, 0.07, 1))
    else
        cielo:SetVertexColor(0.06, 0.06, 0.08, 1)
    end

    -- Guías del centro
    local gh = esc:CreateTexture(nil, "BACKGROUND", nil, 2)
    gh:SetTexture("Interface\\Buttons\\WHITE8X8")
    gh:SetVertexColor(1, 1, 1, 0.06)
    gh:SetHeight(1)
    gh:SetPoint("LEFT", esc, "LEFT", 1, 10)
    gh:SetPoint("RIGHT", esc, "RIGHT", -1, 10)
    local gv = esc:CreateTexture(nil, "BACKGROUND", nil, 2)
    gv:SetTexture("Interface\\Buttons\\WHITE8X8")
    gv:SetVertexColor(1, 1, 1, 0.06)
    gv:SetWidth(1)
    gv:SetPoint("TOP", esc, "TOP", 0, -1)
    gv:SetPoint("BOTTOM", esc, "BOTTOM", 0, 1)

    self.etiquetaZoom = UI.Texto(esc, "GameFontNormalSmall", "Vista previa")
    self.etiquetaZoom:SetPoint("TOPLEFT", 8, -8)
    local pista = UI.Texto(esc, "GameFontDisableSmall", "Arrastra los elementos. Mayús = de 5 en 5.")
    pista:SetPoint("BOTTOMRIGHT", -8, 8)

    -- La placa de prueba (mismo código que las placas reales)
    local raiz = HHP:CrearRaiz(esc)
    raiz:ClearAllPoints()
    raiz:SetPoint("CENTER", esc, "CENTER", 0, 10)
    raiz.zoom = self.zoom
    raiz.sim = ConstruirSim()
    self.raiz = raiz

    -- Zonas invisibles para seleccionar y arrastrar
    local nivel = raiz:GetFrameLevel() + 30
    for clave, campo in pairs(REGIONES) do
        local ov = CreateFrame("Button", nil, esc)
        ov:SetFrameLevel(nivel)
        ov:SetAllPoints(raiz[campo])
        local luz = ov:CreateTexture(nil, "HIGHLIGHT")
        luz:SetAllPoints()
        luz:SetTexture("Interface\\Buttons\\WHITE8X8")
        luz:SetVertexColor(1, 0.82, 0, 0.18)
        ov:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_TOP")
            GameTooltip:SetText(NOMBRES[clave], 1, 0.82, 0)
            GameTooltip:AddLine("Clic para editar, arrastra para mover.", 1, 1, 1)
            GameTooltip:Show()
        end)
        ov:SetScript("OnLeave", function() GameTooltip:Hide() end)
        ov:SetScript("OnMouseDown", function(_, boton)
            if boton == "LeftButton" then
                GameTooltip:Hide()
                D:Seleccionar(clave)
                D:IniciarArrastre(clave)
            end
        end)
        ov:SetScript("OnMouseUp", function() D:TerminarArrastre() end)
        self.overlays[clave] = ov
    end

    -- Marco dorado del elemento seleccionado
    local m = CreateFrame("Frame", nil, esc)
    m:SetFrameLevel(nivel + 5)
    m.borde = HHP.CrearBorde(m, "OVERLAY")
    HHP.AplicarBorde(m.borde, m, 1, C.dorado)
    m.etiqueta = UI.Texto(m, "GameFontNormalSmall", "")
    m.etiqueta:SetPoint("BOTTOMLEFT", m, "TOPLEFT", 0, 3)
    m:Hide()
    self.marcoSel = m
end

function D:CambiarTipo(tipo)
    self.tipo = tipo
    for k, bt in pairs(self.botonesTipo) do bt:SetActivo(k == tipo) end
    self:RefrescarTodo()
end

function D:CrearSimulacion(p)
    local marco = CreateFrame("Frame", nil, p, "BackdropTemplate")
    marco:SetPoint("TOPLEFT", 192, -316)
    marco:SetSize(420, 238)
    UI.Fondo(marco, C.panel)

    local t = UI.Texto(marco, "GameFontNormal", "Tipo de placa")
    t:SetPoint("TOPLEFT", 10, -8)
    local t2 = UI.Texto(marco, "GameFontDisableSmall", "cada tipo tiene su propio diseño")
    t2:SetPoint("LEFT", t, "RIGHT", 8, 0)

    self.botonesTipo = {}
    for i, cat in ipairs(HHP.CATEGORIAS) do
        local b = UI.Boton(marco, cat.nombre, 97, 22, function() D:CambiarTipo(cat.clave) end)
        local col, fil = (i - 1) % 4, floor((i - 1) / 4)
        b:SetPoint("TOPLEFT", 10 + col * 101, -28 - fil * 26)
        b.ayuda = cat.desc
        b:SetActivo(cat.clave == self.tipo)
        self.botonesTipo[cat.clave] = b
    end

    -- Copiar diseños entre tipos
    local copiarDe = UI.Boton(marco, "Copiar de otro tipo...", 140, 22)
    copiarDe:SetPoint("TOPLEFT", 10, -84)
    copiarDe.ayuda = "Reemplaza el diseño de este tipo por el de otro."
    copiarDe:SetScript("OnClick", function(s)
        local opciones = {}
        for _, cat in ipairs(HHP.CATEGORIAS) do
            if cat.clave ~= D.tipo then opciones[#opciones + 1] = { valor = cat.clave, texto = cat.nombre } end
        end
        UI.AbrirMenu(s, opciones, nil, function(origen)
            HHP:GuardarDeshacer()
            HHP:UsarDiseno(HHP.db.disenos[origen], D.tipo)
            D:RefrescarTodo()
            HHP:Print("diseño de " .. HHP.NOMBRE_CATEGORIA[origen] .. " copiado a " .. HHP.NOMBRE_CATEGORIA[D.tipo] .. ".")
        end)
    end)
    local copiarA = UI.Boton(marco, "Copiar a todos", 100, 22, function()
        HHP:GuardarDeshacer()
        HHP:UsarDiseno(HHP.db.disenos[D.tipo], nil)
        D:RefrescarTodo()
        HHP:Print("diseño de " .. HHP.NOMBRE_CATEGORIA[D.tipo] .. " copiado a todos los tipos. Pulsa Deshacer si te arrepientes.")
    end)
    copiarA:SetPoint("LEFT", copiarDe, "RIGHT", 6, 0)
    copiarA.ayuda = "Usa este diseño en todos los tipos de placa."
    local deshacer = UI.Boton(marco, "Deshacer", 70, 22, function()
        if HHP:Deshacer() then
            D:RefrescarTodo()
            HHP:Print("cambio deshecho.")
        else
            HHP:Print("no hay nada que deshacer.")
        end
    end)
    deshacer:SetPoint("LEFT", copiarA, "RIGHT", 6, 0)
    deshacer.ayuda = "Deshace el último copiado, estilo o importación."
    local base = UI.Boton(marco, "Original", 70, 22, function()
        HHP:GuardarDeshacer()
        HHP:UsarDiseno(HHP:BaseDe(D.tipo), D.tipo)
        D:RefrescarTodo()
    end)
    base:SetPoint("LEFT", deshacer, "RIGHT", 6, 0)
    base.ayuda = "Vuelve al diseño original de este tipo."

    local checks = {
        { "lanzando", "Lanzando hechizo" },
        { "noInterrumpible", "No interrumpible" },
        { "objetivo", "Es mi objetivo" },
        { "conMision", "Mob de misión" },
        { "conAuras", "Con mis debuffs" },
        { "conMarca", "Con marca de banda" },
        { "raro", "Es raro (Élite = raro élite)" },
    }
    self.checksSim = {}
    for i, c in ipairs(checks) do
        local ck = UI.Check(marco, c[2], function() return D.flags[c[1]] end, function(v)
            D.flags[c[1]] = v
            D:RefrescarPrevia()
        end)
        local col = (i - 1) % 3
        local fil = floor((i - 1) / 3)
        ck:SetPoint("TOPLEFT", 10 + col * 136, -116 - fil * 24)
        table.insert(self.checksSim, ck)
    end

    local zoom = UI.Deslizador(marco, "Zoom de la vista previa", 1, 4, 0.1,
        function() return D.zoom end,
        function(v) D.zoom = v; D:RefrescarPrevia() end, 250)
    zoom:SetPoint("TOPLEFT", 10, -192)
end

function D:CrearPropiedades(p)
    local marco = CreateFrame("Frame", nil, p, "BackdropTemplate")
    marco:SetPoint("TOPLEFT", 620, -8)
    marco:SetPoint("BOTTOMRIGHT", -10, 8)
    UI.Fondo(marco, C.panel)

    self.propTitulo = UI.Texto(marco, "GameFontNormalLarge", "")
    self.propTitulo:SetPoint("TOPLEFT", 10, -10)
    self.propDesc = UI.Texto(marco, "GameFontHighlightSmall", "")
    self.propDesc:SetPoint("TOPLEFT", self.propTitulo, "BOTTOMLEFT", 0, -4)
    self.propDesc:SetPoint("RIGHT", marco, "RIGHT", -10, 0)
    self.propDesc:SetJustifyH("LEFT")
    self.propDesc:SetWordWrap(true)

    local l = UI.Linea(marco)
    l:SetPoint("TOPLEFT", 10, -62)
    l:SetPoint("TOPRIGHT", -10, -62)

    local sf = UI.PanelDesplazable(marco)
    sf:SetPoint("TOPLEFT", 6, -68)
    sf:SetPoint("BOTTOMRIGHT", -6, 22)
    self.prop = sf

    local pista = UI.Texto(marco, "GameFontDisableSmall", "Usa la rueda del ratón para ver más opciones.")
    pista:SetPoint("BOTTOMLEFT", 10, 6)
end

---------------------------------------------------------------
-- Página General
---------------------------------------------------------------
function D:CrearGeneral(p)
    local g = function() return HHP.db.general end
    local izq = Pila(p, 24, 10)
    local der = Pila(p, 490, 10)
    self.pilasGeneral = { izq, der }

    izq:Titulo("Placas")
    izq:Agregar(UI.Check(p, "Usar las placas HH (si lo quitas vuelven las de Blizzard)",
        function() return g().activo end,
        function(v) g().activo = v; HHP:ReconstruirTodas() end))
    izq:Agregar(UI.Deslizador(p, "Escala de todas las placas", 0.5, 2.5, 0.05,
        function() return HHP.db.disenos.mob.escala end,
        function(v)
            for _, d in pairs(HHP.db.disenos) do d.escala = v end
            HHP:DisenoCambiado()
        end, 400))
    izq:Agregar(UI.Deslizador(p, "Opacidad de las placas que no son tu objetivo", 0.1, 1, 0.05,
        function() return g().alfaSinObjetivo end,
        function(v) g().alfaSinObjetivo = v; HHP:DisenoCambiado() end, 400))

    izq:Titulo("HustlinHitmans")
    local et = UI.Texto(p, "GameFontNormalSmall", "Nombre de la hermandad (para el logo)")
    et.alto = 14
    izq:Agregar(et)
    local caja = UI.Caja(p, 260, 22)
    caja.alto = 24
    local function GuardarHermandad(s)
        local v = (s:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
        g().hermandad = v
        HHP:DisenoCambiado()
    end
    caja:SetScript("OnEnterPressed", function(s) GuardarHermandad(s); s:ClearFocus() end)
    caja:SetScript("OnEditFocusLost", GuardarHermandad)
    caja.Refrescar = function(s) s:SetText(g().hermandad or "") end
    izq:Agregar(caja)
    local probar = UI.Boton(p, "Comprobar", 100, 22, function() HHP:DiagnosticoLogo() end)
    probar:SetPoint("LEFT", caja, "RIGHT", 8, 0)
    probar.ayuda = "Compara tu hermandad con este nombre y muestra el logo de prueba sobre tu retrato."
    izq:Agregar(UI.Check(p, "Marcar mobs de misión con icono y progreso",
        function() return g().misiones end,
        function(v) g().misiones = v; HHP:DisenoCambiado() end))
    izq:Agregar(UI.Check(p, "Mostrar botón en el minimapa",
        function() return g().minimapa.mostrar end,
        function(v) g().minimapa.mostrar = v; HHP:ActualizarMinimapa() end))

    der:Titulo("Opciones del juego")
    der:Agregar(UI.Check(p, "Aplicar distancia y apilado al iniciar sesión",
        function() return g().controlarCVars end,
        function(v) g().controlarCVars = v end))
    der:Agregar(UI.Deslizador(p, "Distancia de las placas (metros)", 10, 60, 1,
        function() return g().distancia end,
        function(v) g().distancia = v; HHP:SetCVar("nameplateMaxDistance", v) end, 400))
    der:Agregar(UI.Check(p, "Placas apiladas (no se enciman unas sobre otras)",
        function() return g().apiladas end,
        function(v) g().apiladas = v; HHP:SetCVar("nameplateMotion", v and 1 or 0) end))
    der:Agregar(UI.Check(p, "Mostrar placas de enemigos",
        function() return HHP:GetCVarBool("nameplateShowEnemies") end,
        function(v) HHP:SetCVar("nameplateShowEnemies", v and 1 or 0) end))
    der:Agregar(UI.Check(p, "Mostrar placas de jugadores aliados",
        function() return HHP:GetCVarBool("nameplateShowFriends") end,
        function(v) HHP:SetCVar("nameplateShowFriends", v and 1 or 0) end,
        "Necesario para ver el logo HH y los tipos Aliado y Hermandad."))
    der:Agregar(UI.Check(p, "Mostrar placas de NPC amistosos",
        function() return HHP:GetCVarBool("nameplateShowFriendlyNPCs") end,
        function(v) HHP:SetCVar("nameplateShowFriendlyNPCs", v and 1 or 0) end,
        "Necesario para el tipo NPC. Si está apagado, el juego dibuja sus nombres por su cuenta y el addon no los puede cambiar."))

    der:Titulo("Pruebas y errores")
    der:Agregar(UI.Check(p, "Avisar en el chat cuando ocurra un error",
        function() return g().depurar end,
        function(v) g().depurar = v end))
    local ver = UI.Boton(p, "Ver errores", 120, 22, function() HHP:MostrarErrores() end)
    der:Agregar(ver)
    local borrar = UI.Boton(p, "Borrar errores", 120, 22, function() HHP:BorrarErrores() end)
    borrar:SetPoint("LEFT", ver, "RIGHT", 8, 0)
    local nota = UI.Texto(p, "GameFontHighlightSmall",
        "Si algo se ve raro, escribe |cffffd100/hhp errores|r y pásame lo que aparece en el chat. "
        .. "En combate Forever oculta algunos datos a los addons: es normal que ciertos textos se vean vacíos hasta salir de combate.")
    nota:SetWidth(400)
    nota:SetJustifyH("LEFT")
    nota.alto = 56
    der:Agregar(nota)

    local pie = UI.Texto(p, "GameFontDisableSmall", "HH Placas v" .. HHP.version .. "  -  hecho por Angelo para HustlinHitmans")
    pie:SetPoint("BOTTOM", p, "BOTTOM", 0, 12)
end

---------------------------------------------------------------
-- Página Estilos
---------------------------------------------------------------
function D:RefrescarEstilosGuardados()
    local cont = self.listaEstilos.hijo
    self.filasEstilo = self.filasEstilo or {}
    local nombres = {}
    for nombre in pairs(HHP.db.estilos) do nombres[#nombres + 1] = nombre end
    table.sort(nombres)

    for i, nombre in ipairs(nombres) do
        local fila = self.filasEstilo[i]
        if not fila then
            fila = CreateFrame("Frame", nil, cont, "BackdropTemplate")
            fila:SetSize(410, 26)
            fila:SetPoint("TOPLEFT", 0, -(i - 1) * 29)
            UI.Fondo(fila, C.boton)
            fila.texto = UI.Texto(fila, "GameFontHighlightSmall", "")
            fila.texto:SetPoint("LEFT", 8, 0)
            fila.borrar = UI.Boton(fila, "Borrar", 60, 20)
            fila.borrar:SetPoint("RIGHT", -3, 0)
            fila.cargar = UI.Boton(fila, "Cargar", 60, 20)
            fila.cargar:SetPoint("RIGHT", fila.borrar, "LEFT", -4, 0)
            self.filasEstilo[i] = fila
        end
        fila.texto:SetText(nombre)
        fila.cargar:SetScript("OnClick", function()
            HHP:GuardarDeshacer()
            HHP:UsarConjunto(HHP.db.estilos[nombre])
            D:RefrescarTodo()
            HHP:Print("estilo '" .. nombre .. "' cargado (todos los tipos de placa).")
        end)
        fila.borrar:SetScript("OnClick", function()
            HHP.db.estilos[nombre] = nil
            D:RefrescarEstilosGuardados()
        end)
        fila:Show()
    end
    for i = #nombres + 1, #self.filasEstilo do self.filasEstilo[i]:Hide() end
    cont:SetHeight(math.max(1, #nombres * 29))
    self.sinEstilos:SetShown(#nombres == 0)
end

function D:RefrescarTextoTipo()
    if self.textoTipoEstilos then
        self.textoTipoEstilos:SetText("Tipo actual en el diseñador: |cffffffff" .. (HHP.NOMBRE_CATEGORIA[self.tipo] or self.tipo) .. "|r")
    end
end

function D:CrearEstilos(p)
    local izq = Pila(p, 24, 10)
    izq:Titulo("Estilos predefinidos")
    self.textoTipoEstilos = UI.Texto(p, "GameFontHighlightSmall", "")
    self.textoTipoEstilos.alto = 14
    izq:Agregar(self.textoTipoEstilos)
    for _, est in ipairs(HHP.PREDEFINIDOS) do
        local card = CreateFrame("Frame", nil, p, "BackdropTemplate")
        card:SetSize(420, 50)
        UI.Fondo(card, C.panel)
        local n = UI.Texto(card, "GameFontNormal", est.nombre)
        n:SetPoint("TOPLEFT", 10, -9)
        local d = UI.Texto(card, "GameFontHighlightSmall", est.desc)
        d:SetPoint("TOPLEFT", n, "BOTTOMLEFT", 0, -4)
        d:SetPoint("RIGHT", card, "RIGHT", -164, 0)
        d:SetJustifyH("LEFT")
        local todos = UI.Boton(card, "Todos", 70, 24, function()
            HHP:GuardarDeshacer()
            if est.conjunto then HHP:UsarConjunto(est.conjunto) else HHP:UsarDiseno(est.diseno, nil) end
            D:RefrescarTodo()
            HHP:Print("estilo '" .. est.nombre .. "' aplicado a todos los tipos.")
        end)
        todos:SetPoint("RIGHT", -10, 0)
        todos.ayuda = "Aplica el estilo a todos los tipos de placa."
        local este = UI.Boton(card, "Este tipo", 70, 24, function()
            HHP:GuardarDeshacer()
            HHP:UsarDiseno(est.conjunto and est.conjunto[D.tipo] or est.diseno, D.tipo)
            D:RefrescarTodo()
            HHP:Print("estilo '" .. est.nombre .. "' aplicado a " .. HHP.NOMBRE_CATEGORIA[D.tipo] .. ".")
        end)
        este:SetPoint("RIGHT", todos, "LEFT", -6, 0)
        este.ayuda = "Aplica el estilo solo al tipo que estás editando en el diseñador."
        card.alto = 50
        izq:Agregar(card)
    end

    izq:Titulo("Mis estilos (guardan todos los tipos)")
    local caja = UI.Caja(p, 290, 22)
    caja.alto = 24
    caja:SetText("")
    izq:Agregar(caja)
    local guardar = UI.Boton(p, "Guardar el actual", 120, 22, function()
        local nombre = (caja:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if nombre == "" then
            HHP:Print("escribe un nombre para el estilo.")
            return
        end
        HHP.db.estilos[nombre] = HHP.Copiar(HHP.db.disenos)
        caja:SetText("")
        caja:ClearFocus()
        D:RefrescarEstilosGuardados()
        HHP:Print("estilo '" .. nombre .. "' guardado.")
    end)
    guardar:SetPoint("LEFT", caja, "RIGHT", 8, 0)

    local lista = UI.PanelDesplazable(p)
    lista:SetPoint("TOPLEFT", p, "TOPLEFT", 24, -izq.y)
    lista:SetSize(420, 100)
    self.listaEstilos = lista
    self.sinEstilos = UI.Texto(p, "GameFontDisableSmall", "Aún no tienes estilos guardados.")
    self.sinEstilos:SetPoint("TOPLEFT", lista, "TOPLEFT", 4, -4)

    -- Compartir
    local der = Pila(p, 490, 10)
    der:Titulo("Compartir diseño")
    local expl = UI.Texto(p, "GameFontHighlightSmall",
        "Exporta y pásale el texto a otro miembro de HH, o pega uno que te compartan y pulsa Importar. "
        .. "Un texto de 'todos los tipos' reemplaza todo; uno de 'este tipo' solo cambia el tipo actual.")
    expl:SetWidth(420)
    expl:SetJustifyH("LEFT")
    expl.alto = 42
    der:Agregar(expl)
    local grande = UI.CajaGrande(p, 420, 280)
    grande.alto = 280
    der:Agregar(grande)
    local estado = UI.Texto(p, "GameFontHighlightSmall", "")

    local function Mostrar(texto)
        grande.caja:SetText(texto)
        grande.caja:SetFocus()
        grande.caja:HighlightText()
        estado:SetText("|cff00ff00Listo: Ctrl+C para copiarlo.|r")
    end
    local exportarTodo = UI.Boton(p, "Exportar todos los tipos", 160, 24, function() Mostrar(HHP:ExportarTodo()) end)
    der:Agregar(exportarTodo)
    local exportarUno = UI.Boton(p, "Exportar este tipo", 130, 24, function() Mostrar(HHP:ExportarDiseno(D.tipo)) end)
    exportarUno:SetPoint("LEFT", exportarTodo, "RIGHT", 8, 0)
    local importar = UI.Boton(p, "Importar", 110, 24, function()
        local clase, datos = HHP:Importar(grande.caja:GetText())
        if not clase then
            estado:SetText("|cffff5555No se pudo importar:|r " .. tostring(datos))
            return
        end
        HHP:GuardarDeshacer()
        if clase == "todo" then
            HHP:UsarConjunto(datos)
            estado:SetText("|cff00ff00Diseños importados (todos los tipos).|r")
        else
            HHP:UsarDiseno(datos, D.tipo)
            estado:SetText("|cff00ff00Diseño importado en " .. HHP.NOMBRE_CATEGORIA[D.tipo] .. ".|r")
        end
        D:RefrescarTodo()
    end)
    importar:SetPoint("LEFT", exportarUno, "RIGHT", 8, 0)
    local limpiar = UI.Boton(p, "Limpiar", 80, 24, function()
        grande.caja:SetText("")
        estado:SetText("")
    end)
    der:Agregar(limpiar)
    local deshacer = UI.Boton(p, "Deshacer", 80, 24, function()
        if HHP:Deshacer() then
            D:RefrescarTodo()
            estado:SetText("Cambio deshecho.")
        else
            estado:SetText("No hay nada que deshacer.")
        end
    end)
    deshacer:SetPoint("LEFT", limpiar, "RIGHT", 8, 0)
    estado:SetPoint("LEFT", deshacer, "RIGHT", 10, 0)
    estado:SetWidth(240)
    estado:SetJustifyH("LEFT")
end

---------------------------------------------------------------
-- Ventana principal
---------------------------------------------------------------
function D:MostrarPagina(nombre)
    self.pagina = nombre
    for k, pg in pairs(self.paginas) do pg:SetShown(k == nombre) end
    for k, b in pairs(self.pestanas) do b:SetActivo(k == nombre) end
    if nombre == "general" then
        for _, pila in ipairs(self.pilasGeneral) do pila:Refrescar() end
    elseif nombre == "estilos" then
        self:RefrescarEstilosGuardados()
        self:RefrescarTextoTipo()
    else
        self:RefrescarPrevia()
    end
end

function D:RefrescarTodo()
    self:RefrescarLista()
    self:RefrescarTextoTipo()
    for _, p in pairs(self.paneles) do p.pila:Refrescar() end
    if self.pilasGeneral then
        for _, pila in ipairs(self.pilasGeneral) do pila:Refrescar() end
    end
    self:RefrescarPrevia()
end

function D:Crear()
    local f = CreateFrame("Frame", "HHPlacasDisenador", UIParent, "BackdropTemplate")
    f:SetSize(940, 600)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    UI.Fondo(f, C.fondo, { 0.6, 0.49, 0, 1 })
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    tinsert(UISpecialFrames, "HHPlacasDisenador")
    self.marco = f

    -- Cabecera
    local logo = f:CreateTexture(nil, "ARTWORK")
    logo:SetTexture(HHP.LOGO)
    logo:SetSize(34, 34)
    logo:SetPoint("TOPLEFT", 10, -6)
    local titulo = UI.Texto(f, "GameFontNormalLarge", "HH Placas")
    titulo:SetPoint("TOPLEFT", logo, "TOPRIGHT", 8, -2)
    local sub = UI.Texto(f, "GameFontDisableSmall", "Diseñador de placas de nombre  -  HustlinHitmans")
    sub:SetPoint("TOPLEFT", titulo, "BOTTOMLEFT", 0, -2)

    local cerrar = UI.Boton(f, "X", 24, 24, function() f:Hide() end)
    cerrar:SetPoint("TOPRIGHT", -10, -10)

    self.pestanas = {}
    local pestanas = { { "disenador", "Diseñador" }, { "general", "General" }, { "estilos", "Estilos" } }
    local anterior
    for i = #pestanas, 1, -1 do
        local clave, texto = pestanas[i][1], pestanas[i][2]
        local b = UI.Boton(f, texto, 96, 24, function() D:MostrarPagina(clave) end)
        if anterior then
            b:SetPoint("RIGHT", anterior, "LEFT", -6, 0)
        else
            b:SetPoint("RIGHT", cerrar, "LEFT", -16, 0)
        end
        anterior = b
        self.pestanas[clave] = b
    end

    local linea = UI.Linea(f)
    linea:SetPoint("TOPLEFT", 1, -46)
    linea:SetPoint("TOPRIGHT", -1, -46)

    -- Páginas
    self.paginas = {}
    for _, par in ipairs(pestanas) do
        local pg = CreateFrame("Frame", nil, f)
        pg:SetPoint("TOPLEFT", 0, -46)
        pg:SetPoint("BOTTOMRIGHT", 0, 0)
        pg:Hide()
        self.paginas[par[1]] = pg
    end

    local pd = self.paginas.disenador
    self:CrearLista(pd)
    self:CrearEscenario(pd)
    self:CrearSimulacion(pd)
    self:CrearPropiedades(pd)
    self:CrearGeneral(self.paginas.general)
    self:CrearEstilos(self.paginas.estilos)

    f:SetScript("OnShow", function()
        D:RefrescarTodo()
        if D.ticker then D.ticker:Cancel() end
        D.ticker = C_Timer.NewTicker(1, function()
            if D.raiz and D.raiz.sim and D.raiz.sim.auras then
                HHP:Seguro("previa", HHP.ActualizarAuras, HHP, D.raiz)
            end
        end)
    end)
    f:SetScript("OnHide", function()
        D:TerminarArrastre()
        if D.ticker then
            D.ticker:Cancel()
            D.ticker = nil
        end
    end)

    self:Seleccionar("vida")
    self:RefrescarLista()
end

function HHP:AbrirDisenador(pagina)
    if not D.marco then
        local ok = self:Seguro("crear diseñador", D.Crear, D)
        if not ok then
            self:Print("no se pudo abrir el diseñador. Escribe /hhp errores para ver por qué.")
            return
        end
    end
    D.marco:Show()
    D:MostrarPagina(pagina or D.pagina or "disenador")
end

function HHP:AlternarDisenador()
    if D.marco and D.marco:IsShown() then
        D.marco:Hide()
    else
        self:AbrirDisenador()
    end
end
