# Call of Duty: World at War Zombies - Remastered Mod
This mod fixes bugs, improves consistency, adds quality of life tweaks, and makes other improvements to each of the four zombie maps. To install & play, download the release and follow the [installation instructions](https://youtu.be/YbOq6Nb9xug). This repository contains the source files of the project. If you would like to make changes to my mod, see the instructions below.

## Created by JB Shady

[YouTube](https://www.youtube.com/c/JBShady)

[Twitter](https://twitter.com/john_b4nana)

[Donate](https://paypal.me/alexmintz01)

## Build Instructions (For modders)
* If you are downloading the source code and wish to build my mod, you will need the latest version of the official [Call of Duty: World at War Mod Tools](https://mega.nz/#!5kwyCYYQ!Onn3s3SfJjrombt7b1lUOcFYAtzhg9T_X7c4SvJljbs) installed before continuing. I also recommend installing the community made [V1.1 Launcher patch](https://www.ugx-mods.com/forum/3rd-party-applications-and-tools/48/world-at-war-mod-tools-v1-1-pwned-w-linkerpc-fix/10245/).
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
* AI can no longer push the player, which removes the "grabbing" effect where touching zombies would slow the player down. Togglable with the new "Enemy Grabbing" setting in Game Options
* All maps now use the same (more balanced) exponential zombie spawning formula from Der Riese which removes the limit of 24 max zombies per round on solo. Togglable with the new "Gametype" setting in Game Options, note that playing with the 24-limit is considered a cheat and high round records will not save
* All maps now make use of improved scripting and bug fixes that were added into the later DLCs
* All maps make use of slightly improved net related code from the later DLCs, including network safe spawning and network wait functions
* Added all zombiemode achievements that were on the console version (and custom achievements for maps that didn't have them). Complete with notifications, sounds, icons, and a menu
* Added stats tracking based on the console version for achievements, personal records, time played, kills, downs, and other miscellaneous stats on a per-map basis that are saved to the player's profile
* Player rank now changes based on the above zombie stats within the mod, allowing players to not just be stuck at Private level 1 as mods do not carry over Multiplayer rank. There is no indication of progression or ranking up, similar to the ranking system in Black Ops II zombies. Note this is only a feature for bragging rights with friends to indicate how experienced you are within a map, and it still uses the vanilla prestige logos and rank numbering system so nothing looks out of place
* Unused entities are cleared after use, both for one time items like radios or songs and for temporary scripting tasks
* Fixed instances where functions should have been threaded instead of being called, which originally resulted in unnecessary delays or bugs
* Game is hardcoded to Campaign "normal" difficulty as the level of difficulty unintentionally changed health regen and other variables in zombies
* Cheats disabled by default, use devmap to load in with cheats. Note that no leaderboard stats or ranks will save while playing with devmap so that you can still test features of the mod or develop without skewing legitimate stats you may have worked hard to earn

### Player
* Player now spawns as a random character in solo instead of always the Player 1 character
* All characters now use accurate starting pistols that match their corresponding faction
* All characters now use hand models that match their player model, all using models from Campaign/Multiplayer
* Increased backwards and sideways movement speed to match somewhat closer to the console version, but balanced for realism
* FOV does not reset upon map restart, map reload, teleporting, or respawning
* Spectators can easily switch between 1st/3rd person as seen on the console version, complete with the proper HUD message hints
* Explosives damage behaves the same on all maps and across any number of players
* Explosives damage has been rebalanced and deals differing radius damage depending on weapon type and proximity instead of the flat damage rate introduced in Der Riese
* Fall damage no longer gives shellshock effect unless the fall damage takes more than 30% of your health
* Fall damage occurs after 150 units instead of 200 units, similar to future Call of Duty titles that all use 128 units as the baseline
* Re-added subtle flame damage friendly fire that was cut on the later DLCs, watch your aim
* Added weapon bobbing and crawl bobbing like future Call of Duty titles, weapons no longer just lowers while moving. Toggleable, see custom DVAR section
* Added footstep sound effect when player lands on the ground after jumping which were originally cut, but are heard in all other Call of Duties
* Slightly increased footstep volume to make up for loud ambient sounds in zombiemode, especially on Der Riese
* Player falls into prone when dying like in Black Ops I
* Player also drops their hands onto the ground when dying as the Game Over screen appears, animation ported from Black Ops II
* Player no longer receives a free pistol when they have no weapons, instead the screen is just blank like future Call of Duty titles
* Player can still pick up weapons if they have no weapons or if they only have 1 weapon that's not a starting pistol, instead of being locked out of any weapon interactions
* Fixed clientside sounds and effects from playing or looping at different speeds depending on the client's FPS, including map visual effects and player sounds like the red screen heartbeat
* Fixed player being able to pull out equipment while drinking perks or purchasing the Bowie Knife
* Fixed player being able to purchase other items while drinking perks or purchasing the Bowie Knife
* Fixed red screen functionality breaking after bleeding out and respawning
* Fixed crashes from being able to purchase things while falling down into death before the game over screen appears
* Fixed damaging yourself with a grenade removing the ability to be shellshocked from certain scripted damages
* Fixed an extra grenade spawning when killing yourself with a grenade
* Fixed earning grenade reward during round change while in last stand
* Fixed potential bug with dead players being able to revive in a very specific scenario
* Fixed potential bug with dead players still triggering electric trap visual effects
* Fixed bug where players could mount weapons on top of other players near balcony ledges
* Fixed large amounts of damage or unknown damages types causing map restarts, including Peter's hanging body. Note Peter's body will still kill you
* Fixed all 3+ weapon glitches
* Points capped at 1 billion to prevent overflow into negative points
* Hid rank logo next to player names while in game as rank only changes at the end of the game and it is not meant to be a core component, similar to how Black Ops I did not show any rank in game
* Dead players spectating can chat with alive players now

### Zombies
* All maps use various improvements to zombie and hellhound logic/pathing
* In addition to Round 1, Round 2 will also only be walkers to allow for more gradual pacing
* Zombies have glowing eye effects in all DLCs, as originally seen only on Nacht Der Untoten
* Zombies can now spawn with random combinations of helmets, hats, bandages, headbands, or other gear based on rare percent chances and the map's location, with the first two maps using more equipment and the last two having less (which is also due to aiding performance on the larger maps)
* Helmets can be shot off a zombie's head and will fling based on the direction of the damage and will play a special sound
* Gibs and helmets shot off of zombies disappear quicker depending on the amount of players to hopefully reduce visual glitches when there are too many vertices on the screen
* Added missing gore fx when gibbing zombie torsos
* All German zombies utilize the same set of moving, crawling, and melee animations, as some animations were only added in later DLCs. Note that the first two maps still utilize the old style swiping board animations. Some adjustments have also been made on a per-map basis regarding crawlers, taunting, and meleeing, see map sections below 
* Added cut walk_v9 animation to all German zombie variants that was later used in Black Ops I. Further cut Japaense zombie animations have been added to Shi No Numa, see map section below
* Zombies must be on the same floor/actually directly behind players to still play their "behind" vocals
* Zombies can now gib from special scripted explosive damage including Bouncing Betties, Satchels, and Mortars
* Zombie neckshots no longer count as headshots on the stats page so that scoreboard headshot value will reconcile with the menu stats
* Hellhounds are now actually invincible while they are spawning in before they are visible
* Mid-round hellhounds count towards the total zombie count
* Mid-round hellhounds have an additional failsafe if they glitch outside the map, automatically despawn after not hitting the player for a long time while also being near the end of the round
* Fixed potential scripting leak when zombies rise out of ground

### HUD
* Damage indicators only fully fade when player is actually at 100% health
* HUD elements no longer touch the very edge of the screen including the ammo counter, round counter, perk shaders, and mission intro text
* Powerup shader alignment has been tweaked so they are not so close to the edge of the screen, creating better spacing with the equipment inventory HUD elements
* Tweaked HUD text elements so none overlap after making the above changes (Max Ammo text, revive related text, hintstrings)
* Shifted bottom right points scoreboard slightly up and to the left, more visually appealing similar to how it appeared on the console version and Black Ops I
* Bottom right points color in solo is now dependent on your character (as seen in co-op). Togglable, see custom DVAR section
* Hintstrings now show yellow highlights for keybinds, similar to Multiplayer and all other Call of Duties
* Removed objective info screen when pressing tab in solo, using T4M or Plutonium will show solo zombie scoreboard instead
* Updated the World at War font with an upscale to look better on HD displays, fixing the pixelated round counter
* Updated crosshair texture with custom HD version, still maintaining the correct art style
* Updated the activation hand logo on hintstrings with a custom HD version, still maintaining the correct art style
* Updated grenade icon and grenade pickup icon to accurately represent the frag grenade in the player's inventory
* Updated flamethrower icon with custom HD version, still maintaining the correct art style
* Updated perk and powerup shaders with custom HD versions, still maintaining the correct art style
* Created new better looking icons for Sticky Grenades and Type 97 frags from scratch, still maintaining the correct art style
* Changed the Monkey bomb icon to look more recognizable while still maintaining the correct art style
* Removed grenade indicators from special grenades because these grenades cannot be picked up and display the incorrect icon
* Improved spacing between hintstrings and the activation hand logo
* Capitalization is more consistent in hintstrings
* Fixed the round counter not fully flashing white when going to round 6
* Fixed yellow points text offseting when players disconnected
* Triggers behave consistently in terms of disabling when a player is throwing a grenade or doing an otherwise invalid action when attempting to interact
* Triggers perform actions in sync across all maps instead of having slight differences depending on map and type (when to subtract points, when to disappear, when to give item)
* Upon respawn, player grenade inventory (while empty) is still shown on HUD before player recieves new round grenade reward
* All HUD elements disappear when the player dies for a cleaner game over screen
* Weapon tutorial hint texts are slightly smaller so they are easier to read, used for Bouncing Betties and Satchel Charges

### Menu
* Start game button added for quick solo play
* Overhauled main menu to remove/reorganize all non-zombiemode related pages, buttons, and settings. While running this mod, it is purely a zombies experience
* Co-op menus auto load the selected map and the co-op settings page now includes the relevant settings from Game Options that will effect all players and are decided by the host
* Added a reminder when heading to co-op for all players to install T4M, a common mistake
* Added Intel menu with an image/description of the map, achievements, and map stats/leaderboard
* Added Character Bios menu, ported from console but with slight grammatical and layout fixes for the best PC experience. Easter egg bios have been added to the first two maps, hidden by default
* Many new options seamlessly integrated into the existing menus with settings for FOV, the HUD, gametype/AI, fog, LOD, dialogue, and more with appropriate pop-up descriptions as needed. See table below
* Added custom co-op loading screen hint messages related to the mod
* Removed intel sponsorship advertisements from all loading screens for a cleaner look and to match the console version
* Hid Multiplayer style progress summary report pop-up when player ends game or disconnects as this data is not relevant

### Gamepad
* Controller Mode setting switches hints to use gamepad icons for hintstrings and the D-pad so that players can enjoy a more immersive controller experience. Uses Xbox 360 style icons by default, but optional patch is available to change to PlayStation 3 style icons
* Loading screens no longer show the mouse cursor and "click to start" hints while Controller Mode is enabled
* New custom scripted aim assist settings (lock on when aiming near enemy), togglable only while Controller Mode is enabled
* Menu settings for sensitivity and flipping triggers, note that any buttons can be rebound by pressing them in the appropriate setting

### Settings
* New settings have been created, see below table
* Existing settings have been added to the options pages for easier access, see below table
* Anti-aliasing now goes up to 8x instead of just 4x
* Max anisotropy texture filtering setting added to the menu and can now be set to 16. Now, the slider lets you properly set your min value from 0-16 instead of the values 5-16 not doing anything because the max being set to 4 would override it
* All settings and stats are saved to the selected profile even if the game is closed, crashes, switches profiles, etc.
* Leaderboard high round records do not save if player has set Gametype or Difficulty to "Classic," as this makes the mod substantially easier and are considered cheats. Note that rank and miscellaneous player statistics such as kills and playtime will still save when using these custom settings 
* Note that some "fake" DVARs were created for bypassing cheat protected settings, labeled the same as the regular DVAR but with "_settings" to allow the player to edit them on the menu and have it carry over in-game

| New Settings | DVAR | Default | Other Values | Description |
| :---: | :--- | :--- | :--- | :--- |
| **GRAPHICS** |  |  |  |  |
| Fog | `r_fog_settings` | `1` Yes | `0` No | Enables or disables fog. |
| Cinematic Mode | `r_filmUseTweaks_settings` | `0` No | `1` Yes | More saturated color grading. |
| **TEXTURE SETTINGS** |  |  |  |  |
| Max Anisotropy | `r_textFilterAnisoMax` | `4` Low | `16` Normal | Increases max possible texture filtering quality. |
| LOD Range (Rigid) | `r_lodBiasRigid_settings` | `0` Default | `-200` High | Increases range of visible detail on rigid models. |
| LOD Range (Skinned) | `r_lodBiasSkinned_settings` | `0` Default | `-200` High | Increases range of visible detail on skinned models. |
| **SOUND** |  |  |  |  |
| Character Dialogue | `character_dialog` | `0` Yes | `1` No | Enable or disables character dialogue. Locked in-game in co-op as dialogue is not clientside. |
| **GAME OPTIONS** |  |  |  |  |
| Gametype | `classic_zombies` | `0` Modified | `1` Classic | By default, 24 zombie cap on solo is disabled. Accessible on menu, requires match restart. |
| Difficulty | `classic_perks` | `0` Modified | `1` Classic | By default, solo Quick Revive, Double Tap buff, and 45 second bleedout are enabled. Accessible on menu, requires match restart. |
| Enemy Grabbing | `grabby_zombies` | `0` Modified | `1` Classic | By default, "sticky" zombies are disabled with PushPlayer() set to false. Accessible on menu, requires match restart. |
| Enemy Intensity | `super_sprinters` | `0` Modified | `1` Classic | By default, additional super sprinters are added to prototype and asylum. Accessible on menu, requires match restart. |
| HUD | `cg_draw2D` `r_flame_allowed` | `1` Yes | `0` No | Enables or disables entire heads up display. |
| Display FPS | `cg_drawFPS` | `Off` No | `Simple` Yes | Enables or disables FPS counter. |
| Limit FPS | `com_maxfps` | `85` Default | `0` Disabled | Adjusts the max FPS value. |
| Field of View | `cg_fov` | `65` Default | `90` Maximum | Adjustable FOV with slider. |
| View Scale | `cg_fovScale` | `1` Normal | `1.1` Medium or `1.2` High | Scales existing FOV higher or lower by multiplier, which also effects ADS FOV. |
| Controller Mode | `cg_drawDpadHUD` | `0` Disabled | `1` Enabled | DVAR switches HUD to use console style D-pad icons. Menu button also executes additional controller bind commands. |
| **CONTROLS** |  |  |  |  |
| Controller Triggers | `gpad_flip_triggers` | `0` Default | `1` Flipped | Flips triggers to top row, useful for PlayStation 3 controller players. |
| Controller Inversion | `input_invertpitch` | `0` Disabled | `1` Enabled | Enables or disables controller inversion. |
| Controller Sensitivity | `input_viewSensitivity` | `0.6` 1 (Low) | Scales up to (Medium), (High), (Very High), (Insane) | Increases or decreases controller sensitivity using the same scale as console. |
| **CONSOLE COMMANDS** |  |  |  |  |
| DVAR Initialization | `dvar_init` | `0` | `1` | Set to 0 in console to reset all new remastered settings back to default, requires mod relaunch. |
| Zombiemode Developer | `zombiemode_dev` | `0` | `1` | Developer command to enable experimental features of the mod, requires map restart. |
| Character | `character` | `0` Random | `1-4` Player # | Developer command to change character in solo, requires map restart. |
| Health Counter | `cg_drawHealthCount` | `0` | `1` | Developer command to enable health counter in solo, requires map restart. |
| Health Counter | `cg_drawHealthCountCoop` | `0` | `1` | Developer command to enable health counter in co-op games, requires map restart. |
| Game Timers | `cg_drawTimers` | `0` | `1` | Developer command to enable game and round timers for all players, requires map restart. |
| Trap Timers | `cg_drawTrapTimers` | `0` | `1` | Developer command to enable trap cooldown timers for all players, requires map restart. |
| Solo Score Color | `cg_SoloScoreColorWhite` | `0` | `1` | Forces white points color in solo, requires map restart. |
| Lower Gun | `cg_lowerGun` | `0` | `1` | Removes custom weapon bobbing so weapon just lowers only in solo, requires map restart. |
| D-pad Logos | `cg_drawDpadLogos` | `1` | `0` | Disable or enable background D-pad logos when using controller if you just want neutral arrows. |
| Clearance Code | `bio_access` | `[PASSWORD]` | `?` | Grants access to confidential menus. |
| Sumpf Completion | `sumpf_quest` | `0` | `?` | Indicates completion of new Shi No Numa Easter Egg achievement with Richtofen in lobby. |
| Factory Completion | `factory_quest` | `0` | `?` | Indicates completion of new Der Riese Easter Egg achievement. |

### Blockers
* All maps use the dust cloud effect when repairing/destroying boards that was cut after Nacht
* All maps use the improved opening debris script and effects from later DLCs
* Upscaled wood board texture by 2x to appear slightly less blurry
* Repairing individual boards gives the player a screenshake, like future Call of Duty titles
* Repairing barriers only plays the cha-ching sound while actively earning points, like future Call of Duty titles
* The barrier cha-ching sound is no longer mixed in with the hammer sound effect, making the act of repairing sound better and closer to Black Ops I when not earning points
* Barrier repair reward limit is based on the number of boards repaired and not the amount of points, allowing double points to actually benefit the player
* Barrier repair reward limit scripting fixed so the limit can be reached instead of being stopped 10 points before the limit, for example, allowing the reward to max out at 500 and not 490
* Barrier repair rewards are now effected after picking up (rare) multiple double points at the same time, resulting in times four of +40 per board
* Zombies are less likely to climb through barriers as they are being boarded up
* Fixed bug where multiple players could purchase a double door, resulting in both players losing points for one purchase

### Mystery Box
* Box loadout redone to include cut guns and special equipment on a per-map basis, see loadout section below
* Wall weapon explosives and starting pistols are excluded from the box, but all regular wall weapons are included in the box
* Ray Gun is obtainable from the first Mystery Box location on all maps without having to first get a Teddy Bear
* Added missing not enough points sound effect when player does not have enough points
* All maps have the same glow effect when the box is opened
* All maps use the same hintstring functionality for when to show/hide the onscreen text
* Hintstring text only says "trade" weapons when it will actually replace a weapon in your inventory
* Reduced cooldown between box uses from 3 seconds to 2 seconds
* Fixed the box playing the debris sound for other players after every use once the location has been changed
* Fixed the box playing the lid close sound when floating away during a Teddy Bear even though the lid never closes
* Fixed the box jingle stopping when too many other sounds play
* Fixed Wonder Weapon stinger sound effect sometimes not playing
* Der Riese & Shi No Numa boxes now share equal weighted odds for Wonder Weapons, which have also been slightly nerfed so the DG-2 is not overly common to the point of being annoying
* Verrückt & Nacht Der Untoten boxes remain a full lottery, except for the Teddy Bear on Verrückt which is still slightly harsher than on later maps

### Powerups
* Powerups last on the ground for the full 20 seconds before disappearing
* Fixed bug where sometimes powerup pickup sound would not play if picked up right before despawning
* Fixed instantly killing groups of zombies allowing the player to potentially bypass the powerup limit
* Fixed bug where score threshold to earn a powerup was not scaling properly with number of players due calculations running before players have loaded in
* Fixed bug where player could pickup powerups during game over screen
* Carpenter available on all maps, combined into the togglable "Gametype" setting in Game Options
* Carpenter will not spawn when up to a maximum of 5 barriers are left destroyed (compared to the original 4) for better balancing. The first two maps had more than 4 barriers in the spawn rooms, and this also makes it more viable for players to block Carpenter spawns as part of their strategy
* Carpenter powerup repairs do not cause a screenshake effect when near a barrier
* Max Ammos now refills equipment on all maps (betties, molotovs, grenades, etc.)
* Fixed the last hellhound sometimes not dropping Max Ammos, especially on Shi No Numa
* Increased volume of Insta-Kill active loop sound as it sometimes did not feel noticeable
* Double points now effects Carpenters and Nukes giving +800 and +400 respectively
* Double points stack on all maps like originally scripted before Der Riese. However, it has been capped at only giving up to 4x for balance reasons due to teleporter powerups

### Perks
* Jugger-nog abilities and health regeneration behaves the same on all maps using improvements from Der Riese
* Double Tap Root Beer now gives a 33% damage buff for bullet weapons, togglable under the "Difficulty" setting in Game Options
* Quick Revive now works on solo giving 3 possible extra lives, togglable under the "Difficulty" setting in Game Options
* Quick Revive machine correctly floats away and disappears with sounds and effects after 3 purchases, all perk sounds turn off including jingle and bump 
* Renamed hintstring to say buy "Quick Revive" instead of just "Revive"
* Perk machine improvements from later maps brought to prior maps to fix bugs and inconsistencies
* Perk machines disabling for a second after purchase was originally an oversight, but it has now been considered a feature representing the real machine cycling bottles--purchase hintstring temporarily disappears during this wait now to prevent confusion

### Traps
* Electric traps now use a 30 second on/30 second off cooldown cycle rather than 25/25, except for Shi No Numa which has 30 on/60 off for balance reasons due to trap locations
* Trap lights change color immediately after purchasing on all maps
* All levers return to upward position when not in use to prevent glitches
* Fixed bug where traps would sometimes not slow down players
* Fixed bug where traps would sometimes not damage players in certain locations
* Fixed bug where traps would stop giving shellshock effects forever
* However, players with Jug and near full-health can still avoid the shellshock effect when running through traps
* Fixed traps sometimes displaying yellow lights on Der Riese
* Fixed potential thread leaks with electric traps, flogger trap, and zipline
* When multiple traps are activated, fixed how certain trap sounds and effects would end for all traps when only the first trap ended
* Slightly decreased zombie death delay in flogger and electric traps
* Decreased Hellhound death delay in electric traps as they run very fast and would get too far past traps before dying
* Removed hand logo from the need power hintstrings for consistency, as there is nothing for the player to interact with when there is no power
* Added missing not enough points sound effect when player does not have enough points

### Teleporters
* Teleporters are only disabled if there is a cooldown with a valid cooldown hint message
* Fixed lack of threading causing teleporters to sometimes be stuck during Samantha dog attacks
* Fixed Samantha talking multiple times after a teleport if there was both no powerup and a dog attack
* Fixed Samantha still talking when an attempt to spawn dogs is canceled due to dogs already being on the map
* Added missing not enough points sound effect when player does not have enough points

### Last Stand
* Solo Quick Revive takes 10 seconds to self revive, zombies & dogs will run away from the player (to a location the player is not at), and the player is equipped with an upgraded version of their starting pistol
* Players equipped with better pistols than their designated last stand pistol (normal in co-op, upgraded in solo) will now pull them out in last stand based on an a hierarchy: Ray Gun has the top priority, then explosive pistols, then the .357
* If a player has no ammo for a pistol before they down, then that weapon will not be counted in the above hierarchy
* Player receives 3 magazines for regular pistols and only 1 cartridge for both the un-upgraded/upgraded Ray Gun
* If a player receives a Max Ammo or the round changes while down, they will not be given grenades/explosive equipment
* Disabled leaning while in last stand
* Recovered breathing sound plays right after being revived with less of a delay so it doesn't overlap with revived voiceover
* Fixed recovered breathing sound playing when player died after bleeding out as they entered spectator mode
* Player does not talk while in last stand (such as about kills or powerups)
* Downing and reviving point loss/reward is the same across all maps, as it was originally not in the the first map
* The co-op bleedout time has been increased from 30 seconds to 45 seconds like future Call of Duty titles, togglable under the "Difficulty" setting in Game Options
* Can no longer switch weapons while reviving\
* Fixed sound glitch when pressing fire with the Syrette

### Sounds
* All maps use the most refined (DLC3) iteration of soundalias settings where applicable for consistency in audio mastering and mixing
* Purchase sounds that previously played on triggers now play on the player/object itself to prevent entity sound glitches
* Slightly increased Easter Egg song volumes and now all songs play through the music channel
* All Easter Egg songs will play a 2 second fadeout if the game ends and switches to the intermission music
* Added soundtrack studio quality versions of the Easter Egg songs
* Removed cha-ching sound when activating DLC1 and DLC2 Easter Egg songs as these triggers do not cost points
* All maps now use the same MusicState system from Der Riese for the background ambient music and intermission music, allowing for better audio mixing where only one song can play at a time
* Game over music fades properly in co-op
* Fixed sound issues with grenade launchers/rocket launchers/a few ambient sounds not playing, potentially attributed to corrupt audio in mod tools
* Lowered volume of wall breaking barrier sounds so they cannot be heard from as far away

## Voiceover
* Fixed voiceover categories that played with a delay being able to overlap, resulting in the character talking twice at the same time
* Fixed Insta-Kill special melee voiceover still being able to play from non-melee kills
* Fixed low ammo quote spam and thread leak
* Low ammo/no ammo quotes are scripted more efficiently on each player rather than on the level, allowing them to have separate timers
* Low ammo/no ammo quotes no longer plays on attachment weapons (launcher)
* Rewrote voiceover for earlier maps to use improved scripts from later DLCs that reduced the repetitiveness of how lines are selected
* Rewrote voiceover interactions so they function properly, players will notice quips from each character more often as this script was originally partially broken
* Voiceover interactions disabled in solo to fix character responses sometimes playing in solo when playing as certain characters
* Added failsafe so player no longer can start talking during the game over screen
* All voiceover categories with delays between action and talking have been made consistent between each map
* Player surrounded voiceover only plays when zombies are directly around the player, not above or below
* (4 Heroes) Added cut sniper pickup voiceover found in the game files
* (4 Heroes) Added cut hellhound kill voiceover found in the game files with a 25% chance of playing per kill
* (4 Heroes) Added cut voiceover that plays when a player downs
* (4 Heroes) Added cut pain voiceover that plays when a player is damaged
* (4 Heroes) Added cut exert voiceover that plays about 75% of the time a player damages a zombie with melee, and 100% of the time when a player kills a zombie with melee (Unless other dialogue is queued, in which case it overrides the exert sound)
* (4 Heroes) Added several cut voiceover lines that play after a player is revived, instead of only alternating between 2 possible lines
* (4 Heroes) Added cut Takeo Panzershrek voiceover
* (4 Heroes) Added cut custom reload voiceover that only plays when reloading an empty LMG when in close proximity to zombies
* (4 Heroes) Unlocked a few cut unused voiceover lines for weapons that were never called in the scripts but were already included in the soundaliases (MP40, BAR, Shotgun, Wunderwaffe, Monkey Bomb)
* (4 Heroes) Reworked "no purchase" sounds and voiceover for purchasable items when a player does not have enough points:
* Fixed Ray Gun voiceover sometimes playing from grenade kills while holding the Ray Gun
* Wall Weapons: Now have a chance of saying a cut voiceover line, the standard groan, or nothing
* Mystery Box: Now has a chance of saying two cut voiceover lines, the standard groan, or nothing
* Perks/PaP: Now have a chance of playing the groan instead of only playing the voiceover dialogue to make it less repetitive
* Improved optimizaton of voiceover lines, allowing certain kill lines to still play when probability-based rare lines do not play

## Nacht Der Untoten
* Added "mission intro" in the bottom left corner to include storyline accurate info
* Added new musical Easter Egg that plays "Undone" by shooting all 31 red barrels, inspired by Black Ops I
* Fixed the Salvation Lies Above wall chalk from being too hard to read, only an issue on PC
* Red barrels slightly buffed and also deal fire damage for several seconds if zombies walk through their fire
* Slightly buffed explosive truck values
* Slightly adjusted vision file to have smoother fading fog
* KZMB radio now pauses when playing the main Easter Egg song or game over intermission music
* KZMB radio now works in co-op for players other than the host, which was originally glitched on PC
* Using audio from campaign, added an entire set of about 100 voicelines per Marine character based on the categories used on other maps (headshots, kills, powerups, weapons, surrounded, downed, etc.)
* New categories and interactions not seen on other maps have been added to reflect the scarier atmosphere of Nacht and the more military-like commands of the squad, inspired by both the original trailer and DLC1 trailer
* Instead of randomizing the player models for each character, each Player (1, 2, 3, 4) always has a consistent and unique player model/face/gear
* Replaced camouflaged Pacific-theater helmets with regular metal helmets, as the are not in the Pacific-theater
* Removed Scoped Kar98k from the box so that the cabinet is actually unique and useful while still being a "troll" that can take your weapon without new players knowing what is inside
* Added Satchel Charges into a "searchable" mysterious crate akin to the Sniper Cabinet with a working LookAt style trigger, animation, and custom model
* Satchel Charge Crate and Sniper Cabinet now both have unique sounds when opened
* Zombies can now use updated animations from future maps for traversing, crawling, attacking, hitting through barriers, walking, running, etc.
* Unique to this map, zombies can use the original "sprint" crawler animation that was later cut
* Unique to this map, while all future melee animations have been added, they have been rebalanced for this map specifically so zombies are still more likely to stop before hitting to reflect how these zombies are less advanced (and makes for better gameplay given the tight layout and lack of perks)
* Unique to this map, taunt animations from later maps have been purposefully excluded to reflect how these zombies are less advanced 
* Added a cut rare type of "super sprinter" that comes after round 10, toggleable under "Enemy Intensity" in Game Options. Note that disabling this is considered a cheat and high round records will not save
* Reorganized the Nacht zombie vocals to have more consistency between ambient, attack, and sprint categories with less repetition
* Added very quiet and rare behind vocals so that zombies are still likely to surprise the player. Player will also nervously breathe if a zombie is too close behind them
* Replaced the existing grey uniform zombie variant texture with an SS camouflage texture, which fits better with the battlefield atmosphere of the map

## Verrückt
* Renamed map from Zombie Verrückt to just Verrückt, similar to how it was named in future Call of Duty titles
* On co-op low rounds, the zombie spawning formula still has a separate calculation that spawns more zombies than normal to account for the players being split up and ensuring both sides of the spawn face enough of a threat
* On this map, the team of Marines now uses camouflage raider gear to reference how they were supposed to be a recon team in the storyline, even though this wasn't traditionally used in the European-theater. First person hand models also reflect this, which helps differentiate the Marine crew from the previous map
* Instead of randomizing the player models for each character, each Player (1, 2, 3, 4) always has a consistent and unique player model/face/gear
* Removed magic sound when Mystery Box reappears, instead just having a debris and poof sound, as this map does not have the magic light so it feels more consistent this way
* Fixed the Bouncing Betty model sometimes moving in the wrong direction when purchasing off the wall
* Fixed vision file changing when going downstairs in the power room
* Fixed music volume lowering too much when in shower room zone
* Uncensored Nazi flag, as seen in the trailer of the map
* Increased level of detail for bipod models at distances so they do not disappear
* Added better green/red light fx from Der Riese and are on both sides of the electric traps
* All BAR wallbuys give the same weapon and are all priced at 1800, there are no longer two different versions of the BAR in order to not confuse the player
* Uses the same green/red glow effect for trap lights as Der Riese
* Fixed missing collision in closed off window on the Double Tap balcony
* The spawnroom power door now loses its bump trigger and hintstring the moment it is powered on/opened, just like the Perk machines
* Reorganized Marine voiceover categories to be less repetitive and more consistent
* Added generic pain voiceover to align with the other three modded maps
* Added new categories for powerups, perks, Teddy Bear (cut), and downed lines (cut)
* Added missing taunt animations that were only into future maps
* Added the Nacht original "sprint" crawler animation to bridge the transition between the first two maps because they feel similar, but it remains cut on Der Riese
* Added a cut rare type of "super sprinter" that comes after round 10, toggleable under "Enemy Intensity" in Game Options. Note that disabling this is considered a cheat and high round records will not save
* Added easter egg scripted dialogue for Player 4
* Added easter egg PA system music that can play after using the traps too much

## Shi No Numa
* Added "mission intro" in the bottom left corner to include storyline accurate info
* Added "level start" voiceover using generic character quotes relating to zombies
* Added cut "jap_walk_v4" animation as another walker variant
* Added cut "jap_run_v6" animation as another rarely occurring runner variant
* Added cut "jap_run_v5" animation as another rarely occurring sprinter variant
* Added unused swamp perk machine textures from the game files
* Re-added unique hintstrings for each Perk machine instead of having the price on the machine, which was originally only on this map
* Added cut hellhound round change "howling" sound that was only used on the PlayStation 3 version
* Hellhound functionality includes some improvements  made in the next DLC including a health buff and fixes to running while invisible before finishing spawning in
* Health scaling is kept slightly lower than Der Riese to account for no Pack-a-Punch
* Fixed hellhounds playing normal zombie death sounds in electric traps
* Carpenter voiceover uses cut repurposed lines that were originally made for general barrier repairing
* When picking up a powerup, character voiceover chooses from three lines instead of one
* When opening the second or third hut, there is a 50% chance of the closest player having voiceover on the randomization of perks
* When a perk is decided, there is a higher chance of the closest player within a close proximity shouting the perk's name, as these voicelines were previously very unlikely to play
* Hut perks are now a fully lottery instead of always forcing Jugger-nog or Speed Cola on the first hut
* Fixed perk machines from clipping into the wall in the Dr.'s hut
* Reduced Arisaka wallbuy and chalk from clipping into a wood board
* Electric traps still utilizie old light fx that was more ambient, which fits the atmosphere better as a jungle facility would not have as good of a power grid as the other maps
* Flogger now damages the player only once per rotation and also sets the player into crouch
* Flogger now damages the player the exact same between solo and co-op, killing instantly without Jug
* Flogger damage to the player has a sound now
* Slightly reduced the flogger delay between zombie being hit by the trap and dying 
* Fixed flogger light fx from spawning clipped into the wall and so they are better alligned with the light model
* Fixed flogger and zipline freezing zombies when too many get ragdolled
* Zipline cooldowns decreased to 15 seconds for the initial cooldown and 30 for the regular cooldowns
* Zipline no longer can glitch player maxhealth values to the wrong value
* Added zombie jump down animation from upper zipline station so zombies do not look like they are holding an invisible gun
* Fixed Richtofen's name being cut off in co-op loadscreen, appearing as if his name was mispelled
* Added hidden easter egg quest including secret items and hidden achievement, the achievement is required to begin Der Riese quest

## Der Riese
* Updated "mission intro" in the bottom left corner to include the full storyline accurate date
* Changed vision file to give the map a more bluer and contrasted look rather than the original greyish-green look
* Fixed the loose change Easter Egg so that it actually gives a real 30 points while only showing +25 on the HUD, this is to prevent confusion because the HUD rounds score to the nearest tens
* Added extra checks so players will never talk about needing to link the teleporters or open Pack-a-Punch after the task is already completed
* Pack-a-Punch trigger disabled when you are holding an upgraded weapon or when another player's weapon is in the machine
* Bowie Knife trigger disabled when equipped and improved to allow other players to purchase it while a player is in the process of purchasing the weapon
* Added cut 5th Maxis handheld radio from the game files that was used on the IOS version
* Added cut rare voiceover that can play after teleporting (5% chance)
* Added cut rare voiceover that can player after picking up a power up (3% chance)
* Added cut Easter Egg voiceover for the "Teddy is a liar" wall writing (Requires scope)
* Increased percent chance for voiceover when interacting with Easter Egg items and also added one unused Takeo line to the Corkboard cycle (50% chance)
* Increased percent chance for general storyline voiceover early game (5% chance)
* Increased PaP "waiting" voiceover odds to play 50% of the time rather than 8%, closer to future Call of Duty titles
* Added several unused voiceover lines when a player picks up the Carpenter power up
* Player surrounded voiceover now also plays in solo, but without the responses from other characters and at a lower percent chance
* The post-teleporter FOV effect now uses your actual FOV when doing the effect instead of zooming into the default 65
* Tweaked teleporter cooldown message to be plural, as all teleporters are set on cooldown after one is used
* Fixed teleporter cooldown message showing on other teleporters that still need to be linked, which are not effected by the cooldown
* Fixed Der Riese zombies switching to flesh colored limbs after being gibbed, as Treyarch kept the gibbed zombie models the same as Nacht Der Untoten
* Fixed potential leak with Monkey Bombs
* Added collision to the metal sheet on the catwalk barrier
* Fixed duplicated Pack-a-Punch model appearing during the light fx while gun is being upgraded
* Realligned Pack-a-Punch model to be more centered in its room
* Fixed wonder weapon achievement requiring you to switch weapons if Monkey Bombs were the last wonder weapon you acquired
* Fixed teleporter sometimes not giving any visual effect at all
* Fixed the meteor loop and affirm sounds having low priority, causing them to be quiet or often not play. The loop also stops after interacting, similar to in Black Ops I
* Fixed instances of scripts attempting certain effects on mid-round dogs that are supposed to be only for regular zombies due to lack of checks
* Added hidden Easter Egg quest including secret items and hidden achievement

## Weapons
* All weapons are 100% consistent in stats, behavior, and appearance between each map
* All use the best available materials (HD textures from Singleplayer, weathered materials if available, normal/spec maps, better reflections)
* All added weapons (and their upgraded variants) use official sounds, stats, names, effects, models, and materials unless non-existent. In such rare cases, they were created from scratch while still matching Treyarch's style
* Bullet weapons show tracers like future Call of Duties, i.e., when shooting there is a chance you see a quick flash as the bullet travels to the target which just looks cooler
* Added missing idle bob, gear sounds, and proper sprint settings for various holdable items and weapons 
* Weapons cannot share ammo reserves anymore because it was a glitchy system where players sometimes would not lose ammo correctly
* All maps share the same loadout, except for the following differences listed below:

### Loadout
| Category | Nacht Der Untoten  | Verrückt | Shi No Numa | Der Riese |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| **Starting Pistols** | Colt M1911 | Colt M1911 | Faction Dependent | Faction Dependent |
| **Bolt-action Rifles** | Kar98k, Springfield | Kar98k, Springfield | Arisaka | Kar98k |
| **Scoped Rifles** | Scoped Kar98k (Cabinet) | Scoped Springfield | Scoped Arisaka | Scoped Mosin Nagant |
| **Rocket Launcher** | Panzerschrek | Panzerschrek | M9A1 Bazooka | Panzerschrek |
| **Frag Grenades** | Stielhandgranate | Stielhandgranate | Type 97 Grenade | Stielhandgranate |
| **Special Grenades** | Molotov, Signal Flare | Molotov, Smoke Grenade | Molotov, Sticky Grenade | Molotov, Monkey Bomb |
| **Equipment** | Satchel Charges (Crate), Mortar | Bouncing Betties, Bipods | Bouncing Betties, Bayonets | Bouncing Betties, Bowie Knife |
| **Entirely New Weapons** | SVT-40 | SVT-40 | SVT-40, DP-28, Type 99 | SVT-40, DP-28, Type 99 |
| **Missing Weapons Added** | Type 100, PPSh-41 | Type 100 | None | M1 Garand, Sawed-Off Double Barrel |
| **Wonder Weapons** | Ray Gun | Ray Gun | Ray Gun, Wunderwaffe DG-2 | Ray Gun, Wunderwaffe DG-2 |
| **Easter Egg Items** | N/A | N/A | Radio, Vodka, Katana, Journal | Beaker, Journal |

#### Starting Pistols
* Starting pistols are now faction dependent. Americans spawn with the Colt M1911, Russian with the Tokarev T-33, Japanese with Type 14 Nambu, and German with Walther P38
* All have identical stats and upgrade into explosive pistols
* (Walther P38) removed first raise animation for consistency/balance with other pistols
* (Upgraded, all) Increased reserve ammo from 40 to 42 so it is actually divisible by the magazine capacity (6)
* (Upgraded, all) Changed the last shot animation so the pistol slides do not go back and glitch forward due to being categorized as a grenade launcher
* (Upgraded, all) Added PaP muzzle flash effects
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
* Tweaked animation sprint/raise/lower timing to look better as this should feel like a heavy weapon
* Has identical damage and ammo stats with the Panzerschreck, used on non-German maps

#### Type 30 Bayonets
* Custom wallbuy that behaves the same as real wallbuys with chalk, model, and a LookAt style trigger
* High damage melee weapon that can be equipped on valid Japanese weapons
* Working gibs, creates blood splats on zombies, and voiceover

#### Type 97 Grenade
* Has identical damage and ammo stats with the Stielhandgranate, used on non-German maps

#### Sticky Grenade
* High damage, low radius grenades rebalanced for zombies
* Custom script that allows them to stick to zombies and other players even in the Singleplayer engine
* Uses cut voicelines

#### Smoke Grenades
* Custom scripted grenades that confuse and slow down zombies, similar to EMPs from Black Ops II
* Only one player can equip them for performance reasons, similar to the Flamethrower

#### Bipods
* Custom mount spot that behaves similar to a buildable with an animation, progress bar, and a LookAt style trigger
* Weapons with bipods can be mounted in the BAR room on Verrückt and turn into turrents with cooldowns
* Removed weapon from inventory, must have enough ammo, and can be destroyed by zombies after being placed
* Rebalanced mounted weapon stats and cooldowns
* Fixed slightly misalligned sights on some mounted weapons

#### Mortar Round
* Very high damage, very high radius explosive rebalanced for zombies
* Deals extra scripted damage based on Bouncing Betty scaling damage
* Occupies an action slot like other equipment, allowing the player to choose when they want to pull out a Mortar Round once acquired
* Added custom putaway animation so player can switch to other weapons without it looking weird
* Added missing idle sway
* Added prone settings so weapon lowers as player crawls

#### Satchel Charges
* Custom wallbuy that behaves similar to the Sniper Cabinet with chalk, an animation, model, and a LookAt style trigger
* High damage, high radius detonable explosives rebalanced for zombies that also deals damage to the player
* Deals extra scripted damage based on Bouncing Betty damage
* One-time purchase that takes up equipment slot, rewarded 2 per round and damage scales with rounds just like Bouncing Betties
* Added functionality for double-tapping interact to detonate, except when inside barrier or Mystery Box triggers
* Limit of 25 charges planted per player, last charge auto detonates but deals nerfed damage to player
* Disabled friendly fire to prevent griefing, unless the satchel owner disconnects
* Added prone settings so weapon lowers as player crawls
* Tutorial hintstring based on Campaign to be realistic, but slightly improved functionality for less cluttered text

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

#### Springfield
* Slight buff to damage to fix weirdly low damage multipliers, but the gun is still the worst of the other bolt action rifles
* Fixed invisible gaps in the scoped version

#### Arisaka
* Renamed to Type 99 Arisaka for historical accuracy

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
* Slightly buffed weapon spread accuracy, but did not buff the Rifle Grenade version accuracy (as this attachment makes the rifle less accurate)
* (Upgraded) Increased reserve ammo 150 to 156 so it is actually divisible by the clip capacity (12)
* (Upgraded) Slightly buffed headshot multiplier so it is the highest out of all regular semi-automatic rifles, which fits with its superiority in WWII

#### M1 Garand w/ Launcher
* Slightly buffed base rifle damage
* Slightly decreased mobility to compensate for Rifle Grenades
* Nerfed maximum ammo to balance with regular M1 Garand and compensate for having to carry Rifle Grenades
* When equipping the launcher, the name changes to the name of the grenade launcher for historical accuracy
* (Upgraded) Nerfed maximum rifle ammo to balance with regular M1 Garand and compensate for added Rifle Grenades
* (Upgraded) Renamed equipped launcher to M7000
* (Upgraded) Receives the same headshot multiplier buff as the non-launcher variant
* (Upgraded) Slightly nerfed max launcher explosion radius so that it is less than the upgraded Panzer, there's no reason these should had identical stats when they're different projectiles
* (Upgraded) Fixed the model missing the launcher mount under the barrel
* All maps use the proper model where an attachment is fitted under the barrel even when a grenade is not loaded

#### Trench Gun
* Slight buff allowing both the un-upgraded/upgraded versions to deal extra damage for headshots, previously shotguns had no multipliers except for the upgraded Trench Gun

#### Double-Barreled Shotgun
* Slight buff allowing both the un-upgraded/upgraded versions to deal extra damage for headshots, previously shotguns had no multipliers
* Removed Trench Gun ejecting shell effect as the shells are only disposed of when reloading
* Fixed small gaps in the model by the hammer
* Uses the model with the smaller grip that does not clip through the player hand
* (Upgraded) Fixed capitalization in the name
* (Upgraded) Fixed ADS FOV being too low

#### Sawed-Off Double-Barreled Shotgun
* Slight buff allowing both the un-upgraded/upgraded versions to deal extra damage for headshots, previously shotguns had no multipliers
* Small damage boost to both un-upgraded/upgraded version so that this version is a little stronger than the normal double barrel, but with a wider and less accurate fire spread
* Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
* Removed "w/ Grip" from the name as there is no grip attachment
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
* (Upgraded) Slightly decreased reserve ammo from 700 to 690 so it is actually divisible by the drum mag capacity (115)

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
* (Upgraded) Receives telescopic scope attachment and updated model to add silver texturing to the metal gaps
* (Upgraded) With scope, weapon is slightly easier to handle with slightly better accuracy aimed down sights

#### Browning M1919
* Name rearranged to M1919 Browning for historical accuracy
* Slightly lower mobility compared to the MG42, representing its heavier weight in real life
* Slightly lower ADS time, as this weapon is supposed to be slow to handle
* (Upgraded) Fixed capitalization in the name
* (Upgraded) The Browning now receives a similar damage multiplier buff compared to the MG42 when upgrading, instead of previously being left behind
* Has visible bipod in models for both upgraded/un-upgraded versions

#### MG42
* Slightly higher mobility compared to the Browning, representing its lighter weight in real life
* Decreased un-upgraded drum magazine capacity from 125 to 100 while still retaining the same 500 stock ammo, so it is only a total difference of 25 bullets. This is to differentiate it from the Browning and better resembles the historically accurate lower capacity of the drum magazine compared to a full chain
* Has visible bipod in models for both upgraded/un-upgraded versions
* (Upgraded) Updated model to remove metal gaps without silver etching and fix different colored panel

#### PTRS-41
* Nerfed reserve ammo to 50 max instead of 60 to match other similar rifles, and also so that the upgraded reserve ammo of 60 feels earned
* Uses the cut sniper voiceover category instead of the PPSh when playing as the four heroes
* (Upgraded) Increased reserve ammo from 60 to 64 so it is actually divisible by the clip capacity (8)
* (Upgraded) Receives small mobility buff

#### M2 Flamethrower
* Player model now has attached fuel tank while weapon it is in inventory
* Uses mobility stats from Nacht Der Untoten on all maps
* Uses slightly buffed damage stats from later DLCs on all maps
* Fixed knife delay
* Fixed ADS glitching when using Toggle ADS settings
* Fixed Bowie Knife missing sound when knifing with this weapon
* (Upgraded) Receives small mobility buff

#### Panzerschrek
* Small damage buff so rockets are deadlier than regular grenades, as they should be
* (Upgraded) Receives small mobility buff

#### Knife
* Knife lunging is more smooth and occurs less often

#### Bouncing Betty
* Decreased delay from 2 seconds to 1 second before activation is possible
* Limit of 30 Betties placed per player, last Betty auto detonates
* When more than 4 mines explode one frame the server waits another frame before continuing to prevent crashes, similar to Treyarch's Satchel Charge failsafe
* Fixed capitalization in the instruction hintstring
* Wallbuy trigger requires the player to look at the chalk, like other weapons
* Removed hand logo from wall buys for consistency
* Added prone settings so weapon lowers as player crawls

#### Molotov Cocktails
* Added fire FX deaths when zombies are killed
* Disabled explosive voiceover, as quotes do not apply
* Received a buff so they are better than normal grenades while still being far from powerful
* Leaves radius at location of impact that deals ticks of fire damage to zombies that walk through the fire

#### Frag Grenades
* Received a small buff, frag grenades on all maps now behave similar to the Der Riese and Black Ops I
* Fixed plurality on wallbuy hintstrings
* If a player with full grenades tries to purchase more, the wall model simply appears but no points are lost
* Grenade suicide does not spawn an extra grenade after dying

#### Ray Gun
* Fixed animation to remove blocky left hand
* Fixed reload animation not matching when ammo counter refills
* (Upgraded) Fixed Ray Gun voiceover not playing, and it is now based on damage weapon variable not current weapon held variable
* (Upgraded) Fixed last stand giving you more than one ammo cartridge
* (Upgraded) Added missing 3rd person weapon model that has the silver etching material

#### Wunderwaffe DG-2
* Does not permanently reduce max health upon zapping yourself
* Fixed missing reload clip on Der Riese for both upgraded/un-upgraded versions
* (Upgraded) Time between arcs is 20% shorter, improving the effectiveness of the weapon upon upgrade
* (Upgraded) Max zombies per chain increases from 10 to 12, improving the effectiveness of the weapon upon upgrade
* (Upgraded) Added missing 3rd person weapon model that has the silver etching material
* (Upgraded) Fixed not playing idle electric humming sound while holding weapon
* (Upgraded) Fixed not playing the tesla sound after getting a 4 killstreak

## Optional Patches
* DualShock patch: Adds PlayStation 3 style icons to the HUD when using Controller Mode instead of the default Xbox 360 icons
* Nacht Der Untoten wall chalk glow: Adds a glow to the regular chalk text on the walls similar to the console version
* Verrückt alternate music: Adds the slightly alternate version of Lullaby for a Deadman with subtle piano keys in the background
* Legacy icons patch: Available for both PlayStation or Xbox style, these patches replace the 3D graphic button logos on Controller Mode which generic 2D text/shapes, which is less accurate to recreating the console HUD but more faithful to the original PC release. Available on my Discord

## Experimental Features
* Toggleable with console command `zombiemode_dev 1`, these features will never be the default/accessible in regular gameplay and are considered cheats, high round records will not save
* Enables ability to close 'help' door on Nacht Der Untoten after opening

## Special Thanks & Credits
* Numan, cristian_m, JezuzLizard, Phil81334, Gympie5, Tristan, NGcaudle, psulions45 - General modding advice
* YaF3li & Vertasea - General modding advice and script fixes from their World at War mod tools project
* MrJayden585 - Zombified SS uniform texture and additional feedback
* Bunz1102 - All custom models and animations for the Dr.'s Easter Egg item and custom animations for Mortar putaway
* Tom Crowley - Easter Egg melee weapon model and animation
* jiggy22 - Original creator of SVT-40, Type 99, and DP-28 upgraded model UV mapping, which I have modified
* ege115 - Original creator of first person sway walking script, which I have modified
* Fusorf - Original creator of HD perk/powerups shaders, which I have modified
* RealVenom - Fixed Ray Gun viewmodel animation at high FOVs
* dontknowletspl & Lachara_43 - Original scripting for aim assist lock on, which I have used heavy inspiration from
* Jbird632 - Original creator of sticky grenades sticking to AI fix and "Reward All Perks" scripts, both of which I have modified
* Inspired by JBleezy's Black Ops I Reimagined mod
* And thank you to the members of both my own & UGX's Discord for feedback along the way
