======================================================
WORLD AT WAR - NAZI ZOMBIES REMASTERED [Requires T4M]
======================================================

## A mod by John_Banana (/u/m4_semperfi)

Mod started: 7/30/2020

This mod, currently only for Shi No Numa & Der Riese, is a "remastered patch" for the WaW stock maps. The other maps are still a work in progress! The aim of this project is to modify WaW stock maps with bug fixes, quality-of-life tweaks, removed inconsistencies, and with some new features inspired by Black Ops 1. At the same time, the mods will not overhaul each map or mess with their original gameplay, they are meant to act as a more polished alternative vanilla experience.

Due to the nature of WaW modding, it was easier to make each map have their own mod file. When they are all finished, you will be able install whichever ones you want. Simply launch the desired map in your mods list, and then press play on the menu. This works in co-op as well, just make sure all players have the same version of the mod launched & T4M installed! 

-> nazi_zombie_remastered_dlc3 (for Der Riese)
-> nazi_zombie_remastered_dlc2 (for Shi No Numa)
& coming in the future:
-> nazi_zombie_remastered_dlc1 (for Verrückt)
-> nazi_zombie_remastered (for Nacht Der Untoten)

Additional Credit
* Numan, Phil81334, cristian_m, Tristan, MrJayden585, psulions45 - General scripting help
* Jbird632 - Working sticky grenades & "All Perks" scripts
* ege115 - Walking animation script
* GKILLA - Updated FG42 viewmodel
* Fusorf - HD perk icons
* SPi for co-op testing
* Inspired by JBleezy's Black Ops 1 Reimagined mod
* Thank you to the UGX WaW Discord members for helping me along the way


### Universal Change Notes ###

## General
* Added Achievement completion notifications and functionality for Shi No Numa and Der Riese. Achievements were previously only available on the console version.
* Added screen shake when boards are removed/placed, similar to future zombie games.
* Repairing barriers only plays the point sound effect when you are actively earning +10, similar to future zombie games.
* Electric traps are now on a 30 on / 30 off cycle, similar to future zombie games. However, on Shi No Numa the cooldown is kept longer for balance reasons, but now just at 60 seconds.
* Stinger sound effect when picking up Wonder Weapons now execute through scripts, like future zombie games, instead of VOX. Fixes issues where it would sometimes not play.
* Slightly increased Easter Egg song volume.
* Fixed the Mystery Box playing the couch slam sound after every roll post Teddy Bear in co-op.

## Zombies
* When playing solo, all maps default to the "Der Riese style" of spawns with more than 24 zombies per round. However, the "Gametype" setting in Game Options allows players to revert this change (With the "Classic" mode referring to only 24 zombies per round).
* Zombies no longer push players (the "grabbing" effect that slowed you down). Similar to above, the "Enemy Pushing" setting in Game Options allows players to revert this change for a more challenging experience (With the "Classic" mode meaning zombies will grab you).
* Zombies now have glowing eyes in all four maps, not just Nacht Der Untoten and Verrückt.
* In addition to Round 1, Round 2 will also only be walkers. This allows for a more gradual increase in pacing.

## Players & Characters
* Player spawns as a random character on solo, with accurate 1st person viewhands, pistols, and corresponding points color.
	For the heroes:
		* Dempsey -- Colt -- Marine bare hands with rolled up sleeves -- taken from Campaign
		* Nikolai -- Tokarev -- Russian jacket sleeves with custom yellowish-tan colorization, Soviet buttons, and added blood splatters -- edited from Campaign 
		* Takeo -- Nambu -- Japanese jacket sleeves with custom bluish-grey colorization -- edited from Multiplayer
		* Richtofen -- Walther -- German tan sleeves and black gloves recolored from the "Black Cats" pilot hands -- edited from Campaign 
	For the Marines:
		* Random voice -- Colt -- Default hands
