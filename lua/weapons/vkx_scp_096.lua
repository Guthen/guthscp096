AddCSLuaFile()

SWEP.PrintName				= "SCP-096"
SWEP.Author					= "Vyrkx A.K.A. Guthen"
SWEP.Instructions			= "Left click to kill your targets and to break everything in your way. Right click to put your hands on your face (first person only)."
SWEP.Category 				= "GuthSCP"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 1
SWEP.AutoSwitchTo			= true
SWEP.AutoSwitchFrom			= false

SWEP.Slot			   	 	= 1
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/v_arms_scp096.mdl"
SWEP.WorldModel				= ""

SWEP.GuthSCPLVL             = 0

local dist_sqr = 125 ^ 2
function SWEP:PrimaryAttack()
	if not SERVER then return end
	self:SetNextPrimaryFire( CurTime() + .1 )

	local ply = self:GetOwner()
	local tr = ply:GetEyeTrace()
    local target = tr.Entity
    if GuthSCP.isSCP096Enraged( ply ) then
        if target:IsPlayer() and target:GetPos():DistToSqr( ply:GetPos() ) <= dist_sqr and GuthSCP.isSCP096Target( target, ply ) then
            target:TakeDamage( 500, ply, self )
            self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

            self:SetNextPrimaryFire( CurTime() + .5 )
        elseif tr.HitPos:DistToSqr( ply:GetPos() ) <= dist_sqr then
            GuthSCP.breakEntitiesAtPlayerTrace( tr )
            self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

            self:SetNextPrimaryFire( CurTime() + .5 )
        end  
    end
end

function SWEP:Initialize()
    self:SetHoldType( "normal" )
end

if SERVER then
    function SWEP:Equip( ply )
        if IsValid( ply ) and ply:IsPlayer() then
            GuthSCP.unrageSCP096( ply )
        end
    end

    function SWEP:Holster()
        self.is_first_time_passed = false
        return true
    end

    function SWEP:Think()
        local ply = self:GetOwner()

        self.GuthSCPLVL = GuthSCP.Config.vkxscp096.keycard_level or 0
        if not self.is_first_time_passed then
            self:SendWeaponAnim( ACT_VM_IDLE )
            self.is_first_time_passed = true
        end
        
        if GuthSCP.isSCP096Enraged( ply ) then
            local time = CurTime() - ply:GetNWInt( "VKX:096EnragedTime", 0 )
            local factor = time / GuthSCP.Config.vkxscp096.trigger_time
            local shake_scale, shake_radius = GuthSCP.Config.vkxscp096.shake_scale, GuthSCP.Config.vkxscp096.shake_radius

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
    timer.Simple( 1.6, function()
        if not IsValid( self ) then return end

        local ply = self:GetOwner()
        if not IsValid( ply ) then return end

        if not GuthSCP.isSCP096Enraged( ply ) then
--[[             ply:GetViewModel():SendViewModelMatchingSequence( self:LookupSequence( "run" ) )
        else ]]
            self:SendWeaponAnim( ACT_VM_IDLE )
        end
    end )
    self:SetNextSecondaryFire( CurTime() + 1.6 )
end