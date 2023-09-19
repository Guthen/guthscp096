# [GuthSCP] SCP-096
Watch the [Trailer Video](https://youtu.be/5fAdBu-0r0A)!

## Steam Workshop
![Steam Views](https://img.shields.io/steam/views/3034739264?color=red&style=for-the-badge)
![Steam Downloads](https://img.shields.io/steam/downloads/3034739264?color=red&style=for-the-badge)
![Steam Favorites](https://img.shields.io/steam/favorites/3034739264?color=red&style=for-the-badge)

This addon is available on the Workshop [here](https://steamcommunity.com/sharedfiles/filedetails/?id=3034739264)!

## Features
Contains a SWEP, of class `guthscp_096`, designed for multiplayer:
+ **Left Mouse Button**: while enraged, **kill your targets** or **break the looking entity**
+ **Right Mouse Button** to cover your hands on your face ─ unfortunately, it's not visible for other players
+ **Enrages** when a non-SCP player has SCP-096's face on his "screen" ([possible incorrect results](#known-issues))
+ **Calms down** when all his targets are killed ─ or, if you enabled `Unrage on Time` option, when the enrage time runs out
+ Can **break doors and props** with a single left click while enraged
+ Configurable in-game with [[GuthSCP] Base](https://steamcommunity.com/sharedfiles/filedetails/?id=3034737316) (`guthscp_menu` in your console)
    + **Weapon** aim and cooldowns
    + **Sound** paths & hear distance
    + **Movement Speed** bonus while enraged
    + **Screen Shake** while near of an enraged SCP-096
    + (optional) [[GuthSCP] Keycard](https://steamcommunity.com/sharedfiles/filedetails/?id=3034740776) custom access
    + *and more..*
+ (fun) Allow multiple SCP-096 instances
+ **Not gamemode dependent**
+ **Custom compatibility with:**
    + [Ultimate gMedic](https://www.gmodstore.com/market/view/ultimate-gmedic)
    + [[GuthSCP] Keycard](https://steamcommunity.com/sharedfiles/filedetails/?id=3034740776)

## Convars
+ `guthscp_096_render_targets_halo <0 or 1>` (client): Render a halo on the SCP-096 targets, more expensive than a line
+ `guthscp_096_render_targets_line <0 or 1>` (client): Render a line between you and the SCP-096 targets 
+ `guthscp_096_render_post_process <0 or 1>` (client): Render post process effects as SCP-096, really expensive on performance but damn cool
+ `guthscp_096_render_path_finding <0 or 1>` (client): Render path toward targets as SCP-096. It's a rudimentary method, it's not 100% relatable.

## Extra Add-ons
+ [[GuthSCP] SCP-096 Bag System (ctx096bag)](https://steamcommunity.com/sharedfiles/filedetails/?id=3035662778)
+ [Project SCRAMBLE | Arctic Version](https://steamcommunity.com/sharedfiles/filedetails/?id=2988971057)
+ [Project SCRAMBLE | MW Version](https://steamcommunity.com/sharedfiles/filedetails/?id=2995171251)

## Known Issues
### "The addon doesn't work!"
Ensure that you have installed [[GuthSCP] Base](https://steamcommunity.com/sharedfiles/filedetails/?id=3034737316) on your server. Verify that you can open the configuration menu with `guthscp_menu` in your game console.

### "I enrage SCP-096 even though I didn't looked at him!"
There are two implemented detection methods: `Serverside` (by default) and `Clientside`.

`Clientside` gives better results that `Serverside` since it's directly checking if SCP-096's face is visible on the screen of the player whereas the `Serverside` detection approximately compares looking angles of SCP-096 and the potential target, taking in account its FOV.

Before choosing `Clientside`, **beware!**, this method can be exploited by cheaters in order to prevent them from triggerring SCP-096
and you (and I) can't do much against that. Plus, Bots players **WILL NOT** trigger SCP-096.

*Pro Tip: When SCP-096 is near, look as low/high to the floor/ceiling as you can*

### "I can't hear the sounds!"
Ensure that you have installed [Guthen SCP Content](https://steamcommunity.com/workshop/filedetails/?id=1673048305) on your client.

Otherwise, check the configured sounds paths in the configuration menu. 

### "The target halos are not drawing!"
First, be sure that you have set the console variable `guthscp_096_render_targets_halo` to `1`.

If the halos are fading out after some time, it's may be caused by an other addon drawing post-processing effects, especially those using the `DrawMotionBlur` function. [SethHUD](https://www.gmodstore.com/market/view/seth-hud) can do this if you have `SethHUD.CustomerConfig.HealthEffects` set to `true`, just disable it or remove the line of code with the `DrawMotionBlur` function call.

### "Which PlayerModel should I use?"
You are not limited to a particular Player Model but if you want a good one, try [this](https://steamcommunity.com/sharedfiles/filedetails/?id=958509894) one. 

## Legal Terms
This addon is licensed under [Creative Commons Sharealike 3.0](https://creativecommons.org/licenses/by-sa/3.0/) and is based on [SCP-096](http://scp-wiki.wikidot.com/scp-096). The weapon's view model is not mine and is made by [Vinrax](https://steamcommunity.com/id/vinrax ).

If you create something derived from this, please credit me (you can also tell me about what you've done).

***Enjoy !***
