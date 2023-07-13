if not guthscp then
	error( "guthscp096 - fatal error! https://github.com/Guthen/guthscpbase must be installed on the server!" )
	return
end

local guthscp096 = guthscp.modules.guthscp096


AddCSLuaFile()

SWEP.PrintName = "SCP-096"
SWEP.Author = "Vyrkx A.K.A. Guthen"
SWEP.Instructions = "Left click to kill your targets and to break everything in your way. Right click to put your hands on your face (first person only)."
SWEP.Category = "GuthSCP"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 1
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom	= false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/v_arms_scp096.mdl"
SWEP.WorldModel	= ""

SWEP.GuthSCPLVL = 0

function SWEP:PrimaryAttack()
	if not SERVER then return end
	
	local ply = self:GetOwner()
	if not guthscp096.is_scp_096_enraged( ply ) then 
		self:SetNextPrimaryFire( CurTime() + .1 )
		return 
	end
	
	--  get target entity
	local start_pos = ply:EyePos()
	local tr = guthscp.world.player_trace_attack( 
		ply, 
		guthscp.configs.guthscp096.distance_unit, 
		Vector( 
			guthscp.configs.guthscp096.attack_hull_size, 
			guthscp.configs.guthscp096.attack_hull_size, 
			guthscp.configs.guthscp096.attack_hull_size 
		) 
	)
	local target = tr.Entity

	--  kill target
	if target:IsPlayer() and guthscp096.is_scp_096_target( target, ply ) then
		target:TakeDamage( 500, ply, self )
		self:SetNextPrimaryFire( CurTime() + guthscp.configs.guthscp096.kill_cooldown )
	--  destroy entities
	else
		guthscp.break_entities_at_player_trace( tr )
		self:SetNextPrimaryFire( CurTime() + guthscp.configs.guthscp096.break_cooldown )
	end
	
	--  attack anim
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

if SERVER then
	function SWEP:Equip( ply )
		if IsValid( ply ) and ply:IsPlayer() then
			guthscp096.unrage_scp_096( ply )
		end
	end

	function SWEP:Holster()
		self.is_first_time_passed = false
		return true
	end

	function SWEP:Think()
		local ply = self:GetOwner()

		self.GuthSCPLVL = guthscp.configs.guthscp096.keycard_level or 0
		if not self.is_first_time_passed then
			self:SendWeaponAnim( ACT_VM_IDLE )
			self.is_first_time_passed = true
		end
		
		if guthscp096.is_scp_096_enraged( ply ) then
			local time = CurTime() - ply:GetNWInt( "guthscp096:enrage_time", 0 )
			local factor = time / guthscp.configs.guthscp096.trigger_time
			local shake_scale, shake_radius = guthscp.configs.guthscp096.shake_scale, guthscp.configs.guthscp096.shake_radius

			if factor <= 1 then
				if shake_scale > 0 then
					util.ScreenShake( ply:GetPos(), 6 * factor * shake_scale, 2, 1, shake_radius )
				end

				--  periodically putting hands on his head (some animation)
				if time < .5 or math.Round( time ) % 3 == 0 --[[ and self:GetNextPrimaryFire() <= CurTime() ]] then
					self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
				end
			elseif shake_scale > 0 then
				util.ScreenShake( ply:GetPos(), 2 * shake_scale, 2, 1, shake_radius )
			end
		end
	end
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	
    timer.Simple( guthscp.configs.guthscp096.cover_cooldown, function()
        if not IsValid( self ) then return end

        local ply = self:GetOwner()
        if not IsValid( ply ) then return end

        if not guthscp096.is_scp_096_enraged( ply ) then
            self:SendWeaponAnim( ACT_VM_IDLE )
        end
    end )
    self:SetNextSecondaryFire( CurTime() + guthscp.configs.guthscp096.cover_cooldown )
end

if CLIENT and guthscp then
	guthscp.spawnmenu.add_weapon( SWEP, "SCPs" )
end