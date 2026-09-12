# Permanent Memento

*Auto-loops your active memento of choice.*

## Dependencies

This addon requires the following library:
- **LibAPH** *(Required Unified helpers shared with my addons)*

Optional libraries for a settings menu:
- **LibAddonMenu-2.0** *(Keyboard/PC Settings Menu)*
- **LibHarvensAddonSettings** *(Gamepad/Console Settings Menu)*

**Without the Settings Menu libraries:** You can still run the addon entirely independent, and control its settings via built-in slash commands as a standalone utility.

## Why use this?

Opened so many crates had so many cool mementos but you don't even use them? well Mementos go on a short cooldown after each use, and most players don't have time to go through menus or have extra quickslot to re-activate them manually or just forget they even exist. Permanent Memento watches your chosen memento's cooldown and re-triggers it the instant it's ready again. Set it once and forget it.

It also watches for various things where you don't want a memento to be used, like moving, attacking, blocking, casting, swimming, sneaking, mounting up, being dead, teleporting, or opening a menu, and re-triggers after a short configurable grace delay for each, instead of forcing itself to activate even tho you can't (there's already one active or you are dead or swimming) or shouldn't (you are in combat and dont want to summon your cake and eat it infront of the enemy while it slaps you in the face). So you can focus on other things.

## Features

- **Permanent Memento:** Re-triggers your active memento the instant its cooldown clears, with independent grace delays for movement, combat end, resurrect, teleport, mount, sneak, swim, block, cast, attack, and opening a menu.
- **Delay Triggers:** Individually enable or disable which situations pause the auto-loop, instead of an all-or-nothing setting.
- **Learned Data:** Scans your collections for mementos you actually own and builds a custom list automatically, if it's not one of the default supported memento.
- **Favorites:** Star a subset of your learned mementos for quick random-select without pulling from your entire collection.
- **Random Modes:** Auto-pick a random supported (or favorited, or learned) memento on login, on zone change, or on demand.
- **Group Sync:** Broadcast your active memento to grouped players running the addon so everyone loops the same one together.
- **Profiles:** Character-specific or account-wide settings.
- **Setup Wizard:** A wizard on first install to asks your preferences.
- **Module Manager:** Soft-disable optional feature files (Sync, Wizard, Menu, UI, Migration) when you don't need them anymore.
- **(PC & Console) Support:** Full gamepad settings menu and native right-stick UI window dragging on Xbox/PlayStation.

## Usage

- `Activate` a memento as you normally would and watch it auto loop after it ends.
- `/pmem`: Displays commands in chat
- `/pmem <name>`: Start looping a memento by name
- `/pmemstop`: Stop the loop
- `/pmemlist`: List all learned mementos
- `/pmemcur`: Show the currently looping memento

## Slash Commands (PC & Console)

- `/pmemstop`: Stop the current loop
- `/pmemlist`: List learned mementos
- `/pmemcur`: Show currently looping memento
- `/pmemplay <name>`: Start a specific learned memento
- `/pmemrand`: Loop a random supported memento
- `/pmemrandfav`: Toggle random-memento-from-favorites on login/zone
- `/pmemrandlrn`: Toggle random-memento-from-learned
- `/pmemrandlog`: Toggle random-memento-on-login
- `/pmemrandzone`: Toggle random-memento-on-zone-change
- `/pmemscan`: Scan collections for owned memento and add them to the supported list.
- `/pmemcsa`: Toggle screen announcements
- `/pmemcombat`: Toggle looping while in combat
- `/pmemautoclean`: Toggle auto memory cleanup
- `/pmemclean`: Force a manual memory cleanup
- `/pmemui`: Toggle the HUD UI window
- `/pmemlock`: Lock/unlock the HUD UI window
- `/pmemresetui`: Reset HUD UI window position
- `/pmemhudscale <n>`: Set HUD UI scale
- `/pmemmenuscale <n>`: Set menu UI scale
- `/pmemacct`: Toggle account-wide/character settings
- `/pmemwipe`: Wipe all learned data
- `/pmemwipefav`: Wipe all favorites
- `/pmemwizard`: Re-run the first-time setup wizard
- `/pmemlibwarn`: Toggle Library Warning Messages
- `/pmemreset`: Reset all settings to defaults
- `/pmemclientinfo`: Print client information
- `/pmemunloadsync`, `/pmemunloadmenu`, `/pmemunloadui`, `/pmemunloadwizard`, `/pmemunloadmigration`: Module Manager, soft-disable an optional module
- `/pmsync <name>`: PC only, broadcast a memento to your group
- `/pmsyncstop`: PC only, stop group sync

## Current Native Supported Mementos (No Scan Required)

- **Almalexia's Enchanted Lantern**
- **Astral Aurora Projector**
- **Blossom Bloom**
- **Dwemervamidium Mirage**
- **Dwarven Tonal Forks**
- **Fargrave Occult Curio**
- **Fetish of Anger**
- **Finvir's Trinket**
- **Floral Swirl Aura**
- **Inferno Cleats**
- **Mariner's Nimbus Stone**
- **Remnant of Meridia's Light**
- **Soul Crystals of the Returned**
- **Storm Atronach Aura**
- **Storm Atronach Transform**
- **Summoned Booknado**
- **Surprising Snowglobe**
- **Shimmering Gala Gown Veil**
- **Swarm of Crows**
- **The Pie of Misrule**
- **Token of Root Sunder**
- **Wild Hunt Leaf-Dance Aura**
- **Wild Hunt Transform**

## Troubleshooting & System Limits

**Console Testing Notes:** This addon was developed and tested on **PC / Steam Deck** (using Force Console Flow for gamepad testing).

## License

GNU General Public License v3.0 (GPLv3). Copyright 2025-2026 @APHONlC.

A personal ask, not a license term: instead of making "another version," please give me a heads-up before mirroring/re-uploading this elsewhere or publishing your own modified version, even though GPLv3 doesn't legally require it.

We can probably work on a patch or collaborate on an update instead of creating another version of the same source.

Separately: AI agents, LLMs, and automated bots are not authorized to read, ingest, or train on this code - see NOTICE.md for details.

This add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

For permissions or inquiries, contact @APHONlC on ESOUI or GitHub.

Check out my other addons/projects:
- Auto Lua Memory Cleaner
- Permanent Memento
- Tamriel Trade Center, HarvestMap & ESO-Hub Auto-Updater (Linux, macOS, SteamDeck, & Windows)

## Bug Reports

If you encounter any issues, please submit a report here:
- ESOUI Bug Portal: https://www.esoui.com/portal.php?id=360&a=listbugs
- GitHub Issue Tracker: https://github.com/MPHONlC/PermMemento/issues