* Splash damage is equal on all maps using a hybrid of existing maps (a little less harsh than Nacht but not too underpowered like Der Riese; near-proximity explosions will instantly down you).
* Increased backwards and sideways movement speed to match closer with the console version of WaW.
* First-person walking animation tweaked. Weapon now sways instead of just lowering, which both looks better and is similar to future zombie games.
* Improved timing of red screen heartbeat sounds to sound better, they are no longer linked to in-game FPS.
* Fixed VOX start delay inconsistencies for the Teddy Bear, song activation, Wunderwaffe kills, Powerups, Teleporter countdown, and picking up Wonder Weapons. Fixing these issues both makes voiceover delays completely consistent between maps/characters, but it also prevents additional voiceover lines from being able to play before queed lines have finished, resulting in an occasional weird overlap
* VOX interactions disabled on solo to prevent non-present characters from talking.
* VOX is disabled while in solo last stand.
* Disabled leaning while downed to fix a bug.
* Player respawn does not reset FOV back to 65.

## Voiceover
	# Four Marines (New)
	* Added an entire set of new voicelines to Nacht Der Untoten based off of the style of the other WaW maps (headshots, power-ups, weapons, oh_shit, etc.).
	* There are a total of 32 categories with over 100 lines per character, and even some unique voice interactions/categories not seen on other maps.
	* Uses audio taken from campaign.

	# Four Heros
	* Added unused sniper pickup VOX found in the game files.
	* Added unused hellhound kill VOX found in the game files, with a 25% chance of it playing per kill.
	* Added unused VOX that plays when a player downs.
	* Added unused reload VOX that has about a 50% chance of playing during an *empty* heavy LMG reload, with a cooldown of 1-2 minutes to prevent repetitiveness (Adds to atmosphere, but also can be useful for teammates to hear).
	* Added unused pain VOX that plays when a player is damaged. 
	* Added unused exert VOX that plays about 75% of the time a player damages a zombie with melee, and 100% of the time when a player kills a zombie with melee (Unless other dialogue VOX is queued, in which case it over rules the exert sound).
	* Added several unused VOX lines that play after a player is revived, instead of only alternating between 2 possible lines.
	* Added unused Takeo Panzershrek VOX.
	* Unlocked just a few unused VOX lines for weapons that were never loaded in the scripts but were included in the soundaliases (MP40, BAR, Shotgun, Wunderwaffe, Monkey Bomb).
	* Reworked "no money" sounds and VOX for purchasable items when a player does not have enough points:
		- Wall Weapons: Now have a chance of saying an unused VOX line, the standard VOX groan, or nothing.
		- Mystery Box: Now have a chance of saying two unused VOX lines, the standard VOX groan, or nothing. Also added "no purchase" sound effect, the same sound that plays when you cannot afford a wall weapon or door.
		- Perk/PaP: Now has a chance of playing the VOX groan instead of only playing the VOX dialogue to make it less repetitive.

## HUD
* The accurate Steilhandgranate grenade icon replaces the American Mk2 grenade icon.
* Monkey bomb icon updated to look more recognizable while still in the greyscale WaW icon art style.
* Perk and powerup icons updated with accurate higher resolution versions.
* Removed grenade indicators from special grenades, not only because they're less necessary (can't pick them back up, don't roll around), but also because WaW can only display the one frag grenade logo type, meaning all grenades "appear" as a frag grenade.
* (T4M) Pressing tab in solo now shows the scoreboard.
* (Console command) "health_hud" can be used to enable or disable a health counter, effective after a restart. Intended for testing/development purposes.

## Menu & Settings
* Solo play button added to the main menu which will automatically run the loaded map. This also prevents the player from accidentally starting the wrong map.
* Redesigned main menu to remove non-Zombiemode related buttons and references. Also, added a reminder for all players to install T4M before playing co-op.
* Added Character Bios, which were only present on the console version. Slight grammatical fixes and layout design changes to adapt it for PC.
* Added Map Intel page, which includes information on Achievements and the image/description of the loaded map (This info is no longer accessible because of the "start button" changes).
* Entirely new settings on the following pages: Graphics, Sounds, Game Options
* Includes an FOV slider, FPS settings, controller support settings, gametype/AI options, fog, character dialougue, LOD bias, and more

## Perks & Powerups
* Quick Revive now works on solo
* Perks have proper hintstring in every map and "Quick Revive" is no longer offered as just "Revive."
* Jugger-Nog abilities and regen is the same on all maps, using the improvements from Der Riese.
* Carpenter available on all maps (Disabled when playing in "Classic" gametype setting for high-rounders).
* Max Ammos now refill equipment on all maps (Bouncing Betties & Molotovs).
* Slightly increased volume of Insta-Kill active loop sound.
* Double Points changes:
	- Carpenters and Nukes are now affected by an active Double Points, able to give +800 and +400 respectively.
	- Picking up 2 Double Points at the same time will now scale together giving x4 points, like the first few WaW maps (rare case). This x4 scaling works with kills, barrier repairs, and other power ups.
