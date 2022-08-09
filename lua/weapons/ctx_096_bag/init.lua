AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "duel"
local dist_sqr = 125 ^ 1.8
function SWEP:PrimaryAttack()
	if not SERVER then return end
	local ply = self:GetOwner()
	local trace = ply:GetEyeTrace()
	local target = trace.Entity
	if not GuthSCP.isSCP096Enraged( target ) then
		if target:IsPlayer() and target:GetPos():DistToSqr( ply:GetPos() ) <= dist_sqr and GuthSCP.isSCP096( target ) then
			if target:HasWeapon("ctx_096_bag") then
				return DarkRP.notify(ply, NOTIFY_ERROR, 8, "SCP-096 a déjà un sac sur sa tête, faites E pour lui retirer le sac.")
			end
			target:Give("ctx_096_bag")
			DarkRP.notify(ply, NOTIFY_GENERIC, 8, "SCP-096 a désormais un sac sur sa tête !")
			ply:StripWeapon("ctx_096_bag")
			
		end
	else
		DarkRP.notify(ply, NOTIFY_ERROR, 8, "SCP-096 est enragé, vous ne pouvez pas lui mettre un sac !")
	end
end