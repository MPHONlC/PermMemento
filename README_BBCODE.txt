[SIZE="5"][COLOR="SeaGreen"]Permanent Memento[/COLOR][/SIZE]

Auto-loops your active memento of choice.

[SIZE="3"][COLOR="DarkOrchid"]Dependencies:[/COLOR][/SIZE]

This addon [b]requires[/b] the following library:
[LIST]
[*] [url="https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html"][COLOR="#FF69B4"]LibAPH[/COLOR][/url] [COLOR="Gray"][i](Required Unified helpers shared with my addons)[/i][/COLOR]
[/LIST]

Optionals for additional features:
[LIST]
[*] [url="https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html"][COLOR="#FF69B4"]LibAddonMenu-2.0[/COLOR][/url] [COLOR="Gray"][i](Keyboard/PC Settings Menu)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info2857-LibHarvensAddonSettings.html"][COLOR="#FF69B4"]LibHarvensAddonSettings[/COLOR][/url] [COLOR="Gray"][i](Console Settings Menu)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info1337-LibGroupBroadcast.html"][COLOR="#FF69B4"]LibGroupBroadcast[/COLOR][/url] [COLOR="Gray"][i](Required for Group Sync)[/i][/COLOR]
[/LIST]

[b]Without the Settings Menu libraries:[/b] You can still run the addon entirely independent, and control its settings via built-in slash commands as a standalone utility.

[SIZE="5"][COLOR="Yellow"]Why use this?[/COLOR][/SIZE]

Opened so many crates had so many cool mementos but you don't even use them? well Mementos go on a short cooldown after each use, and most players don't have time to go through menus or have extra quickslot to re-activate them manually or just forget they even exist. Permanent Memento watches your chosen memento's cooldown and re-triggers it the instant it's ready again. Set it once and forget it.