* Slightly increased VOX delay to make sure dialogue does not overlap the announcer.

## Last Stand
* Solo:
	- With Quick Revive, you can have up to 3 lives until the machine disappears.
	- It takes 10 seconds to self revive, and zombies will run away while the player is down. Added a progress bar that fits well with the WaW visual style.
	- Player equips their upgraded starting pistol while down (Or the Ray Gun, if applicable).
* Co-op:
	- Pistols now have a hierarchy if a player is holding one before going down: Ray Gun has precident, then upgraded starting pistols, .357, and if they have none they go back to the default pistol
	- Bleedout time has been increased from 30 seconds to 45 seconds, like future zombie games. 
* Player receives 3 magazines for regular pistols and only 1 cartridge for both the un-upgraded and upgraded Ray Gun.
* If a player has no ammo for a pistol before they down, then that weapon will not be counted in the above hierarchies.
* If a player recieves a Max Ammo while down, they will not be given grenades.
* Both solo self-revives and the buffed bleedout time are toggleable under the "Last Stand" option in Game Options.

## Weapon Loadouts
* There are 9 new WaW weapons taken from Campaign/Multiplayer that have never been seen in zombies. As it stands, every stock weapon in WaW is now obtainable in some form through this mod. 
* All maps have identical loadouts except for the following discrepencies:
	- Verruckt & Nacht Der Untoten have the Springfield, in addition to the Kar98k
	- Shi No Numa has the Arisaka instead of the Kar98k, as well as the Japanese grenades and American bazooka replacing their respective German versions
	- Each of the 4 maps has a unique scoped rifle in the Mystery Box
	- Unique Wonder Weapons like the Wunderwaffe or Monkey Bombs will stick to their original maps

## New Weapons
For new upgraded variants, all official sounds, effects, stats, and textures were used if they existed, otherwise custom versions had to be made (Described where applicable).

Starting Pistols
Colt M1911 / Tokarev T-33 / Type 14 Nambu / Walther P38 (The 3 new pistols are used as starting weapons for non-American heroes)
- All have identical stats and upgrade to explosive pistols
- Not in Mystery Box, only obtainable through default spawn loadout
- (Walther) Removed first raise animation so it is uniform with the other pistols
- (Upgraded) Increased reserve ammo from 40 to 42 so it is actually divisible by the magazine capacity (6)
- (Upgraded) Custom camos made in Treyarch's style using the official textures
- (Upgraded) All have unique names, either inside jokes or easter eggs relating to the weapon's faction
- (Upgraded) Changed the _lastshot animation so the pistol slides do not go back and then glitch forward
- (Upgraded) Added muzzle flash effects
- (Upgraded) Added both the unused PaP sounds (so all 4 upgraded pistols sound unique) and the grenade sound upon impact
- (Upgraded) Buffed fire rate and damage to make keeping your starting pistol a little more rewarding. In combination with the above sound changes, these tweaks make the pistols feel a little more akin to the Mustang and Sally from Black Ops 1.

Type 99
- Added to the Mystery Box
- Stats slightly buffed from their default SP stats to fit for zombies. Weapon now sits as a mid-tier LMG, above the BAR and FG42, but slightly below the MG42 and Browning
- Increased ADS FOV from 30 to 40 to give more visibility
- (Upgraded) Custom camos made in Treyarch's style using the official textures
- (Upgraded) New variant created with a custom name (name inspired by cut upgraded Type 99 Arisaka rifle), increased damage, fire rate, better multipliers, and more ammo

DP-28
- Added to the Mystery Box
- Rebalanced empty reload speed to closer match animation
- (Upgraded) Custom camos made in Treyarch's style using the official textures
- (Upgraded) New variant with my own custom name and stats as a mid-tier LMG

SVT-40
- Added to the Mystery Box
- (Upgraded) Custom camos made in Treyarch's style using the official textures
- (Upgraded) New variant with my own custom name and stats based on a mixture of the upgraded Gewehr 43 & M1 Carbine

M9A1 Bazooka
- Replaces the Panzerschreck on Pacific-theater maps (Shi No Numa)
- Tweaked some animation timing to look better
- Identical damage/ammo stats to the Panzerschreck. Purely an aesthetic change

