if not GuthSCP or not GuthSCP.Config then
    error( "[VKX SCP 096] '[SCP] Guthen's Addons Base' (https://steamcommunity.com/sharedfiles/filedetails/?id=2139692777) is not installed on the server, the addon won't work as intended, please install the base addon." )
    return
end

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
                    GuthSCP.createTeamsConfigElement( {
                        type = "ComboBox",
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
            local teams = {}

            for i, id in ipairs( form.ignore_teams ) do
                teams[id] = true
            end

            form.ignore_teams = teams
            GuthSCP.applyConfig( "vkxscp096", form, {
                network = true,
                save = true,
            } )
        end,
        parse = function( form )
            local teams = {}

            for k, v in pairs( team.GetAllTeams() ) do
                if not v.Joinable then continue end
                if not form.ignore_teams[v.Name] and not form.ignore_teams[k] then continue end

                teams[k] = true
            end

            form.ignore_teams = teams
            if isstring( form.team ) then
                form.team = _G[form.team]
            end
        end,
    } )

end )