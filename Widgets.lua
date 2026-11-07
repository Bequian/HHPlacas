-- HH Placas - Kit de controles para el diseñador
-- Controles propios (sin plantillas de Blizzard que cambian entre versiones).

local _, HHP = ...

local UI = {}
HHP.UI = UI

local BLANCO = "Interface\\Buttons\\WHITE8X8"
local floor, max, min = math.floor, math.max, math.min

UI.C = {
    fondo = { 0.05, 0.05, 0.07, 0.97 },
    panel = { 0.09, 0.09, 0.11, 1 },
    boton = { 0.14, 0.14, 0.17, 1 },
    borde = { 0.25, 0.25, 0.30, 1 },
    dorado = { 1, 0.82, 0, 1 },
    activo = { 0.30, 0.24, 0.05, 1 },
}
local C = UI.C

function UI.Fondo(f, fondo, borde)
    if not f.SetBackdrop then
        Mixin(f, BackdropTemplateMixin)
        f:HookScript("OnSizeChanged", f.OnBackdropSizeChanged)
    end
    f:SetBackdrop({ bgFile = BLANCO, edgeFile = BLANCO, edgeSize = 1 })
    fondo = fondo or C.panel
    borde = borde or C.borde
    f:SetBackdropColor(fondo[1], fondo[2], fondo[3], fondo[4] or 1)
    f:SetBackdropBorderColor(borde[1], borde[2], borde[3], borde[4] or 1)
end

function UI.Texto(padre, plantilla, texto)
    local fs = padre:CreateFontString(nil, "OVERLAY", plantilla or "GameFontHighlight")
    fs:SetText(texto or "")
    return fs
end

function UI.Linea(padre, r, g, b, a)
    local t = padre:CreateTexture(nil, "ARTWORK")
    t:SetTexture(BLANCO)
    t:SetVertexColor(r or 0.6, g or 0.49, b or 0, a or 0.6)
    t:SetHeight(1)
    return t
end

