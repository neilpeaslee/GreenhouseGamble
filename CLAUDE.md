# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Greenhouse Gamble is a 2D top-down retro pixel greenhouse/farmstead simulator built with Godot 4.5 using GDScript. Win by filling all table slots with fully grown plants.

## Running the Game

Open the project in Godot 4.5+ and press F5 to run, or use the command line:
```bash
godot --path . --editor  # Open in editor
godot --path .           # Run the game directly
```

## Architecture

**Autoload Singletons (project.godot):**
- `UIManager` (UIManagerClass) - Global UI access: toasts, message boxes, pause menu, help screen, countdown timer
- `GameManager` (GameManagerClass) - Win condition tracking, table discovery, debug functions

**Scene Hierarchy:**
- `scenes/main.tscn` - Entry point containing ground TileMapLayers, TableGroup, Player, and PlantTray instances
- `scenes/player/player.tscn` + `player.gd` - CharacterBody2D with movement, raycasting for object detection, and tray carry/drop mechanics
- `scenes/table/table.tscn` + `table.gd` - Table (class_name: `Table`) with TraySlot Area2D nodes for placing plant trays
- `scenes/plant/plantTray.tscn` + `plant_tray.gd` - PlantTray (class_name: `PlantTray`) carriable objects with growth simulation
- `scenes/managers/tray_spawner.gd` - TraySpawner (class_name: `TraySpawner`) manages automatic/manual tray creation
- `scenes/ui/table_info.gd` + `table_info.tscn` - TableInfo (class_name: `TableInfo`) stat bar showing table properties
- `scenes/ui/tray_info.gd` + `tray_info.tscn` - TrayInfo (class_name: `TrayInfo`) stat bar showing tray growth info

**Physics Layers (defined in project.godot):**
- Layer 1: Environment - walls and obstacles
- Layer 2: PlantTrays - pickable plant trays
- Layer 3: TableTraySlots - drop zones on tables

**Signal-Based Communication:**
- `Table` emits `tray_placed(table, slot, tray)` and `tray_removed(table, slot, tray)` when trays are placed/removed
- `PlantTray` emits `growth_changed(tray, growth_stage)` and `fully_grown(tray)` during growth progression
- `TraySpawner` emits `tray_spawned(tray)` and `spawn_failed(reason)` for spawn events
- `GameManager` emits `game_won` when win condition met

**Input Actions:**
- Arrow keys: Movement (200 px/sec)
- Space (ui_select): Pick up/drop trays
- ESC (ui_cancel): Pause menu
- F1 (show_help): Help screen
- F6 (debug_fill_trays): Fill all empty slots with trays
- F7 (debug_grow_trays): Instantly grow all trays to maturity

**Player Mechanics (player.gd):**
- TrayRay (RayCast2D) detects PlantTrays (layer 2) and TableTraySlots (layer 3) in front of player
- Trays can only be dropped on unoccupied TableTraySlots
- Shader color feedback: orange (can carry), green (can drop), red (carrying)
- Info display: standing still near a tray for 0.5s shows TrayInfo; colliding with a table for 1s shows TableInfo

**Plant Growth System:**
- PlantTray grows only when placed on a Table (growth_modifier = 0 when not on table)
- Growth rate affected by Table's environment properties: `light_level`, `temperature`, `humidity`
- Each PlantTray has `preferred_light`, `preferred_temperature`, `preferred_humidity` exports (Optimal Conditions group)
- Growth modifier calculated by comparing table conditions to tray preferences with tolerance factors
- 6 growth stages (frames 0-5); sprite frame updates automatically with growth_stage
- PlantTray tracks its current table via `set_current_table()`/`get_current_table()`

**Table Slot Management:**
- Tables must be in the "tables" group for GameManager auto-discovery
- Each Table has `table_id` export for identification in UI
- Tables track occupied slots via `occupied_slots` dictionary (slot_name -> PlantTray)
- Methods: `is_slot_occupied()`, `get_empty_slots()`, `place_tray_in_slot()`, `remove_tray()`, `get_all_trays()`, `get_tray_count()`
- Slots are named `TraySlot1` through `TraySlot6` as Area2D children of Table

**UI System (via UIManager singleton):**
- `show_message(text, button_text)` - Modal dialog, emits `dismissed` signal
- `show_toast(text, duration)` - Temporary notification
- `start_countdown(duration, message)` / `update_countdown()` / `stop_countdown()` - Timer display
- `show_pause_menu()` / `show_help()` - Overlay screens
- `show_table_info(table)` / `hide_table_info()` - Animated stat bar for table properties
- `show_tray_info(tray)` / `hide_tray_info()` - Animated stat bar for tray growth status

**Assets:**
- `assets/sprites/` - Organized by entity type (player, table, plant, ground)
- `assets/shaders/` - Visual effect shaders (outline highlighting)

## Viewport

768x432 pixels with 3x scaled ground tiles for retro pixel aesthetic.
