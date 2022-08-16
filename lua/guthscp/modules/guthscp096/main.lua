local MODULE = {
	name = "SCP 096",
	author = "Guthen, Certurix",
	version = "2.0.0",
	description = "The must-have addon that allows you to see this interface (and surely more)!",
	icon = "icon16/eye.png",
	version_url = "https://raw.githubusercontent.com/Certurix/vkxscp096/remaster-as-modules-based/lua/guthscp/modules/guthscp096/main.lua",
	requires = {
		["shared/"] = guthscp.REALMS.SHARED,
		["server/"] = guthscp.REALMS.SERVER,
		["client/"] = guthscp.REALMS.CLIENT,
	},
}

--  config
MODULE.config = {
	form = {
		{
			type = "Category",
			name = "General",
		},
		guthscp.config.create_teams_element( {
			name = "SCP-096 Team",
			id = "team",
			desc = "SCP 096 Team(s)",
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
		guthscp.config.create_apply_button(),
	},
	receive = function( form )
		guthscp.config.apply( MODULE.id, form, {
			network = true,
			save = true,
		} )
	end,
}

--  TODO: remove if not used
function MODULE:construct()
end

function MODULE:init()
	print("SCP-096 Module has ben loaded!")
end

guthscp.module.hot_reload( "guthscp096" )
return MODULE