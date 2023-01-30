# Call of Duty: World at War Zombies - Remastered Mod
This mod contains bug fixes, quality of life tweaks, fixed inconsistencies, and other improvements for each of the four zombie maps. To install & play, download the release and follow the [installation instructions](https://youtu.be/YbOq6Nb9xug). This repository contains the source files of the project, if you would like to modify it see the instructions below. 

## Created by JB Shady

[YouTube](https://www.youtube.com/c/JBShady)

[Twitter](https://twitter.com/jb_shady_)

## Build Instructions
* If you are downloading the source code and wish to build it, you will need the latest version of the official [Call of Duty: World at War Mod Tools](https://mega.nz/#!5kwyCYYQ!Onn3s3SfJjrombt7b1lUOcFYAtzhg9T_X7c4SvJljbs) installed before continuing. I also recommend installing the community made [V1.1 Launcher patch](https://www.ugx-mods.com/forum/3rd-party-applications-and-tools/48/world-at-war-mod-tools-v1-1-pwned-w-linkerpc-fix/10245/).
* Drag & drop the "raw" folder, "mods" folder, and d3d9.dll (T4M) file into your game's root folder. Some files will be replaced, this is normal. (Program Files (x86)\Steam\steamapps\common\Call of Duty World at War) 
* Use the mod tools Launcher to compile each of the four mods. (Check "Build mod.ff FastFile" and "Build IWD File" in each)
* If notice any issues with the mod after compiling, please let me know. However, I tested the files on a fresh install and everything appeared to work.
* Keep in mind that not every script file (.gsc & .csc) in the \mods directory has been modified, but having them gives you complete control of every aspect of each map

## Change Notes
To be written. notes wip

### General

### Player

### Zombies

### HUD

### Menu

### Settings

### Perks

### Powerups

### Traps

### Blockers

### Last Stand

### Weapons




* Improved spacing between any strings that used the HINT_ACTIVATE hand logo
* Capitiization is more consistent in hintstrings
* Added T4M installation reminder when selecting co-op
* Added custom co-op loading screen hint message

* Added achievements, stats remembered, like console
* Fixed sound issues m1 launcher, rocket launchers
* Lowered volume of wall breaking barrier sounds
* Added Bo2 death anim
* Fixed ray gun idle anim for high fovs
* removed intel sponsorship advertisement from loading screen
* added character bios
* Tidied up Character Bio messages without changing the content, including small grammatical fixes 
* added map intel page including map name, description, image, and achievements if available
* HUD elements, including ammo, round counter, and perks no longer touch very edge of the screen
* map is loaded by default with solo button and when going into co-op lobbies 
* co-op settings page now includes any of my custom settings that are relevant for co-op lobbies
* removed objective info screen when pressing tab
* new settings:
* Sound: added setting for disabling voiceover
* Graphics: fog, cinematic mode, and higher LOD (default enabled)
* Game settings: 
* classic_zombies default 0, classic 1
* classic_perks default 0, classic 1
* grabby_zombies default 0, classic
* super_sprinters default 0, classic 1
* cg_drawFPS Simple YES, off NO
* com_maxfps 85 yes no 0
* cg_fov 65-90
* cg_fovscale 1 normal, 1.1 med, 1.2 high
* input_invertpitch disabled 0, enabled 1
* input_viewSensitivity uses same scale from console (Low to Insane)
* controller_dummy enable 0 executed 1 dummy variable used to execute controller script

* new menu
* cleaned up all setting pages and menus to remove irrelevant non-zombie related content, as with my mod you can only play zombies
* solo start button
* cooperative now auto loaded, new coop settings, and T4m warning
* map intel page
* character bios
* new walking anim

* fixed clientside heartbeat timing
* fixed delays in voiceover to prevent overlapping lines (powerups)
*
* updated HD font
* updated HD HINT_ACTIVATE hand icon
* updated grenade icon and grenade pickup icon to accurately represent the frag grenade type on the map
* updated HD flamethrower icon
* updated HD wood board texture for barriers
* updated perk and powerup HD icons

* edited der riese vision
* Fixed Der Riese zombies using flesh colored limbs after being gibbed 
New Easter Eggs
* Added Easter Egg quest to Shi No Numa- new achievement 4 players
* Red barrels
* Character bios on nacht/verruckt
* added cut walking animation that was later used in BO1 to all maps

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
### Zombies
### Characters

## Der Riese
* Improved intro screen text with complete date
### Zombies
### Characters

## Weapons
* All maps share the same loadout, except for the exceptions described in the table below.

### Loadout
| Category | Nacht Der Untoten  | Verrückt | Shi No Numa | Der Riese | 
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| Starting Pistols | Colt M1911 | Colt M1911 | Faction Dependent | Faction Dependent |
| Bolt-action Rifles | Kar98k, Springfield | Kar98k, Springfield | Arisaka | Kar98k |
| Scoped Rifles | Scoped Kar98k | Scoped Springfield | Scoped Arisaka | Scoped Mosin Nagant |
| Rocket Launcher | Panzerschrek | Panzerschrek | M9A1 Bazooka | Panzerschrek |
| Frag Grenades | Stielhandgranate | Stielhandgranate | Type 97 Grenade | Stielhandgranate |
| Speical Grenades | Molotov | Molotov, Smoke Grenade | Molotov, Sticky Grenade | Molotov, Monkey Bomb |
| Equipment | None | Bouncing Betties | Bouncing Betties | Bouncing Betties, Bowie Knife |
| Cut Weapons Added | SVT-40 | SVT-40 | SVT-40, DP-28, Type 99 | SVT-40, DP-28, Type 99 |
| Regular Weapons Added | Type 100 | Type 100 | None | M1 Garand, Sawed-Off Double Barrel |
| Wonder Weapons | Ray Gun | Ray Gun | Ray Gun, Wunderwaffe DG-2 | Ray Gun, Wunderwaffe DG-2 |

### Changes
* All weapons are consistent in stats and appearance between each map, with all using the best materials (either the HD materials from Singleplayer, or the weathered material if present).
* Certain weapons no longer share ammo reserves because it was a glitchy system.
* All added weapons (and their upgraded variants) use their official sounds, stats, names, effects, and materials unless non-existent. In such cases, they were created from scratch while still matching Treyarch's style.

#### Starting Pistols
* Starting pistols are now faction dependent. Americans spawn with the Colt M1911, Russian with the Tokarev T-33, Japanese with Type 14 Nambu, and German with Walther P38
* All have identical stats and upgrade into explosive pistols
* (Walther P38) removed first raise animation
* (Upgraded, all) Increased reserve ammo from 40 to 42 so it is actually divisible by the magazine capacity (6)
* (Upgraded, all) Changed the last shot animation so the pistol slides do not go back and glitch forward
* (Upgraded, all) Added muzzle flash effects
* (Upgraded, all) Added PaP firing soundsand grenade impact sounds instead of using the Rifle Grenade sounds
* (Upgraded, all) Slightly buffed fire rate and damage to make these weapons more rewarding, taking inspiration from how useful the Mustang & Sally are in Black Ops 1

#### Type 99
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier LMG (damage, ammo, firerate)
* Increased ADS FOV from 30 to 40 to give more visibility
* Has visible bipod in model

#### DP-28
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier LMG (damage, ammo, firerate)
* Rebalanced empty reload speed to closer match animation
* Has visible bipod in model

#### SVT-40
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier rifle (damage, ammo, firerate)

#### M9A1 Bazooka
* Tweaked sprint and raise animation timing to look better
* Has identical damage and ammo stats with the Panzerschreck

#### Sticky Grenade
* High impact, low radius. Stats rebalanced for zombies. 
* Uses cut voicelines

#### Type 97 Grenade
* Has identical damage and ammo stats with the Stielhandgranate

#### Scoped Snipers
* Has identical damage and ammo between variants depending on the map.
* Names tidied up for more historical accuracy. All have unique in-scope textures.

#### .357 Magnum
* Decreased reserve ammo from 80 to 78 so it is actually divisible by the weapon capacity (6)
* (Upgraded) Slightly increased fire rate
* (Upgraded) Increased reserve ammo from 80 to 90 so it actually an ammo buff upon upgrading

#### Kar98k
* Fixed Bowie Knife missing sound when knifing with this weapon
* (Upgraded) Fixed missing muzzle flash effect
* (Upgraded) Increased reserve ammo from 60 to 64 so it is actually divisible by the magazine capacity (8)

#### Gewehr 43
* (Upgraded) Increased reserve ammo from 170 to 180 so it is actually divisible by the magazine capacity (12)

#### M1A1 Carbine
* Renamed to M1 Carbine for historical accuracy (non-folding stock variant)
* Slightly nerfed damage as this weapon should be similar, if not worse, at raw damage than the M1 Garand
* Slightly buffed mobility to suit this weapon better, being lighter than other rifles in real life
* (Upgraded) Increased magazine size from 15 to 30 so it actually receives a decent ammo buff upon upgrading

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
* (Upgraded) Nerfed maximum ammo to balance with regular M1 Garand and compensate for added Rifle Grenades
* (Upgraded) Renamed equipped launcher to M7000
* (Upgraded) Receives the same headshot multiplier buff as the non-launcher variant
* (Upgraded) Slightly nerfed max launcher explosion radius so that it is less than the upgraded Panzer, there's no reason these should've had identical stats when they're different projectiles

#### Double-Barreled Shotgun
* Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
* (Upgraded) Fixed capitalization in the name
* (Upgraded) Fixed ADS FOV being way too low 

#### Sawed-Off Double-Barreled Shotgun
* Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
* Removed "w/ Grip" from the name
* Small damage boost to both un-upgraded and upgraded version so that this version is a little stronger than the normal double barrel, but with a wider and less accurate fire spread

#### Thompson
* Renamed to M1A1 Thompson for historical accuracy
* (Upgraded) Increased reserve ammo from 250 to 280 so it is actually divisible by the magazine capacity (40)

#### Type 100
* Fixed dry fire sound effect not being the SMG sound effect
* Increased reserve ammo from 160 to 180 so it is actually divisible by the magazine capacity (30)
* (Upgraded) Increased reserve ammo from 220 to 240 so it is actually divisible by the magazine capacity (60)
* (Upgraded) Updated weapon model and first person model with the standard Pack-a-Punch texture, as this weapon still used Treyarch's original silver texture that was not shiny

#### PPSh-41
* (Upgraded) Decreased reserve ammo from 700 to 690 so it is actually divisible by the drum mag capacity (115)

#### STG-44
* Fixed capitalization of the "t" to be lowercase for historical accuracy

#### BAR
* Renamed to M1918 BAR for historical accuracy
* Slightly decreased mobility to suit its weapon category better
* (Upgraded) Increased stock ammo from 180 to 240 so it actually receives a decent ammo buff upon upgrading, especially because it is not a wall weapon on Der Riese

#### FG42
* Updated viewmodel to look more complete for when playing on higher FOVs

#### Browning M1919
* Name rearranged to M1919 Browning for historical accuracy
* Slightly lower mobility compared to the MG42, representing its heavier weight in real life
* Slightly lower ADS time, as this weapon is supposed to be slow to handle
* (Upgraded) Fixed capitalization in the name
* (Upgraded) The Browning now recieves a similar damage multiplier buff compared to the MG42 when upgrading, instead of previously being left behind
* Has visible bipod in model

#### MG42
* Slightly higher mobility compared to the Browning, representing its lighter weight in real life
* Decreased un-upgraded drum magazine capacity from 125 to 100 to differentiate it from the Browning, which also better represents its historically accurate lower capacity
* Has visible bipod in model

#### PTRS-41
* Nerfed reserve ammo to 50 max instead of 60 to match other similar rifles, and also so that the upgraded reserve ammo of 60 feels earned
* Uses the sniper voiceover category instead of the PPSh for the four heroes
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
* Fixed capitalization in the instruction hintstring

#### Molotov Cocktails
* Received a small buff so they are better than normal grenades, but still far from being powerful

#### Frag Grenades
* Fixed plurality on hintstrings
* Grenade suicide does not give you an extra grenade when falling into last stand

#### Ray Gun
* (Upgraded) Fixed Ray Gun VOX not playing
* (Upgraded) Fixed last stand giving you more than one ammo cartridge

#### Wunderwaffe DG-2
* Does not permanently reduce max health or remove Jugger-Nog effects 
* Fixed missing reload clip on Der Riese
* (Upgraded) Fixed not playing idle loop sound while holding weapon (electric humming)
* (Upgraded) Fixed not playing the tesla sound after getting a 4 killstreak

#### Mystery Box
* Ray Gun is obtainable from the first Mystery Box location on all maps without having to first get a Teddy Bear 
* All weapons are now available in the Mystery Box--excluding equipment, frag grenades, and starting pistols.
* All maps have the same glow effect when the box is opened


## Special Thanks
* MrJayden585 - SS uniform texture

