local guthscp096 = guthscp.modules.guthscp096

--  scps filter
guthscp096.filter = guthscp.players_filter:new( "guthscp096" )
if SERVER then
	guthscp096.filter:listen_disconnect()
	guthscp096.filter:listen_weapon_users( "guthscp_096" )  --  being SCP-096 just mean a player having the weapon 

	--  reset on removed
	guthscp096.filter.event_removed:add_listener( "guthscp096:reset", function( ply )
		guthscp096.unrage_scp_096( ply, true )
		guthscp096.stop_scp_096_sounds( ply )
	end )
end

function guthscp096.get_scps_096()
	return guthscp096.filter:get_entities()
end

--  functions
function guthscp096.is_scp_096( ply )
	if CLIENT and ply == nil then
		ply = LocalPlayer() 
	end

	return guthscp096.filter:is_in( ply )
end

function guthscp096.is_scp_096_enraged( ply )
	return ply:GetNWBool( "VKX:Is096Enraged", false )
end
