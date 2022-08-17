local MODULE = guthscp.modules.vkxscp096

--  refresh SCPs-096
local scps_096 = {}
function MODULE.get_scps_096()
	return scps_096
end

net.Receive( "vkxscp096:refresh_list", function( len )
	scps_096 = {}

	--  get scps
	local count = net.ReadUInt( MODULE.NET_SCPS_LIST_BITS )
	for i = 1, count do
		scps_096[i] = net.ReadEntity()
	end
	MODULE:debug( "received %d SCPs", count )
end )

local function refresh_scps_list( is_unreliable )
	net.Start( "vkxscp096:refresh_list", is_unreliable )
	net.SendToServer()
	MODULE:debug( "requesting a refresh of the SCPs list %s", is_unreliable and "(unreliable)" or "" )
end

hook.Add( "InitPostEntity", "vkxscp096:refresh_list", refresh_scps_list )

--  receive SCPs who target me
local target_by_scps = {}
net.Receive( "vkxscp096:trigger", function( len )
	local scp = net.ReadEntity()
	if not IsValid( scp ) then return end

	target_by_scps[scp] = net.ReadBool() or nil
end )

local scr_w, scr_h = ScrW(), ScrH()
local attraction_eye_angles, attraction_force

local current_update_time = 0
hook.Add( "Think", "vkxscp096:trigger", function()
	if not guthscp.configs.vkxscp096 then return end --  wait for the config to be loaded
	
	local ply = LocalPlayer()
	
	--  homemade cooldown
	if guthscp.configs.vkxscp096.detection_method == MODULE.DETECTION_METHODS.CLIENTSIDE and not ( guthscp.configs.vkxscp096.ignore_scps and guthscp.is_scp( ply ) ) and not MODULE.is_scp_096( ply ) then
		local dt = FrameTime()
		current_update_time = current_update_time + dt
		if current_update_time >= guthscp.configs.vkxscp096.detection_update_time then
			current_update_time = current_update_time - guthscp.configs.vkxscp096.detection_update_time
			
			attraction_eye_angles = nil

			local is_unreliable = guthscp.configs.vkxscp096.detection_update_time < .1
	
			--  trigger detection
			local ply_head_id = ply:LookupBone( guthscp.configs.vkxscp096.detection_head_bone )
			local ply_head_pos = ply_head_id and ply:GetBonePosition( ply_head_id ) or ply:EyePos()
		
			for i, scp in ipairs( scps_096 ) do
				if not IsValid( scp ) or not MODULE.is_scp_096( scp ) then 
					refresh_scps_list( is_unreliable )
					continue
				end
				if scp == ply then continue end
				if target_by_scps[scp] then continue end
		
				--  get scp head pos
				local scp_head_id = scp:LookupBone( guthscp.configs.vkxscp096.detection_head_bone )
				local scp_head_pos = scp_head_id and scp:GetBonePosition( scp_head_id ) or scp:EyePos()
				local scp_to_ply = ( ply_head_pos - scp_head_pos ):GetNormal()
				
				local view_dot = scp:GetAimVector():Dot( scp_to_ply ) --  does ply is in scp field of view?
				if view_dot <= 0 then 
					--print( "don't look at each other" )
					continue 
				end
		
				--  look for obstacles to 096
				local tr = util.TraceLine( {
					start = scp_head_pos,
					endpos = scp_head_pos + scp_to_ply * 5000,
					filter = scp,
					mask = MASK_VISIBLE_AND_NPCS, --  avoid traversable objects such as fences & windows
				} )
				--debugoverlay.Cross( scp_head_pos, 1, .1 )
				--debugoverlay.Line( scp_head_pos, scp_head_pos + scp_to_ply * 5000, .1 )
				if not ( tr.Entity == ply ) then 
					--print( "hit something else")
					continue 
				end
		
				--  check if the head is on the screen
				local screen_pos = scp_head_pos:ToScreen()
				if screen_pos.visible and screen_pos.x > 0 and screen_pos.x < scr_w and screen_pos.y > 0 and screen_pos.y < scr_h then
					--print( "on screen" )
					net.Start( "vkxscp096:trigger", is_unreliable )
						net.WriteEntity( scp )
					net.SendToServer()
					MODULE:debug( "triggering %q.. %s", scp:GetName(), is_unreliable and "(unreliable)" or "" )
				else
					attraction_eye_angles = ( scp_head_pos - ply_head_pos ):Angle()
					attraction_force = 1 - math.min( 1, ply_head_pos:DistToSqr( scp_head_pos ) / ( guthscp.configs.vkxscp096.attraction_dist ^ 2 ) )
					--print( "not on screen" )
				end
			end
		end
	else
		attraction_eye_angles = nil
	end

	--  drag player view towards 096 face 
	if guthscp.configs.vkxscp096.attraction_enabled and attraction_eye_angles then 
		local angle = LerpAngle( FrameTime() * guthscp.configs.vkxscp096.attraction_speed * attraction_force, ply:EyeAngles(), attraction_eye_angles )
		angle.r = 0
		ply:SetEyeAngles( angle )
	end
end )


