local guthscp096 = guthscp.modules.guthscp096
local config = guthscp.configs.guthscp096

util.AddNetworkString( "guthscp096:target" )
util.AddNetworkString( "guthscp096:trigger" )

--  enrage
local triggered_scps = {}
function guthscp096.enrage_scp_096( ply )
	if not guthscp096.is_scp_096( ply ) then return false end

	--  ensure to stop sounds
	guthscp096.stop_scp_096_sounds( ply )

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
	ply:SetWalkSpeed( triggered_scps[ply].run_speed * config.enrage_speed_scale )
	ply:SetRunSpeed( ply:GetWalkSpeed() )
	ply:SetJumpPower( triggered_scps[ply].jump_power * config.enrage_jump_scale )

	ply:SetNWBool( "guthscp096:is_enraged", true )
	ply:SetNWInt( "guthscp096:enrage_time", CurTime() )
	ply:Freeze( true )

	if #config.sound_trigger > 0 then
		guthscp.sound.play( ply, config.sound_trigger, config.sound_hear_distance )
	end

	--	trigger enrage animation
	if config.anim_enrage_name:StartsWith( "ACT_" ) then
		ply:DoAnimationEvent( _G[config.anim_enrage_name] )
	end

	local weap = ply:GetWeapon( "guthscp_096" )
	if IsValid( weap ) then
		ply:SetActiveWeapon( weap )
		weap:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	end

	timer.Create( "guthscp096:triggering" .. ply:AccountID(), config.trigger_time, 1, function()
		if not IsValid( ply ) or not guthscp096.is_scp_096( ply ) then return end
		ply:Freeze( false )

		--  stop trigger sound
		if config.sound_stop_trigger_sound then
			guthscp.sound.stop( ply, config.sound_trigger )
		end

		--  play enrage sound
		guthscp.sound.play( ply, config.sound_enrage, config.sound_hear_distance, true )

		--  unrage
		if config.unrage_on_time then
			timer.Create( "guthscp096:idling" .. ply:AccountID(), config.enrage_time, 1, function()
				if not IsValid( ply ) or not guthscp096.is_scp_096( ply ) then return end
				guthscp096.unrage_scp_096( ply )
			end )
		end
	end )

	guthscp096:debug( "%s has been enraged", ply:GetName() )
	return true
end


--  trigger
function guthscp096.trigger_scp_096( target, ply )
	if target == ply then return end
	if not guthscp096.is_scp_096( ply ) then return end
	if guthscp096.is_scp_096_target( target, ply ) then return end

	local should = hook.Run( "guthscp096:should_trigger", target, ply )
	if should == false then return end

	guthscp.sound.play_client( target, config.sound_looked )
	if CurTime() - ( triggered_scps[ply] and triggered_scps[ply].looked_sound_cooldown or 1 ) > 0.5 then
		guthscp.sound.play_client( ply, config.sound_looked )
		if triggered_scps[ply] then
			triggered_scps[ply].looked_sound_cooldown = CurTime()
		end
	end

	guthscp096:debug( "%s triggered %s", target:GetName(), ply:GetName() )

	if not triggered_scps[ply] then
		guthscp096.enrage_scp_096( ply )
	end

	--  add target
	guthscp096.add_scp_096_target( target, ply )
end

--  sounds
function guthscp096.stop_scp_096_sounds( ply )
	guthscp.sound.stop( ply, config.sound_idle )
	guthscp.sound.stop( ply, config.sound_enrage )
	guthscp.sound.stop( ply, config.sound_trigger )
end

--  unrage
function guthscp096.unrage_scp_096( ply, no_sound )
	guthscp096.stop_scp_096_sounds( ply )

	--  timers
	timer.Remove( "guthscp096:triggering" .. ply:AccountID() )
	timer.Remove( "guthscp096:idling" .. ply:AccountID() )

	--  idle
	if not no_sound and ply:Alive() then
		timer.Simple( 0, function()
			guthscp.sound.play( ply, config.sound_idle, config.sound_hear_distance, true )
		end )
	end

	--  select weapon
	local weapon = ply:GetWeapon( "guthscp_096" )
	if IsValid( weapon ) then
		timer.Simple( 0.5, function()
			if not IsValid( weapon ) then return end
			ply:SetActiveWeapon( weapon )

			--  cover the head
			timer.Simple( 0.1, function()
				if not IsValid( weapon ) then return end
				weapon:SecondaryAttack()
			end )
		end )
	end

	--  unset values
	ply:Freeze( false )
	ply:SetNWBool( "guthscp096:is_enraged", false )
	ply:SetNWInt( "guthscp096:enrage_time", 0 )
	if triggered_scps[ply] then
		ply:SetWalkSpeed( triggered_scps[ply].walk_speed )
		ply:SetRunSpeed( triggered_scps[ply].run_speed )
		ply:SetJumpPower( triggered_scps[ply].jump_power )

		--  reset target state
		net.Start( "guthscp096:trigger" )
			net.WriteEntity( ply )
			net.WriteBool( false )
		net.Send( triggered_scps[ply].targets_keys )

		--  reset SCP's targets
		net.Start( "guthscp096:target" )
		net.Send( ply )

		triggered_scps[ply] = nil
	end

	guthscp096:debug( "%s has been unraged", ply:GetName() )
