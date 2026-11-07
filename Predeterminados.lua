-- HH Placas - Diseños predeterminados
-- Generado desde la configuración de Bequian (2026-11-07).
-- Son los diseños de fábrica: los usan las instalaciones nuevas, el botón
-- "Original" y /hhp reset. El juego anterior queda como estilo predefinido.

local _, HHP = ...

-- Guardamos los predeterminados anteriores (v1.1) como estilo
HHP.DISENOS_ORIGINALES = HHP.DISENOS_BASE

HHP.DISENOS_BASE = {
    mob = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 14, x = 74, y = 0 },
            hermandad = { color = { 0.45, 1, 0.45 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = false, tam = 9, tituloNPC = true, x = 0, y = 26 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = true, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 3, y = -16 },
            logo = { mostrar = true, tam = 28, x = 0, y = 38 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 12, tamTexto = 11, x = -91, y = -1 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = true, tam = 9, x = 61, y = 0 },
            nombre = { anchoMax = 195, apellido = true, color = { 1, 0.82, 0 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "personal", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 0.1373, 1, 0.2667, 1 }, estilo = "Flechas", mostrar = true, separacion = 2 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = true, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = false, ancho = 130, borde = "Ninguno", color = { 0.8, 0.2, 0.2 }, colorBorde = { 1, 0.82, 0, 1 }, fondo = 1, modoColor = "clase", mostrar = true, textura = "Suave", x = 0, y = 0 },
        },
        escala = 1,
    },
    elite = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 24, x = 58, y = 2 },
            hermandad = { color = { 0.45, 1, 0.45 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = false, tam = 9, tituloNPC = true, x = 0, y = 26 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = true, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 3, y = -16 },
            logo = { mostrar = true, tam = 28, x = 0, y = 38 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 16, tamTexto = 12, x = -98, y = 0 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = true, tam = 9, x = 45, y = 0 },
            nombre = { anchoMax = 210, apellido = true, color = { 1, 0.82, 0 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "personal", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 0.1373, 1, 0.2667, 1 }, estilo = "Flechas", mostrar = true, separacion = 2 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = true, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = false, ancho = 130, borde = "Ninguno", color = { 0.8, 0.2, 0.2 }, colorBorde = { 1, 0.82, 0, 1 }, fondo = 1, modoColor = "clase", mostrar = true, textura = "Suave", x = 0, y = 0 },
        },
        escala = 1,
    },
    jefe = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 18, x = 60, y = 2 },
            hermandad = { color = { 0.45, 1, 0.45 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = false, tam = 9, tituloNPC = true, x = 0, y = 26 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = true, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 3, y = -16 },
            logo = { mostrar = true, tam = 28, x = 0, y = 38 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 16, tamTexto = 12, x = -98, y = 0 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = true, tam = 9, x = 45, y = 0 },
            nombre = { anchoMax = 210, apellido = true, color = { 1, 0.82, 0 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "personal", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 0.1373, 1, 0.2667, 1 }, estilo = "Flechas", mostrar = true, separacion = 2 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = true, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = false, ancho = 130, borde = "Ninguno", color = { 0.8, 0.2, 0.2 }, colorBorde = { 1, 0.82, 0, 1 }, fondo = 1, modoColor = "clase", mostrar = true, textura = "Suave", x = 0, y = 0 },
        },
        escala = 1,
    },
    npc = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 14, x = 74, y = 0 },
            hermandad = { color = { 0.8941, 1, 0.8784 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = true, tam = 11, tituloNPC = true, x = 1, y = 5 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = false, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 3, y = -16 },
            logo = { mostrar = true, tam = 28, x = 0, y = 38 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 16, tamTexto = 12, x = -98, y = 0 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = false, tam = 9, x = 61, y = 0 },
            nombre = { anchoMax = 200, apellido = true, color = { 0.1098, 1, 0.1059 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "personal", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 1, 0.82, 0, 1 }, estilo = "Flechas", mostrar = true, separacion = 2 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = false, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = false, ancho = 130, borde = "Ninguno", color = { 0.8, 0.2, 0.2 }, colorBorde = { 1, 0.82, 0, 1 }, fondo = 1, modoColor = "clase", mostrar = false, textura = "Blizzard", x = 0, y = 0 },
        },
        escala = 1,
    },
    aliado = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 14, x = 74, y = 0 },
            hermandad = { color = { 0.45, 1, 0.45 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = true, tam = 11, tituloNPC = true, x = 0, y = -21 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = true, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 6, y = -11 },
            logo = { mostrar = true, tam = 28, x = 0, y = 38 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 16, tamTexto = 12, x = -98, y = 0 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = true, tam = 9, x = 61, y = 0 },
            nombre = { anchoMax = 195, apellido = true, color = { 1, 0.82, 0 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "blanco", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 1, 0.82, 0, 1 }, estilo = "Flechas", mostrar = true, separacion = 2 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = true, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = true, ancho = 130, borde = "Fino", color = { 0.8, 0.2, 0.2 }, colorBorde = { 0, 0, 0, 1 }, fondo = 1, modoColor = "reaccion", mostrar = true, textura = "Suave", x = 0, y = 0 },
        },
        escala = 1,
    },
    rival = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 14, x = 74, y = 0 },
            hermandad = { color = { 0.45, 1, 0.45 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = true, tam = 11, tituloNPC = true, x = 0, y = -21 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = true, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 6, y = -11 },
            logo = { mostrar = true, tam = 28, x = -96, y = 0 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 16, tamTexto = 12, x = -98, y = 0 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = true, tam = 9, x = 61, y = 0 },
            nombre = { anchoMax = 195, apellido = true, color = { 1, 0.82, 0 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "reaccion", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 1, 0.0588, 0.1137, 1 }, estilo = "Flechas", mostrar = true, separacion = 0 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = true, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = true, ancho = 130, borde = "Fino", color = { 0.3294, 0.8, 0.2706 }, colorBorde = { 0, 0, 0, 1 }, fondo = 1, modoColor = "reaccion", mostrar = true, textura = "Suave", x = 0, y = 0 },
        },
        escala = 1,
    },
    hermandad = {
        elementos = {
            auras = { espacio = 2, max = 5, mostrar = true, soloMias = true, tam = 20, x = 0, y = 36 },
            elite = { bordeRaroElite = true, colorBorde = { 1, 0.82, 0 }, colorElite = { 1, 1, 1 }, colorJefe = { 1, 1, 1 }, colorRaro = { 1, 1, 1 }, colorRaroElite = { 1, 1, 1 }, mostrar = true, tam = 14, x = 74, y = 0 },
            hermandad = { color = { 0.45, 1, 0.45 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", mostrar = true, tam = 11, tituloNPC = true, x = 0, y = -21 },
            lanzamiento = { alto = 6, ancho = 112, borde = "Ninguno", color = { 1, 0.7, 0 }, colorBorde = { 1, 0.82, 0, 1 }, colorNoInterrumpible = { 0.6, 0.6, 0.6 }, icono = true, mostrar = true, tamIcono = 12, tamTexto = 8, textoHechizo = true, textura = "Plano", tiempo = true, x = 6, y = -11 },
            logo = { mostrar = true, tam = 28, x = -96, y = 0 },
            marcaBanda = { mostrar = true, tam = 22, x = 0, y = 54 },
            mision = { color = { 1, 0.82, 0 }, contador = true, lado = "izquierda", mostrar = true, tam = 16, tamTexto = 12, x = -98, y = 0 },
            nivel = { color = { 1, 1, 1 }, contorno = "OUTLINE", fuente = "Friz", justificar = "RIGHT", mostrar = true, tam = 9, x = 61, y = 0 },
            nombre = { anchoMax = 195, apellido = true, color = { 1, 0.82, 0 }, contorno = "OUTLINE", fuente = "Friz", justificar = "CENTER", modoColor = "blanco", mostrar = true, tam = 13, x = 0, y = 17 },
            objetivo = { ancla = "auto", color = { 1, 0.82, 0, 1 }, estilo = "Flechas", mostrar = true, separacion = 0 },
            textoVida = { color = { 1, 1, 1 }, contorno = "OUTLINE", formato = "porcentaje", fuente = "Friz", justificar = "CENTER", mostrar = true, ocultarLleno = false, tam = 10, x = 0, y = 0 },
            vida = { alto = 14, amenaza = true, ancho = 130, borde = "Fino", color = { 0.3294, 0.8, 0.2706 }, colorBorde = { 0, 0, 0, 1 }, fondo = 1, modoColor = "personal", mostrar = true, textura = "Suave", x = 0, y = 0 },
        },
        escala = 1,
    },
}

-- Los diseños nuevos completan lo que les falte con estos valores
for clave, d in pairs(HHP.DISENOS_BASE) do HHP.Completar(d, HHP.DISENO_BASE) end

table.insert(HHP.PREDEFINIDOS, 1, {
    nombre = "HH Bequian",
    desc = "La configuración de Bequian: un diseño para cada tipo de placa.",
    conjunto = HHP.DISENOS_BASE,
})
table.insert(HHP.PREDEFINIDOS, {
    nombre = "HH Original",
    desc = "Los diseños por tipo de la versión 1.1 del addon.",
    conjunto = HHP.DISENOS_ORIGINALES,
})
