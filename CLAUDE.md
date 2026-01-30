# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Greenhouse Gamble is a 2D top-down retro pixel greenhouse/farmstead simulator built with Godot 4.5 using GDScript.

## Running the Game

Open the project in Godot 4.5+ and press F5 to run, or use the command line:
```bash
godot --path . --editor  # Open in editor
godot --path .           # Run the game directly
```

## Architecture

**Scene Hierarchy:**
- `scenes/main.tscn` - Entry point containing ground TileMapLayers, TableGroup, Player, and PlantTray instances
- `scenes/player/player.tscn` + `player.gd` - CharacterBody2D with movement, raycasting for object detection, and tray carry/drop mechanics
- `scenes/table/table.tscn` + `table.gd` - Table (class_name: `Table`) with TraySlot Area2D nodes for placing plant trays
- `scenes/plant/plantTray.tscn` + `plant_tray.gd` - PlantTray (class_name: `PlantTray`) carriable objects with growth simulation
- `scenes/managers/tray_spawner.gd` - TraySpawner (class_name: `TraySpawner`) manages automatic/manual tray creation

**Physics Layers (defined in project.godot):**
- Layer 1: Environment - walls and obstacles
- Layer 2: PlantTrays - pickable plant trays
- Layer 3: TableTraySlots - drop zones on tables

**Signal-Based Communication:**
- `Table` emits `tray_placed(table, slot, tray)` and `tray_removed(table, slot, tray)` when trays are placed/removed
- `PlantTray` emits `growth_changed(tray, growth_stage)` and `fully_grown(tray)` during growth progression
- `TraySpawner` emits `tray_spawned(tray)` and `spawn_failed(reason)` for spawn events

**Player Mechanics (player.gd):**
- Movement: Arrow keys at 200 px/sec
- TrayRay (RayCast2D) detects PlantTrays (layer 2) and TableTraySlots (layer 3) in front of player
- ui_select action picks up/drops trays; trays can only be dropped on unoccupied TableTraySlots
- Shader color feedback: orange (can carry), green (can drop), red (carrying)

**Plant Growth System:**
- PlantTray grows only when placed on a Table (growth_modifier = 0 when not on table)
- Growth rate affected by Table's environment properties: `light_level`, `temperature`, `humidity`
- 6 growth stages (frames 0-5); sprite frame updates automatically with growth_stage
- PlantTray tracks its current table via `set_current_table()`/`get_current_table()`

**Table Slot Management:**
- Tables track occupied slots via `occupied_slots` dictionary (slot_name -> PlantTray)
- Methods: `is_slot_occupied()`, `get_empty_slots()`, `place_tray_in_slot()`, `remove_tray()`
- Slots are named `TraySlot1` through `TraySlot6` as Area2D children of Table

**Assets:**
- `assets/sprites/` - Organized by entity type (player, table, plant, ground)
- `assets/shaders/` - Visual effect shaders (outline highlighting)

## Viewport

768x432 pixels with 3x scaled ground tiles for retro pixel aesthetic.