Sticky Grenade
- Additional special grenade on Shi No Numa that was cut from the map
- Uses cut voicelines

Type 97 Frag Grenade
- Replaces the Stielhandgranate on Pacific-theater maps (Shi No Numa)
- Identical damage/ammo stats to the Stielhandgranate. Purely an aesthetic change

Scoped Snipers
- Added to the Mystery Box accordingly: the Scoped Springfield will be on Verruckt, the Scoped Arisaka is on Shi No Numa, the Scoped Mosin is on Der Riese, and the Scoped Kar98k remains on Nacht
- Names tidied up for more historical accuracy. All have unique in-scope textures
- While the addition of these Scoped Snipers into each map is new, the difference between each variant is purely aesthetic, as the damage/ammo stats are identical
- (Upgraded) New variants with my own custom names, camos, and stats based on a mixture of the upgraded Kar98k & PTRS-41

## Weapon Changes
Additionally, I have adjusted many of the existing weapons, usually for balance reasons as a result of Treyarch not giving adequate Pack-a-Punch buffs, upgraded weapons not having properly calculated reserve ammunition (ending up with half filled magazines), some weapons having bugs, or me wanting to add my own personal tweaks.  

.357 Magnum
- Decreased reserve ammo from 80 to 78 so it is actually divisible by the weapon capacity (6)
- (Upgraded) Slightly increased fire rate
- (Upgraded) Increased reserve ammo from 80 to 90 so it actually receives a decent ammo buff upon upgrading

Kar98k
- Fixed Bowie Knife missing sound when knifing with this weapon
- (Upgraded) Fixed missing muzzle flash effect
- (Upgraded) Increased reserve ammo from 60 to 64 so it is actually divisible by the magazine capacity (8)

Gewehr 43
- (Upgraded) Increased reserve ammo from 170 to 180 so it is actually divisible by the magazine capacity (12)

M1A1 Carbine
- Renamed to M1 Carbine for historical accuracy (non-folding stock variant)
- Slightly nerfed damage as this weapon should be similar, if not worse, at raw damage than the M1 Garand
- Slightly buffed mobility to suit this weapon better, being lighter than other rifles in real life
- (Upgraded) Increased magazine size from 15 to 30 so it actually receives a decent ammo buff upon upgrading

M1 Garand
- Slightly buffed base rifle damage
- Slightly buffed weapon spread accuracy to balance with the Rifle Grenade version (which makes the rifle less accurate)
- (Upgraded) Increased reserve ammo 150 to 156 so it is actually divisible by the clip capacity (12)
- (Upgraded) Slightly buffed headshot multiplier so it is the highest out of all regular semi-automatic rifles, which fits with its superiority in WWII

M1 Garand w/ Launcher
- Slightly buffed base rifle damage
- Decreased mobility to compensate for Rifle Grenades
- Nerfed maximum ammo to balance with regular M1 Garand and compensate for Rifle Grenades
- When equipping the launcher, the name changes to the name of the grenade launcher for historical accuracy
- (Upgraded) Nerfed maximum ammo to balance with regular M1 Garand and compensate for added Rifle Grenades
- (Upgraded) Renamed equipped launcher to M7000
- (Upgraded) Slightly buffed headshot multiplier so it is the highest out of all regular semi-automatic rifles, which fits with its superiority in WWII
- (Upgraded) Slightly nerfed max launcher explosion radius so that it is less than the upgraded Panzer, there's no reason these should've had identical stats when they're different projectiles
- No longer shares reserve ammo with the regular M1 Garand to fix a reload bug

Double-Barreled Shotgun
- Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
- (Upgraded) Fixed capitalization in the name
- (Upgraded) Fixed ADS FOV being way too low 

Sawed-Off Double-Barreled Shotgun
- Added to the Mystery Box
- Removed "w/ Grip" from the name
- Removed Trench Gun ejecting shell effect, as the shells are only disposed of when reloading
- Small damage boost to both un-upgraded and upgraded version; a little stronger than the normal double barrel but with a wider and less accurate fire spread
- (Upgraded) Scrapped variant created by Treyarch

Thompson
- Renamed to M1A1 Thompson for historical accuracy
- (Upgraded) Increased reserve ammo from 250 to 280 so it is actually divisible by the magazine capacity (40)

