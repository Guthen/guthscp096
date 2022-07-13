if not GuthSCP or not GuthSCP.Config then
	return
end

util.AddNetworkString( "vkxscp096:refresh_list" )
util.AddNetworkString( "vkxscp096:target" )
util.AddNetworkString( "vkxscp096:trigger" )

--  enrage
local triggered_scps = {}
function GuthSCP.enrageSCP096( ply )
	if not GuthSCP.isSCP096( ply ) then return false end

	--  ensure to stop sounds
	GuthSCP.stopSCP096Sounds( ply )

	--  save default values
	if not triggered_scps[ply] then
		triggered_scps[ply] = {
			walk_speed = ply:GetWalkSpeed(),
			run_speed = ply:GetRunSpeed(),
			jump_power = ply:GetJumpPower(),
			looked_sound_cooldown = CurTime(),
			targets = {},
			targets_keys = {},
		}
	end

	--  setup
	ply:SetWalkSpeed( triggered_scps[ply].run_speed * GuthSCP.Config.vkxscp096.enrage_speed_scale )
	ply:SetRunSpeed( ply:GetWalkSpeed() )
	ply:SetJumpPower( triggered_scps[ply].jump_power * GuthSCP.Config.vkxscp096.enrage_jump_scale )

	ply:SetNWBool( "VKX:Is096Enraged", true )
	ply:SetNWInt( "VKX:096EnragedTime", CurTime() )
	ply:Freeze( true )
	if #GuthSCP.Config.vkxscp096.sound_trigger > 0 then
		GuthSCP.playSound( ply, GuthSCP.Config.vkxscp096.sound_trigger, GuthSCP.Config.vkxscp096.sound_hear_distance )
	end

	local weap = ply:GetWeapon( "vkx_scp_096" )
	if IsValid( weap ) then
		ply:SetActiveWeapon( weap )
		weap:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	end

	timer.Create( "VKX:Triggering096" .. ply:AccountID(), GuthSCP.Config.vkxscp096.trigger_time, 1, function()
		if not IsValid( ply ) or not GuthSCP.isSCP096( ply ) then return end
		ply:Freeze( false )

		--  stop trigger sound
		if GuthSCP.Config.vkxscp096.sound_stop_trigger_sound then
			GuthSCP.stopSound( ply, GuthSCP.Config.vkxscp096.sound_trigger )
		end
		
		--  play enrage sound
		GuthSCP.playSound( ply, GuthSCP.Config.vkxscp096.sound_enrage, GuthSCP.Config.vkxscp096.sound_hear_distance, true )

		--  unrage
		if GuthSCP.Config.vkxscp096.unrage_on_time then
			timer.Create( "VKX:Idling096" .. ply:AccountID(), GuthSCP.Config.vkxscp096.enrage_time, 1, function()
				if not IsValid( ply ) or not GuthSCP.isSCP096( ply ) then return end
				GuthSCP.unrageSCP096( ply )
			end )
		end
	end )

	GuthSCP.debugPrint( "VKX SCP 096", "%s has been enraged", ply:GetName() )
	return true
end


--  trigger
function GuthSCP.triggerSCP096( target, ply )
	if target == ply then return end
	if not GuthSCP.isSCP096( ply ) then return end
	if GuthSCP.isSCP096Target( target, ply ) then return end

	local should = hook.Run( "vkxscp096:should_trigger", target, ply )
	if should == false then return end

	GuthSCP.playClientSound( target, GuthSCP.Config.vkxscp096.sound_looked )
	if CurTime() - ( triggered_scps[ply] and triggered_scps[ply].looked_sound_cooldown or 1 ) > .5 then
		GuthSCP.playClientSound( ply, GuthSCP.Config.vkxscp096.sound_looked )
		if triggered_scps[ply] then
			triggered_scps[ply].looked_sound_cooldown = CurTime()
		end
	end

	GuthSCP.debugPrint( "VKX SCP 096", "%s triggered %s", target:GetName(), ply:GetName() )

	if not triggered_scps[ply] then
		GuthSCP.enrageSCP096( ply )
	end

	--  add target
	GuthSCP.addSCP096Target( target, ply )
end