--  targets
local targets, targets_keys = {}, {}
net.Receive( "vkxscp096:target", function()
	local ply = net.ReadEntity()
	
	--  add target
	if IsValid( ply ) then
		targets[ply] = net.ReadBool() or nil
		ply.scp_096_path = { ply:GetPos() }

		targets_keys = table.GetKeys( targets )
	--  clear targets
	else
		for i, v in ipairs( targets_keys ) do v.scp_096_path = nil end
		targets, targets_keys = {}, {}
	end
end )

function MODULE.get_scp_096_targets()
	return targets_keys
end

--  render
local render_halo = CreateClientConVar( "vkx_scp096_render_targets_halo", "1", true, false, "Render a halo on the SCP-096 targets, more expensive than a line" )
local render_line = CreateClientConVar( "vkx_scp096_render_targets_line", "0", true, false, "Render a line between you and the SCP-096 targets" )
local render_pp = CreateClientConVar( "vkx_scp096_render_post_process", "1", true, false, "Render post process effects as SCP-096, really expensive on performance but damn cool" )
local render_pathfinding = CreateClientConVar( "vkx_scp096_render_path_finding", "0", true, false, "Render path toward targets as SCP-096. It's a rudimentary method, it's not 100% relatable." )

local indicator_color = Color( 220, 62, 62 )
hook.Add( "PreDrawHalos", "vkxscp096:target", function()
	if not render_halo:GetBool() then return end
	if not MODULE.is_scp_096() then return end

	halo.Add( targets_keys, indicator_color, 2, 2, 1, true, true )
end )

local new_point_interval = 5 --  every 5 seconds
local sphere_radius = 16
local sphere_radius_sqr = sphere_radius ^ 2
local last_path_time = CurTime()
hook.Add( "PostDrawTranslucentRenderables", "vkxscp096:target", function()
	if not render_line:GetBool() then return end
	if not MODULE.is_scp_096() then return end

	render.SetColorMaterial()
	local start_pos = LocalPlayer():GetPos()
	for i, v in ipairs( targets_keys ) do
		--  draw line between targets and you
		if not IsValid( v ) then
			targets[v] = nil
			targets_keys = table.GetKeys( targets )
			return
		end

		--  draw path
		if render_pathfinding:GetBool() then
			for i, point in ipairs( v.scp_096_path ) do
				if point:DistToSqr( start_pos ) <= sphere_radius_sqr then
					for j = i, 1, -1 do
						table.remove( v.scp_096_path, j )
					end
				end

				render.DrawSphere( point, sphere_radius, 30, 30, indicator_color )
				if v.scp_096_path[i - 1] then
					render.DrawLine( point, v.scp_096_path[i - 1], indicator_color )
				end
			end

			if #v.scp_096_path == 0 then
				render.DrawLine( start_pos, v:EyePos(), indicator_color )
			else
				render.DrawLine( v.scp_096_path[#v.scp_096_path], v:EyePos(), indicator_color )
			end

			--  new point
			if CurTime() - last_path_time > new_point_interval then
				last_path_time = CurTime()
				if #v.scp_096_path == 0 or v.scp_096_path[#v.scp_096_path]:DistToSqr( v:GetPos() ) > sphere_radius_sqr then
					v.scp_096_path[#v.scp_096_path + 1] = v:GetPos()
				end
			end
		else
			render.DrawLine( start_pos, v:EyePos(), indicator_color )
		end
	end
end )

local enrage_time, scale, factor, end_scale = 0, 0, 1.1, 0
hook.Add( "HUDPaint", "zzz_vkxscp096:rage", function()
	if not render_pp:GetBool() then return end
	if not MODULE.is_scp_096() then return end

	local ply = LocalPlayer()
	--  enraged
	if MODULE.is_scp_096_enraged( ply ) then
		enrage_time = enrage_time + FrameTime()
		factor = math.min( 1.1, enrage_time / guthscp.configs.vkxscp096.trigger_time )

		scale = Lerp( FrameTime() * 3, scale, 1 )
		end_scale = Lerp( FrameTime() * factor, end_scale, 1 ) * .25
	--  idle
	else
		enrage_time = 0
		factor = math.sin( CurTime() ) * .03 + .95

		scale = Lerp( FrameTime() * 2, scale, .2 )
		end_scale = Lerp( FrameTime() * 3, end_scale, 0 )
	end

	--  draw
	local tab = {
		["$pp_colour_addr"] = .09 * factor * math.min( 1, math.random() + .5 ) * scale,
		["$pp_colour_addg"] = .05 * end_scale,
		["$pp_colour_addb"] = .02 * math.abs( math.sin( CurTime() / 5 ) ) + .1 * end_scale,
		["$pp_colour_brightness"] = 1 * end_scale,
		["$pp_colour_contrast"] = .5 * factor + scale,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 1 + 1 * end_scale,
		["$pp_colour_mulg"] = 1 * end_scale,
		["$pp_colour_mulb"] = 0,
	}
	DrawColorModify( tab )
	DrawToyTown( 50, ScrH() * 2 * ( 1 - factor ) * scale )
	DrawBloom( 5, .6, 9, 9, 1, 1, 1, 1, 2 )
	DrawSharpen( 1, 1.2 * ( 1 - factor ) * scale )
	DrawMotionBlur( .4, 1 * scale * factor, .02 )
end )