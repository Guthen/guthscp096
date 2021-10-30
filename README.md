# [SCP] Enhanced SCP-096

Watch the [Trailer Video](https://youtu.be/5fAdBu-0r0A)!

## Features
+ **System**: 
    + **Enrages** when a non-SCP player have SCP-096 face on his "screen" ([possible incorrect results](#known-issues))
    + **Unrages** when all his targets are killed ─ or, if you enabled `Unrage on Time` option, when the enrage time runs out
    + Configurable **Sound** paths & hear distance
    + Configurable **Movement Speed** bonus while enraged
    + Configurable **Screen Shake** while near of an enraged SCP-096
    + *(fun) Allow multiple SCP-096 instances*
+ **SWEP**:
    + **Class**: `vkx_scp_096`
    + **Left Mouse Button**: while enraged, **kill your targets** or **break the looked entity**
    + **Right Mouse Button** to cover your hands on your face ─ unfortunately, it's not visible for other players
    + (optional & configurable) [Keycard System](https://steamcommunity.com/sharedfiles/filedetails/?id=1781514401) custom access
+ Configurable in-game with [[SCP] Guthen's Addons Base](https://steamcommunity.com/sharedfiles/filedetails/?id=2139692777) (`guthscpbase` in your console)
+ Can **break doors and props** with a single left click while enraged
+ **Compatible every gamemodes**

## Convars
+ `vkx_scp096_render_path_finding <0 or 1>`: Render path toward targets as SCP-096. It's a rudimentary method, it's not 100% relatable.
+ `vkx_scp096_render_post_process <0 or 1>`: Render post process effects as SCP-096
+ `vkx_scp096_render_targets_halo <0 or 1>`: Render a halo on the SCP-096 targets, more expensive than a line
+ `vkx_scp096_render_targets_line <0 or 1>`: Render a line between you and the SCP-096 targets 

## Known Issues
### "I enrage SCP-096 even though I didn't looked at him"
The detection system is far from being perfect as you can tell. 

Other than that, the method used is choose to be secure, an other solution (= client check 096's head on his screen and send whenever or not he should enrage him to the server) might gives better (or even perfect) results but will open the doors to cheats (just by not sending the message to the server), so for the moment we have the secure and weak option.

*Pro Tip: When SCP-096 is near, look as low/high to the floor/ceiling as you can*

## Legal Terms
This addon is licensed under [Creative Commons Sharealike 3.0](https://creativecommons.org/licenses/by-sa/3.0/) and is based on [SCP-173](http://scp-wiki.wikidot.com/scp-173) by "Moto42".

If you create something derived from this, please credit me (you can also tell me about what you've done).

***Enjoy !***