--  sounds
function GuthSCP.stopSCP096Sounds( ply )
	GuthSCP.stopSound( ply, GuthSCP.Config.vkxscp096.sound_idle )
	GuthSCP.stopSound( ply, GuthSCP.Config.vkxscp096.sound_enrage ) 
	GuthSCP.stopSound( ply, GuthSCP.Config.vkxscp096.sound_trigger )
end

--  unrage
function GuthSCP.unrageSCP096( ply, no_sound )
	GuthSCP.stopSCP096Sounds( ply )

	--  timers
	timer.Remove( "VKX:Triggering096" .. ply:AccountID() )
	timer.Remove( "VKX:Idling096" .. ply:AccountID() )

	--  idle
	if not no_sound and ply:Alive() then
		timer.Simple( 0, function()
			GuthSCP.playSound( ply, GuthSCP.Config.vkxscp096.sound_idle, GuthSCP.Config.vkxscp096.sound_hear_distance, true )
		end )
	end

	--  select weapon
	local weap = ply:GetWeapon( "vkx_scp_096" )
	if IsValid( weap ) then 
		timer.Simple( .5, function()
			if not IsValid( weap ) then return end
			ply:SetActiveWeapon( weap )

			--  cover the head
			timer.Simple( .1, function()
				if not IsValid( weap ) then return end
				weap:SecondaryAttack()
			end )
		end )
	end

	--  unset values
	ply:Freeze( false )
	ply:SetNWBool( "VKX:Is096Enraged", false )
	ply:SetNWInt( "VKX:096EnragedTime", 0 )
	if triggered_scps[ply] then
		ply:SetWalkSpeed( triggered_scps[ply].walk_speed )
		ply:SetRunSpeed( triggered_scps[ply].run_speed )
		ply:SetJumpPower( triggered_scps[ply].jump_power )

		--  reset target state
		net.Start( "vkxscp096:trigger" )
			net.WriteEntity( ply )
			net.WriteBool( false )
		net.Send( triggered_scps[ply].targets_keys )

		--  reset SCP's targets
		net.Start( "vkxscp096:target" )
		net.Send( ply )
		
		triggered_scps[ply] = nil
	end

	GuthSCP.debugPrint( "VKX SCP 096", "%s has been unraged", ply:GetName() )
end

