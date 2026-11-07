-- HH Placas - Núcleo
-- Configuración, utilidades, estilos predefinidos, comandos y arranque.

local ADDON, HHP = ...
_G.HHPlacas = HHP

HHP.nombre = ADDON
HHP.RUTA = "Interface\\AddOns\\" .. ADDON .. "\\"
HHP.LOGO = HHP.RUTA .. "Media\\logo"

local function Metadato(campo)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON, campo)
    elseif GetAddOnMetadata then
        return GetAddOnMetadata(ADDON, campo)
    end
end
HHP.version = Metadato("Version") or "1.0.0"

local PREFIJO = "|cffffd100HH Placas:|r "
function HHP:Print(...)
    local partes = {}
    for i = 1, select("#", ...) do
        partes[i] = tostring((select(i, ...)))
    end
    print(PREFIJO .. table.concat(partes, " "))
end

---------------------------------------------------------------
-- Valores secretos (Midnight / Forever)
-- En combate algunas APIs devuelven "valores secretos": se pueden
-- pasar a SetText/SetValue, pero no comparar ni operar con ellos.
---------------------------------------------------------------
local issecret = issecretvalue

function HHP.Secreto(v)
    if issecret then return issecret(v) and true or false end
    return false
end

-- Devuelve v si es un valor normal; si es secreto, devuelve 'def'
function HHP.Limpio(v, def)
    if issecret and issecret(v) then return def end
    return v
end

-- true si el valor existe (un secreto siempre existe)
function HHP.Existe(v)
    if issecret and issecret(v) then return true end
    return v ~= nil
end

---------------------------------------------------------------
-- Registro de errores (para testear dentro del juego)
---------------------------------------------------------------
HHP.errores = {}
local vistos = {}

function HHP:Error(origen, err)
    local msg = tostring(origen) .. ": " .. tostring(err)
    local e = vistos[msg]
    if e then
        e.n = e.n + 1
        return
    end
    e = { msg = msg, n = 1 }
    vistos[msg] = e
    table.insert(self.errores, e)
    if self.db and self.db.general.depurar then
        self:Print("|cffff5555error|r " .. msg)
    end
end

