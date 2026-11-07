-- HH Placas - Texturas y fuentes
-- Usa texturas incluidas en el juego. Si algún addon registra texturas o
-- fuentes en LibSharedMedia, también aparecen en el diseñador.

local _, HHP = ...

HHP.TEXTURAS = {
    { "Suave", "Interface\\RaidFrame\\Raid-Bar-Hp-Fill" },
    { "Blizzard", "Interface\\TargetingFrame\\UI-StatusBar" },
    { "Plano", "Interface\\Buttons\\WHITE8X8" },
    { "Brillante", "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar" },
}

HHP.FUENTES = {
    { "Friz", "Fonts\\FRIZQT__.TTF" },
    { "Arial", "Fonts\\ARIALN.TTF" },
    { "Morpheus", "Fonts\\MORPHEUS.TTF" },
    { "Skurri", "Fonts\\SKURRI.TTF" },
}

HHP.BORDES = { Ninguno = 0, Fino = 1, Grueso = 2 }
HHP.LISTA_BORDES = { "Ninguno", "Fino", "Grueso" }

HHP.CONTORNOS = {
    { valor = "", texto = "Sin contorno (sombra)" },
    { valor = "OUTLINE", texto = "Contorno" },
    { valor = "THICKOUTLINE", texto = "Contorno grueso" },
}

HHP.JUSTIFICADO = {
    { valor = "LEFT", texto = "Izquierda" },
    { valor = "CENTER", texto = "Centro" },
    { valor = "RIGHT", texto = "Derecha" },
}

local function LSM()
    return LibStub and LibStub("LibSharedMedia-3.0", true)
end

local function Buscar(lista, nombre)
    for _, t in ipairs(lista) do
        if t[1] == nombre then return t[2] end
    end
end

local function Lista(propias, tipo)
    local res = {}
    for _, t in ipairs(propias) do
        res[#res + 1] = { valor = t[1], texto = t[1], ruta = t[2] }
    end
    local lsm = LSM()
    if lsm then
        local ok, nombres = pcall(lsm.List, lsm, tipo)
        if ok and type(nombres) == "table" then
            for _, nombre in ipairs(nombres) do
                if not Buscar(propias, nombre) then
                    res[#res + 1] = {
                        valor = "LSM:" .. nombre,
                        texto = nombre .. " |cff888888(SM)|r",
                        ruta = lsm:Fetch(tipo, nombre, true),
                    }
                end
            end
        end
    end
    return res
end

local function Resolver(propias, tipo, valor)
    local ruta = Buscar(propias, valor)
    if ruta then return ruta end
    if type(valor) == "string" and valor:sub(1, 4) == "LSM:" then
        local lsm = LSM()
        if lsm then
            local ok, p = pcall(lsm.Fetch, lsm, tipo, valor:sub(5), true)
            if ok and p then return p end
        end
    end
    return propias[1][2]
end

function HHP:ListaTexturas() return Lista(self.TEXTURAS, "statusbar") end
function HHP:ListaFuentes() return Lista(self.FUENTES, "font") end
function HHP:Textura(valor) return Resolver(self.TEXTURAS, "statusbar", valor) end
function HHP:Fuente(valor) return Resolver(self.FUENTES, "font", valor) end

-- Iconos de misión (los mismos de HH Misiones)
HHP.ICONOS_MISION = {
    matar = "Interface\\Icons\\inv_misc_bone_humanskull_02",
    objeto = "Interface\\Icons\\inv_misc_bag_10",
    progreso = "Interface\\GossipFrame\\AvailableQuestIcon",
}
