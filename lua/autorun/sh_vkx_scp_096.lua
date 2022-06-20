if not GuthSCP or not GuthSCP.Config then
	error( "[VKX SCP 096] '[SCP] Guthen's Addons Base' (https://steamcommunity.com/sharedfiles/filedetails/?id=2139692777) is not installed on the server, the addon won't work as intended, please install the base addon." )
	return
end

GuthSCP.DETECTION_METHODS = {
	SERVERSIDE = 0,
	CLIENTSIDE = 1,
}
GuthSCP.NET_SCPS_LIST_BITS = 5  --  allows 31 differents players in the list (which hopefully won't happen :x)

--  functions
function GuthSCP.isSCP096( ply )
	ply = ply or CLIENT and LocalPlayer() 
	return ply:Team() == GuthSCP.Config.vkxscp096.team or ply:HasWeapon( "vkx_scp_096" )
end

function GuthSCP.isSCP096Enraged( ply )
	return ply:GetNWBool( "VKX:Is096Enraged", false )
end

--  config
hook.Add( "guthscpbase:config", "vkxscp096", function()

	GuthSCP.addConfig( "vkxscp096", {
		label = "SCP-096",
		icon = "icon16/user_red.png",
		elements = {
			{
				type = "Form",
				name = "Configuration",
				elements = {
					--  general
					{
						type = "Category",
						name = "General",
					},
					GuthSCP.createTeamConfigElement( {
						name = "SCP-096 Team",
						id = "team",
						default = "TEAM_SCP096",
					} ),
					{
						type = "NumWang",
						name = "Screen Shake Scale",
						id = "shake_scale",
						desc = "Scale the screen shake intensity when SCP-096 is enraged. Set this to 0 to disable screen shakes",
						default = 1,
						decimals = 1,
					},
					{
						type = "NumWang",
						name = "Screen Shake Radius",
						id = "shake_radius",
						desc = "In game units, radius of the screen shake when SCP-096 is enraged. Players in the radius will be affected by the screen shakes",
						default = 500,
						decimals = 1,
					},
					{
						type = "NumWang",
						name = "Enrage Speed Scale",
						id = "enrage_speed_scale",
						desc = "Scale the run speed when SCP-096 is enraged",
						default = 2,
						decimals = 1,
					},
					{
						type = "NumWang",
						name = "Enrage Jump Scale",
						id = "enrage_jump_scale",
						desc = "Scale the jump power when SCP-096 is enraged",
						default = 1.5,
						decimals = 1,
					},
					{
						type = "NumWang",
						name = "Trigger Time",
						id = "trigger_time",
						desc = "Time taken during the trigger state to entering in the enrage state, should depends on the trigger sound",
						default = 30,
						min = 0,
					},
					{
						type = "NumWang",
						name = "Enrage Time",
						id = "enrage_time",
						desc = "Time taken during the enrage state to entering in the idle state, should depends on the enrage sound",
						default = 30,
						min = 0,
					},
					GuthSCP.maxKeycardLevel and {
						type = "NumWang",
						name = "Keycard Level",
						id = "keycard_level",
						desc = "Compatibility with my keycard system. Set a keycard level to SCP-096's swep",
						default = 5,
						min = 0,
						max = GuthSCP.maxKeycardLevel,
					},
					{
						type = "CheckBox",
						name = "Unrage on Time",
						id = "unrage_on_time",
						desc = "Should SCP-096 unrage with the time? Allow the use of 'Enrage Time' above. If unchecked, SCP-096 will only unrage when he killed all his targets. If checked, SCP-096 will unrage with time or when all his targets are killed",
						default = false,
					},
					{
						type = "CheckBox",
						name = "Immortal",
						id = "immortal",
						desc = "If checked, SCP-096 can't take damage",
						default = true,
					},
					{
						type = "CheckBox",
						name = "Ignore SCPs",
						id = "ignore_scps",
						desc = "If checked, SCP-096 won't be triggered by 'SCP Teams' defined in 'guthscpbase' config and by the 'Ignore Teams' below. If unchecked, only the 'Ignore Teams' below won't trigger SCP-096",
						default = true,
					},
					GuthSCP.createTeamsConfigElement( {
						name = "Ignore Teams",
						id = "ignore_teams",
						desc = "All teams that can't trigger SCP-096.",
						default = {},
					} ),
					--  detection
					{
						type = "Category",
						name = "Trigger Detection",
					},
					{
						type = "NumWang",
						name = "Update Time",
						id = "detection_update_time",
						desc = "Set the Cooldown between each Trigger Detection Update, in seconds",
						default = .1,
						decimals = 2,
					},
					GuthSCP.createEnumElement( GuthSCP.DETECTION_METHODS, {
						name = "Detection Method",
						id = "detection_method",
						desc = [[Method used to trigger SCP-096 while looking at his face.
						'Clientside' method lighten the calculations on the server in spite of the players and gives a better result than the 'Serverside' method, but it's exploitable by 'cheaters' (and you (and I) can't do so much about it), so they can just prevent themselves from triggering SCP-096, you are warned! Since it's clientside, it also doesn't work with Bots. 
						'Serverside' method is the secured (not exploitable) but unperfect option, it might trigger if you look a bit lower than his face.]],
						default = "Serverside",
					} ),
					{
						type = "TextEntry",
						name = "Head Bone Name",
						id = "detection_head_bone",
						desc = "The Head Bone's Name to use for detecting obstacles between the potential target & SCP-096",
						default = "ValveBiped.Bip01_Head1",
					},
					--  attraction
					{
						type = "Category",
						name = "Attraction",
					},
					{
						type = "CheckBox",
						name = "Attraction Enabled",
						id = "attraction_enabled",
						desc = "Detection Method must be set to 'Clientside'! If checked, non-SCPs players will be attracted to look at SCP-096's face when they are near enough",
						default = true,
					},
					{
						type = "NumWang",
						name = "Attraction Speed",
						id = "attraction_speed",
						desc = "Scale the speed of the attraction",
						default = .5,
                        decimals = 2,
					},
					{
						type = "NumWang",
						name = "Attraction Distance",
						id = "attraction_dist",
                        desc = "Maximum distance where SCP-096's attraction take effect. 1 meter ~= 40 unit",
						default = 8 * 40, -- 8 meters
					},
					--  sounds
					{
						type = "Category",
						name = "Sounds",
					},
					{
						type = "NumWang",
						name = "Hear Distance",
						id = "sound_hear_distance",
						desc = "Maximum distance where you can hear SCP-096's sounds",
						default = 2048,
					},
					{
						type = "CheckBox",
						name = "Stop Trigger Sound",
						id = "sound_stop_trigger_sound",
						desc = "Should we force stop the trigger sound when the trigger timer has finished?",
						default = false,
					},
					{
						type = "TextEntry",
						name = "Idle",
						id = "sound_idle",
						desc = "Looped-sound played in idle state",
						default = "guthen_scp/096/idle.ogg",
					},
					{
						type = "TextEntry",
						name = "Enrage",
						id = "sound_enrage",
						desc = "Looped-sound played in enrage state",
						default = "guthen_scp/096/scream.ogg",
					},
					{
						type = "TextEntry",
						name = "Trigger",
						id ="sound_trigger",
						desc = "Sound played in trigger state",
						default = "guthen_scp/096/angered.ogg",
					},
					{
						type = "TextEntry",
						name = "Looked",
						id = "sound_looked",
						desc = "Sound played on the player who looked at SCP-096",
						default = "guthen_scp/096/triggered.ogg",
					},
					{
						type = "TextEntry[]",
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
					{
						type = "Button",
						name = "Apply",
						action = function( form, serialize_form )
							--PrintTable( serialize_form )
							GuthSCP.sendConfig( "vkxscp096", serialize_form )
						end,
					},
				},
			},
		},
		receive = function( form )
			form.ignore_teams = GuthSCP.receiveTeamsConfig( form.ignore_teams )

			GuthSCP.applyConfig( "vkxscp096", form, {
				network = true,
				save = true,
			} )
		end,
		parse = function( form )
			form.ignore_teams = GuthSCP.parseTeamsConfig( form.ignore_teams )
			form.team = GuthSCP.parseTeamConfig( form.team )

			if SERVER then
				timer.Adjust( "vkxscp096:trigger", form.detection_update_time )
			end
		end,
	} )

end )