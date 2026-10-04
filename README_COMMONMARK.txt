# Permanent Memento

*Auto-loops your active memento of choice.*

## Dependencies

This addon requires the following library:
- **LibAPH** *(Required Unified helpers shared with my addons)*

Optionals for additional features:
- **LibAddonMenu-2.0** *(Keyboard/PC Settings Menu)*
- **LibHarvensAddonSettings** *(Console Settings Menu)*
- **LibGroupBroadcast** *(Required for Group Sync)*

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
- **Group Sync:** Broadcast your active memento to grouped players running the addon so everyone loops the same one together (needs LibGroupBroadcast).
- **Profiles:** Character-specific or account-wide settings.
- **Setup Wizard:** A wizard on first install to asks your preferences.
- **Module Manager:** Soft-disable optional feature files (Sync, Wizard, Menu, UI, Migration) when you don't need them anymore.
- **(PC & Console) Support:** Full console settings menu and native right-stick UI window dragging on Xbox/PlayStation.

## Usage

`Activate` - a memento as you normally would and watch it auto loop after it ends. Activate it again and it should stop the loop.

## Slash Commands (PC & Console)

- `/pmem`: Displays commands in chat
- `/pmsync <name>`: PC only, broadcast a memento to your group
- `/pmemstop`: Stop the current loop
- `/pmempause`: Pause/resume the current loop
- `/pmemlist`: List learned mementos
- `/pmemcur`: Show currently looping memento
- `/pmemplay <name>`: Start a specific learned memento
- `/pmemrand`: Loop a random supported memento
- `/pmemrandfav`: Toggle random-memento-from-favorites on login/zone
- `/pmemrandlrn`: Toggle random-memento-from-learned
- `/pmemrandlog`: Toggle random-memento-on-login
- `/pmemrandzone`: Toggle random-memento-on-zone-change
- `/pmemlearn`: Toggle learning mode (auto-learn new mementos)
- `/pmemfree`: Toggle unrestricted mode (bypass activation restrictions)
- `/pmemscan`: Scan collections for owned memento and add them to the supported list.
- `/pmemcsa`: Toggle screen announcements
- `/pmemcombat`: Toggle looping while in combat
- `/pmembugreport`: Open the bug report copy box
- `/pmemui`: Toggle the HUD UI window
- `/pmemlock`: Lock/unlock the HUD UI window
- `/pmemresetui`: Reset HUD UI window position
- `/pmemhudscale <n>`: Set HUD UI scale
- `/pmemmenuscale <n>`: Set menu UI scale
- `/pmemacct`: Toggle account-wide/character settings
- `/pmemset <name> <seconds>`: Set a delay by name - `/pmemset list` shows valid names
- `/pmemwipe`: Wipe all learned data
- `/pmemwipefav`: Wipe all favorites
- `/pmemwizard`: Re-run the first-time setup wizard
- `/pmemlibwarn`: Toggle Library Warning Messages
- `/pmemreset`: Reset all settings to defaults
- `/pmemclientinfo`: Print client information
- `/pmemlogs`: PC only, toggle chat log messages
- `/pmemnospin`: PC only, stop the character-spin animation during activation
- `/pmemunloadsync`, `/pmemunloadmenu`, `/pmemunloadui`, `/pmemunloadwizard`, `/pmemunloadmigration`: Module Manager, soft-disable an optional module
- `/pmsyncon`: PC only, toggle group sync listening
- `/pmsyncrand`: PC only, broadcast a random supported memento to your group
- `/pmsyncdelay`: PC only, toggle a random delay before your sync broadcast
- `/pmsyncstop`: PC only, stop group sync

## Current Native Supported Mementos

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

**Console Testing Notes:** This addon was developed and tested on **PC / Steam Deck** (using Force Console Flow for console testing).

## License

Copyright &#169; 2025-2026 @APHONlC. All rights reserved. See LICENSE.md

This add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls&#174; and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

For permissions or inquiries, contact @APHONlC on ESOUI.

## Credits

I would like to thank the following, for providing resources and their awesome projects:

- ESOUI Wiki
- UESP
- @sirinsidiator
- @Flat-Badger-1971
- @sirinsidiator & @Seerah (LibAddonMenu-2.0)
- @Harven & @votan (LibHarvensAddonSettings)
- @sirinsidiator (LibGroupBroadcast)
- @SinusPi, @merlight, @Rhyono, @Dolgubon (Zgoo High Isle)
- @Baertram (Mer Torchbug - Fixed and Improved "Variable inspector/Scripts/Events/and more")

Inspired the idea of Permanent Memento:
- Realizing I had far too many mementos and some of them act like character VFX, I came to ESOUI to see if someone had made an add-on for it. I found some promising ones that worked, until I noticed they had issues or limitations and were abandoned; one needed slash commands every time, and the other ran without them but could be janky at times.
- Memento Refresh (@Pretz333)
- PermAlmalexia: Permanent Mementos (@Mouton)

Things my addon is compatible with:
- BeamMeUp (@DeadSoon, @Gamer1986PAN and others)
- PerfectPixel (@KL1SK, @Baertram, @Dakjaniels)

Testers & Suggestions:
- @Drakius192
- @phlupp89
- @AHB182
- @HeyIt'sAmber
- @DemonCatDaphne
- @imPDA
- @Baertram
- @SeablueSky
- @THAMER_AKATOSH

Check out my other addons/projects:
- Auto Lua Memory Cleaner
- Permanent Memento
- Tamriel Trade Center, HarvestMap, ESO-Hub, ESOUI Auto-Updater (Linux, macOS, SteamDeck, & Windows)

## Bug Reports

If you encounter any issues, please submit a report on ESOUI