--  target
function GuthSCP.addSCP096Target( target, ply )
	triggered_scps[ply].targets[target] = true
	triggered_scps[ply].targets_keys = table.GetKeys( triggered_scps[ply].targets )

	--  add target to SCP's view
	net.Start( "vkxscp096:target" )
		net.WriteEntity( target )
		net.WriteBool( true )
	net.Send( ply )

	--  alert target from being targeted by the SCP
	net.Start( "vkxscp096:trigger" )
		net.WriteEntity( ply )
		net.WriteBool( true )
	net.Send( target )

	GuthSCP.debugPrint( "VKX SCP 096", "%s has been added to %s's targets. %d targets remaining.", target:GetName(), ply:GetName(), #triggered_scps[ply].targets_keys )
end

function GuthSCP.removeSCP096Target( target, ply )
	triggered_scps[ply].targets[target] = nil
	triggered_scps[ply].targets_keys = table.GetKeys( triggered_scps[ply].targets )

	--  remove target from SCP's view
	net.Start( "vkxscp096:target" )
		net.WriteEntity( target )
		net.WriteBool( false )
	net.Send( ply )

	--  alert target from being untargeted by the SCP
	net.Start( "vkxscp096:trigger" )
		net.WriteEntity( ply )
		net.WriteBool( false )
	net.Send( target )

	GuthSCP.debugPrint( "VKX SCP 096", "%s has been removed from %s's targets. %d targets remaining.", target:GetName(), ply:GetName(), #triggered_scps[ply].targets_keys )

	--  unrage 096 when there is no remaining target
	if #triggered_scps[ply].targets_keys == 0 then
		GuthSCP.unrageSCP096( ply )
	end
end

function GuthSCP.removeFromSCP096Targets( ply )
	for i, v in ipairs( GuthSCP.getSCP096s() ) do
		if GuthSCP.isSCP096Target( ply, v ) then
			GuthSCP.removeSCP096Target( ply, v )
		end
	end
end

function GuthSCP.isSCP096Target( target, ply )
	return triggered_scps[ply] and triggered_scps[ply].targets[target]
end

function GuthSCP.getSCP096Targets( ply )
	return triggered_scps[ply] and triggered_scps[ply].targets_keys
end

local scps_096 = {}
function GuthSCP.getSCP096s()
	return scps_096
end

--  refresh scps list if necessary
local function sync_scps_list( ply )
	net.Start( "vkxscp096:refresh_list" )
		net.WriteUInt( #scps_096, GuthSCP.NET_SCPS_LIST_BITS )
		for i, v in ipairs( scps_096 ) do
			net.WriteEntity( v )
		end
	if ply then
		net.Send( ply )
	else
		net.Broadcast()
	end
end

local function refresh_scps_list()
	scps_096 = {}

	for i, v in ipairs( player.GetAll() ) do
		if GuthSCP.isSCP096( v ) then
			scps_096[#scps_096 + 1] = v
		end
	end

	sync_scps_list()
	GuthSCP.debugPrint( "VKX SCP 096", "SCPs cache has been updated, %d instances found", #scps_096 )
end

hook.Add( "WeaponEquip", "vkxscp096:add_scp", function( weapon, ply )
	if not ( weapon:GetClass() == "vkx_scp_096" ) then return end

	--  is in list
	for i, v in ipairs( scps_096 ) do
		if v == ply then 
			return
		end
	end

	--  add in the list
	scps_096[#scps_096 + 1] = ply
	sync_scps_list()
	GuthSCP.debugPrint( "VKX SCP 096", "%s is a new SCP-096 instance", ply:GetName() )
end )

concommand.Add( "vkx_scp096_print_scps", function( ply )
	local text = ""

	if #scps_096 == 0 then
		text = "No SCP-096 instances found"
	else
		for i, v in ipairs( scps_096 ) do
			text = text .. ( "%d: %s\n" ):format( i, v:GetName() )
		end
	end
	
	if IsValid( ply ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, text )
	else
		print( text )
	end
end )

net.Receive( "vkxscp096:trigger", function( len, ply )
	if not ( GuthSCP.Config.vkxscp096.detection_method == GuthSCP.DETECTION_METHODS.CLIENTSIDE ) then return end

	local scp = net.ReadEntity()
	if not IsValid( scp ) or not GuthSCP.isSCP096( scp ) then return end

	GuthSCP.triggerSCP096( ply, scp )
end )

--  think
local red, green = Color( 255, 0, 0 ), Color( 0, 255, 0 )
timer.Create( "vkxscp096:trigger", .1, 0, function()
	if #scps_096 == 0 then return end

	--  remove invalid scps (e.g.: disconnected, team changed)
	for i, scp in ipairs( scps_096 ) do
		if not IsValid( scp ) or not GuthSCP.isSCP096( scp ) then
			refresh_scps_list()
			break
		end
	end

	--  trigger detection
	if GuthSCP.Config.vkxscp096.detection_method == GuthSCP.DETECTION_METHODS.SERVERSIDE then 
		for i, ply in ipairs( player.GetAll() ) do
			if not ply:Alive() or GuthSCP.isSCP096( ply ) then continue end
			if GuthSCP.Config.vkxscp096.ignore_scps and GuthSCP.isSCP( ply ) then continue end
			
			local ply_head_id = ply:LookupBone( GuthSCP.Config.vkxscp096.detection_head_bone )
			local ply_head_pos = ply_head_id and ply:GetBonePosition( ply_head_id ) or ply:EyePos()
	
			for i, scp in ipairs( scps_096 ) do
				if not scp:Alive() or GuthSCP.isSCP096Target( ply, scp ) then continue end
	
				local aim_dot = ply:GetAimVector():Dot( scp:GetAimVector() ) --  does ply and scp look at each other (avoid trigger when looking at his back)?
				if aim_dot >= 0 then continue end
	
				--  bones
				local scp_head_id = scp:LookupBone( GuthSCP.Config.vkxscp096.detection_head_bone )
				local scp_head_pos = scp_head_id and scp:GetBonePosition( scp_head_id ) or scp:EyePos()
	
				--  angles
				local ply_to_scp = ( scp_head_pos - ply_head_pos ):GetNormal()
				local view_dot = ply:GetAimVector():Dot( ply_to_scp ) --  does ply see scp?
				if view_dot > GuthSCP.Config.vkxscp096.detection_angle then
					--  check obstacles
					local scp_to_ply = ( ply_head_pos - scp_head_pos ):GetNormal()
					local tr = util.TraceLine( {
						start = scp_head_pos,
						endpos = scp_head_pos + scp_to_ply * 5000,
						filter = scp,
						mask = MASK_VISIBLE_AND_NPCS, --  avoid traversable objects such as fences & windows
					} )
	
					--debugoverlay.Text( tr.StartPos + Vector( 0, 0, 10 ), "in theoric view", .1 )
					--debugoverlay.Line( tr.StartPos, tr.HitPos, .1, tr.Entity == ply and green or red )
					if tr.Entity == ply then
						GuthSCP.triggerSCP096( ply, scp )
						--debugoverlay.Text( tr.StartPos + Vector( 0, 0, 20 ), "trigger!", .1 )
					--else
						--debugoverlay.Text( tr.StartPos + Vector( 0, 0, 20 ), "obstacle!", .1 )
					end
				--else
					--debugoverlay.Text( scp_head_pos + Vector( 0, 0, 20 ), "no trigger", .1 )
					--debugoverlay.Text( scp_head_pos + Vector( 0, 0, 10 ), "not in theoric view", .1 )
				end
	
				--debugoverlay.Text( scp_head_pos, "view dot: " .. tostring( math.Round( view_dot, 3 ) ) .. "> 0.55?", .1 )
				--debugoverlay.Text( scp_head_pos - Vector( 0, 0, 10 ), "aim dot: " .. tostring( math.Round( aim_dot, 3 ) ) .. "< 0?", .1 )
				--debugoverlay.Text( scp_head_pos - Vector( 0, 0, 20 ), "view angle: " .. tostring( math.Round( math.deg( math.acos( view_dot ) ) ), 3 ) .. "°", .1 )
			end
		end
	end
end )

--  unrage
hook.Add( "OnPlayerChangedTeam", "vkxscp096:reset", function( ply, old_team, new_team )
	if GuthSCP.isSCP096( ply ) then
		GuthSCP.unrageSCP096( ply, true )
	end
end )

hook.Add( "DoPlayerDeath", "vkxscp096:reset", function( ply, attacker, dmg_info )
	if GuthSCP.isSCP096( ply ) then 
		GuthSCP.unrageSCP096( ply, true )
	else
		GuthSCP.removeFromSCP096Targets( ply )
	end
end )

--  gMedic Compatibility (https://www.gmodstore.com/market/view/ultimate-gmedic)
if MedConfig then
	hook.Add( "OnEntityCreated", "vkxscp096:reset", function( ent )
		if not ( ent:GetClass() == "sent_death_ragdoll" ) then return end

		timer.Simple( 0, function()
			local ply = ent:GetOwner()
			if not IsValid( ply ) or not ply:IsPlayer() then return end
			
			GuthSCP.removeFromSCP096Targets( ply )
		end )
	end )
end

hook.Add( "PlayerShouldTakeDamage", "vkxscp096:invinsible", function( ply, attacker )
	if GuthSCP.isSCP096( ply ) and GuthSCP.Config.vkxscp096.immortal then
		return false
	end
end )

hook.Add( "PlayerDisconnected", "vkxscp096:disconnect", function( ply )
	for scp, v in pairs( triggered_scps ) do
		if v.targets[ply] then
			GuthSCP.removeSCP096Target( ply, scp )
		end
	end
end )

hook.Add( "PlayerFootstep", "vkxscp096:footstep", function( ply, pos, foot, sound, volume )
	if GuthSCP.isSCP096( ply ) then
		local sounds = GuthSCP.Config.vkxscp096.sounds_footstep
		if #sounds == 0 then return end

		ply:EmitSound( sounds[math.random( #sounds )], nil, nil, volume )

		return true
	end
end )

hook.Add( "vkxscp096:should_trigger", "vkxscp096:ignore_teams", function( target, ply )
	if GuthSCP.Config.vkxscp096.ignore_teams[GuthSCP.getTeamKeyname( target:Team() )] then
		return false
	end
end )