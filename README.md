# Call of Duty: World at War Zombies - Remastered Mod
This mod contains bug fixes, quality of life tweaks, fixed inconsistencies, and other improvements for each of the four stock zombie maps. To install & play, download the release and follow the [installation instructions](https://youtu.be/YbOq6Nb9xug). This repository contains the source files of the project. If you would like to modify it, see the instructions below. 

## Created by JB Shady

[YouTube](https://www.youtube.com/c/JBShady)

[Twitter](https://twitter.com/jb_shady_)

[Donate](https://paypal.me/alexmintz01)

## Build Instructions
* If you are downloading the source code and wish to build it, you will need the latest version of the official [Call of Duty: World at War Mod Tools](https://mega.nz/#!5kwyCYYQ!Onn3s3SfJjrombt7b1lUOcFYAtzhg9T_X7c4SvJljbs) installed before continuing. I also recommend installing the community made [V1.1 Launcher patch](https://www.ugx-mods.com/forum/3rd-party-applications-and-tools/48/world-at-war-mod-tools-v1-1-pwned-w-linkerpc-fix/10245/).
* Drag & drop the "raw" folder, "mods" folder, and d3d9.dll (T4M) file from this repository into your game's root folder. Some files will be replaced, this is normal. (Program Files (x86)\Steam\steamapps\common\Call of Duty World at War) 
* Use the mod tools Launcher to compile each of the four mods. (Check "Build mod.ff FastFile" and "Build IWD File" in each)
* If you notice any issues with the mod after compiling, please let me know. However, I tested the files on a fresh install and everything appeared to work.
* Keep in mind that not every script file (.gsc & .csc) in the \mods directory has been modified, but having them all gives you complete control of every aspect of each map

<p align="center">
nazi_zombie_remastered (Nacht Der Untoten) 
<br>
nazi_zombie_remastered_dlc1 (Verrückt)
<br>
nazi_zombie_remastered_dlc2 (Shi No Numa)
<br>
nazi_zombie_remastered_dlc3 (Der Riese)
</p>

## Change Notes

### General
* All maps now use the same (more optimized) zombie spawning formula as Der Riese except for the first few rounds of co-op on Verrückt, fixing the unbalanced 24-limit on solo. Togglable with the new "Gametype" setting in Game Options.
* All maps now make use of improved scripting and bug fixes that were only added into the later DLCs. 
* AI no longer pushes, removing the "grabbing" effect where zombies slowed the player down. Togglable with the new "Enemy Grabbing" setting in Game Options.
* Added all zombiemode achievements that were on the console version (as well as custom achievements for maps that didn't have them) complete with notifications, sounds, icons, and a menu.
* Added stats tracking based on the console version for achievements, personal records, time played, rank, and other miscellaneous stats on a per-map basis that save to the player's profile.
* Purchase sounds that previously played on triggers now play on the player/object itself to prevent potential entity sound bugs
* Upscaled wood board texture by 2x to appear slightly less blurry.
* Cheats disabled by default

### Player
* Player now spawns as a random character in solo
* All characters now use historically accurate starting pistols and hand viewmodels that match their corresponding player model, all using assets from elsewhere in the game
* Spectators can easily switch to 1st person with proper HUD messages as seen on the console version.  
* Increased backwards and sideways movement speed to match closer to the console version.
* FOV does not reset upon map restart, map reload, teleporting, or respawning.
* Splash damage has been rebalanced and is equal on all maps and across any # of players. Explosives damage deals differing radius damage depending on impact type and proximity.
* Fall damage no longer gives shellshock effect unless fall damage takes more than 30% of your health
* Fall damage occurs after 150 units instead of 200 units, similar to future Call of Duties that all use 128 units as the baseline. 
* Added weapon bobbing and crawl bobbing like future Call of Duties, weapons no longer just lower while walking 
* Added cut sound effect when player lands on the ground after jumping
* Slightly increased footstep volume
* Players drop their hands onto the ground when dying as the Game Over screen appears, using an animation ported from Black Ops II
* Fixed clientside sounds and effects from looping or playing at different speeds depending on the client's FPS
* Fixed player being able to pull out equipment while drinking pe3rks or purchasing the Bowie Knife 
* Fixed voiceover categories played with a delay having the ability to overlap with other lines
* Fixed red screen breaking after bleeding out & respawning
* Fixed crashes from being able to purchase things while falling down when dying
* Player no longer receives a free Colt when they have no weapons, instead the screen is just blank like future zombie games.
* Voiceover interactions disabled on a player size of 1 to fix character responses sometimes playing in solo

### Zombies
* Zombies have glowing eye effects in all DLCs now.
* In addition to Round 1, Round 2 will also only be walkers to allow for more gradual pacing.
* All maps use various improvements to zombie logic and pathing 
* Zombies can now spawn with random combinations of helmets, hats, bandages, headbands, or other gear based on rare percent chances and the map's setting, with the first two maps using more equipment and the last two having less
* Helmets can be shot off a zombie's head and fling in a direction based on the damage and will play a special sound
* Gibs and helmets shot off of zombies disappear quicker depending on the amount of playerse to hopefully reduce visual glitches
* Zombies must be on the same floor/actually directly behind players to still play their behind vocals
* Added missing gore fx when gibbing zombie torsos
* Zombies can gib from special scripted explosive damage including Betties, Satchels, and Mortars
* Fixed potential leak when zombies rise out of ground
* Zombie neckshots no longer count as headshots on the stats page, so now the scoreboard headshot value will reconcile with the menu stats

### HUD
* Damage indicators are only fully faded when player is actually at full health 
* HUD elements no longer touch the very edge of the screen, including the ammo counter, round counter, and perk shaders.
* Added a game option that allows for the D-pad equipment and action hintstrings to actually reflect using a controller, using textures from the console version.
* Hintstrings now show a yellow colored interact key, similar to Multiplayer and all other Call of Duties.
* Removed objective info screen when pressing tab in solo.
* Updated the World at War font with an upscale to look better on HD displays, fixing the pixelated round counter
* Updated crosshair texture with custom made HD version
* Updated the activation hand logo on hintstrings with a custom made HD version
* Updated grenade icon and grenade pickup icon to accurately represent the frag grenade in the player's inventory
* Updated flamethrower icon with custom HD version still in the correct art style
* Updated perk and powerup shaders with custom made HD versions still in the correct art style
* Created new better looking icons for Sticky Grenades and Type 97 frags still using the correct art style.
* Changed the Monkey bomb icon to look more recognizable while still in the correct  art style.
* Removed grenade indicators from special grenades because these grenades cannot be picked up and display the incorrect icon
* Fixed the round counter not changing white when going to round 6.
* Fixed yellow point text getting offset when players disconnected.
* All HUD icons disappear when the player dies for the game over screen
* Controller Mode setting switches hints to use Xbox gamepad icons for hintstrings and the D-pad so that players can enjoy a more immersive controller experience. Patches are available to change the look/use PlayStation style icons.
* (T4M) Pressing tab in solo now shows the zombie scoreboard.

### Menu
* Start game button added for quick solo play
* Overhauled main menu to remove all non-zombiemode related pages and buttons. While running this mod, it is purely a Nazi Zombies experience. Added a reminder when heading to co-op for all players to install T4M.
* Co-op menus auto load the selected map and the co-op host settings page now includes the relevant settings added Game Options.
* Added Intel menu with an image/description of the map, achievements, and map stats/leaderboard.
* Added Character Bios menu, ported from console but with slight grammatical and layout fixes for the best PC experience. Easter egg bios on first two maps, hidden by default.
* Many new options seamlessly integrated into the existing menus with settings for FOV, the HUD, controller support, gametype/AI, fog, LOD, dialogue, and more all detailed in the table below.
* Improved spacing between hintstrings and the activation hand logo
* Capitalization is more consistent in hintstrings
* Added custom co-op loading screen hint messages relating to the mod
* Removed intel sponsorship advertisements from all loading screens
* Hide Mutliplayer progress summary report when player ends game or disconnects

### Settings
* Both new settings have been created and also useful existing settings have been added to the options pages for easier access
* New "fake" DVARs created for cheat protected settings, now labeled with "_settings"--this allow players to edit them in-game and on the menu.
* All settings and stats are saved to the selected profile even if the game is closed, crashes, switches profiles, etc.
* Leaderboard records do not save if player has set Gametype or Difficulty to "Classic," as this makes the mod substantially easier  
* Anti-aliasing now goes up to 8x

| New Settings | DVAR | Default | Other Values | Description | 
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
| Difficulty | `classic_perks` | `0` Modified Default | `1` Classic | By default, solo Quick Revive, Double Tap buff, and 45 second bleedout is enabled. Accessible on menu, requires match restart. |
| Enemy Grabbing | `grabby_zombies` | `0` Modified Default | `1` Classic | By default, "sticky" zombies are disabled with PushPlayer(false). Accessible on menu, requires match restart. |
| Enemy Intensity | `super_sprinters` | `0` Modified Default | `1` Classic | By default, additional super sprinters are added to prototype and asylum. Accessible on menu, requires match restart. |
| HUD | `cg_draw2D` `r_flame_allowed` | `1` Yes | `0` No | Enables or disables full heads up display. |
| Display FPS | `cg_drawFPS` | `Off` No | `Simple` Yes | Enables or disables FPS counter. |
| Limit FPS | `com_maxfps` | `85` Default | `0` Disabled | Adjusts the max FPS value. |
| Field of View | `cg_fov` | `65` Default | `90` Maximum | Adjustable FOV with slider. |
| View Scale | `cg_fovScale` | `1` Normal | `1.1` Medium or `1.2` High | Scales existing FOV higher or lower by multiplier. |
| Controller Mode | `cg_drawDpadHUD` | `0` Disabled | `1` Enabled | DVAR switches HUD to use console style D-pad icons, but menu button executes additional controller bind commands. |
| **CONTROLS** |  |  |  |  |
| Controller Triggers | `gpad_flip_triggers` | `0` Default | `1` Flipped | Flips triggers to top row. |
| Controller Inversion | `input_invertpitch` | `0` Disabled | `1` Enabled | Enables or disables controller inversion. |
| Controller Sensitivity | `input_viewSensitivity` | `0.6` 1 (Low) | Scales up to (Medium), (High), (Very High), (Insane) | Increases or decreases controller sensitivity using the same scale as console. |
| **CONSOLE COMMANDS** |  |  |  |  |
| DVAR Initialization | `dvar_init` | `0` | `1` | Set to 0 in console to reset all new remastered settings back to default, requires mod relaunch. |
| Zombiemode Developer | `zombiemode_dev` | `0` | `1` | Developer command to enable experimental features of the mod, requires map restart. |
| Character | `character` | `0` Random | `1-4` Player # | Developer command to change character in solo, requires map restart. |
| Health Counter | `cg_drawHealthCount` | `0` | `1` | Developer command to enable health counter in solo, requires map restart. |
| D-pad Logos | `cg_drawDpadLogos` | `1` | `0` | Disable or enable background D-pad logos when using controller if you just want neutral arrows. |
| Clearance Code | `bio_access` | `[PASSWORD]` | `?` | Grants access to confidential menus. |
| Sumpf Completion | `sumpf_quest` | `0` | `?` | Indicates completion of new Shi No Numa Easter Egg achievement with Richtofen in lobby. |
| Factory Completion | `factory_quest` | `0` | `?` | Indicates completion of new Der Riese Easter Egg achievement. |

### Blockers
* Repairing individual boards gives the player a screenshake like future games
* Repairing barriers only plays the cha-ching sound while actively earning +10 points
* Barriers are now effected by two active double points giving +40
* Zombies are less likely to climb through barriers as they are being boarded up

### Mystery Box
* Ray Gun is obtainable from the first Mystery Box location on all maps without having to first get a Teddy Bear 
* All weapons are now always available in the Mystery Box excluding equipment, frag grenades, and starting pistols
* All maps have the same glow effect when the box is opened
* All maps use the same hintstring functionality for when to show/hide it
* Reduced Mystery Box cooldown from 3 seconds to 2 seconds
* Added "no purchase" sound effect when player does not have enough points
* Fixed Mystery Box playing the debris sound for other players after every use once moving locations
* Fixed Mystery Box playing the lid close sound when floating away during a Teddy Bear even though the lid never closes
* Fixed Mystery Box jingle stopping when too many other sounds play
* Fixed Wonder Weapon stinger sound effect sometimes not playing
* Der Riese & Shi No Numa boxes now share equal weighted odds for Wonder Weapons, which have also been slightly nerfed so the Ray Gun and DG-2 are not overly common
* Verrückt & Nacht Der Untoten boxes remain a full lottery, except for the Teddy Bear which is still slightly less forgiving than on later maps

### Powerups
* Carpenter available on all maps, togglable under the "Gametype" setting in Game Options.
* Max Ammmos now refill equipment on all maps (betties, molotovs, grenades)
* Fixed Insta-Kill special melee voiceover still being able to play from non-melee kills
* Increased volume of Insta-Kill active loop sound
* Double points now effects Carpenters and Nukes giving +800 and +400 respectively
* Double points stack on all maps like originally scripted. However, it has been capped at only giving up to 4x for balance. 
* Fixed killing groups of zombies instantly allowing the player to bypass the powerup limit

### Perks
* Quick Revive now works on solo giving 3 possible extra lives, togglable under the "Difficulty" setting in Game Options.
* Renamed hintstring from saying to buy "Revive" to "Quick Revive".
* Jugger-nog abilities and health regeneration behaves the same on all maps using improvements from Der Riese.
* Double Tap Root Beer now gives a 33% damage buff for bullet weapons, togglable under the "Difficulty" setting in Game Options.
* Originally a bug, Perks disabling for a second after purchase is now a feature representing the machine cycling bottles, purchase hintstring now temporarily disappears during this

### Traps
* All electric traps last for 30 seconds with a 30 second cooldown, except for Shi No Numa which has 60 second cooldowns for balance reasons
* All levers return to upward position when not in use to prevent glitches
* Fixed bug where traps would not slow down player, but players with Jug that do not stand still in traps can still avoid the slow down
* Fixed traps sometimes displaying yellow lights on Der Riese 
* Fixed potential thread leaks with electric traps and flogger trap
* Decreased Hellhound death delay in traps
* Fixed Hellhounds playing normal zombie death sounds on Shi No Numa
* Added "no money" sound effect to all levers when player does not have enough points 

### Last Stand
* Self revives take 10 seconds, zombies will run away from the player, and the player is equipped with an upgraded version of their starting pistol
* Player does not talk about kills or powerups while in last stand in solo
* Downing and reviving point loss/reward is the same across all maps
* The co-op bleedout time has been increased from 30 seconds to 45 seconds, togglable under the "Difficulty" setting in Game Options
* Players equipped with better pistols than their designated last stand pistol (normal in co-op, upgraded in solo) will now pull them out in last stand based on an a hierarchy: Ray Gun has precident, then explosive pistols, then the .357
* Player receives 3 magazines for regular pistols and only 1 cartridge for both the un-upgraded/upgraded Ray Gun
* If a player has no ammo for a pistol before they down, then that weapon will not be counted in the above hierarchy
* If a player recieves a Max Ammo or the round changes while down, they will not be given grenades/explosive equipment
* Disabled leaning while in last stand

### Music & Sounds
* Slightly increased Easter Egg song volumes and now all songs now play through the music channel
* All Easter Egg songs will play a 2 second fadeout if the game ends and switches to the intermission music
* Added soundtrack/studio quality versions of the Easter Egg songs
* Removed cha-ching sound when activating DLC1 and DLC2 Easter Egg songs
* All maps now use the same MusicState system from Der Riese for the background ambient music and intermission music, allowing for better audio mixing where only one song can play at a time
* Game over music fades properly in co-op 
* Fixed sound issues with grenade launchers/rocket launchers not playing correctly, potentially attributed to mod tools
* Lowered volume of wall breaking barrier sounds so they cannot be heard from as far away

## Nacht Der Untoten
* Added "mission intro" in the bottom left corner to include storyline accurate info.
* Added new musical Easter Egg that plays "Undone" by shooting all 31 red barrels
* Red barrels slightly buffed and also do AOE fire damage
* Slightly buffed explosive truck values
* KZMB radio now pauses when playing the main Easter Egg song or game over intermission music 
* KZMB radio now works in co-op for players other than the host
* Using audio from campaign, added an entire set of new voicelines based off of the style of the other maps (headshots, kills, powerups, weapons, surrounded, downed, etc.).
* 4 characters with around 100 lines each spread out through about 30 categories, including new categories and interactions not seen on other maps, inspired by both the original trailer and DLC1 trailer.
* Removed Scoped Kar98k from the box so that the cabinet is actually unique and useful while still being a "troll" that does not tell you what you are purchasing
* Added Satchel Charges into a "searchable" mysterious crate akin to the Sniper Cabinet with a working trigger, animation, and custom model.
* Satchel Charge Crate and Sniper Cabinet now both use unique sounds when opened
* Instead of randomizing the player models for each character, each Player (1, 2, 3, 4) always has a consistent and unique player model/face/gear.
* Replaced camoflauged Pacific-theater helmets with regular bare metal helmets
* Zombies can now use updated animations from future maps for traversing, crawling, attacking, hitting through barriers, walking, running, etc. (The Nacht-unique "sprint" crawler is still present)
* The exception remains that zombies on this map are still "slower," with custom balanced hit animations where they are more likely to stop before hitting.
* Reorganized zombie vocals to have more consistency between ambient, attack, and sprint categories with less repetition.
* Added very quiet and rare behind vocals, with instead the more common indicator of being snuck up on is the character begins nervously breathing
* Added a cut rare type of "super sprinter" that comes after round 10, toggleable under "Enemy Intensity" in Game Options.
* Replaced the existing grey uniform zombie variant texture with an SS camouflage texture, which fits better with the battlefield atmosphere of the map.

## Verrückt
* Renamed map from Zombie Verrückt to just Verrückt, similar to how it was named in future Call of Duty titles
* On co-op low rounds, the zombie spawning formula still has a separate calculation that spawns more zombies than normal to account for the players being split up and ensuring both sides of the spawn face enough of a threat
* On this map, the team of Marines now uses camouflage raider gear to reference how they were supposed to be a recon team in the storyline. First person viewmodel also reflects this, and this also helps differentiate the two different Marine crews. 
* Instead of randomizing the player models for each character, each Player (1, 2, 3, 4) always has a consistent and unique player model/face/gear.
* Added the Nacht "sprint" crawler animation to bridge the consistency between the first two maps.
* Added a second new cut "super sprinter" that comes after round 10, toggleable under "Enemy Intensity" in Game Options.
* Added rare co-op voiceover Easter Egg when player 4 turns on the power
* Fixed the Bouncing Betty model sometimes moving in the wrong direction when purchasing off the wall 
* Fixed vision file changing when going downstairs in the power room
* Fixed music audio dropping too much when in shower room zone
* Added easter egg scripted dialogue for Player 4
* Added easter egg PA system music that can play after using the traps too much
* Uncensored Nazi flag, as seen in the trailer of the map

## Shi No Numa
* Added "mission intro" in the bottom left corner to include storyline accurate info.
* Added "level start" voiceover using generic character quotes.
* Added cut jap_walk_v4 animation as another walker variant.
* Added cut jap_run_v6 animation as another rarely occuring runner variant.
* Added cut jap_run_v5 animation as another rarely occuring sprinter variant
* Added unused swamp perk machine textures from the game files.
* Re-added unique hintstrings for each Perk machine thanks to T4M's increased hintstring limit.
* Added cut hellhound round "howling" sound that was only used on the PS3 version. 
* Hellhound functionality includes changes made in the next DLC including a health buff, but it is still slightly lower than Der Riese to account for no Pack-a-Punch.
* Fixed hellhounds playing normal zombie death sounds in electric traps.
* Carpenter voiceover uses cut repurposed lines that were originally made for general barrier repairing.
* When picking up a powerup, characters choose from three lines instead of one. 
* When opening the second or third hut, there is a 50% chance of the closest player commenting on the randomization of perks.
* When a perk is decided, there is a higher chance of the closest player within a close proximity shouting the perk's name.
* Fixed perk machines from clipping into the wall in the Dr.'s hut. 
* Reduced Arisaka wallbuy and chalk from clipping into wood board
* Flogger now damages the player only once per rotation and also sets the player into crouch
* Flogger now damages the player the exact same between solo and co-op, killing instantly without Jug
* Slightly reduced flogger damage delay 
* Fixed flogger light fx from spawning clipped into the wall
* Fixed flogger freezing zombies when too many get ragdolled
* Zipline cooldowns decreased to 15 seconds for the initial cooldown and 30 for the regular cooldowns.
* Zipline no longer can glitch player maxhealth values to the wrong value. 
* Added zombie jump down animation from upper zipline station so zombies do not look like they are holding an invisible gun.
* Fixed Richtofen's name being cut off in co-op loadscreen appearing as a typo
* Added hidden easter egg quest including secret items and hidden achievement, required to complete Der Riese quest

## Der Riese
* Updated "mission intro" in the bottom left corner to include the full storyline accurate date.
* Changed vision file to give the map a bluer and dark tint rather than the original greyish-green look.
* Added cut German walk_v9 animation that was later used in Black Ops I
* Added cut 5th Maxis handheld radio from the game files that was used on the IOS version. 
* Added cut rare voiceover that can play after teleporting. (5% chance)
* Added cut rare voiceover that can player after picking up a power up. (3% chance)
* Added cut Easter Egg voiceover for the "Teddy is a liar" wall writing. (Requires scope)
* Increased percent chance for voiceover when interacting with Easter Egg items and also added one unused Takeo line to the Corkboard cycle. (50% chance)
* Increased percent chance for general storyline VOX early game. (5% chance)
* Increased PaP "waiting" voiceover odds to play 50% of the time rather than 8%, closer to future zombie games.
* Fixed the loose change Easter Egg so that it actually gives a real 30 points while only showing +25 on the HUD, this is to prevent confusion because the HUD rounds score to the nearest tens.
* Added extra checks so players will never talk about needing to link the teleporters or open Pack-a-Punch after the task is already completed.
* Pack-a-Punch hintstring disappears when you are holding an upgraded weapon or when another player's weapon is in the machine.
* Added several unused voiceover lines when a player picks up the Carpenter power up.
* Player surrounded voiceover now also plays in solo, but without the responses from other characters and at a lower percent chance.
* The post-teleporter FOV effect now uses your actual FOV when doing the effect instead of zooming out into the default 65.
* Tweaked teleporter cooldown message to be plural, as all teleporters are set on cooldown after one is used
* Fixed teleporter cooldown message showing on top of other teleporters that still need to be linked, which are not effected by the cooldown. 
* Fixed Der Riese zombies using flesh colored limbs after being gibbed 
* Fixed potential leak with Monkey Bombs
* Added collision to the metal sheet on the catwalk barrier 
* Added hidden easter egg quest including secret items and hidden achievement
* Improved PaP and Bowie Knife triggers with improvements from Black Ops I including but not limited to hiding them when they cannot be purchased

## Voiceover
* Fixed low ammo quote spam and thread leak
* Rewrote voiceover for ealier maps to use improved code from later DLCs that reduced the repetiveness of how lines are selected 
* Rewrote voiceover interactions so they function properly
* Player surrounded voiceover only plays when zombies are directly around the player, not upstairs or downstairs
* (Verrückt Marines) Added generic pain voiceover to allign with the other three modded maps.
* (Verrückt Marines) Reorganized voiceover categories to be less repetitive and more consistent
* (Verrückt Marines) Added new categories for powerups, perks, Teddy Bear (cut), and downed lines (cut)
* (4 Heroes) Added cut sniper pickup voiceover found in the game files.
* (4 Heroes) Added cut hellhound kill voiceover found in the game files with a 25% chance of it playing per kill.
* (4 Heroes) Added cut voiceover that plays when a player downs.
* (4 Heroes) Added cut reload voiceover that only plays when reloading an empty LMG when in close proximity to zombies 
* (4 Heroes) Added cut pain voiceover that plays when a player is damaged. 
* (4 Heroes) Added cut exert voiceover that plays about 75% of the time a player damages a zombie with melee, and 100% of the time when a player kills a zombie with melee (Unless other dialogue is queued, in which case it over rules the exert sound).
* (4 Heroes) Added several cut voiceover lines that play after a player is revived, instead of only alternating between 2 possible lines.
* (4 Heroes) Added cut Takeo Panzershrek voiceover
* (4 Heroes) Unlocked a few cut unused voiceover lines for weapons that were never called in the scripts but were already included in the soundaliases (MP40, BAR, Shotgun, Wunderwaffe, Monkey Bomb).
* (4 Heroes) Reworked "no money" sounds and voiceover for purchasable items when a player does not have enough points:
* Wall Weapons: Now have a chance of saying a cut voiceover line, the standard groan, or nothing.
* Mystery Box: Now has a chance of saying two cut voiceover lines, the standard groan, or nothing.
* Perks/PaP: Now have a chance of playing the groan instead of only playing the voiceover dialogue to make it less repetitive.

## Weapons
* All weapons are 100% consistent in stats, behavior, and appearance between each map.
* All use the best available materials (HD textures from Singleplayer, weathered materials if available, normal/spec maps).
* Weapons cannot share ammo reserves anymore because it was a glitchy system where players could create ammo out of thin air.
* All added weapons (and their upgraded variants) use official sounds, stats, names, effects, models, and materials unless non-existent. In such rare cases, they were created from scratch while still matching Treyarch's style.
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
| **Equipment** | Satchel Charges, Mortar | Bouncing Betties, Bipods | Bouncing Betties, Bayonets | Bouncing Betties, Bowie Knife |
| **Entirely New Weapons** | SVT-40 | SVT-40 | SVT-40, DP-28, Type 99 | SVT-40, DP-28, Type 99 |
| **Missing Weapons Added** | Type 100, PPSh-41 | Type 100 | None | M1 Garand, Sawed-Off Double Barrel |
| **Wonder Weapons** | Ray Gun | Ray Gun | Ray Gun, Wunderwaffe DG-2 | Ray Gun, Wunderwaffe DG-2 |

#### Starting Pistols
* Starting pistols are now faction dependent. Americans spawn with the Colt M1911, Russian with the Tokarev T-33, Japanese with Type 14 Nambu, and German with Walther P38
* All have identical stats and upgrade into explosive pistols
* (Walther P38) removed first raise animation
* (Upgraded, all) Increased reserve ammo from 40 to 42 so it is actually divisible by the magazine capacity (6)
* (Upgraded, all) Changed the last shot animation so the pistol slides do not go back and glitch forward due to being categorized as a grenade launcher
* (Upgraded, all) Added muzzle flash effects
* (Upgraded, all) Added PaP firing sounds and grenade impact sounds instead of using the Rifle Grenade sounds
* (Upgraded, all) Slightly buffed fire rate and damage to make these weapons more rewarding, taking inspiration from how great the Mustang & Sally were in Black Ops I

#### Type 99
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier LMG (damage, ammo, firerate)
* Increased ADS FOV from 30 to 40 to give more visibility
* Has visible bipod in models for both upgraded/un-upgraded versions
* (Upgraded) Custom model with unique UV mapping of silver etching 

#### DP-28
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid/low-tier LMG (damage, ammo, firerate)
* Rebalanced empty reload speed to closer match animation
* Has visible bipod in models for both upgraded/un-upgraded versions
* (Upgraded) Custom model with unique UV mapping of silver etching 

#### SVT-40
* Stats for upgraded/un-upgraded slightly rebalanced from default SP values to fit for zombies as a mid-tier rifle (damage, ammo, firerate)
* (Upgraded) Gains 3-round burst functionality
* (Upgraded) Custom model with unique UV mapping of silver etching 

#### M9A1 Bazooka
* Tweaked sprint and raise animation timing to look better
* Has identical damage and ammo stats with the Panzerschreck, used on non-German maps

#### Type 30 Bayonets
* Custom wallbuy that behaves the same as real wallbuys with chalk, model, and a LookAt style trigger
* High damage melee weapon that can be equipped on valid Japanese weapons
* Working gibs, blood splats, and voiceover

#### Type 97 Grenade
* Has identical damage and ammo stats with the Stielhandgranate, used on non-German maps

#### Sticky Grenade
* High damage, low radius grenades rebalanced for zombies
* Custom code that allows them to stick to zombies and other players even in the Singleplayer engine 
* Uses cut voicelines

#### Smoke Grenades
* Custom scripted grenades that confuse and slow down zombies, similar to EMPs from Black Ops II
* Only one player can hold them for performance reasons, similar to the Flamethrower

#### Bipods
* Custom mount spot that behaves similar to a buildable with an animation, progress bar, and a LookAt style trigger
* Weapons with bipods can be mounted in the BAR room on Verrückt and turn into turrents with cooldowns
* Removed weapon from inventory, must have enough ammo, and can be destroyed by zombies after being placed

#### Mortar Round
* Very high damage, very high radius explosive rebalanced for zombies
* Deals extra scripted damage based on Bouncing Betty scaling damage 
* Occupies an action slot like other equipment, allowing the player to choose when they want to pull out a Mortar Round once acquired 

#### Satchel Charges
* Custom wallbuy that behaves similar to the Sniper Cabinet with chalk, an animation, model, and a LookAt style trigger
* High damage, high radius detonable explosives rebalanced for zombies that also deals damage to the player
* Deals extra scripted damage based on Bouncing Betty scaling damage 
* One-time purchase that takes up equipment slot, rewarded 2 per round and damage scales with rounds just like Bouncing Betties
* Added functionality for double-tapping interact to detonate, except when inside barrier or Mystery Box triggers
* Limit of 25 charges planted per player, last charge auto detonates but deals nerfed damage to player
* Disabled friendly fire to prevent griefing, unless the satchel owner disconnects  

#### Scoped Snipers
* Have identical damage and ammo between variants depending on the map
* Names tidied up for more historical accuracy and all have unique in-scope textures
* (Upgraded Mosin Nagant) Uses cut model made by Treyarch along with custom name & stats

#### .357 Magnum
* Can now gib zombies
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

#### Trench Gun
* Slight buff allowing both the un-upgraded/upgraded versions to deal extra damage for headshots, previously shotguns had no multipliers except for the upgraded Trench Gun

#### Double-Barreled Shotgun
* Slight buff allowing both the un-upgraded/upgraded versions to deal extra damage for headshots, previously shotguns had no multipliers
* Removed Trench Gun ejecting shell effect as the shells are only disposed of when reloading
* (Upgraded) Fixed capitalization in the name
* Fixed small gaps in the model by the hammer
* Uses the model with the smaller grip that does not clip through the player hand

#### Sawed-Off Double-Barreled Shotgun
* Slight buff allowing both the un-upgraded/upgraded versions to deal extra damage for headshots, previously shotguns had no multipliers
* Small damage boost to both un-upgraded/upgraded version so that this version is a little stronger than the normal double barrel, but with a wider and less accurate fire spread
* Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
* Removed "w/ Grip" from the name
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
* Slightly buffed damage to better fit being in the rifle weapon category
* Fixed capitalization of the "t" to be lowercase for historical accuracy
* (Upgraded) Updated model to remove metal gaps without silver etching

#### BAR
* Renamed to M1918 BAR for historical accuracy
* Slightly decreased mobility to suit its weapon category better
* (Upgraded) Increased stock ammo from 180 to 240 so it actually receives a decent ammo buff upon upgrading, especially because it is not a wall weapon on Der Riese

#### FG42
* Updated viewmodels to look more complete when playing on higher FOVs
* (Upgraded) Receives telescopic scope attachment and updated model to remove metal gaps without silver etching

#### Browning M1919
* Name rearranged to M1919 Browning for historical accuracy
* Slightly lower mobility compared to the MG42, representing its heavier weight in real life
* Slightly lower ADS time, as this weapon is supposed to be slow to handle
* (Upgraded) Fixed capitalization in the name
* (Upgraded) The Browning now receives a similar damage multiplier buff compared to the MG42 when upgrading, instead of previously being left behind
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
* (Upgraded) Receives small mobility buff

#### M2 Flamethrower
* Player model now has attached fuel tank while weapon is in inventory 
* Uses mobility stats from Nacht Der Untoten
* USes slightly buffed damage stats from later DLCs
* Fixed knife delay
* Fixed ADS glitching when using Toggle ADS settings
* Fixed Bowie Knife missing sound when knifing with this weapon
* (Upgraded) Receives additional small mobility buff

#### Panzerschrek
* Small damage buff so rockets are actually (logically) deadlier than grenades 
* (Upgraded) Receives small mobility buff

#### Knife
* Knife lunging is more smooth and occurs less often

#### Bouncing Betty
* Decreased delay from 2 seconds to 1 second before activation
* Limit of 30 Betties placed per player, last Betty auto detonates
* When more than 4 mines explode one server frame the server waits another frame before continung to prevent crashes, similar to Satchel failsafes
* Fixed capitalization in the instruction hintstring
* Hintstring also requires the player to look at the wall chalk, like other weapons

#### Molotov Cocktails
* Added fire FX deaths when zombies are killed
* Disabled explosive voiceover, quotes do not apply
* Received a small buff so they are better than normal grenades while still being far from powerful
* Leaves AOE damage at location of impact that deals ticks of fire damage to zombies that walk through the fire 

#### Frag Grenades
* Recieved a small buff making frag grenades on all maps behave similar to the regular Der Riese style / Black Ops I
* Fixed plurality on hintstrings
* If a player with full grenades tries to purchase more, the wall model simply appears but no points are lost 
* Grenade suicide does not give you an extra grenade when falling into last stand

#### Ray Gun
* Fixed idle animation to remove blocky left hand
* Fixed reload animation not matching when ammo counter refills
* (Upgraded) Fixed Ray Gun voiceover not playing
* (Upgraded) Fixed last stand giving you more than one ammo cartridge
* (Upgraded) Added missing 3rd person weapon model that has the silver etching material

#### Wunderwaffe DG-2
* Does not permanently reduce max health upon zapping yourself
* Fixed missing reload clip on Der Riese for both upgraded/un-upgraded versions
* (Upgraded) Time between arcs is 20% shorter, improving the effectiveness of the weapon
* (Upgraded) Added missing 3rd person weapon model that has the silver etching material
* (Upgraded) Fixed not playing idle electric humming sound while holding weapon
* (Upgraded) Fixed not playing the tesla sound after getting a 4 killstreak

## Special Thanks
* Numan, Phil81334, cristian_m, Gympie5, Tristan, NGcaudle, psulions45 - General modding advice
* MrJayden585 - Zombified SS uniform texture
* Bunz1102 - Secret model & animations work
* Tom Crowley - Secret melee weapon model & animation
* ege115 - Original creator of first person sway walking script
* jiggy22 - Original creator of SVT-40, Type 99, and DP-28 upgraded model UV mapping
* Fusorf - Original creator of some assets used in HD shaders
* RealVenom - Fixed Ray Gun viewmodel animation at high FOVs
* Jbird632 - Working sticky grenades on AI & "Reward All Perks" scripts
* Inspired by JBleezy's Black Ops I Reimagined mod
* Thank you to the members of both my own & UGX's Discord for helping me along the way
