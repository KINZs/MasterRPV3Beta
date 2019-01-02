#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>

#define CLASSNAME "weapon_mp5"
#define FIRE_FORCE 4500.0
#define MASS_SCALE 8.0 // more mass = more damage
#define DELETE_AFTER 2.5

#define AMMO_COST_SECONDARY 1
#define COOLDOWN_PRIMARY 0.4143
#define COOLDOWN_SECONDARY 0.9343

#define MODEL "models/items/ar2_grenade.mdl"
//#define MODEL "models/items/grenadeammo.mdl"

public Plugin myinfo =
{
	name = "Weapon_mp5",
	author = "Master(D)",
	description = "CustomGuns Weapon_mp5 Extension",
	version = "00.00.01",
	url = ""

};

public void OnPluginStart()
{

}

public void OnMapStart()
{

}

//Public Void OnClientPutInServer(int Client)
public void OnClientPostAdminCheck(int Client)
{

}


public OnConfigsExecuted()
{
	PrecacheModel(MODEL, true);
}

public void CG_OnSecondaryAttack(int client, int weapon)
{
	char cls[32];
	GetEntityClassname(weapon, cls, sizeof(cls));
	
	if(StrEqual(cls, CLASSNAME))
	{
		int Ammo = getWeaponAmmo2(client);
		
		if(Ammo > 0)
		{

			CG_SetNextPrimaryAttack(weapon, GetGameTime() + COOLDOWN_PRIMARY);
			CG_SetNextSecondaryAttack(weapon, GetGameTime() + COOLDOWN_SECONDARY);

			setWeaponAmmo2(client, (Ammo - AMMO_COST_SECONDARY), CLASSNAME);

			//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_SECONDARY);

			CG_PlayPrimaryAttack(weapon);
			
			EmitGameSoundToAll("Weapon_SMG1.Double", weapon);
			
			CG_SetPlayerAnimation(client, PLAYER_ATTACK1);
			
			ForeGrenadeLauncher(client, 0.25);
		}
	}
}

public void ForeGrenadeLauncher(int client, float forceScale)
{
	int ent = CreateEntityByName("grenade_ar2");
	//int ent = CreateEntityByName("npc_contactgrenade");
	//int ent = CreateEntityByName("npc_concussiongrenade"); // for non damage 
	SetEntityModel(ent, MODEL);
	DispatchSpawn(ent);

	//Set Prop ClassName
	SetEntPropString(ent, Prop_Data, "m_iClassname", "launched_grenade");

	float fwd[3], force[3], pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(fwd, FIRE_FORCE * forceScale);
	force = fwd;
	
	GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(fwd, 7.0);
	AddVectors(fwd, pos, pos);

	CG_GetShootPosition(client, pos, 12.0, 6.0, -12.0);

	ang[0] = 0.0;
	TeleportEntity(ent, pos, ang, force);

	//SetEntPropVector(ent, Prop_Data, "m_vecAbsVelocity", Float:{0.0,0.0,0.0}); //trampoline fix

	SetEntityGravity(ent, 0.5);
	
	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
	SetEntPropEnt(ent, Prop_Data, "m_hThrower", client);

	CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
}

public Action explode(Handle timer, any data){
	if(IsValidEntity(data)){
		AcceptEntityInput(data, "kill");
	}
}