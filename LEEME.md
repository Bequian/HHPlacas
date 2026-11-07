# HH Placas

Placas de nombre personalizables para WoW Forever, hechas para HustlinHitmans.
Reúne en un solo addon: placas propias con diseñador visual + HHLogo + HH Misiones.

## Instalación
1. Copia la carpeta `HHPlacas` a `World of Warcraft\_forever_\Interface\AddOns\`.
2. **Desactiva HHLogo, HHMisiones y Platynator** (HH Placas ya hace lo mismo y chocarían).
3. Entra al juego y escribe `/hhp`.

## Qué incluye
- **Un diseño por tipo de placa**: Mob, Élite, Jefe, NPC, Aliado, Rival y Hermandad. Cada uno
  se edita por separado (botones "Tipo de placa" del diseñador), con "Copiar de otro tipo",
  "Copiar a todos", "Original" y "Deshacer".
- **Diseñador** (`/hhp`): vista previa en vivo; arrastra cualquier elemento para moverlo
  (Mayús = de 5 en 5), edita tamaño, textura, borde, fuente, colores...
- **Simulación**: lanzamiento, no interrumpible, objetivo, misión, debuffs y marca de banda.
- **Elementos**: barra de vida, nombre, texto de vida, nivel, barra de lanzamiento, debuffs,
  resaltado de objetivo (brillo, borde, flechas, subrayado), marca de banda, élite/raro/jefe,
  misión, logo HH y nombre de hermandad.
- **Estilos**: 4 predefinidos (HH Clásico, Minimal, HH Dorado, Neón) aplicables a un tipo o a
  todos; "Mis estilos" guardan los 7 tipos juntos; exportar/importar todo o solo un tipo.
- **General**: distancia de placas, apilado, escala de todas las placas, opacidad de las placas
  que no son tu objetivo, nombre de la hermandad, botón de minimapa.

## Comandos
| Comando | Qué hace |
|---|---|
| `/hhp` | Abre o cierra el diseñador |
| `/hhp general` | Opciones generales |
| `/hhp estilos` | Estilos, importar y exportar |
| `/hhp logo` | Revisa la detección de la hermandad |
| `/hhp distancia 41` | Cambia la distancia de las placas |
| `/hhp errores` | Lista los errores capturados (`/hhp errores borrar` para limpiar) |
| `/hhp debug` | Avisa en el chat cuando ocurre un error |
| `/hhp reset confirmar` | Vuelve al diseño por defecto |

## Notas para probar
- Forever usa el cliente de Midnight: en combate oculta algunos datos a los addons
  ("valores secretos"). El addon lo maneja, pero puede que algún texto quede vacío
  hasta salir de combate; al salir se refresca todo solo.
- Las placas de aliados dentro de instancias están protegidas por el juego: ahí se ven las de Blizzard.
- Si algo falla: `/hhp errores` y copia lo que aparece. Para ver errores de Lua sin capturar,
  activa `/console scriptErrors 1`.

## Texturas
Usa texturas del propio juego y el logo de HH (`Media\logo.tga`). Si tienes un addon que
registre texturas o fuentes en LibSharedMedia, aparecen automáticamente en las listas
marcadas con "(SM)". Para agregar tus propias imágenes, ponlas en `Media` y añádelas a la
lista `HHP.TEXTURAS` en `Media.lua`.
