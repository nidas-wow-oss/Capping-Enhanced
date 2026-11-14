# Capping Enhanced

Battleground timers for World of Warcraft 3.3.5a (WotLK): node and flag timers, queue and entry timers, the Wintergrasp timer and a narrow map mode.

Based on **Capping** by **TotalPackage**. All credit for the original addon goes to its author.

## What this version does differently

- Split into three addons so it costs very little outside battlegrounds:
  - `Capping`: the core (bars, queue/entry timers, Wintergrasp, map).
  - `Capping_Battlegrounds`: the per-battleground logic, loaded only inside a battleground or Wintergrasp.
  - `Capping_Options`: the options panel, loaded only when you open it.
- Lighter idle work: the narrow map check only runs in narrow mode, and Wintergrasp polling is much less frequent.
- Several bug fixes (queue handling, per-character profile reset, French start warning, Alterac Valley sync).

## Installation

1. Download this repository (**Code → Download ZIP**).
2. Copy the `Capping`, `Capping_Battlegrounds` and `Capping_Options` folders into `World of Warcraft/Interface/AddOns/`.
3. Make sure all three are enabled in the AddOns list.

## Usage

`/capping` opens the options.
