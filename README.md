<div align="center">

# Permanent Memento

[![ESOUI](https://img.shields.io/badge/PC-ESOUI-orange.svg?style=for-the-badge)](https://www.esoui.com/downloads/fileinfo.php?id=4116)
[![Bethesda Mods](https://img.shields.io/badge/Console-Bethesda.net-black.svg?style=for-the-badge&logo=bethesda&logoColor=white)](https://mods.bethesda.net/en/elderscrollsonline/details/2aa223e9-ba88-45f7-90d3-0a47002c720c/Permanent_Memento)

</div>
<div align="center">
Keep your chosen memento effects active permanently.
</div>

## Optional Dependencies
This addon requires the following optional library to access the settings GUI menu:
* [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)

**Without the Dependencies:** you can still run the addon entirely independent, and control its settings via built-in slash commands as a standalone control.

## Description
PermMemento automates your mementos so you don't have to manually refresh them. Supports randomization, learned data scanning, and automatic memory management!

<p align="center">
  <img src="https://ugcmods.bethesda.net/image/eyJidWNrZXQiOiJ1Z2Ntb2RzLmJldGhlc2RhLm5ldCIsImtleSI6InB1YmxpYy9jb250ZW50L0VTTy81ODY1NTEvQ0xBU1NJRklDQVRJT05fU0NSRUVOU0hPVF9JTUFHRS9CY0N6cG9iZHJJQ3dGdXhzTWw1VzFRPT0vZXNvNjRfQTJMbmNrd3ZiVC5wbmciLCJlZGl0cyI6eyJyZXNpemUiOnsid2lkdGgiOjYwMH19LCJvdXRwdXRGb3JtYXQiOiJ3ZWJwIn0=" alt="Permanent Memento UI 1" />
  <br>
  <img src="https://ugcmods.bethesda.net/image/eyJidWNrZXQiOiJ1Z2Ntb2RzLmJldGhlc2RhLm5ldCIsImtleSI6InB1YmxpYy9jb250ZW50L0VTTy81ODY1NTEvQ0xBU1NJRklDQVRJT05fU0NSRUVOU0hPVF9JTUFHRS91MjlHdjRxVG1XVzJVOFp5Snc5YmtBPT0vU2NyZWVuc2hvdCBGcm9tIDIwMjYtMDItMDggMTMtNTYtMzcucG5nIiwiZWRpdHMiOnsicmVzaXplIjp7IndpZHRoIjo2MDB9fSwib3V0cHV0Rm9ybWF0Ijoid2VicCJ9" alt="Permanent Memento UI 2" />
</p>

## Features
* **Permanent Mementos:** Makes memento effects like Finvir's Trinket, Almalexia’s Lantern, or Wild Hunt Transform remain permanent. Pauses when in combat, crafting, or in menus to avoid interruptions.
* **Auto-Scanner & Learned Data:** No longer restricted to Current Supported Mementos! Use the **LEARN: Auto-Scan** button to learn the durations/Effect IDs of all unmapped mementos. Includes a full Learned Data management settings. After learning your memento data turn on **UNRESTRICTED MODE** to allow them to loop.
* **Favorites Settings:** Build a custom list of mementos, **"Reload UI"** after you're done adding them. All **"Randomize"** features will exclusively pull from your Favorites pool if any are selected. 
* **Auto Lua Cleanup:** Background memory cleaner. Automatically runs when memory hits 400MB (PC) or 85MB (Console) to prevent performance stuttering. Only triggers outside combat.
* **Live Statistics Panel:** A real-time dashboard displaying Addon Memory footprint, Total/Session loops, and your Top 5 most used mementos.
* **Character Profiles:** Easily Copy or Delete settings profiles between different characters via a new submenu.
* **Group Sync:** Share your active memento with your party. Supports ANY memento in the game, as long as you have it unlocked/owned!
* **Status UI:** A draggable UI label shows current memento, player state, and settings status.
* **Delay Settings:** Specific settings for Idle, Casting, Resurrecting, Teleporting, Menus etc.

## Usage (PC & Console)

> [!TIP]
> **AUTO-LOOP:** Activate any supported memento via Collections > Mementos. The addon will detect it and begin the loop automatically.

**SETTINGS MENU:** Configure settings, randomize, or manage Learned Data.

### Slash Commands

| Command | Description |
| :--- | :--- |
| `/pmem <name>` | Fallback command to force start looping a memento (supports partial names). |
| `/pmemstop` | Stops the current loop and any active Auto-Scan. |
| `/pmemrandom` | Immediately activates a random supported memento. |
| `/pmemrandomzonechange` | Toggles the "Randomize on Zone Change" setting. |
| `/pmemrandomlogin` | Toggles the "Randomize on Login" setting. |
| `/pmemautolearn` | Starts the Auto-Scan process to identify memento IDs. |
| `/pmemcleanup` | Manually triggers a Lua Memory Cleanup. |
| `/pmemui` | Toggles the status display visibility. |
| `/pmemuimode` | Toggles between HUD mode and Menu Only mode. |
| `/pmemlock` | Locks or unlocks the status display for dragging. |
| `/pmemuireset` | Resets the UI scale and position to default settings. |
| `/pmemreset` | Alias for `/pmemuireset`. |
| `/pmemcsa` | Toggles Screen Announcements (CSA) on or off. |
| `/pmemunrestrict` | Toggles Unrestricted Mode (skips movement/sprint checks). |
| `/pmsync <name>` | Sends a sync request for a specific memento to your party. |
| `/pmsyncrandom` | Sends a random sync request to your party. |
| `/pmsyncstop` | Sends a stop request to your party. |
| `/pmemcurrent` | Displays the name of the currently active memento loop in chat. |
| `/pmemactivatelearned <name>` | Forces activation of a specifically named memento from Learned Data. |
| `/pmemdeletealllearned` | Permanently wipes all manual and auto-scanned learned data. |
| `/pmemcsacleanup` | Toggles the Auto-Cleanup CSA notification on or off. |
| `/pmemlearned` | Lists all learned memento data in chat. |

---

> **Current Supported Mementos:**

| Memento Name | Collectible ID | Duration |
| :--- | :--- | :--- |
| [**Almalexia's Enchanted Lantern**](https://en.uesp.net/wiki/Online:Almalexia's_Enchanted_Lantern) | 341 | 30s |
| [**Astral Aurora Projector**](https://en.uesp.net/wiki/Online:Astral_Aurora_Projector) | 9862 | 180s |
| [**Blossom Bloom**](https://en.uesp.net/wiki/Online:Blossom_Bloom) | 10706 | 180s |
| [**Dwemervamidium Mirage**](https://en.uesp.net/wiki/Online:Dwemervamidium_Mirage) | 1183 | 36s |
| [**Dwarven Tonal Forks**](https://en.uesp.net/wiki/Online:Dwarven_Tonal_Forks) | 1182 | 10s |
| [**Fargrave Occult Curio**](https://en.uesp.net/wiki/Online:Fargrave_Occult_Curio) | 10371 | 30s |
| [**Fetish of Anger**](https://en.uesp.net/wiki/Online:Fetish_of_Anger) | 347 | 33s |
| [**Finvir's Trinket**](https://en.uesp.net/wiki/Online:Finvir's_Trinket) | 336 | 13s |
| [**Floral Swirl Aura**](https://en.uesp.net/wiki/Online:Floral_Swirl_Aura) | 758 | 180s |
| [**Inferno Cleats**](https://en.uesp.net/wiki/Online:Inferno_Cleats) | 9361 | 18s |
| [**Mariner's Nimbus Stone**](https://en.uesp.net/wiki/Online:Mariner's_Nimbus_Stone) | 10236 | 30s |
| [**Remnant of Meridia's Light**](https://en.uesp.net/wiki/Online:Remnant_of_Meridia's_Light) | 13092 | 69s |
| [**Soul Crystals of the Returned**](https://en.uesp.net/wiki/Online:Soul_Crystals_of_the_Returned) | 10652 | 180s |
| [**Storm Atronach Aura**](https://en.uesp.net/wiki/Online:Storm_Atronach_Aura) | 594 | 180s |
| [**Storm Atronach Transform**](https://en.uesp.net/wiki/Online:Storm_Atronach_Transform) | 596 | 18s |
| [**Summoned Booknado**](https://en.uesp.net/wiki/Online:Summoned_Booknado) | 11480 | 18s |
| [**Surprising Snowglobe**](https://en.uesp.net/wiki/Online:Surprising_Snowglobe) | 13105 | 18s |
| [**Shimmering Gala Gown Veil**](https://en.uesp.net/wiki/Online:Shimmering_Gala_Gown_Veil) | 13105 | 18s |
| [**Swarm of Crows**](https://en.uesp.net/wiki/Online:Swarm_of_Crows) | 1384 | 18s |
| [**The Pie of Misrule**](https://en.uesp.net/wiki/Online:The_Pie_of_Misrule) | 1167 | 30s |
| [**Token of Root Sunder**](https://en.uesp.net/wiki/Online:Token_of_Root_Sunder) | 349 | 30s |
| [**Wild Hunt Leaf-Dance Aura**](https://en.uesp.net/wiki/Online:Wild_Hunt_Leaf-Dance_Aura) | 760 | 180s |
| [**Wild Hunt Transform**](https://en.uesp.net/wiki/Online:Wild_Hunt_Transform) | 759 | 180s |

> If the memento you want is not supported feel free to request.

---

> ⚠️ **Console Flow Mode Warning:** If you use the "Force Console Mode" toggle on PC to test and get stuck, type the following into your chat box to revert it:
> `/script SetCVar("ForceConsoleFlow.2", "0")`
> Then type `/reloadui`

<div align="center">

> ### ⚠️ **CONSOLE TESTING NOTES** ⚠️
> This addon was developed and tested on **PC / Steam Deck** (using Force Console Flow for gamepad testing).
> The **Group Sync** feature has not yet been fully tested on actual Console hardware. If you are on Xbox/PlayStation, please report if this feature works for you!

</div>

<div align="center">

> ### 🐞 **BUG REPORTS (PC & CONSOLE)**
> If you encounter any issues, please submit a report here:
> * [ESOUI Bug Portal](https://www.esoui.com/portal.php?id=360&a=listbugs)
> * [GitHub Issue Tracker](https://github.com/MPHONlC/PermMemento/issues)

</div>

## Support

If this project has been useful to you, consider supporting its development:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/aph0nlc)
