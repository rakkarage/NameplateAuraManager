# 📛 Nameplate Aura Manager

This World of Warcraft addon manages aura visibility on default player and enemy nameplates.

## Features

- Customizes which auras are visible on player and enemy nameplates.
- Separate management for buffs (player nameplate) and debuffs (enemy nameplate) allowed and blocked.
- Uses game default settings if no custom lists are provided.

## Class Defaults

- Currently, only Warriors and Hunters have pre-defined default debuff lists.
- Game default settings will be used if buff (player) or debuff (enemy) lists are empty.
- Feel free to suggest default lists for other classes.

## Usage

- `/nam list` to display class allow and block, buff and debuff lists.
- `/nam clear` to clear class allow and block, buff and debuff lists.
- `/nam reset` to reset class allow and block, buff and debuff lists to default.

### Player Nameplate

- `/nam allowbuff [spellId]` to toggle an allowed buff on the player nameplate.
- `/nam blockbuff [spellid]` to toggle a blocked buff on the player nameplate.
- `/nam listbuff` to display class allow and block buff lists.
- `/nam clearbuff` to clear class allow and block buff lists.
- `/nam resetbuff` to reset class allow and block buff lists to default.

### Enemy Nameplates

- `/nam allowdebuff [spellId]` to toggle an allowed debuff on the enemy nameplate.
- `/nam blockdebuff [spellId]` to toggle a blocked debuff on the enemy nameplate.
- `/nam listdebuff` to display class allow and block debuff lists.
- `/nam cleardebuff` to clear class allow and block debuff lists.
- `/nam resetdebuff` to reset class allow and block debuff lists to default.

## Finding Spell IDs

You can find spell ID in aura tooltip with [idTip](https://github.com/ItsJustMeChris/idTip-Community-Fork) or find on [wowhead](http://wowhead.com/spell).

## Screenshots

![Enemy nameplate with auras.](screenshot1.png)
![Enemy nameplate with aura stacks.](screenshot2.png)
![Player nameplate with auras.](screenshot3.png)