It also watches for various things where you don't want a memento to be used, like moving, attacking, blocking, casting, swimming, sneaking, mounting up, being dead, teleporting, or opening a menu, and re-triggers after a short configurable grace delay for each, instead of forcing itself to activate even tho you can't [COLOR="Gray"][i](there's already one active or you are dead or swimming)[/i][/COLOR] or shouldn't [COLOR="Gray"][i](you are in combat and dont want to summon your cake and eat it infront of the enemy while it slaps you in the face)[/i][/COLOR]. So you can focus on other things.

[SIZE="5"][COLOR="Yellow"]Features[/COLOR][/SIZE]

[LIST]
[*] [b][COLOR="Lime"]Permanent Memento:[/COLOR][/b] Re-triggers your active memento the instant its cooldown clears, with independent grace delays for movement, combat end, resurrect, teleport, mount, sneak, swim, block, cast, attack, and opening a menu.
[*] [b][COLOR="Lime"]Delay Triggers:[/COLOR][/b] Individually enable or disable which situations pause the auto-loop, instead of an all-or-nothing setting.
[*] [b][COLOR="Lime"]Learned Data:[/COLOR][/b] Scans your collections for mementos you actually own and builds a custom list automatically, if it's not one of the default supported memento.
[*] [b][COLOR="Lime"]Favorites:[/COLOR][/b] Star a subset of your learned mementos for quick random-select without pulling from your entire collection.
[*] [b][COLOR="Lime"]Random Modes:[/COLOR][/b] Auto-pick a random supported [COLOR="Gray"][i](or favorited, or learned)[/i][/COLOR] memento on login, on zone change, or on demand.
[*] [b][COLOR="Lime"]Group Sync:[/COLOR][/b] Broadcast your active memento to grouped players running the addon so everyone loops the same one together (needs LibGroupBroadcast).
[*] [b][COLOR="Lime"]Profiles:[/COLOR][/b] Character-specific or account-wide settings.
[*] [b][COLOR="Lime"]Setup Wizard:[/COLOR][/b] A wizard on first install to asks your preferences.
[*] [b][COLOR="Lime"]Module Manager:[/COLOR][/b] Soft-disable optional feature files [COLOR="Gray"][i](Sync, Wizard, Menu, UI, Migration)[/i][/COLOR] when you don't need them anymore.
[*] [b][COLOR="Lime"](PC & Console) Support:[/COLOR][/b] Full console settings menu and native right-stick UI window dragging on [COLOR="#FF69B4"]Xbox/PlayStation[/COLOR].
[/LIST]

[b][COLOR="RoyalBlue"]Usage:[/COLOR][/b]
[b][color=#00FFFF]Activate[/color][/b] - a memento as you normally would and watch it auto loop after it ends. Activate it again and it should stop the loop.

[b][COLOR="RoyalBlue"]Slash Commands [COLOR="Gray"][i](PC & Console)[/i][/COLOR]:[/COLOR][/b]
[LIST]
[*] [b][color=#00FFFF]/pmem[/color][/b] - Displays commands in chat
[*] [b][color=#00FFFF]/pmsync <name>[/color][/b] - PC only: broadcast a memento to your group
[/LIST]
[spoiler]
[LIST]
[*] [b][color=#00FFFF]/pmemstop[/color][/b] - Stop the current loop
[*] [b][color=#00FFFF]/pmempause[/color][/b] - Pause/resume the current loop
[*] [b][color=#00FFFF]/pmemlist[/color][/b] - List learned mementos
[*] [b][color=#00FFFF]/pmemcur[/color][/b] - Show currently looping memento
[*] [b][color=#00FFFF]/pmemplay <name>[/color][/b] - Start a specific learned memento
[*] [b][color=#00FFFF]/pmemrand[/color][/b] - Loop a random supported memento
[*] [b][color=#00FFFF]/pmemrandfav[/color][/b] - Toggle random-memento-from-favorites on login/zone
[*] [b][color=#00FFFF]/pmemrandlrn[/color][/b] - Toggle random-memento-from-learned
[*] [b][color=#00FFFF]/pmemrandlog[/color][/b] - Toggle random-memento-on-login
[*] [b][color=#00FFFF]/pmemrandzone[/color][/b] - Toggle random-memento-on-zone-change
[*] [b][color=#00FFFF]/pmemlearn[/color][/b] - Toggle learning mode (auto-learn new mementos)
[*] [b][color=#00FFFF]/pmemfree[/color][/b] - Toggle unrestricted mode (bypass activation restrictions)
[*] [b][color=#00FFFF]/pmemscan[/color][/b] - Scan collections for owned memento and add them to the supported list.
[*] [b][color=#00FFFF]/pmemcsa[/color][/b] - Toggle screen announcements
[*] [b][color=#00FFFF]/pmemcombat[/color][/b] - Toggle looping while in combat
[*] [b][color=#00FFFF]/pmembugreport[/color][/b] - Open the bug report copy box
[*] [b][color=#00FFFF]/pmemui[/color][/b] - Toggle the HUD UI window
[*] [b][color=#00FFFF]/pmemlock[/color][/b] - Lock/unlock the HUD UI window
[*] [b][color=#00FFFF]/pmemresetui[/color][/b] - Reset HUD UI window position
[*] [b][color=#00FFFF]/pmemhudscale <n>[/color][/b] - Set HUD UI scale
[*] [b][color=#00FFFF]/pmemmenuscale <n>[/color][/b] - Set menu UI scale
[*] [b][color=#00FFFF]/pmemacct[/color][/b] - Toggle account-wide/character settings
[*] [b][color=#00FFFF]/pmemset <name> <seconds>[/color][/b] - Set a delay by name - [b][color=#00FFFF]/pmemset list[/color][/b] shows valid names
[*] [b][color=#00FFFF]/pmemwipe[/color][/b] - Wipe all learned data
[*] [b][color=#00FFFF]/pmemwipefav[/color][/b] - Wipe all favorites
[*] [b][color=#00FFFF]/pmemwizard[/color][/b] - Re-run the first-time setup wizard
[*] [b][color=#00FFFF]/pmemlibwarn[/color][/b] - Toggle Library Warning Messages
[*] [b][color=#00FFFF]/pmemreset[/color][/b] - Reset all settings to defaults
[*] [b][color=#00FFFF]/pmemclientinfo[/color][/b] - Print client information
[*] [b][color=#00FFFF]/pmemlogs[/color][/b] - PC only: toggle chat log messages
[*] [b][color=#00FFFF]/pmemnospin[/color][/b] - PC only: stop the character-spin animation during activation
[*] [b][color=#00FFFF]/pmemunloadsync[/color][/b], [b][color=#00FFFF]/pmemunloadmenu[/color][/b], [b][color=#00FFFF]/pmemunloadui[/color][/b], [b][color=#00FFFF]/pmemunloadwizard[/color][/b], [b][color=#00FFFF]/pmemunloadmigration[/color][/b] - Module Manager: soft-disable an optional module
[*] [b][color=#00FFFF]/pmsyncon[/color][/b] - PC only: toggle group sync listening
[*] [b][color=#00FFFF]/pmsyncrand[/color][/b] - PC only: broadcast a random supported memento to your group
[*] [b][color=#00FFFF]/pmsyncdelay[/color][/b] - PC only: toggle a random delay before your sync broadcast
[*] [b][color=#00FFFF]/pmsyncstop[/color][/b] - PC only: stop group sync
[/LIST]
[/spoiler]

[b][COLOR="RoyalBlue"]Current Native Supported Mementos:[/COLOR][/b]
[LIST]
[*] [b][url="https://en.uesp.net/wiki/Online:Almalexia%27s_Enchanted_Lantern"]Almalexia's Enchanted Lantern[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Astral_Aurora_Projector"]Astral Aurora Projector[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Blossom_Bloom"]Blossom Bloom[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Dwemervamidium_Mirage"]Dwemervamidium Mirage[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Dwarven_Tonal_Forks"]Dwarven Tonal Forks[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Fargrave_Occult_Curio"]Fargrave Occult Curio[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Fetish_of_Anger"]Fetish of Anger[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Finvir%27s_Trinket"]Finvir's Trinket[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Floral_Swirl_Aura"]Floral Swirl Aura[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Inferno_Cleats"]Inferno Cleats[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Mariner%27s_Nimbus_Stone"]Mariner's Nimbus Stone[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Remnant_of_Meridia's_Light"]Remnant of Meridia's Light[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Soul_Crystals_of_the_Returned"]Soul Crystals of the Returned[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Storm_Atronach_Aura"]Storm Atronach Aura[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Storm_Atronach_Transform"]Storm Atronach Transform[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Summoned_Booknado"]Summoned Booknado[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Surprising_Snowglobe"]Surprising Snowglobe[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Shimmering_Gala_Gown_Veil"]Shimmering Gala Gown Veil[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Swarm_of_Crows"]Swarm of Crows[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:The_Pie_of_Misrule"]The Pie of Misrule[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Token_of_Root_Sunder"]Token of Root Sunder[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Wild_Hunt_Leaf-Dance_Aura"]Wild Hunt Leaf-Dance Aura[/url][/b]
[*] [b][url="https://en.uesp.net/wiki/Online:Wild_Hunt_Transform"]Wild Hunt Transform[/url][/b]
[/LIST]

[center]
[SIZE="5"][COLOR="Red"]Troubleshooting & System Limits[/COLOR][/SIZE]

[b][COLOR="Orange"]&#9888;&#65039; CONSOLE TESTING NOTES &#9888;&#65039;[/COLOR][/b]
This addon was developed and tested on [b][COLOR="#FF69B4"]PC / Steam Deck[/COLOR][/b] [COLOR="Gray"][i](using Force Console Flow for console testing)[/i][/COLOR].

[SIZE="5"][COLOR="Red"]LICENSE & USAGE[/COLOR][/SIZE]

Copyright &#169; 2025-2026 [COLOR="#FF69B4"]@APHONlC[/COLOR]. All rights reserved. See LICENSE.md

[COLOR="Gray"][i](For permissions or inquiries, contact [COLOR="#FF69B4"]@APHONlC[/COLOR] on ESOUI.)[/i][/COLOR]

[SIZE="5"][COLOR="Red"]Credits[/COLOR][/SIZE]
[b][COLOR="Orange"]I would like to thank the following:[/COLOR][/b]
[COLOR="Gray"][i](For providing resources and their awesome projects)[/i][/COLOR]
[LIST]
[*] [url="https://wiki.esoui.com/Main_Page"][color=#fa9c1b]ESOUI Wiki[/color][/url]
[*] [url="https://en.uesp.net/"][color=#fa9c1b]UESP[/color][/url]
[*] [url="https://github.com/esoui/esoui"][color=#fa9c1b]@sirinsidiator[/color][/url]
[*] [url="https://github.com/Flat-Badger-1971/eso-api"][color=#fa9c1b]@Flat-Badger-1971[/color][/url]
[*] [url="https://www.esoui.com/downloads/info7.html"][color=#fa9c1b]@sirinsidiator & @Seerah[/color][/url][COLOR="Gray"][i](LibAddonMenu-2.0)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info584.html"][color=#fa9c1b]@Harven & @votan[/color][/url][COLOR="Gray"][i](LibHarvensAddonSettings)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info1337-LibGroupBroadcast.html"][color=#fa9c1b]@sirinsidiator[/color][/url][COLOR="Gray"][i](LibGroupBroadcast)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info1624.html"][color=#fa9c1b]@SinusPi, @merlight, @Rhyono, @Dolgubon[/color][/url][COLOR="Gray"][i](Zgoo High Isle)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info2601.html"][color=#fa9c1b]@Baertram[/color][/url][COLOR="Gray"][i](Mer Torchbug - Fixed and Improved "Variable inspector/Scripts/Events/and more")[/i][/COLOR]
[/LIST]

[b][COLOR="Orange"]Inspired the idea of Permanent Memento:[/COLOR][/b]
[LIST]
[*] Realizing I had far too many mementos and some of them act like character VFX, I came to ESOUI to see if someone had made an add-on for it. I found some promising ones that worked, until I noticed they had issues or limitations and were abandoned; one needed slash commands every time, and the other ran without them but could be janky at times.
[*] [url="https://www.esoui.com/downloads/info2671-MementoRefresh.html"][color=#fa9c1b]Memento Refresh[/color][/url][COLOR="Gray"][i](@Pretz333)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info3578-PermAlmalexiaPermanentMementos.html#info"][color=#fa9c1b]PermAlmalexia: Permanent Mementos[/color][/url][COLOR="Gray"][i](@Mouton)[/i][/COLOR]
[/LIST]

[b][COLOR="Orange"]Things my addon is compatible with:[/COLOR][/b]
[LIST]
[*] [url="https://www.esoui.com/downloads/info2143.html"][color=#fa9c1b]BeamMeUp[/color][/url][COLOR="Gray"][i](@DeadSoon, @Gamer1986PAN and others)[/i][/COLOR]
[*] [url="https://www.esoui.com/downloads/info2103.html"][color=#fa9c1b]PerfectPixel[/color][/url][COLOR="Gray"][i](@KL1SK, @Baertram, @Dakjaniels)[/i][/COLOR]
[/LIST]

[b][COLOR="Orange"]Testers & Suggestions:[/COLOR][/b]
[LIST]
[*] [color="#FF69B4"]@Drakius192[/color]
[*] [color="#FF69B4"]@phlupp89[/color]
[*] [color="#FF69B4"]@AHB182[/color]
[*] [color="#FF69B4"]@HeyIt'sAmber[/color]
[*] [color="#FF69B4"]@DemonCatDaphne[/color]
[*] [color="#FF69B4"]@imPDA[/color]
[*] [color="#FF69B4"]@Baertram[/color]
[*] [color="#FF69B4"]@SeablueSky[/color]
[*] [color="#FF69B4"]@THAMER_AKATOSH[/color]
[/LIST]

[b][color=#9CD04C]Check out my other addons/projects:[/color][/b]

[LIST]
[*] [url="https://www.esoui.com/downloads/fileinfo.php?id=4388#info"][color=#fa9c1b]Auto Lua Memory Cleaner[/color][/url]
[*] [url="https://www.esoui.com/downloads/fileinfo.php?id=4116#info"][color=#fa9c1b]Permanent Memento[/color][/url]
[*] [url="https://www.esoui.com/downloads/fileinfo.php?id=3249#info"][color=#fa9c1b]Tamriel Trade Center, HarvestMap, ESO-Hub, ESOUI Auto-Updater[/color][/url] [COLOR="Gray"][i](Linux, macOS, SteamDeck, & Windows)[/i][/COLOR]
[/LIST]

[b][color=#ff3300][SIZE="4"]BUG REPORTS[/SIZE][/color][/b]
If you encounter any issues, please submit a report here
[/center]
