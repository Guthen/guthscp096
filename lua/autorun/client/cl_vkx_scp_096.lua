if not GuthSCP or not GuthSCP.Config then
    return
end

--  targets
local targets, targets_keys = {}, {}

net.Receive( "vkxscp096:target", function()
    local ply = net.ReadEntity()
    if IsValid( ply ) then
        targets[ply] = net.ReadBool() or nil
        ply.scp_096_path = { ply:GetPos() }
    else
        for i, v in ipairs( targets_keys ) do v.scp_096_path = nil end
        targets = {}
    end

    targets_keys = table.GetKeys( targets )
end )

function GuthSCP.getSCP096Targets()
    return targets_keys
end

--  render
local render_halo = CreateClientConVar( "vkx_scp096_render_targets_halo", "1", true, false, "Render a halo on the SCP-096 targets, more expensive than a line" )
local render_line = CreateClientConVar( "vkx_scp096_render_targets_line", "0", true, false, "Render a line between you and the SCP-096 targets" )
local render_pp = CreateClientConVar( "vkx_scp096_render_post_process", "1", true, false, "Render post process effects as SCP-096" )
local render_pathfinding = CreateClientConVar( "vkx_scp096_render_path_finding", "0", true, false, "Render path toward targets as SCP-096. It's a rudimentary method, it's not 100% relatable." )

local indicator_color = Color( 220, 62, 62 )
hook.Add( "PreDrawHalos", "vkxscp096:target", function()
    if not render_halo:GetBool() then return end
    if not GuthSCP.isSCP096() then return end

    halo.Add( targets_keys, indicator_color, 2, 2, 1, true, true )
end )

local new_point_interval = 5 --  every 5 seconds
local sphere_radius = 16
local sphere_radius_sqr = sphere_radius ^ 2
local last_path_time = CurTime()
hook.Add( "PostDrawTranslucentRenderables", "vkxscp096:target", function()
    if not render_line:GetBool() then return end
    if not GuthSCP.isSCP096() then return end

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
    if not GuthSCP.isSCP096() then return end

    local ply = LocalPlayer()
    --  enraged
    if GuthSCP.isSCP096Enraged( ply ) then
        enrage_time = enrage_time + FrameTime()
        factor = math.min( 1.1, enrage_time / GuthSCP.Config.vkxscp096.trigger_time )

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

--  test
--[[ hook.Remove( "HUDPaint", "Guthen:CelesteHUD" )
hook.Remove("HUDPaint", "FPP_HUDPaint")
hook.Add( "HUDShouldDraw", "no", function( name )
    if name == "DarkRP_EntityDisplay" or name == "CHudDeathNotice" then return false end
end )
function notification.AddLegacy() end ]]