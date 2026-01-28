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
- `scenes/table/table.tscn` - Table with TraySlot collision shapes for placing plant trays
- `scenes/plant/plantTray.tscn` - Carriable plant tray objects

**Physics Layers (defined in project.godot):**
- Layer 1: Environment - walls and obstacles
- Layer 2: PlantTrays - pickable plant trays
- Layer 3: TableTraySlots - drop zones on tables

**Player Mechanics (player.gd):**
- Movement: Arrow keys at 200 px/sec
- TrayRay (RayCast2D) detects PlantTrays (layer 2) and TableTraySlots (layer 3) in front of player
- ui_select action picks up/drops trays; trays can only be dropped on TableTraySlots
- Shader color feedback: orange (can carry), green (can drop), red (carrying)

**Assets:**
- `assets/sprites/` - Organized by entity type (player, table, plant, ground)
- `assets/shaders/` - Visual effect shaders (outline highlighting)

## Viewport

768x432 pixels with 3x scaled ground tiles for retro pixel aesthetic.