Type 100
- Fixed dry fire sound effect not being the SMG sound effect
- Increased reserve ammo from 160 to 180 so it is actually divisible by the magazine capacity (30)
- (Upgraded) Increased reserve ammo from 220 to 240 so it is actually divisible by the magazine capacity (60)
- (Upgraded) Updated weapon model and first person model with the newer Pack-a-Punch texture, as for some reason this weapon still used Treyarch's original silver texture (less shiny, only found on scrapped weapons) 

PPSh-41
- (Upgraded) Decreased reserve ammo from 700 to 690 so it is actually divisible by the drum mag capacity (115)

STG-44
- Fixed capitalization of the "t" to be lowercase for historical accuracy

BAR
- Renamed to M1918 BAR for historical accuracy
- Slightly decreased mobility to suit its weapon category better
- (Upgraded) Increased stock ammo from 180 to 240 so it actually receives a decent ammo buff upon upgrading (also, not being a wall weapon)

FG42
- Updated viewmodel to look more complete for when playing on higher FOVs

Browning M1919
- Name rearranged to M1919 Browning for historical accuracy
- Slightly lower mobility compared to the MG42, representing its heavier weight in real life
- Slightly lower ADS time, as this weapon is supposed to be slow to handle
- (Upgraded) Fixed capitalization in the name
- (Upgraded) The Browning now recieves a similar damage multiplier buff compared to the MG42 when upgrading, instead of previously being left behind

MG42
- Slightly higher mobility compared to the Browning, representing its lighter weight in real life
- Decreased un-upgraded drum magazine capacity from 125 to 100 to differentiate it from the Browning, which also better represents its (historically) lower capacity

PTRS-41
- Nerfed reserve ammo to 50 max instead of 60 to match other similar rifles, and also so that the upgraded reserve ammo of 60 feels earned
- Now plays cut sniper VOX instead of PPSh VOX, which also makes the PPSh VOX more special being used for just one weapon
- (Upgraded) Increased reserve ammo from 60 to 64 so it is actually divisible by the clip capacity (8)

M2 Flamethrower
- Fixed knife delay
- Fixed ADS glitching when using Toggle ADS settings
- Fixed Bowie Knife missing sound when knifing with this weapon

Knife
- Knife lunging is more smooth and occurs less often

Bouncing Betty
- Decreased delay from 2 seconds to 1 second before activation
- Fixed capitalization in the instruction hintstring

Molotov Cocktails
- Received a moderate buff so they are somewhat better than normal grenades, but are still not very useful

Stielhandgranate
- Fixed plurality on hintstring
- Grenade suicide does not magically give you an extra grenade when falling into last stand

Ray Gun
- (Upgraded) Fixed Ray Gun VOX not playing
- (Upgraded) Fixed last stand giving you more than one ammo cartridge

Wunderwaffe DG-2
- Does not permanently reduce max health/remove Jugger-Nog health buff 
- Fixed missing loading clip on Der Riese
- (Upgraded) Fixed not playing idle loop sound while holding weapon (electric humming)
- (Upgraded) Fixed not playing the tesla sound after getting a 4 killstreak

Mystery Box
- Ray Gun is obtainable from the first Mystery Box location on all maps now, and you are not required to get a Teddy Bear first 
- Gewehr 43 & regular M1 Garand are no longer excluded from the box on any maps where they were

Heavy Weapons
- (Upgraded) Flamethrower, PTRS, and Panzerschreck all increase in mobility



### Map Specific Change Notes ###

## Shi No Numa
* Added "mission intro" in bottom left corner at the start of the game.
* Added "level start" VOX using generic Zombie quotes.
* Added unused jap_walk_v4 animation.
* Added unused (rarely occuring)  jap_run_v5 animation.
* Added unused (rarely occuring)  jap_run_v6 animation.
* Added unused swamp perk machine textures from the game files.
* Added cut hellhound round start "howling" sound that was only used on the PS3 version. 
* Perk hintstrings now have unique messages, like the other maps.
* Hellhound functionality includes improvements made in future maps, including a health buff, but slightly lower than Der Riese to account for no Pack-a-punch.
* Fixed hellhounds playing normal zombie death sounds in electric traps.
* FIxed electric trap "ready to use" warning sound so it plays on the actual location rather than always at the flogger.
* Carpenter VOX uses additional repurposed lines that were originally made for general barrier repairing.
* When picking up a powerup, characters choose from 3 lines instead of 1. 
* When opening the second or third hut, there is a 50% chance of the closest player commenting on the randomization of perks.
* When a perk is decided, there is a higher chance of the closest player within a small radius shouting the perk name.

