-- Shared functions
guthscp.DETECTION_METHODS = {
	SERVERSIDE = 0,
	CLIENTSIDE = 1,
}
guthscp.NET_SCPS_LIST_BITS = 5  --  allows 31 differents players in the list (which hopefully won't happen :x)
function guthscp.isSCP096( ply )
	ply = ply or CLIENT and LocalPlayer() 
	return ply:Team() == guthscp.configs.vkxscp096.team or ply:HasWeapon( "vkx_scp_096" )
end

function guthscp.isSCP096Enraged( ply )
	return ply:GetNWBool( "VKX:Is096Enraged", false )
end