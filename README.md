# PermMemento 🎭

[![ESOUI](https://img.shields.io/badge/PC-ESOUI-orange.svg?style=for-the-badge)](https://www.esoui.com/downloads/fileinfo.php?id=4116)
[![Bethesda Mods](https://img.shields.io/badge/Console-Bethesda.net-black.svg?style=for-the-badge&logo=bethesda&logoColor=white)](https://mods.bethesda.net/en/elderscrollsonline/details/2aa223e9-ba88-45f7-90d3-0a47002c720c/Permanent_Memento)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=for-the-badge)](LICENSE)

Keep your chosen memento effects active permanently.

<p align="center">
  <img src="https://cdn-eso.mmoui.com/preview/pvw15320.png" alt="Permanent Memento UI 1" />
  <br>
  <img src="https://cdn-eso.mmoui.com/preview/pvw15319.png" alt="Permanent Memento UI 2" />
</p>

### 🛠️ Optional Dependencies
This addon requires the following optional library to access the settings GUI menu:
* [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)

**Without the Dependencies:** you can still run the addon entirely independent and control its settings via built-in slash commands as a standalone control.

### ✨ Features
* **Permanent Mementos:** Automates memento effects like Finvir's Trinket, Almalexia’s Lantern, or Wild Hunt Transform. Intelligently pauses during combat, crafting, or specific menus to ensure zero gameplay interruption.
* **Auto Lua Cleanup Integration:** background memory cleaner. Automatically runs when memory hits 400MB (PC) or 85MB (Console) to prevent performance stuttering. Only triggers outside combat. For more control use [Auto Lua Memory Cleaner](https://www.esoui.com/downloads/info4388.html) addon.
* **Auto-Scanner & Learned Data:** No longer restricted to hardcoded mementos. Use the **LEARN: Auto-Scan** button to learn the durations and Effect IDs of any memento you own.
* **Favorites Manager:** Build a curated list of your favorite effects. All "Randomize" features will prioritize your favorites pool.
* **Live Statistics Panel:** A real-time dashboard displaying Addon Memory footprint, Total/Session loops, and your Top 5 most used mementos.
* **Character Profiles:** Easily Copy or Delete settings profiles between different characters.
* **Group Sync (PC):** Synchronize your memento with your party. Supports every memento in the game, as long as you have it unlocked/owned!
* **Status UI:** A draggable UI label shows current memento, player state, and settings status.
* **Delay Settings:** Specific settings for Idle, Casting, Resurrecting, Teleporting, Menus etc.

### ⌨️ Slash Commands

| Command | Description |
| :--- | :--- |
| `/pmem` | Displays the help menu and supported memento list (Alias: `/permmemento`) |
| `/pmem <name>` | Force loop a specific memento |
| `/pmemstop` | Stops current loop and any active Auto-Scan (Alias: `/permmementostop`) |
| `/pmempause` | Pause or Resume the current loop (Alias: `/pmemtogglepause`) |
| `/pmemcur` | Print the name of the currently looping memento (Alias: `/pmemcurrent`) |
| `/pmemrand` | Activate a random memento (Alias: `/pmemrandom`) |
| `/pmemrandzone` | Toggle randomizing every time you change zones (Alias: `/pmemrandomzonechange`) |
| `/pmemrandlog` | Toggle randomizing every time you login (Alias: `/pmemrandomlogin`) |
| `/pmemstats` | Master toggle for the Stats Tracker module |
| `/pmemrandfav` | Master toggle for Randomization & Favorites logic |
| `/pmemlearn` | Master toggle for Learning Mode & Auto-Scan hooks |
| `/pmemperf` | Toggle Performance Mode for UI refresh optimization (Alias: `/pmemperformancemode`) |
| `/pmemclean` | Run manual Lua memory cleanup sweep (Alias: `/pmemcleanup`) |
| `/pmemautoclean` | Toggle background Auto Lua Cleanup (Alias: `/pmemautocleanup`) |
| `/pmemcsacls` | Toggle announcements for Auto-Cleanups (Alias: `/pmemcsacleanup`) |
| `/pmemscan` | Start the silent Auto-Scan sequence (Alias: `/pmemautolearn`) |
| `/pmemlist` | List all learned mementos and durations (Alias: `/pmemlearned`) |
| `/pmemplay <name>` | Force loop a learned memento (Alias: `/pmemactivatelearned`) |
| `/pmemwipe` | Permanently wipe all learned data (Alias: `/pmemdeletealllearned`) |
| `/pmemwipefav` | Clear your entire favorites list (Alias: `/pmemdeleteallfavorites`) |
| `/pmemui` | Toggle status display visibility (Alias: `/pmemtoggleui`) |
| `/pmemhud` | Toggle between HUD mode and Menu-only mode (Alias: `/pmemuimode`) |
| `/pmemlock` | Lock or Unlock UI dragging (Alias: `/pmemuilock`) |
| `/pmemresetui` | Reset UI scale and position to default (Alias: `/pmemuireset`) |
| `/pmemhudscale <val>` | Set HUD UI scale (0.5 to 2.0) (Alias: `/pmemsethudscale`) |
| `/pmemmenuscale <val>` | Set Menu UI scale (0.5 to 2.0) (Alias: `/pmemsetmenuscale`) |
| `/pmemcsa` | Toggle all screen announcements (Alias: `/pmemtogglecsa`) |
| `/pmemfree` | Toggle Unrestricted Mode to loop any memento (Alias: `/pmemunrestrict`) |
| `/pmemcombat` | Toggle Looping while in Combat (Alias: `/pmemloopincombat`) |
| `/pmemacct` | Toggle Account-Wide vs Character settings (Alias: `/pmemuseaccountsettings`) |
| `/pmemreset` | Reset all settings to default (Alias: `/pmemresetdefaults`) |
| `/pmsyncon` | (PC Only) Master toggle for Group Sync Listener (Alias: `/pmemsyncenable`) |
| `/pmsync <name>` | (PC Only) Send party sync request (Alias: `/permmementosync`) |
| `/pmsyncrand` | (PC Only) Send random party sync (Alias: `/permmementosyncrandom`) |
| `/pmsyncstop` | (PC Only) Send party stop request (Alias: `/permmementosyncstop`) |
| `/pmsyncdelay` | (PC Only) Toggle random delay for syncs (Alias: `/pmemsyncrandomdelay`) |
| `/pmemlogs` | (PC Only) Toggle Chat Logs (Alias: `/pmemchatlogs`) |
| `/pmemnospin` | (PC Only) Toggle Camera Spin Lock in menus (Alias: `/pmemstopspinning`) |

### 🎭 Current Native Supported Mementos (No Scan Required)
* [Almalexia's Enchanted Lantern](https://en.uesp.net/wiki/Online:Almalexia%27s_Enchanted_Lantern)
* [Astral Aurora Projector](https://en.uesp.net/wiki/Online:Astral_Aurora_Projector)
* [Blossom Bloom](https://en.uesp.net/wiki/Online:Blossom_Bloom)
* [Dwemervamidium Mirage](https://en.uesp.net/wiki/Online:Dwemervamidium_Mirage)
* [Dwarven Tonal Forks](https://en.uesp.net/wiki/Online:Dwarven_Tonal_Forks)
* [Fargrave Occult Curio](https://en.uesp.net/wiki/Online:Fargrave_Occult_Curio)
* [Fetish of Anger](https://en.uesp.net/wiki/Online:Fetish_of_Anger)
* [Finvir's Trinket](https://en.uesp.net/wiki/Online:Finvir%27s_Trinket)
* [Floral Swirl Aura](https://en.uesp.net/wiki/Online:Floral_Swirl_Aura)
* [Inferno Cleats](https://en.uesp.net/wiki/Online:Inferno_Cleats)
* [Mariner's Nimbus Stone](https://en.uesp.net/wiki/Online:Mariner%27s_Nimbus_Stone)
* [Remnant of Meridia's Light](https://en.uesp.net/wiki/Online:Remnant_of_Meridia's_Light)
* [Soul Crystals of the Returned](https://en.uesp.net/wiki/Online:Soul_Crystals_of_the_Returned)
* [Storm Atronach Aura](https://en.uesp.net/wiki/Online:Storm_Atronach_Aura)
* [Storm Atronach Transform](https://en.uesp.net/wiki/Online:Storm_Atronach_Transform)
* [Summoned Booknado](https://en.uesp.net/wiki/Online:Summoned_Booknado)
* [Surprising Snowglobe](https://en.uesp.net/wiki/Online:Surprising_Snowglobe)
* [Shimmering Gala Gown Veil](https://en.uesp.net/wiki/Online:Shimmering_Gala_Gown_Veil)
* [Swarm of Crows](https://en.uesp.net/wiki/Online:Swarm_of_Crows)
* [The Pie of Misrule](https://en.uesp.net/wiki/Online:The_Pie_of_Misrule)
* [Token of Root Sunder](https://en.uesp.net/wiki/Online:Token_of_Root_Sunder)
* [Wild Hunt Leaf-Dance Aura](https://en.uesp.net/wiki/Online:Wild_Hunt_Leaf-Dance_Aura)
* [Wild Hunt Transform](https://en.uesp.net/wiki/Online:Wild_Hunt_Transform)

> [!IMPORTANT]
> **Console Flow Mode Warning:** If you use the "Force Console Mode" toggle on PC and get stuck, use: `/script SetCVar("ForceConsoleFlow.2", "0")` followed by `/reloadui`.

<div align="center">

### ⚠️ CONSOLE TESTING NOTES ⚠️
This addon was developed and tested on **PC / Steam Deck** (using Force Console Flow for gamepad testing). The **Group Sync** feature is built using the official ZOS chat listener and is pending full verification on actual console hardware. 

If you are on Xbox or PlayStation, please report your results on the [ESOUI Bug Portal](https://www.esoui.com/portal.php?id=360&a=listbugs) or the GitHub issue tracker! While the core looping logic is verified, console-specific hardware constraints for group chat syncing require community feedback.

</div>

## 📜 LICENSE

Copyright 2025-2026 @APHONlC

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at: [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, **WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND**, either express or implied. See the License for the specific language governing permissions and limitations under the License.

*For permissions or inquiries, contact @APHONlC on ESOUI or GitHub.*

### How to Attribute This Work
If you use, redistribute, or modify this script in your own project, please use the following attribution format:
* **Project Name:** Permanent Memento
* **Author:** @APHONlC
* **License:** Apache License 2.0
* **Original Source:** [Permanent Memento](https://www.esoui.com/downloads/info4116)

## 📂 Check out my other addons/projects
* [Auto Lua Memory Cleaner](https://www.esoui.com/downloads/fileinfo.php?id=4388#info) - Intelligent, low footprint event based LUA memory garbage collection for PC and Console.
* [Permanent Memento](https://www.esoui.com/downloads/fileinfo.php?id=4116#info) - Automate and loop or share your favorite mementos.
* [Tamriel Trade Center, HarvestMap & ESO-Hub Auto-Updater (Linux, macOS, SteamDeck, & Windows)](https://www.esoui.com/downloads/fileinfo.php?id=3249#info) - Cross-platform data updater for Linux, macOS, SteamDeck, and Windows.

<div align="center">

## 🐛 BUG REPORTS
If you encounter any issues, please submit a report here:
[ESOUI Bug Portal](https://www.esoui.com/portal.php?id=360&a=listbugs) | [GitHub Issue Tracker](https://github.com/MPHONlC/PermMemento/issues)


## Support

If this project has been useful to you, consider supporting its development:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/aph0nlc)

</div>