## Der Riese
* Changed vision file to give the map a bluer and dark tint, rather than the original greyish-green look.
* Updated 'mission intro' in bottom left corner to include the storyline accurate date.
* Added unused walk_v9 animation. (Used in Black Ops 1)
* Added unused 5th Maxis radio from the game files. To compensate for this radio covering up a pre-existing Field OP easter egg, this page has been moved to a new hidden location. (Used on IOS version) 
* Der Riese Easter Egg/Storyline changes & additions:
	- Increased percent chance for VOX when interacting with Easter Egg items and added one unused Takeo line to the Corkboard cycle. (50% chance)
	- Increased percent chance for general storyline VOX early game. (5% chance)
	- Added unused rare VOX that can play after teleporting. (5% chance)
	- Added unused rare VOX that can player after picking up a power up. (3% chance)
	- Added new Easter Egg VOX for the "Teddy is a liar" wall writing.
	- The Fly Trap Easter Egg now spawns in a random power up as an award.
	- Proning at a perk will now randomly either give you one, two, or three "+10 points" instead of always just "+25." This not only adds some nice variety and mirrors how each perk is supposedly worth "10 cents," but it also fixes an issue where WaW only displays points rounded to the nearest tenth, meaning a player may think they have more points than they actually do.
* Increased PaP "waiting" VOX odds to play 50% of the time you upgrade, rather than 8%, which is more similar to future zombie games.
* Added extra checks so players will never talk about needing to link the teleporters or open Pack-a-Punch after the task is already completed.
- Pack-a-Punch hintstring disappear when you are holding an upgraded weapon and when another player's weapon is in the machine.
* Added several unused VOX lines when a player picks up the Carpenter power up.
* Player surrounded VOX now also plays in solo, but without the responses from other characters and at a lower % chance.
* Player no longer receives a free Colt when they have 0 weapons from leaving a weapon in the Pack-a-punch machine, instead the screen is just blank, similar to future zombie games.
* The post-teleporter FOV effect now remembers your FOV if it has been changed.
* Tweaked teleporter cooldown message to be plural, as all teleporter[s] are set on cooldown after one is used 





DER RIESE QUEST
* Open PaP
* Fly trap 
* A different player must succesfully interact at each of the 3 corkboards
* Aquire upgraded wunderwaffe

	- one puzzle step
	- one challenge step
	- book from SNN



NACHT:
	-Old sounds
	-Old heads (make sure same as verruckt)
	-Main Bodies: 
		-SS Uniform (camo)
			-35% chance of spawning "charred"
			-50% chance of having sleeves off
			-4% chance of spawning with hat model (3/4 normal camo helmet, 1/4 rare decaled helmet)
			-4% chance of spawning with gear

		-Light Uniform - Nazi Armband
			-35% chance of spawning "charred"
			-50% chance of having sleeves off
			-4% chance of spawning with hat model (3/4 normal helmet, 1/4 rare cap)
			-4% chance of spawning with gear





DIFFERENCES:
-  No longer need to wait for all characters to do their tasks before being able to do Richtofen notes
	- more straightforward, once you have the diary you dont have to weirdly just wait around
	- however, it could mean players dont stick together as much
- No longer have to do tallys before or on round 20, this was a little too unfair for first time players
- Dempsey now has to pick up a radio before doing his step (requires finding it in the spawn hut)



Steps:

-- Phase 1 -- (Individual tasks)

1) Interact with Richtofen's bookshelf to activate the quest.