function HHP:Seguro(origen, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then self:Error(origen, err) end
    return ok
end

function HHP:MostrarErrores()
    if #self.errores == 0 then
        self:Print("no hay errores registrados. ¡Todo bien!")
        return
    end
    self:Print(#self.errores .. " error(es) distintos:")
    for i, e in ipairs(self.errores) do
        if i > 15 then
            print("  ...y " .. (#self.errores - 15) .. " más.")
            break
        end
        print(string.format("  |cffff7777%d.|r (x%d) %s", i, e.n, e.msg))
    end
end

function HHP:BorrarErrores()
    wipe(self.errores)
    wipe(vistos)
    self:Print("errores borrados.")
end

---------------------------------------------------------------
-- Tablas
---------------------------------------------------------------
function HHP.Copiar(t)
    if type(t) ~= "table" then return t end
    local c = {}
    for k, v in pairs(t) do c[k] = HHP.Copiar(v) end
    return c
end

-- Rellena en 't' lo que falte de 'base' y corrige tipos incorrectos
function HHP.Completar(t, base)
    for k, v in pairs(base) do
        if type(v) == "table" then
            if type(t[k]) ~= "table" then
                t[k] = HHP.Copiar(v)
            else
                HHP.Completar(t[k], v)
            end
        elseif t[k] == nil or type(t[k]) ~= type(v) then
            t[k] = v
        end
    end
    return t
end

---------------------------------------------------------------
-- Diseño por defecto
-- Las posiciones (x, y) son relativas al centro de la placa.
---------------------------------------------------------------
local TEXTO = function(t)
    t.fuente = t.fuente or "Friz"
    t.contorno = t.contorno or "OUTLINE"
    t.justificar = t.justificar or "CENTER"
    t.color = t.color or { 1, 1, 1 }
    return t
end

HHP.DISENO_BASE = {
    escala = 1,
    elementos = {
        vida = {
            mostrar = true, x = 0, y = 0, ancho = 130, alto = 12,
            textura = "Suave", borde = "Fino", colorBorde = { 0, 0, 0, 1 },
            fondo = 0.6, modoColor = "clase", color = { 0.8, 0.2, 0.2 }, amenaza = false,
        },
        nombre = TEXTO({ mostrar = true, x = 0, y = 14, tam = 11, anchoMax = 160, modoColor = "blanco", apellido = true }),
        textoVida = TEXTO({ mostrar = true, x = 0, y = 0, tam = 9, formato = "porcentaje", ocultarLleno = false }),
        nivel = TEXTO({ mostrar = true, x = -74, y = 0, tam = 9, justificar = "RIGHT" }),
        lanzamiento = {
            mostrar = true, x = 0, y = -13, ancho = 130, alto = 9,
            textura = "Suave", borde = "Fino", colorBorde = { 0, 0, 0, 1 },
            color = { 1, 0.7, 0 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 },
            icono = true, tamIcono = 20, textoHechizo = true, tiempo = true, tamTexto = 8,
        },
        auras = { mostrar = true, x = 0, y = 32, tam = 20, espacio = 2, max = 5, soloMias = true },
        objetivo = { mostrar = true, estilo = "Brillo", color = { 1, 1, 1, 0.9 }, ancla = "auto", separacion = 2 },
        marcaBanda = { mostrar = true, x = 0, y = 54, tam = 22 },
        elite = {
            mostrar = true, x = 74, y = 0, tam = 14,
            colorElite = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 },
            bordeRaroElite = true, colorBorde = { 1, 0.82, 0 },
        },
        mision = { mostrar = true, x = -98, y = 0, tam = 16, contador = true, lado = "izquierda", tamTexto = 12, color = { 1, 0.82, 0 } },
        logo = { mostrar = true, x = 0, y = 34, tam = 24 },
        hermandad = TEXTO({ mostrar = false, x = 0, y = 26, tam = 9, color = { 0.45, 1, 0.45 }, tituloNPC = true }),
    },
}

HHP.GENERAL_BASE = {
    activo = true,
    controlarCVars = true,
    distancia = 41,
    apiladas = true,
    alfaSinObjetivo = 0.7,
    hermandad = "HustlinHitmans",
    misiones = true,
    depurar = false,
    minimapa = { mostrar = true, angulo = 215 },
}

---------------------------------------------------------------
-- Estilos predefinidos
---------------------------------------------------------------
local function Estilo(cambios)
    local d = HHP.Copiar(HHP.DISENO_BASE)
    for clave, valores in pairs(cambios) do
        if clave == "escala" then
            d.escala = valores
        else
            for k, v in pairs(valores) do
                d.elementos[clave][k] = HHP.Copiar(v)
            end
        end
    end
    return d
end

HHP.PREDEFINIDOS = {
    {
        nombre = "HH Clásico",
        desc = "El estilo por defecto: limpio y fácil de leer.",
        diseno = Estilo({}),
    },
    {
        nombre = "Minimal",
        desc = "Barra fina, sin números. Ideal para mucho mob en pantalla.",
        diseno = Estilo({
            vida = { alto = 6, textura = "Plano" },
            textoVida = { mostrar = false },
            nombre = { y = 9, tam = 10 },
            nivel = { mostrar = false },
            lanzamiento = { alto = 6, y = -8, tamTexto = 7, tamIcono = 12 },
            auras = { y = 24, tam = 16 },
            logo = { y = 28, tam = 20 },
            mision = { x = -80 },
        }),
    },
    {
        nombre = "HH Dorado",
        desc = "Bordes dorados y letra Morpheus al estilo HustlinHitmans.",
        diseno = Estilo({
            vida = { alto = 14, textura = "Blizzard", borde = "Grueso", colorBorde = { 1, 0.82, 0, 1 } },
            nombre = { fuente = "Morpheus", tam = 13, y = 17, modoColor = "personal", color = { 1, 0.82, 0 } },
            textoVida = { tam = 10 },
            lanzamiento = { borde = "Grueso", colorBorde = { 1, 0.82, 0, 1 }, y = -16, alto = 10 },
            objetivo = { estilo = "Flechas", color = { 1, 0.82, 0, 1 } },
            auras = { y = 36 },
            logo = { y = 38, tam = 28 },
        }),
    },
    {
        nombre = "Neón",
        desc = "Colores intensos, borde cian y brillo en tu objetivo.",
        diseno = Estilo({
            vida = { textura = "Plano", alto = 10, fondo = 0.85, colorBorde = { 0, 1, 1, 1 } },
            nombre = { modoColor = "clase", tam = 12 },
            textoVida = { formato = "ambos", tam = 8 },
            objetivo = { estilo = "Brillo", color = { 0, 1, 1, 1 } },
            lanzamiento = { color = { 1, 0, 1 }, textura = "Plano", colorBorde = { 0, 1, 1, 1 } },
        }),
    },
}

---------------------------------------------------------------
-- Tipos de placa: cada uno tiene su propio diseño
---------------------------------------------------------------
HHP.CATEGORIAS = {
    { clave = "mob", nombre = "Mob", desc = "Enemigos normales", enemigo = true },
    { clave = "elite", nombre = "Élite", desc = "Élites y raros", enemigo = true },
    { clave = "jefe", nombre = "Jefe", desc = "Jefes de mazmorra y de mundo", enemigo = true },
    { clave = "npc", nombre = "NPC", desc = "NPC amistosos o que no se pueden atacar" },
    { clave = "aliado", nombre = "Aliado", desc = "Jugadores aliados" },
    { clave = "rival", nombre = "Rival", desc = "Jugadores enemigos", enemigo = true },
    { clave = "hermandad", nombre = "Hermandad", desc = "Miembros de tu hermandad" },
}
HHP.NOMBRE_CATEGORIA = {}
for _, c in ipairs(HHP.CATEGORIAS) do HHP.NOMBRE_CATEGORIA[c.clave] = c.nombre end

-- Base de los amistosos: solo nombre (se puede activar la barra después)
local SOLO_NOMBRE = {
    vida = { mostrar = false },
    textoVida = { mostrar = false },
    nivel = { mostrar = false },
    lanzamiento = { mostrar = false },
    auras = { mostrar = false },
    elite = { mostrar = false },
    nombre = { y = 0, modoColor = "reaccion" },
    logo = { y = 20 },
    marcaBanda = { y = 30 },
}
local function Junto(a, b)
    local t = HHP.Copiar(a)
    for k, v in pairs(b) do
        t[k] = t[k] or {}
        for k2, v2 in pairs(v) do t[k][k2] = HHP.Copiar(v2) end
    end
    return t
end

HHP.DISENOS_BASE = {
    mob = Estilo({}),
    elite = Estilo({
        vida = { ancho = 140 },
        lanzamiento = { ancho = 140 },
        nivel = { x = -79 },
        elite = { x = 79 },
        mision = { x = -103 },
    }),
    jefe = Estilo({
        vida = { ancho = 170, alto = 16 },
        textoVida = { tam = 11, formato = "ambos" },
        nombre = { tam = 14, y = 17 },
        lanzamiento = { ancho = 170, alto = 11, y = -16 },
        nivel = { x = -94, tam = 11 },
        elite = { x = 96, tam = 20 },
        auras = { y = 36, tam = 24 },
        marcaBanda = { y = 62, tam = 26 },
    }),
    npc = Estilo(Junto(SOLO_NOMBRE, {
        hermandad = { mostrar = true, y = -12, color = { 0.6, 1, 0.6 } },
    })),
    aliado = Estilo(Junto(SOLO_NOMBRE, {
        nombre = { modoColor = "clase" },
        hermandad = { mostrar = true, y = -12 },
    })),
    rival = Estilo({
        nombre = { modoColor = "clase" },
        hermandad = { mostrar = true, y = -27, color = { 1, 0.45, 0.45 } },
    }),
    hermandad = Estilo(Junto(SOLO_NOMBRE, {
        nombre = { modoColor = "clase" },
        hermandad = { mostrar = true, y = -12 },
    })),
}

function HHP:BaseDe(categoria)
    return self.DISENOS_BASE[categoria] or self.DISENO_BASE
end

-- Convierte un diseño único (versión anterior) en un juego completo
function HHP:ConjuntoDesde(diseno)
    local set = {}
    for _, c in ipairs(self.CATEGORIAS) do
        if c.enemigo and type(diseno) == "table" then
            set[c.clave] = HHP.Completar(HHP.Copiar(diseno), self:BaseDe(c.clave))
        else
            set[c.clave] = HHP.Copiar(self:BaseDe(c.clave))
        end
    end
    return set
end

function HHP:CompletarConjunto(set)
    for _, c in ipairs(self.CATEGORIAS) do
        if type(set[c.clave]) ~= "table" then set[c.clave] = HHP.Copiar(self:BaseDe(c.clave)) end
        HHP.Completar(set[c.clave], self:BaseDe(c.clave))
    end
    return set
end

---------------------------------------------------------------
-- Exportar / importar diseños (sin ejecutar código)
---------------------------------------------------------------
local function Serializar(v)
    local t = type(v)
    if t == "number" then
        return tostring(v)
    elseif t == "boolean" then
        return v and "t" or "f"
    elseif t == "string" then
        return '"' .. (v:gsub('[\\"]', "\\%0")) .. '"'
    elseif t == "table" then
        local claves = {}
        for k in pairs(v) do claves[#claves + 1] = k end
        table.sort(claves, function(a, b) return tostring(a) < tostring(b) end)
        local partes = {}
        for _, k in ipairs(claves) do
            local kk = type(k) == "number" and ("[" .. k .. "]") or k
            partes[#partes + 1] = kk .. "=" .. Serializar(v[k])
        end
        return "{" .. table.concat(partes, ",") .. "}"
    end
    return "f"
end

local function Parsear(s)
    local pos = 1
    local function Espacio()
        pos = s:find("[^%s]", pos) or (#s + 1)
    end
    local Valor
    local function Tabla()
        pos = pos + 1
        local t = {}
        while true do
            Espacio()
            local c = s:sub(pos, pos)
            if c == "}" then
                pos = pos + 1
                return t
            end
            local clave, fin
            if c == "[" then
                local num
                num, fin = s:match("^%[(%-?%d+)%]()", pos)
                if not num then error("clave inválida") end
                clave = tonumber(num)
            else
                clave, fin = s:match("^([%a_][%w_]*)()", pos)
                if not clave then error("clave inválida") end
            end
            pos = fin
            Espacio()
            if s:sub(pos, pos) ~= "=" then error("falta '='") end
            pos = pos + 1
            t[clave] = Valor()
            Espacio()
            local sep = s:sub(pos, pos)
            if sep == "," then
                pos = pos + 1
            elseif sep ~= "}" then
                error("falta ',' o '}'")
            end
        end
    end
    Valor = function()
        Espacio()
        local c = s:sub(pos, pos)
        if c == "{" then
            return Tabla()
        elseif c == '"' then
            local i, buf = pos + 1, {}
            while true do
                local ch = s:sub(i, i)
                if ch == "" then error("texto sin cerrar") end
                if ch == "\\" then
                    buf[#buf + 1] = s:sub(i + 1, i + 1)
                    i = i + 2
                elseif ch == '"' then
                    pos = i + 1
                    return table.concat(buf)
                else
                    buf[#buf + 1] = ch
                    i = i + 1
                end
            end
        elseif c == "t" then
            pos = pos + 1
            return true
        elseif c == "f" then
            pos = pos + 1
            return false
        else
            local num, fin = s:match("^(%-?[%d%.]+[eE]?[%-+]?%d*)()", pos)
            if not num or not tonumber(num) then error("valor inválido") end
            pos = fin
            return tonumber(num)
        end
    end
    return Valor()
end

-- HHP2 = todos los tipos de placa; HHP1 = un solo diseño
function HHP:ExportarTodo()
    return "HHP2:" .. Serializar({ disenos = self.db.disenos })
end

function HHP:ExportarDiseno(categoria)
    return "HHP1:" .. Serializar(self.db.disenos[categoria])
end

-- Devuelve ("todo", conjunto) o ("uno", diseño), o nil y el error
function HHP:Importar(texto)
    texto = (texto or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local prefijo = texto:sub(1, 5)
    if prefijo ~= "HHP1:" and prefijo ~= "HHP2:" then
        return nil, "el texto no es de HH Placas (debe empezar con HHP1: o HHP2:)"
    end
    local ok, res = pcall(Parsear, texto:sub(6))
    if not ok then return nil, "texto dañado (" .. tostring(res):gsub("^.-:%d+: ", "") .. ")" end
    if type(res) ~= "table" then return nil, "el texto no contiene un diseño válido" end
    if prefijo == "HHP2:" then
        if type(res.disenos) ~= "table" then return nil, "el texto no contiene diseños válidos" end
        return "todo", self:CompletarConjunto(res.disenos)
    end
    if type(res.elementos) ~= "table" then return nil, "el texto no contiene un diseño válido" end
    return "uno", res
end

-- Copia de seguridad para el botón Deshacer
function HHP:GuardarDeshacer()
    self.deshacer = HHP.Copiar(self.db.disenos)
end

function HHP:Deshacer()
    if not self.deshacer then return false end
    self.db.disenos = self.deshacer
    self.deshacer = nil
    self:DisenoCambiado()
    return true
end

-- Aplica un diseño a un tipo de placa (o a todos si categoria es nil)
function HHP:UsarDiseno(diseno, categoria)
    for _, c in ipairs(self.CATEGORIAS) do
        if categoria == nil or categoria == c.clave then
            self.db.disenos[c.clave] = HHP.Completar(HHP.Copiar(diseno), self:BaseDe(c.clave))
        end
    end
    self:DisenoCambiado()
end

function HHP:UsarConjunto(set)
    self.db.disenos = self:CompletarConjunto(HHP.Copiar(set))
    self:DisenoCambiado()
end

---------------------------------------------------------------
-- CVars del juego
---------------------------------------------------------------
function HHP:SetCVar(nombre, valor)
    if InCombatLockdown() then
        self:Print("no puedo cambiar opciones del juego en combate; inténtalo al salir.")
        return false
    end
    local fn = (C_CVar and C_CVar.SetCVar) or SetCVar
    local ok, err = pcall(fn, nombre, tostring(valor))
    if not ok then self:Error("CVar " .. nombre, err) end
    return ok
end

function HHP:GetCVarBool(nombre)
    local fn = (C_CVar and C_CVar.GetCVarBool) or GetCVarBool
    local ok, v = pcall(fn, nombre)
    return ok and v and true or false
end

function HHP:AplicarCVars()
    local g = self.db.general
    if not g.controlarCVars then return end
    self:SetCVar("nameplateMaxDistance", g.distancia)
    self:SetCVar("nameplateMotion", g.apiladas and 1 or 0)
end

---------------------------------------------------------------
-- Comandos
---------------------------------------------------------------
SLASH_HHPLACAS1 = "/hhp"
SLASH_HHPLACAS2 = "/hhplacas"
SlashCmdList.HHPLACAS = function(msg)
    local cmd, resto = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()
    if cmd == "" then
        HHP:AlternarDisenador()
    elseif cmd == "general" or cmd == "opciones" then
        HHP:AbrirDisenador("general")
    elseif cmd == "estilos" then
        HHP:AbrirDisenador("estilos")
    elseif cmd == "logo" then
        HHP:DiagnosticoLogo()
    elseif cmd == "errores" then
        if resto == "borrar" then HHP:BorrarErrores() else HHP:MostrarErrores() end
    elseif cmd == "debug" then
        HHP.db.general.depurar = not HHP.db.general.depurar
        HHP:Print("modo depuración: " .. (HHP.db.general.depurar and "|cff00ff00activado|r" or "|cffff4444desactivado|r"))
    elseif cmd == "distancia" then
        local n = tonumber(resto)
        if n then
            HHP.db.general.distancia = n
            HHP:SetCVar("nameplateMaxDistance", n)
        end
        HHP:Print("distancia de placas = " .. tostring(GetCVar("nameplateMaxDistance")) .. " m")
    elseif cmd == "reset" then
        if resto == "confirmar" then
            HHP:GuardarDeshacer()
            HHP:UsarConjunto(HHP.DISENOS_BASE)
            HHP:Print("todos los diseños restablecidos.")
        else
            HHP:Print("escribe |cffffd100/hhp reset confirmar|r para volver al diseño por defecto.")
        end
    else
        HHP:Print("comandos:")
        print("  |cffffd100/hhp|r - abre o cierra el diseñador")
        print("  |cffffd100/hhp general|r - opciones generales")
        print("  |cffffd100/hhp estilos|r - estilos, importar y exportar")
        print("  |cffffd100/hhp logo|r - revisa la detección de la hermandad")
        print("  |cffffd100/hhp distancia 41|r - cambia la distancia de las placas")
        print("  |cffffd100/hhp errores|r [borrar] - lista los errores capturados")
        print("  |cffffd100/hhp debug|r - muestra los errores en el chat al ocurrir")
        print("  |cffffd100/hhp reset confirmar|r - restablece el diseño")
    end
end

-- Botón del compartimento de addons (junto al minimapa)
function HHPlacas_Compartimento()
    HHP:AlternarDisenador()
end

---------------------------------------------------------------
-- Arranque
---------------------------------------------------------------
local function AvisarConflictos()
    local cargado = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    if not cargado then return end
    for _, nombre in ipairs({ "HHlogo", "HHLogo", "HHMisiones", "Platynator", "Plater", "Kui_Nameplates", "TidyPlates_ThreatPlates" }) do
        local ok, si = pcall(cargado, nombre)
        if ok and si then
            HHP:Print("|cffff9900aviso:|r " .. nombre .. " está activo y puede chocar con HH Placas. Desactívalo en la lista de addons.")
        end
    end
end

local inicio = CreateFrame("Frame")
inicio:RegisterEvent("ADDON_LOADED")
inicio:RegisterEvent("PLAYER_LOGIN")
inicio:SetScript("OnEvent", function(self, evento, arg)
    if evento == "ADDON_LOADED" and arg == ADDON then
        HHPlacasDB = HHPlacasDB or {}
        local db = HHPlacasDB
        -- Diseños por tipo de placa (la v1.0 tenía uno solo: pasa a los enemigos)
        if type(db.disenos) ~= "table" then
            db.disenos = HHP:ConjuntoDesde(db.diseno)
        end
        HHP:CompletarConjunto(db.disenos)
        if not db.migracion11 then
            -- v1.1.1: los NPC muestran su título por defecto
            local h = db.disenos.npc.elementos.hermandad
            h.mostrar, h.y, h.color = true, -12, { 0.6, 1, 0.6 }
            db.migracion11 = true
        end
        db.diseno = nil
        db.general = HHP.Completar(type(db.general) == "table" and db.general or {}, HHP.GENERAL_BASE)
        db.general.aliadosSoloNombre = nil
        db.estilos = type(db.estilos) == "table" and db.estilos or {}
        for nombre, d in pairs(db.estilos) do
            if type(d) ~= "table" then
                db.estilos[nombre] = nil
            elseif d.elementos then
                db.estilos[nombre] = HHP:ConjuntoDesde(d)
            else
                HHP:CompletarConjunto(d)
            end
        end
        HHP.db = db
        self:UnregisterEvent("ADDON_LOADED")
    elseif evento == "PLAYER_LOGIN" then
        HHP:Seguro("cvars", HHP.AplicarCVars, HHP)
        HHP:Seguro("placas", HHP.IniciarPlacas, HHP)
        HHP:Seguro("minimapa", HHP.IniciarMinimapa, HHP)
        HHP:Print("v" .. HHP.version .. " cargado. Escribe |cffffd100/hhp|r para abrir el diseñador.")
        AvisarConflictos()
    end
end)
