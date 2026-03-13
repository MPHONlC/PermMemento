<div align="center">

# [Permanent Memento](https://www.esoui.com/downloads/info4116)

[![ESOUI](https://img.shields.io/badge/PC-ESOUI-orange.svg?style=for-the-badge)](https://www.esoui.com/downloads/fileinfo.php?id=4116)
[![Bethesda Mods](https://img.shields.io/badge/Console-Bethesda.net-black.svg?style=for-the-badge&logo=bethesda&logoColor=white)](https://mods.bethesda.net/en/elderscrollsonline/details/2aa223e9-ba88-45f7-90d3-0a47002c720c/Permanent_Memento)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=for-the-badge)](LICENSE)

Keep your chosen memento effects active permanently.

<p align="center">
  <img src="https://cdn-eso.mmoui.com/preview/pvw15320.png" alt="Permanent Memento UI 1" />
  <br>
  <img src="https://cdn-eso.mmoui.com/preview/pvw15319.png" alt="Permanent Memento UI 2" />
</p>
</div>

---

<a id="install-title"></a>
<div align="center">

[![INSTALLATION & USAGE](https://img.shields.io/badge/INSTALLATION%20%26%20USAGE-purple?style=for-the-badge)](#install-title)
</div>

**Optional Dependencies:**
This addon requires the following optional library to access the settings GUI menu:
* [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)

> [!NOTE]
> **Without the Dependencies:** You can still run the addon entirely independent, and control its 
> settings via built-in slash commands as a standalone utility.

**Usage & Settings:**
* **AUTO-LOOP:** Activate any supported memento via Collections. The addon detects it and begins 
  the loop automatically.
* **MODULE MANAGER:** Use the Settings Toggles to put unused modules to sleep.

---

<a id="features-title"></a>
<div align="center">

[![FEATURES](https://img.shields.io/badge/FEATURES-D4A017?style=for-the-badge)](#features-title)
</div>

* <a id="feat-perm"></a>[![Permanent Mementos](https://img.shields.io/badge/Permanent%20Mementos-forestgreen?style=flat-square)](#feat-perm) : Automates memento effects like Finvir's Trinket, Almalexia’s Lantern, or Wild Hunt Transform. Intelligently pauses during combat, crafting, or specific menus to avoid gameplay interruption.
* <a id="feat-scan"></a>[![Auto Scanner & Learned Data](https://img.shields.io/badge/Auto%20Scanner%20%26%20Learned%20Data-forestgreen?style=flat-square)](#feat-scan) : No longer restricted to hardcoded mementos. Use the **LEARN: Auto-Scan** button to safely scan through all your unlocked mementos, and saves the data gathered.
* <a id="feat-fav"></a>[![Favorites Manager](https://img.shields.io/badge/Favorites%20Manager-forestgreen?style=flat-square)](#feat-fav) : Build a curated list of your favorite effects. All "Randomize" features will prioritize your favorites pool.
* <a id="feat-stats"></a>[![Live Statistics Panel](https://img.shields.io/badge/Live%20Statistics%20Panel-forestgreen?style=flat-square)](#feat-stats) : A real-time dashboard displaying Addon Memory footprint, Total/Session loops, and your Top 5 most used mementos.
* <a id="feat-char"></a>[![Character Profiles](https://img.shields.io/badge/Character%20Profiles-forestgreen?style=flat-square)](#feat-char) : Easily Copy or Delete settings profiles between different characters.
* <a id="feat-sync"></a>[![Group Sync (PC)](https://img.shields.io/badge/Group%20Sync%20%28PC%29-forestgreen?style=flat-square)](#feat-sync) : Synchronize your memento with your party. Supports every memento in the game, as long as you have it unlocked/owned!
* <a id="feat-ui"></a>[![Status UI](https://img.shields.io/badge/Status%20UI-forestgreen?style=flat-square)](#feat-ui) : A draggable UI label shows current memento, player state, and settings status.
* <a id="feat-delay"></a>[![Delay Settings](https://img.shields.io/badge/Delay%20Settings-forestgreen?style=flat-square)](#feat-delay) : Specific settings for Idle, Casting, Resurrecting, Teleporting, Menus etc.
* <a id="feat-alc"></a>[![Auto Lua Cleanup Integration](https://img.shields.io/badge/Auto%20Lua%20Cleanup%20Integration-forestgreen?style=flat-square)](#feat-alc) : Background memory cleaner. Automatically runs when memory hits 400MB <sub>*(PC)*</sub> or 85MB <sub>*(Console)*</sub> to prevent performance stuttering. Only triggers outside combat. For more control use [Auto Lua Memory Cleaner](https://www.esoui.com/downloads/info4388.html) addon.

---

<a id="cmd-title"></a>
<div align="center">

[![SLASH COMMANDS (PC & Console)](https://img.shields.io/badge/SLASH%20COMMANDS%20%28PC%20%26%20Console%29-orange?style=for-the-badge)](#cmd-title)
</div>

* <kbd>/pmem</kbd> <sub>*(or <kbd>/permmemento</kbd>)*</sub> : Help menu and supported memento list.
* <kbd>/pmem [name]</kbd> : Force loop a specific memento.
* <kbd>/pmemstop</kbd> : Stops current loop and any active Auto-Scan.
* <kbd>/pmempause</kbd> : Pause or Resume the current loop.
* <kbd>/pmemcur</kbd> : Print the name of the currently looping memento.
* <kbd>/pmemrand</kbd> : Activate a random memento <sub>*(favors your Favorites list)*</sub>.
* <kbd>/pmemrandzone</kbd> : Toggle randomizing every time you change zones.
* <kbd>/pmemrandlog</kbd> : Toggle randomizing every time you login.
* <kbd>/pmemstats</kbd> : Toggle for the Stats Tracker module.
* <kbd>/pmemrandfav</kbd> : Toggle for Randomization & Favorites logic.
* <kbd>/pmemlearn</kbd> : Toggle for Learning Mode & Auto-Scan hooks.
* <kbd>/pmemperf</kbd> : Toggle Performance Mode <sub>*(Throttles UI refresh from 0.25s to 1.0s)*</sub>.
* <kbd>/pmemclean</kbd> : Run manual Lua memory cleanup sweep.
* <kbd>/pmemautoclean</kbd> : Toggle background Auto Lua Cleanup.
* <kbd>/pmemcsacls</kbd> : Toggle announcements for Auto-Cleanups.
* <kbd>/pmemscan</kbd> : Start the silent Auto-Scan sequence.
* <kbd>/pmemlist</kbd> : List all learned mementos and durations.
* <kbd>/pmemplay [name]</kbd> : Force loop a learned memento.
* <kbd>/pmemwipe</kbd> : Permanently wipe all learned data.
* <kbd>/pmemwipefav</kbd> : Clear your entire favorites list.
* <kbd>/pmemui</kbd> : Toggle status display visibility.
* <kbd>/pmemhud</kbd> : Toggle between HUD mode and Menu-only mode.
* <kbd>/pmemlock</kbd> : Lock/unlock UI dragging.
* <kbd>/pmemresetui</kbd> : Reset UI scale and position to default.
* <kbd>/pmemhudscale [val]</kbd> : Set HUD UI scale <sub>*(0.5 to 2.0)*</sub>.
* <kbd>/pmemmenuscale [val]</kbd> : Set Menu UI scale <sub>*(0.5 to 2.0)*</sub>.
* <kbd>/pmemcsa</kbd> : Toggle all screen announcements.
* <kbd>/pmemfree</kbd> : Toggle Unrestricted Mode <sub>*(loop any memento)*</sub>.
* <kbd>/pmemcombat</kbd> : Toggle Looping while in Combat.
* <kbd>/pmemacct</kbd> : Toggle Account-Wide vs Character settings.
* <kbd>/pmemreset</kbd> : Reset all settings to 0.8.6 defaults.
* <kbd>/pmsyncon</kbd> <sub>*(PC Only)*</sub> : Master toggle for the Group Sync Listener.
* <kbd>/pmsync [name]</kbd> <sub>*(PC Only)*</sub> : Send party sync request.
* <kbd>/pmsyncrand</kbd> <sub>*(PC Only)*</sub> : Send random party sync.
* <kbd>/pmsyncstop</kbd> <sub>*(PC Only)*</sub> : Send party stop request.
* <kbd>/pmsyncdelay</kbd> <sub>*(PC Only)*</sub> : Toggle random delay for syncs.
* <kbd>/pmemlogs</kbd> <sub>*(PC Only)*</sub> : Toggle Chat Logs.
* <kbd>/pmemnospin</kbd> <sub>*(PC Only)*</sub> : Toggle Camera Spin Lock in menus.

---

<a id="mementos-title"></a>
<div align="center">

[![CURRENT SUPPORTED MEMENTOS (No Scan Required)](https://img.shields.io/badge/CURRENT%20SUPPORTED%20MEMENTOS%20%28No%20Scan%20Required%29-D4A017?style=for-the-badge)](#mementos-title)
</div>

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

---

<a id="trouble-title"></a>
<div align="center">

[![TROUBLESHOOTING & SYSTEM LIMITS](https://img.shields.io/badge/TROUBLESHOOTING%20%26%20SYSTEM%20LIMITS-red?style=for-the-badge)](#trouble-title)
</div>

> [!WARNING]
> **Console Flow Mode Warning:**
> If you use the "Force Console Mode" toggle on PC and get stuck, type:
> <kbd>/script SetCVar("ForceConsoleFlow.2", "0")</kbd> followed by <kbd>/reloadui</kbd>

> [!IMPORTANT]
> **⚠️ CONSOLE TESTING NOTES ⚠️**
> This addon was developed and tested on **PC / Steam Deck** <sub>*(using Force Console Flow for gamepad testing)*</sub>.
> The **Group Sync** feature has not yet been fully tested on actual Console hardware. 
> If you are on Xbox/PlayStation, please report if this feature works for you!

---

<a id="license-title"></a>
<div align="center">

[![LICENSE & USAGE](https://img.shields.io/badge/LICENSE%20%26%20USAGE-red?style=for-the-badge)](#license-title)
</div>

**Copyright (c) 2025-2026 @APHONlC. All rights reserved.**

* Don't re-upload or mirror this on ESOUI/Nexus/etc without asking me first.
* Don't release modified versions of this code publicly.
* You're 100% free to tweak the code for your own private use on your machine.

Licensed under the **Apache License, Version 2.0**.

<sub>*(For permissions or inquiries, contact @APHONlC on ESOUI or GitHub.)*</sub>

**How to Attribute This Work:**
If you use, redistribute, or modify this script in your own project, please attribute it:<br>
* **Project Name:** Permanent Memento<br>
* **Author:** @APHONlC<br>
* **License:** Apache License 2.0
* **Original Source:** [Permanent Memento](https://www.esoui.com/downloads/info4116)

---

<div align="center">

**Check out my other addons/projects:**

• [Auto Lua Memory Cleaner](https://www.esoui.com/downloads/fileinfo.php?id=4388#info) 
• [Permanent Memento](https://www.esoui.com/downloads/fileinfo.php?id=4116#info) 
• [Tamriel Trade Center, HarvestMap & ESO-Hub Auto-Updater <sub>*(Linux, macOS, SteamDeck, & Windows)*</sub>](https://www.esoui.com/downloads/fileinfo.php?id=3249#info)

<br>

[![Buy Me A Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/aph0nlc)

<br>

<a id="bug-title"></a>
[![BUG REPORTS](https://img.shields.io/badge/BUG%20REPORTS-ff3300?style=for-the-badge)](#bug-title)

If you encounter any issues, please submit a report here:

**[ESOUI Bug Portal](https://www.esoui.com/portal.php?id=360&a=listbugs)** • **[GitHub Issue Tracker](https://github.com/MPHONlC/PermMemento/issues)**

</div>
