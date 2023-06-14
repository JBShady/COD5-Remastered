THIS GIT PAGE (and the readme) IS STILL WIP, I unfortunately follow my own scripting convetions which includes not actually using git until I finish the whole thing. But if you want to follow or save this page for when everything is ready, feel free.

# Call of Duty: World at War Zombies - Remastered Mod
This mod contains bug fixes, quality of life tweaks, fixed inconsistencies, and other improvements for each of the four stock zombie maps. To install & play, download the release and follow the [installation instructions](https://youtu.be/YbOq6Nb9xug). This repository contains the source files of the project. If you would like to modify it, see the instructions below. 

## Created by JB Shady

[YouTube](https://www.youtube.com/c/JBShady)

[Twitter](https://twitter.com/jb_shady_)

## Build Instructions
* If you are downloading the source code and wish to build it, you will need the latest version of the official [Call of Duty: World at War Mod Tools](https://mega.nz/#!5kwyCYYQ!Onn3s3SfJjrombt7b1lUOcFYAtzhg9T_X7c4SvJljbs) installed before continuing. I also recommend installing the community made [V1.1 Launcher patch](https://www.ugx-mods.com/forum/3rd-party-applications-and-tools/48/world-at-war-mod-tools-v1-1-pwned-w-linkerpc-fix/10245/).
* Drag & drop the "raw" folder, "mods" folder, and d3d9.dll (T4M) file from this repository into your game's root folder. Some files will be replaced, this is normal. (Program Files (x86)\Steam\steamapps\common\Call of Duty World at War) 
* Use the mod tools Launcher to compile each of the four mods. (Check "Build mod.ff FastFile" and "Build IWD File" in each)
* If you notice any issues with the mod after compiling, please let me know. However, I tested the files on a fresh install and everything appeared to work.
* Keep in mind that not every script file (.gsc & .csc) in the \mods directory has been modified, but having them all gives you complete control of every aspect of each map

## Change Notes
To be written. notes wip

### General

### Player
* new walking anim
* Added Bo2 death anim
* fixed clientside heartbeat timing
* fixed delays in voiceover to prevent overlapping lines (powerups)
* can no longer pull out equipment while drinking perks/bowie knife

### Zombies
* added cut walking animation that was later used in BO1 to all maps

### HUD
* HUD elements, including ammo, round counter, and perks no longer touch very edge of the screen
* removed objective info screen when pressing tab
* updated HD font
* updated HD HINT_ACTIVATE hand icon
* updated grenade icon and grenade pickup icon to accurately represent the frag grenade type on the map
* updated HD flamethrower icon
* updated HD wood board texture for barriers
* updated perk and powerup HD icons
### Menu
* Improved spacing between any strings that used the HINT_ACTIVATE hand logo
* Capitiization is more consistent in hintstrings
* Added custom co-op loading screen hint message
* Added T4M installation reminder when selecting co-op
* removed intel sponsorship advertisement from loading screen

### Settings

### Perks
* Quick Revive now works on solo giving 3 possible extra lives
* Renamed hintstring from saying to buy "Revive" to "Quick Revive"
* Jugger-nog abilities and health regeneration behaves the same on all maps using improvements from Der Riese

### Powerups
* Carpenter available on all maps
* Max Ammmos now refill equipment on all maps (betties, molotovs, grenades)
* Increased volume of Insta-Kill active loop sound
* Double points now effects Carpenters and Nukes giving +800 and +400 respectively
* Double points stack on all maps including Der Riese like originally scripted 

### Traps
* All electric traps last for 30 seconds with a 30 second cooldown, except for Shi No Numa which is 60 for balance
* All levers return to upward posistion when not in use to prevent glitches but will not be usable until cooldown completes and the lights turn green
* Fixed bug where traps would not slow down player, but players with Jug that do not stand still in traps can still avoid the slow down
* Fixed traps sometimes displaying yellow lights on Der Riese 
* Decreased Hellhound death delay in traps
* Fixed Hellhounds playing normal zombie death sounds on Shi No Numa

### Blockers
* Repairing individual boards gives the player a screenshake like future games
* Repairing barriers only plays the cha-ching sound while actively earning +10 points
* Barriers are now effected by two active double points giving +40

### Last Stand







* Added achievements, stats remembered, like console
* Fixed sound issues m1 launcher, rocket launchers
* Lowered volume of wall breaking barrier sounds
* added character bios
* Tidied up Character Bio messages without changing the content, including small grammatical fixes 
* added map intel page including map name, description, image, and achievements if available
* map is loaded by default with solo button and when going into co-op lobbies 
* co-op settings page now includes any of my custom settings that are relevant for co-op lobbies

New "fake" DVARs created for cheat protected settings, now labeled with "_settings"--this allow players to edit them in-game and on the menu. 
| New Settings | DVAR | Default | Alternate | Description | 
| :---: | :--- | :--- | :--- | :--- |
| **GRAPHICS** |  |  |  |  |
| Fog | `r_fog_settings` | `1` Yes | `0` No | Enables or disables fog. |
| Cinematic Mode | `r_filmUseTweaks_settings` | `0` No | `1` Yes | More saturated color grading. |
| **TEXTURE SETTINGS** |  |  |  |  |
| LOD Range (Rigid) | `r_lodBiasRigid_settings` | `0` Default | `-200` High | Increases range of visible detail on rigid models. |
| LOD Range (Skinned) | `r_lodBiasSkinned_settings` | `0` Default | `-200` High | Increases range of visible detail on skinned models. |
| **SOUND** |  |  |  |  |
| Character Dialogue | `character_dialog` | `0` Yes | `1` No | Enable or disables character dialogue. Locked in-game on co-op. |
| **GAME OPTIONS** |  |  |  |  |
| Gametype | `classic_zombies` | `0` Modified Default | `1` Classic | By default, 24 zombie cap on solo is disabled. Accessible on menu, requires match restart. |
| Last Stand | `classic_perks` | `0` Modified Default | `1` Classic | By default, solo Quick Revive and 45 second bleedout buffs are enabled. Accessible on menu, requires match restart. |
| Enemy Pushing | `grabby_zombies` | `0` Modified Default | `1` Classic | By default, "sticky" zombies are disabled with PushPlayer(false). Accessible on menu, requires match restart. |
| Enemy Intensity | `super_sprinters` | `0` Modified Default | `1` Classic | By default, additional super sprinters are added to prototype and asylum. Accessible on menu, requires match restart. |
| HUD | `cg_draw2D` `r_flame_allowed` | `1` Yes | `0` No | Enables or disables full heads up display. |
| Display FPS | `cg_drawFPS` | `Off` No | `Simple` Yes | Enables or disables FPS counter. |
| Limit FPS | `com_maxfps` | `85` Default | `0` Disabled | Adjusts the max FPS value. |
| Field of View | `cg_fov` | `65` Default | `90` Maximum | Adjustable FOV with slider. |
| View Scale | `cg_fovScale` | `1` Normal | `1.1` Medium or `1.2` High | Scales existing FOV higher or lower by multiplier. |
| Controller Inversion | `input_invertpitch` | `0` Disabled | `1` Enabled | Enables or disables controller inversion. |
| Controller Sensitivity | `input_viewSensitivity` | `0.6` 1 (Low) | Scales up to (Medium), (High), (Very High), (Insane) | Increases or decreases controller sensitivity using the same scale as console. |
| Controller Support | `controller_dummy` | `0` Enable | `1` Enabled | Variable that when enabled, automatically executes "default_controller.cfg". |
| **CONSOLE / EASTER EGGS** |  |  |  |  |
| DVAR Initialization | `dvar_init_dummy` | `0` | `1` | Set to 0 in console to reset all new remastered settings back to default, requires mod relaunch. |
| Character | `character` | `0` Random | `1-4` Player # | Developer command to change character in solo, requires map restart. |
| Health Counter | `cg_drawHealthCount` | `0` | `1` | Developer command to enable health counter in solo, requires map restart. |
| Clearance Code | `bio_access` | `[PASSWORD]` | `?` | Grants access to confidential menus. |
| Sumpf Completion | `sumpf_quest` | `?` | `?` | Indicates completion of new Shi No Numa Easter Egg achievement in 4-player. |
| Factory Completion | `factory_quest` | `?` | `?` | Indicates completion of new Der Riese Easter Egg achievement in 4-player. |



* new menu
* cleaned up all setting pages and menus to remove irrelevant non-zombie related content, as with my mod you can only play zombies
* solo start button
* cooperative now auto loaded, new coop settings, and T4m warning
* map intel page
* character bios





* edited der riese vision
New Easter Eggs
* Added Easter Egg quest to Shi No Numa- new achievement 4 players
* Red barrels
* Character bios on nacht/verruckt

## Nacht Der Untoten
* Added intro screen text
* Added new musical Easter Egg to play "Undone" by shooting all 31 red barrels

### Zombies
* Zombies can now spawn with random combinations of helmets, hats, or gear based on rare % chances.
* Zombies can now use updated animations from future maps for traversing, crawling, attacking, hitting through barriers, walking, running, etc. The exception remains that Nacht zombies are "slower," they are more likely to stop before hitting than on other maps. Nacht-unique "sprint" crawlers are still present.
* Reorganized zombie vocals to have more consistency between ambient, attack, and sprint categories. Added new behind vocals category.
* Added a new type of "super sprinter" that comes after round 10, toggleable in Game Options.
* Replaced the existing grey uniform zombie variant texture with an SS camouflage texture, which fits better with the battlefield atmosphere of the map.

### Characters
* Added characters. Instead of randomizing the player models for each character, each Player (1, 2, 3, 4) always has a consistent player model.
* Added new generic voiceover taken from Campaign assets using factory style code. Includes categories for weapons, low ammo, close kill, damaged close kill, explosion cough, explosion kill, flamethrower kill, headshot kill, killstreak, scared breathing, pain, reload, player surrounded, player responses, powerups, downed/mandown, revived/revived teammate, Insta-Kill melee, and level start.

## Verrückt
* Renamed map from Zombie Verrückt to Verrückt, like in future Call of Duty titles
* Specific box sound

### Zombies
* Zombies can now spawn with random combinations of helmets, hats, bandages, or gear based on rare % chances.
* Added the Nacht "sprint" crawler animation to bridge the consistency between the first two maps.
* Added a second new type of "super sprinter" that comes after round 10, toggleable in Game Options.

### Characters
* Added characters. Instead of randomizing the player models for each character, each Player (1, 2, 3, 4) always has a consistent player model.
* Changed player models and player viewmodel hands to use Marine Raider recon gear. These Marines were supposed to be a "recon team" in the story and it helps differentiate them from the Marines on the previous map. 
* Rewrote voiceover to use factory style code. 
* Reorganized voiceover categories to be less repetitive and more consistent. Added new category for powerups, perks, (cut) Teddy Bear, and (cut) downed lines.

## Shi No Numa
* Added intro screen text
* Flogger changes, cooldown, fx light, dmg is the same in solo vs co-op, kills player instantly no jug/does damage with jug, sets player to crouch, JBleezy fix damaging multiple times in one hit
* Zipline initial cooldown decreased


### Zombies
### Characters

## Der Riese
* Improved intro screen text with complete date
### Zombies
* Fixed Der Riese zombies using flesh colored limbs after being gibbed 

### Characters

## Weapons
* All maps share the same loadout, except for the exceptions described in the table below:

### Loadout
| Category | Nacht Der Untoten  | Verrückt | Shi No Numa | Der Riese | 
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| **Starting Pistols** | Colt M1911 | Colt M1911 | Faction Dependent | Faction Dependent |
| **Bolt-action Rifles** | Kar98k, Springfield | Kar98k, Springfield | Arisaka | Kar98k |
| **Scoped Rifles** | Scoped Kar98k | Scoped Springfield | Scoped Arisaka | Scoped Mosin Nagant |
| **Rocket Launcher** | Panzerschrek | Panzerschrek | M9A1 Bazooka | Panzerschrek |
| **Frag Grenades** | Stielhandgranate | Stielhandgranate | Type 97 Grenade | Stielhandgranate |
| **Speical Grenades** | Molotov | Molotov, Smoke Grenade | Molotov, Sticky Grenade | Molotov, Monkey Bomb |
| **Equipment** | None | Bouncing Betties | Bouncing Betties | Bouncing Betties, Bowie Knife |
| **Entirely New Weapons** | SVT-40 | SVT-40 | SVT-40, DP-28, Type 99 | SVT-40, DP-28, Type 99 |
| **Missing Weapons Added** | Type 100 | Type 100 | None | M1 Garand, Sawed-Off Double Barrel |
| **Wonder Weapons** | Ray Gun | Ray Gun | Ray Gun, Wunderwaffe DG-2 | Ray Gun, Wunderwaffe DG-2 |

### Changes
* All weapons are consistent in stats and appearance between each map.
* All use the best available materials (HD textures from Singleplayer, weathered materials if available, normal/spec maps).
* Certain weapons no longer share ammo reserves because it was a glitchy system where players could create ammo out of thin air.
* All added weapons (and their upgraded variants) use official sounds, stats, names, effects, models, and materials unless non-existent. In such rare cases, they were created from scratch while still matching Treyarch's style.

#### Starting Pistols
* Starting pistols are now faction dependent. Americans spawn with the Colt M1911, Russian with the Tokarev T-33, Japanese with Type 14 Nambu, and German with Walther P38
* All have identical stats and upgrade into explosive pistols
* (Walther P38) removed first raise animation
* (Upgraded, all) Increased reserve ammo from 40 to 42 so it is actually divisible by the magazine capacity (6)
* (Upgraded, all) Changed the last shot animation so the pistol slides do not go back and glitch forward due to being categorized as a grenade launcher
* (Upgraded, all) Added muzzle flash effects
* (Upgraded, all) Added PaP firing soundsand grenade impact sounds instead of using the Rifle Grenade sounds
* (Upgraded, all) Slightly buffed fire rate and damage to make these weapons more rewarding, taking inspiration from how great the Mustang & Sally were in Black Ops 1

#### Type 99
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier LMG (damage, ammo, firerate)
* Increased ADS FOV from 30 to 40 to give more visibility
* Has visible bipod in models for both upgraded/un-upgraded versions
* (Upgraded) Custom model with uniqe UV mapping of silver etching 

#### DP-28
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid/low-tier LMG (damage, ammo, firerate)
* Rebalanced empty reload speed to closer match animation
* Has visible bipod in models for both upgraded/un-upgraded versions
* (Upgraded) Custom model with uniqe UV mapping of silver etching 

#### SVT-40
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier rifle (damage, ammo, firerate)
* (Upgraded) Custom model with uniqe UV mapping of silver etching 

#### M9A1 Bazooka
* Tweaked sprint and raise animation timing to look better
* Has identical damage and ammo stats with the Panzerschreck, used on non-German maps

#### Type 97 Grenade
* Has identical damage and ammo stats with the Stielhandgranate, used on non-German maps

#### Sticky Grenade
* High impact, low radius grenades rebalanced for zombies 
* Uses cut voicelines

#### Scoped Snipers
* Have identical damage and ammo between variants depending on the map
* Names tidied up for more historical accuracy and all have unique in-scope textures
* (Upgraded Mosin Nagant) Uses cut model made by Treyarch along with custom name & stats

#### .357 Magnum
* Decreased reserve ammo from 80 to 78 so it is actually divisible by the weapon capacity (6)
* (Upgraded) Slightly increased fire rate
* (Upgraded) Increased reserve ammo from 80 to 90 so it actually an ammo buff upon upgrading

#### Kar98k
* Fixed Bowie Knife missing sound when knifing with this weapon
* (Upgraded) Fixed missing muzzle flash effect
* (Upgraded) Increased reserve ammo from 60 to 64 so it is actually divisible by the magazine capacity (8)
* (Upgraded) Updated model to remove metal gaps without silver etching

#### Gewehr 43
* (Upgraded) Increased reserve ammo from 170 to 180 so it is actually divisible by the magazine capacity (12)

#### M1A1 Carbine
* Renamed to M1 Carbine for historical accuracy (non-folding stock variant)
* Slightly nerfed damage as this weapon should be similar, if not worse, at pure damage than the M1 Garand
* Slightly buffed mobility to suit this weapon better, being lighter than other rifles in real life
* (Upgraded) Increased magazine size from 15 to 30 so it actually receives a decent ammo buff upon upgrading
* (Upgraded) Updated model to use the 30-round magazine from Multiplayer

#### M1 Garand
* Slightly buffed base rifle damage
* Slightly buffed weapon spread accuracy to balance with the Rifle Grenade version (which makes the rifle less accurate)
* (Upgraded) Increased reserve ammo 150 to 156 so it is actually divisible by the clip capacity (12)
* (Upgraded) Slightly buffed headshot multiplier so it is the highest out of all regular semi-automatic rifles, which fits with its superiority in WWII

#### M1 Garand w/ Launcher
* Slightly buffed base rifle damage
* Decreased mobility to compensate for Rifle Grenades
* Nerfed maximum ammo to balance with regular M1 Garand and compensate for having to carry Rifle Grenades
* When equipping the launcher, the name changes to the name of the grenade launcher for historical accuracy
* (Upgraded) Nerfed maximum rifle ammo to balance with regular M1 Garand and compensate for added Rifle Grenades
* (Upgraded) Renamed equipped launcher to M7000
* (Upgraded) Receives the same headshot multiplier buff as the non-launcher variant
* (Upgraded) Slightly nerfed max launcher explosion radius so that it is less than the upgraded Panzer, there's no reason these should had identical stats when they're different projectiles
* All maps use the proper model where an attachment is fitted under the barrel even when a grenade is not loaded

#### Double-Barreled Shotgun
* Removed Trench Gun ejecting shell effect as the shells are only disposed of when reloading
* (Upgraded) Fixed capitalization in the name
* Fixed small gaps in the model by the hammer
* Uses the model with the smaller grip that does not clip through the player hand

#### Sawed-Off Double-Barreled Shotgun
* Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
* Removed "w/ Grip" from the name
* Small damage boost to both un-upgraded and upgraded version so that this version is a little stronger than the normal double barrel, but with a wider and less accurate fire spread
* Uses the model with the smaller grip that does not clip through the player hand

#### Thompson
* Renamed to M1A1 Thompson for historical accuracy
* (Upgraded) Increased reserve ammo from 250 to 280 so it is actually divisible by the magazine capacity (40)

#### Type 100
* Increased reserve ammo from 160 to 180 so it is actually divisible by the magazine capacity (30)
* Fixed dry fire sound effect not being the SMG sound effect
* Fixed shells ejecting from the wrong position on the weapon
* (Upgraded) Increased reserve ammo from 220 to 240 so it is actually divisible by the magazine capacity (60)
* (Upgraded) Updated models with the standard Pack-a-Punch texture, as this weapon used Treyarch's original silver texture that was not shiny
* Fixed wood material from appearing as all black on some maps

#### PPSh-41
* (Upgraded) Decreased reserve ammo from 700 to 690 so it is actually divisible by the drum mag capacity (115)

#### STG-44
* Fixed capitalization of the "t" to be lowercase for historical accuracy
* (Upgraded) Updated model to remove metal gaps without silver etching

#### BAR
* Renamed to M1918 BAR for historical accuracy
* Slightly decreased mobility to suit its weapon category better
* (Upgraded) Increased stock ammo from 180 to 240 so it actually receives a decent ammo buff upon upgrading, especially because it is not a wall weapon on Der Riese

#### FG42
* Updated viewmodels to look more complete when playing on higher FOVs
* (Upgraded) Recieves telescopic scope attachment and updated model to remove metal gaps without silver etching

#### Browning M1919
* Name rearranged to M1919 Browning for historical accuracy
* Slightly lower mobility compared to the MG42, representing its heavier weight in real life
* Slightly lower ADS time, as this weapon is supposed to be slow to handle
* (Upgraded) Fixed capitalization in the name
* (Upgraded) The Browning now recieves a similar damage multiplier buff compared to the MG42 when upgrading, instead of previously being left behind
* Has visible bipod in models for both upgraded/un-upgraded versions

#### MG42
* Slightly higher mobility compared to the Browning, representing its lighter weight in real life
* Decreased un-upgraded drum magazine capacity from 125 to 100 while still retaining 500 stock ammo to differentiate it from the Browning, which also better represents its historically accurate lower capacity
* Has visible bipod in models for both upgraded/un-upgraded versions
* (Upgraded) Updated model to remove metal gaps without silver etching

#### PTRS-41
* Nerfed reserve ammo to 50 max instead of 60 to match other similar rifles, and also so that the upgraded reserve ammo of 60 feels earned
* Uses the cut sniper voiceover category instead of the PPSh when playing as the four heroes
* (Upgraded) Increased reserve ammo from 60 to 64 so it is actually divisible by the clip capacity (8)
* (Upgraded) Recieves small mobility buff

#### M2 Flamethrower
* Fixed knife delay
* Fixed ADS glitching when using Toggle ADS settings
* Fixed Bowie Knife missing sound when knifing with this weapon
* (Upgraded) Recieves small mobility buff

#### Panzerschrek
* (Upgraded) Recieves small mobility buff

#### Knife
* Knife lunging is more smooth and occurs less often

#### Bouncing Betty
* Decreased delay from 2 seconds to 1 second before activation
* Each player can only have 30 Bouncing Betties placed at once to prevent errors
* When more than 4 mines explode one server frame the server waits another frame before continung to prevent crashes 
* Fixed capitalization in the instruction hintstring
* Hintstring also requires the player to look at the wall chalk, like other weapons

#### Molotov Cocktails
* Added fire FX deaths when zombies are killed
* Received a small buff so they are better than normal grenades while still being far from powerful

#### Frag Grenades
* Recieved a small buff making frag grenades on all maps behave similar to the regular Der Riese style / Black Ops 1
* Fixed plurality on hintstrings
* If a player with full grenades tries to purchase more, the wall model simply appears but no points are lost 
* Grenade suicide does not give you an extra grenade when falling into last stand

#### Ray Gun
* Fixed idle animation to remove blocky left hand
* (Upgraded) Fixed Ray Gun VOX not playing
* (Upgraded) Fixed last stand giving you more than one ammo cartridge

#### Wunderwaffe DG-2
* Does not permanently reduce max health upon zapping yourself
* Fixed missing reload clip on Der Riese for both upgraded/un-upgraded versions
* (Upgraded) Time between arcs is 20% shorter, improving the effectiveness of the weapon
* (Upgraded) Added 3rd person weapon model that has the silver etching material
* (Upgraded) Fixed not playing idle loop sound while holding weapon (electric humming)
* (Upgraded) Fixed not playing the tesla sound after getting a 4 killstreak

#### Mystery Box
* Ray Gun is obtainable from the first Mystery Box location on all maps without having to first get a Teddy Bear 
* All weapons are now always available in the Mystery Box excluding equipment, frag grenades, and starting pistols
* All maps have the same glow effect when the box is opened
* Fixed Mystery Box playing the debris sound for other players after every use once moving locations
* Der Riese & Shi No Numa boxes now share equal weighted odds for Wonder Weapons, which have also been slightly rebalanced

## Special Thanks
* Numan, Phil81334, cristian_m, Gympie5, Tristan, NGcaudle, psulions45 - General modding advice
* MrJayden585 - Zombified SS uniform texture
* Bunz1102 - Secret model & animations work
* Tom Crowley - Secret melee weapon model & animation
* ege115 - New first person sway walking script
* jiggy22 - Original creator of SVT-40, Type 99, and DP-28 upgraded model UV mapping
* Fusorf - Original creator of some assets used in HD shaders
* RealVenom - Fixed Ray Gun viewmodel animation at high FOVs
* Jbird632 - Working sticky grenades on AI & "Reward All Perks" scripts
* Inspired by JBleezy's Black Ops 1 Reimagined mod
* Thank you to the members of both my own & UGX WaW's Discord for helping me along the way