---------------------------------------------------------------
-- Botón
---------------------------------------------------------------
function UI.Boton(padre, texto, ancho, alto, alClic)
    local b = CreateFrame("Button", nil, padre, "BackdropTemplate")
    b:SetSize(ancho or 100, alto or 22)
    UI.Fondo(b, C.boton)
    b.texto = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.texto:SetPoint("CENTER")
    b.texto:SetText(texto or "")
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    function b:SetActivo(v)
        self.activo = v
        if v then
            self:SetBackdropColor(C.activo[1], C.activo[2], C.activo[3], 1)
            self:SetBackdropBorderColor(C.dorado[1], C.dorado[2], C.dorado[3], 1)
        else
            self:SetBackdropColor(C.boton[1], C.boton[2], C.boton[3], 1)
            self:SetBackdropBorderColor(C.borde[1], C.borde[2], C.borde[3], 1)
        end
    end

    b:SetScript("OnEnter", function(s)
        s:SetBackdropBorderColor(C.dorado[1], C.dorado[2], C.dorado[3], 1)
        if s.ayuda then
            GameTooltip:SetOwner(s, "ANCHOR_TOP")
            GameTooltip:SetText(s.ayuda, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", function(s)
        if not s.activo then s:SetBackdropBorderColor(C.borde[1], C.borde[2], C.borde[3], 1) end
        GameTooltip:Hide()
    end)
    b:SetScript("OnClick", function(s, boton)
        if alClic then alClic(s, boton) end
    end)
    return b
end

---------------------------------------------------------------
-- Casilla
---------------------------------------------------------------
function UI.Check(padre, etiqueta, obtener, poner, ayuda)
    local c = CreateFrame("CheckButton", nil, padre)
    c:SetSize(22, 22)
    c:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    c:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    c:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
    c:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    c.etiqueta = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    c.etiqueta:SetPoint("LEFT", c, "RIGHT", 2, 0)
    c.etiqueta:SetText(etiqueta or "")
    c:SetHitRectInsets(0, -(c.etiqueta:GetStringWidth() + 6), 0, 0)
    c:SetScript("OnClick", function(s) poner(s:GetChecked() and true or false) end)
    if ayuda then
        c:SetScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(ayuda, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        c:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    function c:Refrescar() self:SetChecked(obtener() and true or false) end
    c.alto = 24
    c:Refrescar()
    return c
end

---------------------------------------------------------------
-- Deslizador con caja numérica
---------------------------------------------------------------
local function Redondear(v, paso)
    return floor(v / paso + 0.5) * paso
end

local function Formato(v, paso)
    if paso < 0.1 then return string.format("%.2f", v) end
    if paso < 1 then return string.format("%.1f", v) end
    return tostring(floor(v + 0.5))
end

function UI.Deslizador(padre, etiqueta, vmin, vmax, paso, obtener, poner, ancho)
    ancho = ancho or 240
    local cont = CreateFrame("Frame", nil, padre)
    cont:SetSize(ancho, 38)
    cont.alto = 40

    cont.etiqueta = cont:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cont.etiqueta:SetPoint("TOPLEFT", 0, 0)
    cont.etiqueta:SetText(etiqueta)

    local s = CreateFrame("Slider", nil, cont, "BackdropTemplate")
    s:SetOrientation("HORIZONTAL")
    s:SetSize(ancho - 58, 10)
    s:SetPoint("TOPLEFT", 2, -18)
    UI.Fondo(s, { 0.02, 0.02, 0.03, 1 })
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local th = s:GetThumbTexture()
    if th then th:SetSize(24, 24) end
    s:SetMinMaxValues(vmin, vmax)
    s:SetValueStep(paso)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    cont.slider = s

    local caja = CreateFrame("EditBox", nil, cont, "BackdropTemplate")
    caja:SetSize(48, 18)
    caja:SetPoint("LEFT", s, "RIGHT", 8, 0)
    UI.Fondo(caja, { 0.02, 0.02, 0.03, 1 })
    caja:SetFontObject(GameFontHighlightSmall)
    caja:SetJustifyH("CENTER")
    caja:SetAutoFocus(false)
    caja:SetScript("OnEnterPressed", function(e)
        local v = tonumber(e:GetText())
        if v then
            v = max(vmin, min(vmax, v))
            s:SetValue(v)
            if not cont.cargando then poner(Redondear(v, paso)) end
        end
        e:SetText(Formato(s:GetValue(), paso))
        e:ClearFocus()
    end)
    caja:SetScript("OnEscapePressed", function(e)
        e:SetText(Formato(s:GetValue(), paso))
        e:ClearFocus()
    end)

    s:SetScript("OnValueChanged", function(_, v)
        v = Redondear(v, paso)
        caja:SetText(Formato(v, paso))
        if cont.cargando then return end
        poner(v)
    end)

    function cont:Refrescar()
        self.cargando = true
        local v = obtener() or vmin
        s:SetValue(v)
        caja:SetText(Formato(v, paso))
        self.cargando = false
    end
    cont:Refrescar()
    return cont
end

---------------------------------------------------------------
-- Selector de color
---------------------------------------------------------------
function UI.AbrirSelectorColor(r, g, b, a, alCambiar)
    local tieneAlfa = a ~= nil
    local function Leer()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        local na
        if tieneAlfa then
            if ColorPickerFrame.GetColorAlpha then
                na = ColorPickerFrame:GetColorAlpha()
            elseif OpacitySliderFrame then
                na = 1 - OpacitySliderFrame:GetValue()
            else
                na = 1
            end
        end
        alCambiar(nr, ng, nb, na)
    end
    local function Cancelar(prev)
        if type(prev) == "table" and prev.r then
            local pa = prev.a
            if pa == nil and prev.opacity then pa = prev.opacity end
            alCambiar(prev.r, prev.g, prev.b, tieneAlfa and (pa or a) or nil)
        else
            alCambiar(r, g, b, a)
        end
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            opacity = a, hasOpacity = tieneAlfa,
            swatchFunc = Leer, opacityFunc = Leer, cancelFunc = Cancelar,
        })
    else
        ColorPickerFrame.func = Leer
        ColorPickerFrame.opacityFunc = Leer
        ColorPickerFrame.cancelFunc = Cancelar
        ColorPickerFrame.hasOpacity = tieneAlfa
        ColorPickerFrame.opacity = tieneAlfa and (1 - a) or nil
        ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end
end

function UI.Color(padre, etiqueta, obtener, poner)
    local cont = CreateFrame("Frame", nil, padre)
    cont:SetSize(240, 22)
    cont.alto = 26

    local b = CreateFrame("Button", nil, cont, "BackdropTemplate")
    b:SetSize(32, 18)
    b:SetPoint("LEFT", 0, 0)
    UI.Fondo(b, { 1, 1, 1, 1 }, { 0, 0, 0, 1 })
    local et = cont:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    et:SetPoint("LEFT", b, "RIGHT", 8, 0)
    et:SetText(etiqueta)

    b:SetScript("OnEnter", function(s) s:SetBackdropBorderColor(C.dorado[1], C.dorado[2], C.dorado[3], 1) end)
    b:SetScript("OnLeave", function(s) s:SetBackdropBorderColor(0, 0, 0, 1) end)
    b:SetScript("OnClick", function()
        local c = obtener()
        UI.AbrirSelectorColor(c[1], c[2], c[3], c[4], function(nr, ng, nb, na)
            poner(nr, ng, nb, na)
            cont:Refrescar()
        end)
    end)

    function cont:Refrescar()
        local c = obtener()
        b:SetBackdropColor(c[1], c[2], c[3], 1)
    end
    cont:Refrescar()
    return cont