2) Players must split up and each complete a task:
	* Dempsey must attempt to report intel on Peter (Comm Room)
		- Activate spawn room radio to hear the message first
		- Dislodge Peter's radio by using an explosive near his parachute
		- Using the radio, interact with the 3 radios in the correct order to "power it on" and "connect" your radio.
		- Simply place your radio down and a message will begin sending.
		- After sending the message, you will have to pick the radio back up and destroy it in the water to cover your tracks.
	* Nikolai must find Vodka (Storage)
		- Find a bottle of Vodka in the storage hut hidden at one of three random locations
		- ?
	* Takeo must find his blade (Fishing Hut)
		- First pick up a bucket, hidden at one of three random locations
		- Place the bucket at the fishing pole
		- To operate the fishing pole, hold down F to lower and raise the bucket
        - Using the bucket, you can clean the Katana by interacting with, losing the bucket in the process
        - Finally, you can pick up the Katana
   	* Richtofen must acquire his journal (Doctor's Quarters)
		- Pick up the journal
		- Avoid touching water or you will lose the book, you will have to power on the zipline
		- Take notes at 3 intel sites
		- After suceeding, you will no longer lose your journal in water.

-- Phase 2 -- (Team task)

3) Find and collet a 115 sample. The team will first need to use the Flogger until a zombie drops a sack, which any player can pick up (4 consecutive zombie "fling" kills are required).

4) The team must then locate a small 115 meteor for the player with the sack to pick up.

5) The player with the 115 meteor must obtain the Wunderwaffe DG-2 and acquire 20 succesfull zaps without swapping it out. This means, you must kill at least 20 zombies each with a separate shot. After doing this, the HUD icon will update and a shock sound will play.

-- Phase 3 -- (Challenge)

6) Someone must then interact with the tally marks showing "20," which both signifies how many zaps were needed and that the team must continue to survive until at least round 20. 

7) With (a) the charged 115 sample, (b) the tally markes interacted with, and (c) on at least round 20, the player with the Wunderwaffe must shoot the large 115 meteor. This will result in a nuke effect shocking the surrounding zombies and the players will be rewarded. Here represents where the characters would have teleported to Der Riese, after succesfully completeling everything in Shi No Numa.



Game Design Analysis:
This quest has all the essential aspects of a classic 4-player BO1-style easter egg, but adapted and simplified for World at War.

It combines several elements:
	- Luck (Need Wudnerwaffe from the box, and several steps are mysterious enough that players will have to stumble into them)
	- Skill (Surving from  zombies for 20 rounds, ability to find secret items)
	- Puzzle Solving (Dempsey's radio message, understanding the steps, i.e. that the 20 tally marks means that the number 20 has some sort of significance)
	- Teamwork (Protecting Richtofen, everyone doing their tasks, it's not just up to one player)
 
 The quest must also be activated before any steps can be completed, making it completely possible for players to never know the easter egg existed. None of the steps are explained to the player and they must figure it out themselves. The quest not only requires all 4 players (a classic element of early Treyarch easter eggs), but it also actually makes sense because each player has a specific role. 

 The quest also makes use of the map's setting and design:
 	- The required tasks correspond to each hut's purpose (Comm Room: Radio, Storage: Vodka, Fishing: Blade, Dr's Quarters: Richtofen's Journal)
 	- The swampy marsh creates a challenge for Richtofen as he must navigate the map without touching water, requiring the use of the Zipline
 	- The newly introduced Wunderwaffe DG-2, flogger, and Element 115 meteor are all essential parts of the quest


Story Analysis:
The quest also combines several story related elements:
	- Obtaining Richtofen's journal & any additional information from the Rising Sun facility
	- Dempsey's connection to Peter
	- The significance of Element 115, the Wunderwaffe, and it's ability to generate massive power, as these are things all introduced to us in Shi No Numa
	- Some sillier elements relate to character stereotypes, which were also introduced on Shi No Numa, like Nikolai's vodka

The understanding of this quest is that Shi No Numa is where Richtofen's grand scheme began (for the playable experience). He obtains his journal and additional notes, while the other characters explore the map and complete their own character-specific tasks. The heroes eventually harness the power of the Wunderwaffe and collect a sample of 115 as part of Richtofen's "research." In reality, acquirring 115 would also be an attempt at him trying to further his own goals. However, as the heroes were fighting off zombies they accidently overcharged the 115 sample due to the Wunderwaffe's power. Seeing this, Ricthofen realized this could be used to try to teleport him to the moon. He shoots the larger meteor with the Wunderwaffe, sending an electric and powerful shock throughout the facility. This waves leave the players in an unstable aura of 115 that at any point could cause them to teleport randomly. It happens to be that they accidently teleport to the Der Riese facility mainframe, which is briefly powered by their 115 which quickly fades away once they arrive, as they hear the voice over stating that it is shutting down... and zombies start to come.
