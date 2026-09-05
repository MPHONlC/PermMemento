<div align="center">

# Permanent Memento

*Auto-loops your active memento of choice.*

![Version](https://img.shields.io/badge/version-0.8.8-9CD04C?style=flat-square)
![ESO API](https://img.shields.io/badge/ESO%20API-101050%20%7C%20101051-00FFFF?style=flat-square)
![License](https://img.shields.io/badge/license-Apache%202.0-fa9c1b?style=flat-square)
![Platform](https://img.shields.io/badge/platform-PC%20%7C%20Xbox%20%7C%20PlayStation-FF69B4?style=flat-square)

</div>

## Dependencies

This addon **requires** the following library:
- **[LibAPH](https://www.esoui.com/downloads/info4)** *(Required Unified helpers shared with my addons)*

Optional libraries for a settings menu:
- **[LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)** *(Keyboard/PC Settings Menu)*
- **[LibHarvensAddonSettings](https://www.esoui.com/downloads/info2857-LibHarvensAddonSettings.html)** *(Gamepad/Console Settings Menu)*

**Without the Settings Menu libraries:** You can still run the addon entirely independent, and control its settings via built-in slash commands as a standalone utility.

## Why use this?

Opened so many crates had so many cool mementos but you don't even use them? well Mementos go on a short cooldown after each use, and most players don't have time to go through menus or have extra quickslot to re-activate them manually or just forget they even exist. Permanent Memento watches your chosen memento's cooldown and re-triggers it the instant it's ready again — set it once and forget it.

It also watches for various things where you don't want a memento to be used like — moving, sprinting, blocking, casting, swimming, sneaking, mounting up, being dead, teleporting, or opening a menu — and re-triggers after a short configurable grace delay for each, instead of forcing itself to activate even tho you can't (there's already one active or you are dead or swimming) or shouldn't (you are in combat and dont want to summon your cake and eat it infront of the enemy while it slaps you in the face)

## Features

- **Permanent Memento** — Re-triggers your active memento the instant its cooldown clears, with independent grace delays for movement, combat end, resurrect, teleport, mount, sneak, swim, block, cast, sprint, and opening a menu.
- **Learned Data** — Scans your collections for mementos you actually own and builds a custom list automatically, if it's not one of the default supported memento.
- **Favorites** — Star a subset of your learned mementos for quick random-select without pulling from your entire collection.
- **Random Modes** — Auto-pick a random supported (or favorited, or learned) memento on login, on zone change, or on demand.
- **Group Sync** — Broadcast your active memento to grouped players running the addon so everyone loops the same one together.
- **Profiles** — Character-specific or account-wide settings.
- **Setup Wizard** — A wizard on first install to asks your preferences.
- **Module Manager** — Soft-disable optional feature files (Sync, Wizard, Menu, UI, Migration) when you don't need them anymore.
- **(PC & Console) Support** — Full gamepad settings menu and native right-stick UI window dragging on Xbox/PlayStation.

## Usage

| Command | Effect |
|---|---|
| <kbd>Activate</kbd> | a memento as you normally would and watch it auto loop after it ends. |
| <kbd>/pmem</kbd> | Displays commands in chat |
| <kbd>/pmem &lt;name&gt;</kbd> | Start looping a memento by name |
| <kbd>/pmemstop</kbd> | Stop the loop |
| <kbd>/pmemlist</kbd> | List all learned mementos |
| <kbd>/pmemcur</kbd> | Show the currently looping memento |

## Slash Commands *(PC & Console)*

| Command | Effect |
|---|---|
| <kbd>/pmemstop</kbd> | Stop the current loop |
| <kbd>/pmemlist</kbd> | List learned mementos |
| <kbd>/pmemcur</kbd> | Show currently looping memento |
| <kbd>/pmemplay &lt;name&gt;</kbd> | Start a specific learned memento |
| <kbd>/pmemrand</kbd> | Loop a random supported memento |
| <kbd>/pmemrandfav</kbd> | Toggle random-memento-from-favorites on login/zone |
| <kbd>/pmemrandlrn</kbd> | Toggle random-memento-from-learned |
| <kbd>/pmemrandlog</kbd> | Toggle random-memento-on-login |
| <kbd>/pmemrandzone</kbd> | Toggle random-memento-on-zone-change |
| <kbd>/pmemscan</kbd> | Scan collections for owned memento and add them to the supported list |
| <kbd>/pmemcsa</kbd> | Toggle screen announcements |
| <kbd>/pmemcombat</kbd> | Toggle looping while in combat |
| <kbd>/pmemautoclean</kbd> | Toggle auto memory cleanup |
| <kbd>/pmemclean</kbd> | Force a manual memory cleanup |
| <kbd>/pmemui</kbd> | Toggle the HUD UI window |
| <kbd>/pmemlock</kbd> | Lock/unlock the HUD UI window |
| <kbd>/pmemresetui</kbd> | Reset HUD UI window position |
| <kbd>/pmemhudscale &lt;n&gt;</kbd> | Set HUD UI scale |
| <kbd>/pmemmenuscale &lt;n&gt;</kbd> | Set menu UI scale |
| <kbd>/pmemacct</kbd> | Toggle account-wide/character settings |
| <kbd>/pmemwipe</kbd> | Wipe all learned data |
| <kbd>/pmemwipefav</kbd> | Wipe all favorites |
| <kbd>/pmemwizard</kbd> | Re-run the first-time setup wizard |
| <kbd>/pmemreset</kbd> | Reset all settings to defaults |
| <kbd>/pmemclientinfo</kbd> | Print client information |
| <kbd>/pmemunloadsync</kbd> / <kbd>/pmemunloadmenu</kbd> / <kbd>/pmemunloadui</kbd> / <kbd>/pmemunloadwizard</kbd> / <kbd>/pmemunloadmigration</kbd> | Module Manager: soft-disable an optional module |
| <kbd>/pmsync &lt;name&gt;</kbd> | *PC only:* broadcast a memento to your group |
| <kbd>/pmsyncstop</kbd> | *PC only:* stop group sync |

## Current Native Supported Mementos *(No Scan Required)*

- **[Almalexia's Enchanted Lantern](https://en.uesp.net/wiki/Online:Almalexia%27s_Enchanted_Lantern)**
- **[Astral Aurora Projector](https://en.uesp.net/wiki/Online:Astral_Aurora_Projector)**
- **[Blossom Bloom](https://en.uesp.net/wiki/Online:Blossom_Bloom)**
- **[Dwemervamidium Mirage](https://en.uesp.net/wiki/Online:Dwemervamidium_Mirage)**
- **[Dwarven Tonal Forks](https://en.uesp.net/wiki/Online:Dwarven_Tonal_Forks)**
- **[Fargrave Occult Curio](https://en.uesp.net/wiki/Online:Fargrave_Occult_Curio)**
- **[Fetish of Anger](https://en.uesp.net/wiki/Online:Fetish_of_Anger)**
- **[Finvir's Trinket](https://en.uesp.net/wiki/Online:Finvir%27s_Trinket)**
- **[Floral Swirl Aura](https://en.uesp.net/wiki/Online:Floral_Swirl_Aura)**
- **[Inferno Cleats](https://en.uesp.net/wiki/Online:Inferno_Cleats)**
- **[Mariner's Nimbus Stone](https://en.uesp.net/wiki/Online:Mariner%27s_Nimbus_Stone)**
- **[Remnant of Meridia's Light](https://en.uesp.net/wiki/Online:Remnant_of_Meridia's_Light)**
- **[Soul Crystals of the Returned](https://en.uesp.net/wiki/Online:Soul_Crystals_of_the_Returned)**
- **[Storm Atronach Aura](https://en.uesp.net/wiki/Online:Storm_Atronach_Aura)**
- **[Storm Atronach Transform](https://en.uesp.net/wiki/Online:Storm_Atronach_Transform)**
- **[Summoned Booknado](https://en.uesp.net/wiki/Online:Summoned_Booknado)**
- **[Surprising Snowglobe](https://en.uesp.net/wiki/Online:Surprising_Snowglobe)**
- **[Shimmering Gala Gown Veil](https://en.uesp.net/wiki/Online:Shimmering_Gala_Gown_Veil)**
- **[Swarm of Crows](https://en.uesp.net/wiki/Online:Swarm_of_Crows)**
- **[The Pie of Misrule](https://en.uesp.net/wiki/Online:The_Pie_of_Misrule)**
- **[Token of Root Sunder](https://en.uesp.net/wiki/Online:Token_of_Root_Sunder)**
- **[Wild Hunt Leaf-Dance Aura](https://en.uesp.net/wiki/Online:Wild_Hunt_Leaf-Dance_Aura)**
- **[Wild Hunt Transform](https://en.uesp.net/wiki/Online:Wild_Hunt_Transform)**

## Troubleshooting & System Limits

> [!WARNING]
> **Console Testing Notes** — This addon was developed and tested on **PC / Steam Deck** *(using Force Console Flow for gamepad testing)*.

## License & Usage

Copyright (c) 2025-2026 @APHONlC. All rights reserved.
- Don't re-upload or mirror this on ESOUI/Nexus/etc without asking me first.
- Don't release modified versions of this code publicly.
- You're 100% free to tweak the code for your own private use on your machine.

Licensed under the **Apache License, Version 2.0**.

<sub>*(For permissions or inquiries, contact @APHONlC on ESOUI or GitHub.)*</sub>

This add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

**Check out my other addons/projects:**

• [Auto Lua Memory Cleaner](https://www.esoui.com/downloads/fileinfo.php?id=4388#info)<br>
• [Permanent Memento](https://www.esoui.com/downloads/fileinfo.php?id=4116#info)<br>
• [Tamriel Trade Center, HarvestMap & ESO-Hub Auto-Updater](https://www.esoui.com/downloads/fileinfo.php?id=3249#info) *(Linux, macOS, SteamDeck, & Windows)*

<br>
[![Buy Me A Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/aph0nlc)
<br>
### Bug Reports

If you encounter any issues, please submit a report here:
[ESOUI Bug Portal](https://www.esoui.com/portal.php?id=360&a=listbugs) | [GitHub Issue Tracker](https://github.com/MPHONlC/PermMemento/issues)