end

---------------------------------------------------------------
-- Lista desplegable (menú propio)
---------------------------------------------------------------
local menu
local FILAS = 12
local ALTO_FILA = 20

local function Normalizar(opciones)
    local res = {}
    for _, o in ipairs(opciones) do
        if type(o) == "table" then
            if o.valor ~= nil then
                res[#res + 1] = o
            else
                res[#res + 1] = { valor = o[1], texto = o[2] or tostring(o[1]) }
            end
        else
            res[#res + 1] = { valor = o, texto = tostring(o) }
        end
    end
    return res
end

local function CrearMenu()
    menu = CreateFrame("Frame", "HHPlacasMenu", UIParent, "BackdropTemplate")
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    UI.Fondo(menu, { 0.04, 0.04, 0.06, 0.98 }, C.dorado)
    menu:EnableMouse(true)
    menu:SetClampedToScreen(true)
    menu:Hide()
    menu.filas = {}
    menu.offset = 0

    menu.cierre = CreateFrame("Button", nil, UIParent)
    menu.cierre:SetAllPoints(UIParent)
    menu.cierre:SetFrameStrata("FULLSCREEN")
    menu.cierre:RegisterForClicks("AnyUp")
    menu.cierre:SetScript("OnClick", function() menu:Hide() end)
    menu.cierre:Hide()
    menu:SetScript("OnHide", function() menu.cierre:Hide() end)

    for i = 1, FILAS do
        local fila = CreateFrame("Button", nil, menu)
        fila:SetHeight(ALTO_FILA)
        fila:SetPoint("TOPLEFT", 2, -2 - (i - 1) * ALTO_FILA)
        fila:SetPoint("TOPRIGHT", -2, -2 - (i - 1) * ALTO_FILA)
        fila.muestra = fila:CreateTexture(nil, "BACKGROUND")
        fila.muestra:SetPoint("TOPLEFT", 1, -2)
        fila.muestra:SetPoint("BOTTOMRIGHT", -1, 2)
        fila.luz = fila:CreateTexture(nil, "HIGHLIGHT")
        fila.luz:SetAllPoints()
        fila.luz:SetTexture(BLANCO)
        fila.luz:SetVertexColor(1, 0.82, 0, 0.25)
        fila.texto = fila:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fila.texto:SetPoint("LEFT", 6, 0)
        fila.texto:SetPoint("RIGHT", -6, 0)
        fila.texto:SetJustifyH("LEFT")
        fila:SetScript("OnClick", function(s)
            menu:Hide()
            if menu.alElegir then menu.alElegir(s.valor) end
        end)
        menu.filas[i] = fila
    end

    menu:EnableMouseWheel(true)
    menu:SetScript("OnMouseWheel", function(s, delta)
        s.offset = max(0, min(#s.opciones - FILAS, s.offset - delta))
        s:Dibujar()
    end)

    function menu:Dibujar()
        for i = 1, FILAS do
            local fila = self.filas[i]
            local o = self.opciones[i + self.offset]
            if o then
                fila.valor = o.valor
                local marca = (o.valor == self.actual) and "|cffffd100> |r" or ""
                fila.texto:SetText(marca .. o.texto)
                if o.ruta then
                    fila.muestra:SetTexture(o.ruta)
                    fila.muestra:SetVertexColor(0.35, 0.55, 0.9, 0.9)
                    fila.muestra:Show()
                else
                    fila.muestra:Hide()
                end
                fila:Show()
            else
                fila:Hide()
            end
        end
    end
end

function UI.AbrirMenu(ancla, opciones, actual, alElegir)
    if not menu then CrearMenu() end
    if menu:IsShown() and menu.ancla == ancla then
        menu:Hide()
        return
    end
    menu.ancla = ancla
    menu.opciones = opciones
    menu.actual = actual
    menu.alElegir = alElegir
    menu.offset = 0
    for i, o in ipairs(opciones) do
        if o.valor == actual and i > FILAS then
            menu.offset = min(i - 1, #opciones - FILAS)
        end
    end
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", ancla, "BOTTOMLEFT", 0, -2)
    menu:SetWidth(max(ancla:GetWidth(), 140))
    menu:SetHeight(min(#opciones, FILAS) * ALTO_FILA + 4)
    menu:Dibujar()
    menu.cierre:Show()
    menu:Show()
end

function UI.Lista(padre, etiqueta, opciones, obtener, poner, ancho)
    ancho = ancho or 240
    local cont = CreateFrame("Frame", nil, padre)
    cont:SetSize(ancho, 40)
    cont.alto = 44

    local et = cont:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    et:SetPoint("TOPLEFT", 0, 0)
    et:SetText(etiqueta)

    local function Opciones()
        local o = opciones
        if type(o) == "function" then o = o() end
        return Normalizar(o)
    end

    local b = UI.Boton(cont, "", ancho - 4, 20)
    b:SetPoint("TOPLEFT", 0, -15)
    b.texto:ClearAllPoints()
    b.texto:SetPoint("LEFT", 6, 0)
    b.texto:SetPoint("RIGHT", -18, 0)
    b.texto:SetJustifyH("LEFT")
    b.flecha = b:CreateTexture(nil, "OVERLAY")
    b.flecha:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
    b.flecha:SetSize(10, 12)
    b.flecha:SetPoint("RIGHT", -5, 0)
    if b.flecha.SetRotation then b.flecha:SetRotation(-math.pi / 2) end
    b.flecha:SetVertexColor(1, 0.82, 0)

    b:SetScript("OnClick", function()
        UI.AbrirMenu(b, Opciones(), obtener(), function(v)
            poner(v)
            cont:Refrescar()
        end)
    end)

    function cont:Refrescar()
        local v = obtener()
        local txt = tostring(v)
        for _, o in ipairs(Opciones()) do
            if o.valor == v then txt = o.texto break end
        end
        b.texto:SetText(txt)
    end
    cont:Refrescar()
    return cont
end

---------------------------------------------------------------
-- Caja de texto
---------------------------------------------------------------
function UI.Caja(padre, ancho, alto)
    local e = CreateFrame("EditBox", nil, padre, "BackdropTemplate")
    e:SetSize(ancho or 160, alto or 20)
    UI.Fondo(e, { 0.02, 0.02, 0.03, 1 })
    e:SetFontObject(GameFontHighlightSmall)
    e:SetTextInsets(6, 6, 0, 0)
    e:SetAutoFocus(false)
    e:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(s) s:ClearFocus() end)
    return e
end

-- Caja multilínea con desplazamiento
function UI.CajaGrande(padre, ancho, alto)
    local marco = CreateFrame("Frame", nil, padre, "BackdropTemplate")
    marco:SetSize(ancho, alto)
    UI.Fondo(marco, { 0.02, 0.02, 0.03, 1 })

    local sf = CreateFrame("ScrollFrame", nil, marco)
    sf:SetPoint("TOPLEFT", 6, -6)
    sf:SetPoint("BOTTOMRIGHT", -6, 6)

    local e = CreateFrame("EditBox", nil, sf)
    e:SetMultiLine(true)
    e:SetAutoFocus(false)
    e:SetFontObject(GameFontHighlightSmall)
    e:SetWidth(ancho - 12)
    e:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
    e:SetScript("OnCursorChanged", function(_, _, y, _, h)
        local actual = sf:GetVerticalScroll()
        local alto2 = sf:GetHeight()
        y = -y
        if y < actual then
            sf:SetVerticalScroll(y)
        elseif y + h > actual + alto2 then
            sf:SetVerticalScroll(y + h - alto2)
        end
    end)
    sf:SetScrollChild(e)
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(s, d)
        s:SetVerticalScroll(max(0, min(s:GetVerticalScrollRange(), s:GetVerticalScroll() - d * 20)))
    end)
    marco:EnableMouse(true)
    marco:SetScript("OnMouseDown", function() e:SetFocus() end)
    marco.caja = e
    return marco
end

---------------------------------------------------------------
-- Panel con desplazamiento por rueda del ratón
---------------------------------------------------------------
function UI.PanelDesplazable(padre)
    local sf = CreateFrame("ScrollFrame", nil, padre)
    local hijo = CreateFrame("Frame", nil, sf)
    hijo:SetSize(1, 1)
    sf:SetScrollChild(hijo)
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(s, d)
        local rango = s:GetVerticalScrollRange()
        s:SetVerticalScroll(max(0, min(rango, s:GetVerticalScroll() - d * 30)))
    end)
    sf:SetScript("OnSizeChanged", function(_, w) hijo:SetWidth(w) end)
    sf.hijo = hijo
    return sf
end
