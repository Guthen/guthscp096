local MODULE = guthscp.modules.guthscp096

MODULE.NET_SCPS_LIST_BITS = 5  --  allows 31 differents players in the list (which hopefully won't happen :x)

--  functions
function MODULE.is_scp_096( ply )
	ply = ply or CLIENT and LocalPlayer() 
	return ply:HasWeapon( "vkx_scp_096" )
end

function MODULE.is_scp_096_enraged( ply )
	return ply:GetNWBool( "VKX:Is096Enraged", false )
end