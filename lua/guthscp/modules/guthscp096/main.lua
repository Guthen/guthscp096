local MODULE = {
	name = "SCP-096",
	author = "Guthen",
	version = "2.3.0",
	description = [[Be SCP-096 and kill anyone who angered you while seeing your face, either by throwing doors or props at them or by dismembering them!]],
	icon = "icon16/status_offline.png",
	version_url = "https://raw.githubusercontent.com/Guthen/guthscp096/master/lua/guthscp/modules/guthscp096/main.lua",
	dependencies = {
		base = "2.5.0",
		guthscpkeycard = "optional:2.0.0",
	},
	requires = {
		["shared.lua"] = guthscp.REALMS.SHARED,
		["server.lua"] = guthscp.REALMS.SERVER,
		["client.lua"] = guthscp.REALMS.CLIENT,
	},
}

MODULE.DETECTION_METHODS = {
	SERVERSIDE = 0,
	CLIENTSIDE = 1,
}

MODULE.menu = {
	config = {
		form = {
			"General",
			{
				{
					type = "Number",
					name = "Screen Shake Scale",
					id = "shake_scale",
					desc = "Scale the screen shake intensity when SCP-096 is enraged. Set this to 0 to disable screen shakes",
					default = 1,
					decimals = 1,
				},
				{
					type = "Number",
					name = "Screen Shake Radius",
					id = "shake_radius",
					desc = "In game units, radius of the screen shake when SCP-096 is enraged. Players in the radius will be affected by the screen shakes",
					default = 500,
					decimals = 1,
				},
				{
					type = "Number",
					name = "Enrage Speed Scale",
					id = "enrage_speed_scale",
					desc = "Scale the run speed when SCP-096 is enraged",
					default = 2,
					decimals = 1,
				},
				{
					type = "Number",
					name = "Enrage Jump Scale",
					id = "enrage_jump_scale",
					desc = "Scale the jump power when SCP-096 is enraged",
					default = 1.5,
					decimals = 1,
				},
				{
					type = "Number",
					name = "Trigger Time",
					id = "trigger_time",
					desc = "Time taken during the trigger state to entering in the enrage state, should depends on the trigger sound",
					default = 30,
					min = 0,
				},
				{
					type = "Number",
					name = "Enrage Time",
					id = "enrage_time",
					desc = "Time taken during the enrage state to entering in the idle state, should depends on the enrage sound",
					default = 30,
					min = 0,
				},
				{
					type = "Number",
					name = "Keycard Level",
					id = "keycard_level",
					desc = "Compatibility with my keycard system. Set a keycard level to SCP-096's swep",
					default = 5,
					min = 0,
					max = function( self, numwang )
						if self:is_disabled() then return 0 end

						return guthscp.modules.guthscpkeycard.max_keycard_level
					end,
					is_disabled = function( self, numwang )
						return guthscp.modules.guthscpkeycard == nil
					end,
				},
				{
					type = "Bool",
					name = "Unrage on Time",
					id = "unrage_on_time",
					desc = "Should SCP-096 unrage with the time? Allow the use of 'Enrage Time' above. If unchecked, SCP-096 will only unrage when he killed all his targets. If checked, SCP-096 will unrage with time or when all his targets are killed",
					default = false,
				},
				{
					type = "Bool",
					name = "Immortal",
					id = "immortal",
					desc = "If checked, SCP-096 can't take damage",
					default = true,
				},
				{
					type = "Bool",
					name = "Trigger on Damaged",
					id = "trigger_on_damaged",
					desc = "If checked, SCP-096 can be triggered by other players if they damage him",
					default = false,
				},
				{
					type = "Bool",
					name = "Ignore SCPs",
					id = "ignore_scps",
					desc = "If checked, SCP-096 won't be triggered by 'SCP Teams' defined in the 'Base' config. The 'Ignore Teams' below won't trigger SCP-096 in both cases",
					default = true,
				},
				{
					type = "Teams",
					name = "Ignore Teams",
					id = "ignore_teams",
					desc = "All teams that can't trigger SCP-096.",
					default = {},
				},
			},
			"Weapon",
			{
				{
					type = "String",
					name = "Hold Type",
					id = "hold_type",
					desc = "Set the weapon's hold type, see the full list here: https://wiki.facepunch.com/gmod/Hold_Types. It can be used to fix 3rd person animations on some SCP-096 models",
					default = "normal",
				},
				{
					type = "String",
					name = "View Model",
					id = "view_model",
					desc = "Set the weapon's view model.",
					default = "models/weapons/v_arms_scp096.mdl",
				},
				{
					type = "Number",
					name = "Distance Unit",
					id = "distance_unit",
					desc = "Maximum distance where SCP-096 can attacks his targets. 1 meter ~= 40 unit",
					default = 3.5 * 40, --  3.5 meter
				},
				{
					type = "Number",
					name = "Attack Hull Size",
					id = "attack_hull_size",
					desc = "Size of tolerance for targeting in units. The higher the number, the easier it is to aim, but the less precise it is",
					default = 10,
				},
				{
					type = "Number",
					name = "Kill Cooldown",
					id = "kill_cooldown",
					desc = "Cooldown between attacks (left click)",
					default = 0.3,
					decimals = 2
				},
				{
					type = "Number",
					name = "Break Cooldown",
					id = "break_cooldown",
					desc = "Cooldown between entities breaks (left click)",
					default = 0.5,
					decimals = 2
				},
				{
					type = "Number",
					name = "Cover Cooldown",
					id = "cover_cooldown",
					desc = "Cooldown between head cover (right click)",
					default = 1.6,
					decimals = 2
				},
			},
			"Animations",
			{
				{
					type = "String",
					name = "Enrage Animation",
					id = "anim_enrage_name",
					desc = "Animation name to play when SCP-096 is triggered. It will only work on playermodels that support it. The value must starts with 'ACT_'.",
					default = "ACT_GMOD_GESTURE_TAUNT_ZOMBIE",
				},
			},
			"Trigger Detection",
			{
				{
					type = "Number",
					name = "Update Time",
					id = "detection_update_time",
					desc = "Set the Cooldown between each Trigger Detection Update, in seconds",
					default = 0.1,
					decimals = 2,
				},
				{
					type = "Enum",
					name = "Detection Method",
					id = "detection_method",
					desc = "Method used to trigger SCP-096 while looking at his face. 'Clientside' method lighten the calculations on the server in spite of the players and gives a better result than the 'Serverside' method, but it's exploitable by 'cheaters' (and you (and I) can't do so much about it), so they can just prevent themselves from triggering SCP-096, you are warned! Since it's clientside, it also doesn't work with Bots. 'Serverside' method is the secured (not exploitable) but unperfect option, it might trigger if you look a bit lower than his face.",
					enum = MODULE.DETECTION_METHODS,
					default = MODULE.DETECTION_METHODS.SERVERSIDE,
				},
				{
					type = "String",
					name = "Head Bone Name",
					id = "detection_head_bone",
					desc = "The Head Bone's Name to use for detecting obstacles between the potential target & SCP-096",
					default = "ValveBiped.Bip01_Head1",
				},
				{
					type = "Number",
					name = "Detection Angle",
					id = "detection_angle",
					desc = "Detection Method must be set to 'Serverside'! Cosine of the victim's field of view angle used to trigger SCP-096. Increasing this value will make the detection threshold smaller and vice-versa. By default, set to 0.55 which is equivalent to an angle of 56°.",
					default = 0.55,
					decimals = 4,
					min = -1,
					max = 1
				},
			},
			"Attraction",
			{
				{
					type = "Bool",
					name = "Attraction Enabled",
					id = "attraction_enabled",
					desc = "Detection Method must be set to 'Clientside'! If checked, non-SCPs players will be attracted to look at SCP-096's face when they are near enough",
					default = true,
				},
				{
					type = "Number",
					name = "Attraction Speed",
					id = "attraction_speed",
					desc = "Scale the speed of the attraction",
					default = 0.5,
					decimals = 2,
				},
				{
					type = "Number",
					name = "Attraction Distance",
					id = "attraction_dist",
					desc = "Maximum distance where SCP-096's attraction take effect. 1 meter ~= 40 unit",
					default = 8 * 40, -- 8 meters
				},
			},
			"Sounds",
			{
				{
					type = "Number",
					name = "Hear Distance",
					id = "sound_hear_distance",
					desc = "Maximum distance where you can hear SCP-096's sounds",
					default = 2048,
				},
				{
					type = "Bool",
					name = "Stop Trigger Sound",
					id = "sound_stop_trigger_sound",
					desc = "Should we force stop the trigger sound when the trigger timer has finished?",
					default = false,
				},
				{
					type = "String",
					name = "Idle",
					id = "sound_idle",
					desc = "Looped-sound played in idle state",
					default = "guthen_scp/096/idle.ogg",
				},
				{
					type = "String",
					name = "Enrage",
					id = "sound_enrage",
					desc = "Looped-sound played in enrage state",
					default = "guthen_scp/096/scream.ogg",
				},
				{
					type = "String",
					name = "Trigger",
					id = "sound_trigger",
					desc = "Sound played in trigger state",
					default = "guthen_scp/096/angered.ogg",
				},
				{
					type = "String",
					name = "Looked",
					id = "sound_looked",
					desc = "Sound played on the player who looked at SCP-096",
					default = "guthen_scp/096/triggered.ogg",
				},
				{
					type = "String[]",
					name = "Footstep",
					id = "sounds_footstep",
					desc = "Sounds randomly played when SCP-096 move. Remove all elements to disable the custom footstep sounds",
					default = {
						"guthen_scp/scp/stepscp1.ogg",
						"guthen_scp/scp/stepscp2.ogg",
						"guthen_scp/scp/stepscp3.ogg",
						"guthen_scp/scp/stepscp4.ogg",
					},
				},
			},
		},
	},
	details = {
		{
			text = "CC-BY-SA",
			icon = "icon16/page_white_key.png",
		},
		"Wiki",
		{
			text = "Read Me",
			icon = "icon16/information.png",
			url = "https://github.com/Guthen/guthscp096/blob/master/README.md",
		},
		"Modules",
		{
			text = "Certurix's SCP-096 Bag",
			icon = "icon16/brick_link.png",
			url = "https://github.com/Certurix/ctx096bag",
		},
		"Social",
		{
			text = "Github",
			icon = "guthscp/icons/github.png",
			url = "https://github.com/Guthen/guthscp096",
		},
		{
			text = "Steam",
			icon = "guthscp/icons/steam.png",
			url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3034739264"
		},
		{
			text = "Discord",
			icon = "guthscp/icons/discord.png",
			url = "https://discord.gg/Yh5TWvPwhx",
		},
		{
			text = "Ko-fi",
			icon = "guthscp/icons/kofi.png",
			url = "https://ko-fi.com/vyrkx",
		},
	},
}

function MODULE:init()
	--  porting old config file 
	self:port_old_config_file( "guthscpbase/vkxscp096.json" )

	--  warn for old version
	timer.Simple( 0, function()
		if weapons.GetStored( "vkx_scp_096" ) then
			local text = "The old version of this addon is currently running on this server. Please, delete the '[SCP] Enhanced SCP-096' addon to avoid any possible conflicts."
			self:add_error( text )
			self:error( text )
		end
	end )
end

guthscp.module.hot_reload( "guthscp096" )
return MODULE
