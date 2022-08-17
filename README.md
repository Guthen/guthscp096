# [SCP] Enhanced SCP-096 [Module]
Watch the [Trailer Video](https://youtu.be/5fAdBu-0r0A)!

## Steam Workshop
![Steam Views](https://img.shields.io/steam/views/2641523360?color=red&style=for-the-badge)
![Steam Downloads](https://img.shields.io/steam/downloads/2641523360?color=red&style=for-the-badge)
![Steam Favorites](https://img.shields.io/steam/favorites/2641523360?color=red&style=for-the-badge)

This addon is available on the Workshop [here](https://steamcommunity.com/sharedfiles/filedetails/?id=2641523360)!

## Features
+ **System**: 
    + **Enrages** when a non-SCP player has SCP-096's face on his "screen" ([possible incorrect results](#known-issues))
    + **Calms down** when all his targets are killed ─ or, if you enabled `Unrage on Time` option, when the enrage time runs out
    + Configurable **Sound** paths & hear distance
    + Configurable **Movement Speed** bonus while enraged
    + Configurable **Screen Shake** while near of an enraged SCP-096
    + *(fun) Allow multiple SCP-096 instances*
+ **SWEP**:
    + **Class**: `guthscp_096`
    + **Left Mouse Button**: while enraged, **kill your targets** or **break the looking entity**
    + **Right Mouse Button** to cover your hands on your face ─ unfortunately, it's not visible for other players
    + (optional & configurable) [Keycard System](https://steamcommunity.com/sharedfiles/filedetails/?id=1781514401) custom access
+ Configurable in-game with [[SCP] Guthen's Addons Base](https://steamcommunity.com/sharedfiles/filedetails/?id=2139692777) (`guthscp_menu` in your console)
+ Can **break doors and props** with a single left click while enraged
+ **Compatible with every gamemodes**
+ **Compatible with addons:**
    + [Ultimate gMedic](https://www.gmodstore.com/market/view/ultimate-gmedic)

## Convars
+ `guthscp_096_render_targets_halo <0 or 1>`: Render a halo on the SCP-096 targets, more expensive than a line
+ `guthscp_096_render_targets_line <0 or 1>`: Render a line between you and the SCP-096 targets 
+ `guthscp_096_render_post_process <0 or 1>`: Render post process effects as SCP-096, really expensive on performance but damn cool
+ `guthscp_096_render_path_finding <0 or 1>`: Render path toward targets as SCP-096. It's a rudimentary method, it's not 100% relatable.

## Known Issues
### "The addon doesn't work!"
Be sure to have installed [[SCP] Guthen's Addons Base](https://steamcommunity.com/sharedfiles/filedetails/?id=2139692777) on your server. Verify that you can open the configuration menu with `guthscp_menu` in your game console.

### "I enrage SCP-096 even though I didn't looked at him!"
There are two implemented detection methods: `Serverside` (the one by default) & `Clientside`.

`Clientside` gives better results that `Serverside` since it's directly checking if SCP-096's face is visible on the screen of the player
whereas the `Serverside` detection compares approximately direction angles of SCP-096 and the potential target.

Before choosing `Clientside`, **beware!**, this method can be exploited by cheaters in order to prevent them from triggerring SCP-096
and you (and I) can't do much against that (and Bots players WILL NOT trigger SCP-096).

*Pro Tip: When SCP-096 is near, look as low/high to the floor/ceiling as you can*

### "I can't hear the sounds!"
Be sure to have installed [Guthen SCP Content](https://steamcommunity.com/workshop/filedetails/?id=1673048305) on your client.

Otherwise, check the configured sounds paths in the configuration menu. 

### "Which PlayerModel should I use?"
You are not limited to a particular Player Model but if you want a good one, try [this](https://steamcommunity.com/sharedfiles/filedetails/?id=958509894) one. 

## Legal Terms
This addon is licensed under [Creative Commons Sharealike 3.0](https://creativecommons.org/licenses/by-sa/3.0/) and is based on [SCP-096](http://scp-wiki.wikidot.com/scp-096). The weapon's view model is not mine and is made by [Vinrax](https://steamcommunity.com/id/vinrax ).

If you create something derived from this, please credit me (you can also tell me about what you've done).

***Enjoy !***
