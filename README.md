# PermMemento
Keep your chosen memento effects active permanently.

## Description
PermMemento automates your mementos so you don't have to manually refresh them. It distinguishes between **Mobile** mementos (auras that fire instantly) and **Stationary** mementos (animations that wait for idle state).

## Key Features
* **Permanent Mementos:** Makes memento effects like Finvir's Trinket or Almalexia’s Lantern or Wild Hunt Transform remain permanent, waits until you are out of combat/idle to avoid interrupting gameplay.
* **Group Sync:** Share your active memento with your party using chat slash commands.
* **Status UI:** A simple, draggable UI label shows current memento and its cooldowns and player state.

## Usage (PC & Console):
* **COLLECTIBLES > MEMENTOS IN-GAME UI** - Activate any supported memento via in-game collectibles menu to start looping (no need for slash commands).
| Command | Description |
| :--- | :--- |
| `/pmem <name>` | Fallback command to force start looping a memento (e.g., /pmem almalexia) [supports partial names]. |
| `/pmem stop` | Stops the current loop. |
| `/pmsync <name>` | Sends a sync request to your party |
| `/pmem ui` | Toggles the status display. |
| `/pmem lock` | Locks/unlocks UI movement. |
