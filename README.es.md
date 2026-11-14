# Capping Enhanced

Timers de campos de batalla para World of Warcraft 3.3.5a (WotLK): nodos y banderas, tiempos de cola y de entrada, el timer de Conquista del Invierno y un modo de mapa angosto.

Basado en **Capping** de **TotalPackage**. Todo el crédito del addon original es de su autor.

## Qué cambia en esta versión

- Está partido en tres addons para que casi no consuma fuera de los BG:
  - `Capping`: lo básico (barras, tiempos de cola y entrada, Conquista del Invierno, mapa).
  - `Capping_Battlegrounds`: la lógica de cada BG; se carga solo dentro de un BG o en Conquista del Invierno.
  - `Capping_Options`: el panel de opciones; se carga solo al abrirlo.
- Menos trabajo en segundo plano: el chequeo del mapa angosto corre solo en ese modo y el de Conquista del Invierno es mucho menos frecuente.
- Varios bugs arreglados (colas, reinicio del perfil por personaje, aviso de inicio en francés, sincronización de AV).

## Instalación

1. Descargá este repositorio (**Code → Download ZIP**).
2. Copiá las carpetas `Capping`, `Capping_Battlegrounds` y `Capping_Options` en `World of Warcraft/Interface/AddOns/`.
3. Fijate que las tres estén activadas en la lista de addons.

## Uso

`/capping` abre las opciones.