end

--  target
function guthscp096.add_scp_096_target( target, ply )
	triggered_scps[ply].targets[target] = true
	triggered_scps[ply].targets_keys = table.GetKeys( triggered_scps[ply].targets )

	--  add target to SCP's view
	net.Start( "guthscp096:target" )
		net.WriteEntity( target )
		net.WriteBool( true )
	net.Send( ply )

	--  alert target from being targeted by the SCP
	net.Start( "guthscp096:trigger" )
		net.WriteEntity( ply )
		net.WriteBool( true )
	net.Send( target )

	guthscp096:debug( "%s has been added to %s's targets. %d targets remaining.", target:GetName(), ply:GetName(), #triggered_scps[ply].targets_keys )
end

function guthscp096.remove_scp_096_target( target, ply )
	triggered_scps[ply].targets[target] = nil
	triggered_scps[ply].targets_keys = table.GetKeys( triggered_scps[ply].targets )

	--  remove target from SCP's view
	net.Start( "guthscp096:target" )
		net.WriteEntity( target )
		net.WriteBool( false )
	net.Send( ply )

	--  alert target from being untargeted by the SCP
	net.Start( "guthscp096:trigger" )
		net.WriteEntity( ply )
		net.WriteBool( false )
	net.Send( target )

	guthscp096:debug( "%s has been removed from %s's targets. %d targets remaining.", target:GetName(), ply:GetName(), #triggered_scps[ply].targets_keys )

	--  unrage 096 when there is no remaining target
	if #triggered_scps[ply].targets_keys == 0 then
		guthscp096.unrage_scp_096( ply )
	end
end

function guthscp096.remove_from_scp_096_targets( ply )
	for i, v in ipairs( guthscp096.get_scps_096() ) do
		if guthscp096.is_scp_096_target( ply, v ) then
			guthscp096.remove_scp_096_target( ply, v )
		end
	end
end

function guthscp096.is_scp_096_target( target, ply )
	return triggered_scps[ply] and triggered_scps[ply].targets[target]
end

function guthscp096.get_scp_096_targets( ply )
	return triggered_scps[ply] and triggered_scps[ply].targets_keys
end

concommand.Add( "guthscp_096_print_scps", function( ply )
	local text = ""

	local scps_096 = guthscp096.get_scps_096()
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

net.Receive( "guthscp096:trigger", function( len, ply )
	if config.detection_method ~= guthscp096.DETECTION_METHODS.CLIENTSIDE then return end

	local scp = net.ReadEntity()
	if not IsValid( scp ) or not guthscp096.is_scp_096( scp ) then return end

	--  check PVS
	if not ply:TestPVS( scp ) then return end

	guthscp096.trigger_scp_096( ply, scp )
end )

--  think
timer.Create( "guthscp096:trigger", 0.1, 0, function()
	if guthscp096.filter:get_count() == 0 then return end
	if config.detection_method ~= guthscp096.DETECTION_METHODS.SERVERSIDE then return end

	--  trigger detection
	local scps_096 = guthscp096.get_scps_096()

	for _, ply in ipairs( player.GetAll() ) do
		if not ply:Alive() or guthscp096.is_scp_096( ply ) then continue end
		if config.ignore_scps and guthscp.is_scp( ply ) then continue end

		local ply_head_id = ply:LookupBone( config.detection_head_bone )
		local ply_head_pos = ply_head_id and ply:GetBonePosition( ply_head_id ) or ply:EyePos()

		for _, scp in ipairs( scps_096 ) do
			if not scp:Alive() or guthscp096.is_scp_096_target( ply, scp ) then continue end

			local aim_dot = ply:GetAimVector():Dot( scp:GetAimVector() ) --  does ply and scp look at each other (avoid trigger when looking at his back)?
			if aim_dot >= 0 then continue end

			--  bones
			local scp_head_id = scp:LookupBone( config.detection_head_bone )
			local scp_head_pos = scp_head_id and scp:GetBonePosition( scp_head_id ) or scp:EyePos()

			--  angles
			local ply_to_scp = ( scp_head_pos - ply_head_pos ):GetNormal()
			local view_dot = ply:GetAimVector():Dot( ply_to_scp ) --  does ply see scp?
			if view_dot > config.detection_angle then
				--  check obstacles
				local scp_to_ply = ( ply_head_pos - scp_head_pos ):GetNormal()
				local tr = util.TraceLine( {
					start = scp_head_pos,
					endpos = scp_head_pos + scp_to_ply * 5000,
					filter = scp,
					mask = MASK_VISIBLE_AND_NPCS, --  avoid traversable objects such as fences & windows
				} )

				--debugoverlay.Text( tr.StartPos + Vector( 0, 0, 10 ), "in theoric view", 0.1 )
				--debugoverlay.Line( tr.StartPos, tr.HitPos, 0.1, tr.Entity == ply and Color( 0, 255, 0 ) or Color( 255, 0, 0 ) )
				if tr.Entity == ply then
					guthscp096.trigger_scp_096( ply, scp )
					--debugoverlay.Text( tr.StartPos + Vector( 0, 0, 20 ), "trigger!", 0.1 )
				--else
					--debugoverlay.Text( tr.StartPos + Vector( 0, 0, 20 ), "obstacle!", 0.1 )
				end
			--else
				--debugoverlay.Text( scp_head_pos + Vector( 0, 0, 20 ), "no trigger", 0.1 )
				--debugoverlay.Text( scp_head_pos + Vector( 0, 0, 10 ), "not in theoric view", 0.1 )
			end

			--debugoverlay.Text( scp_head_pos, "view dot: " .. tostring( math.Round( view_dot, 3 ) ) .. "> 0.55?", 0.1 )
			--debugoverlay.Text( scp_head_pos - Vector( 0, 0, 10 ), "aim dot: " .. tostring( math.Round( aim_dot, 3 ) ) .. "< 0?", 0.1 )
			--debugoverlay.Text( scp_head_pos - Vector( 0, 0, 20 ), "view angle: " .. tostring( math.Round( math.deg( math.acos( view_dot ) ) ), 3 ) .. "°", 0.1 )
		end
	end
end )

--  unrage
hook.Add( "OnPlayerChangedTeam", "guthscp096:reset", function( ply, old_team, new_team )
	if guthscp096.is_scp_096( ply ) then
		guthscp096.unrage_scp_096( ply, true )
	end
end )

hook.Add( "DoPlayerDeath", "guthscp096:reset", function( ply, attacker, dmg_info )
	if guthscp096.is_scp_096( ply ) then
		guthscp096.unrage_scp_096( ply, true )
	else
		guthscp096.remove_from_scp_096_targets( ply )
	end
end )

--  gMedic Compatibility (https://www.gmodstore.com/market/view/ultimate-gmedic)
if MedConfig then
	hook.Add( "OnEntityCreated", "guthscp096:reset", function( ent )
		if ent:GetClass() ~= "sent_death_ragdoll" then return end

		timer.Simple( 0, function()
			local ply = ent:GetOwner()
			if not IsValid( ply ) or not ply:IsPlayer() then return end

			guthscp096.remove_from_scp_096_targets( ply )
		end )
	end )
end

hook.Add( "PlayerShouldTakeDamage", "guthscp096:invinsible", function( ply, attacker )
	if guthscp096.is_scp_096( ply ) and config.immortal then
		return false
	end
end )

hook.Add( "PostEntityTakeDamage", "test", function( target, dmg, is_took )
	if not config.trigger_on_damaged then return end

	--  check target
	if not target:IsPlayer() or not guthscp096.is_scp_096( target ) then return end

	--  check attacker
	local attacker = dmg:GetAttacker()
	if not IsValid( attacker ) or not attacker:IsPlayer() then return end
	if config.ignore_scps and guthscp.is_scp( attacker ) then return end

	--  trigger
	guthscp096.trigger_scp_096( attacker, target )
end )

hook.Add( "PlayerDisconnected", "guthscp096:disconnect", function( ply )
	for scp, v in pairs( triggered_scps ) do
		if v.targets[ply] then
			guthscp096.remove_scp_096_target( ply, scp )
		end
	end
end )

hook.Add( "PlayerFootstep", "guthscp096:footstep", function( ply, pos, foot, sound, volume )
	if guthscp096.is_scp_096( ply ) then
		local sounds = config.sounds_footstep
		if #sounds == 0 then return end

		ply:EmitSound( sounds[math.random( #sounds )], nil, nil, volume )

		return true
	end
end )

hook.Add( "guthscp096:should_trigger", "guthscp096:ignore_teams", function( target, ply )
	if config.ignore_teams[guthscp.get_team_keyname( target:Team() )] then
		return false
	end
end )