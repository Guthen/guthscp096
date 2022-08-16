-- Shared functions

function GuthSCP.isSCP096( ply )
	ply = ply or CLIENT and LocalPlayer() 
	return ply:Team() == GuthSCP.Config.vkxscp096.team or ply:HasWeapon( "vkx_scp_096" )
end

function GuthSCP.isSCP096Enraged( ply )
	return ply:GetNWBool( "VKX:Is096Enraged", false )
end