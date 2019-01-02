#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>

#define FIRE_FORCE 7500.0
#define MASS_SCALE 80.00.0
#define DELETE_AFTER 3.333333

#define CLASSNAME "weapon_plasmagun"

#define AMMO_COST_PRIMARY 1
#define AMMO_COST_SECONDARY 18
#define AMMO_MAX 50
#define COOLDOWN_PRIMARY 0.2743
#define COOLDOWN_SECONDARY 1.2
#define COOLDOWN_RECHARGE 2.0
#define COOLDOWN_CHARGE 0.2743
#define PRIMARY_BULLET_DAMAGE 30.0
#define SECONDARY_BULLET_DAMAGE 150.0

int LightSprite = -1;
int GlowSprite = -1;
int WeaponOffset = -1;

float LastFiredWeapon[MAXPLAYERS + 1] = {0.0,...};
float LastCharged[MAXPLAYERS + 1] = {0.0,...};
bool IsChargedBolt[2047] = {false,...};
int BoltOwner[2047] = {-1,...};
int BoltLight[2047] = -1;
int BoltProp[2047] = -1;
int BoltSprite[2047] = -1;

//Plugin Info:
public Plugin myinfo =
{
	name = "Weapon_PlasmaGun",
	author = "Master(D)",
	description = "CustomGuns Weapon_PlasmaGun Extension",
	version = "00.00.15",
	url = ""
};

public void OnPluginStart()
{

	//Find Offsets:
	WeaponOffset = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
}

public void OnMapStart()
{

	//Loop:
	for(int Entity = GetMaxClients() + 1; Entity < 2047; Entity++)
	{
		IsChargedBolt[Entity] = false;
		BoltOwner[Entity] = -1;
		BoltLight[Entity] = -1;
		BoltProp[Entity] = -1;
		BoltSprite[Entity] = -1;
	}
	
	LightSprite = PrecacheModel("sprites/combineball_trail_black_1.vmt", true);
	//LightSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	GlowSprite = PrecacheModel("materials/sprites/blueglow2.vmt", true);
}

//Public Void OnClientPutInServer(int Client)
public void OnClientPostAdminCheck(int Client)
{

	LastFiredWeapon[Client] = 0.0;
	LastCharged[Client] = 0.0;
}

//Think:
public void OnGameFrame()
{

	//Loop:
	for(int Client = 1; Client < GetMaxClients(); Client++)
	{

		if(IsClientConnected(Client) && IsClientInGame(Client) && !IsFakeClient(Client))
		{
		
			int Weapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

			if(IsValidEdict(Weapon))
			{
			
				char cls[32];
				GetEntityClassname(Weapon, cls, sizeof(cls));

				if(StrEqual(cls, CLASSNAME))
				{
					if(GetGameTime() >= (LastCharged[Client] + COOLDOWN_CHARGE) && GetGameTime() >= (LastFiredWeapon[Client] + COOLDOWN_CHARGE))
					{
						int Ammo = getWeaponAmmo(Client);
						if(Ammo < AMMO_MAX)
						{
							LastCharged[Client] = GetGameTime();
							setWeaponAmmo(Client, (getWeaponAmmo(Client) + AMMO_COST_PRIMARY), CLASSNAME);
						}
				
						//Print:
						//PrintToServer("Weapon Last Fire %f gametime %f", LastFiredWeapon[Client], GetGameTime());
					}
				}
			}
		}
	}
	
	//Loop:
	for(int Entity = GetMaxClients() + 1; Entity < 2047; Entity++)
	{

		if(IsValidEdict(Entity))
		{

			char cls[32];
			GetEntityClassname(Entity, cls, sizeof(cls));

			if(StrEqual(cls, "Plasma_Bolt"))
			{

				//Declare:
				float Origin[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_vecOrigin", Origin);

				//Check Is Charged Bolt:
				if(IsChargedBolt[Entity] == true)
				{

					//Declare:
					float Angels[3];

					//Initulize:
					GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angels);

					//Temp Ent:
					TE_SetupEnergySplash(Origin, Angels, true);

					//Show To Client:
					TE_SendToAll();
				}
				
				//Declare:
				float Velocity[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_vecVelocity", Velocity);

				//Check to see if Plasma Bolt has stopped Moving:
				if(Velocity[0] == 0.0 || Velocity[1] == 0.0 || Velocity[2] == 0.0)
				{

					//Is Valid:
					if(!IsValidEdict(Entity))
					{

						//Print:
						//PrintToServer("Invalid Plasma Bolt");
						
						//Return:
						return;
					}
					
					//Accept:
					RemoveEdict(Entity);
				}
				
				//PrintToServer("bolt velocity %f %f %f", Velocity[0], Velocity[1], Velocity[2]);
			}
		}
	}
}

public OnConfigsExecuted()
{
	PrecacheSound("weapons/plasmarifle/plasma_impact.wav");
	PrecacheSound("weapons/plasmarifle/plasmarifle_fire.wav");
	PrecacheSound("weapons/plasmarifle/plasmarifle_fire2.wav");
}

public void CG_OnPrimaryAttack(int client, int weapon)
{
	char cls[32];
	GetEntityClassname(weapon, cls, sizeof(cls));

	if(StrEqual(cls, CLASSNAME)){
		if(getWeaponAmmo(client) > 0)
		{
			FirePlasmaGun(client, 0.25, true);
			CG_PlayPrimaryAttack(weapon);

			int Ammo = getWeaponAmmo(client);

			//Check:
			if(Ammo - AMMO_COST_PRIMARY == 0)
			{
				//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_PRIMARY);
				setWeaponAmmo(client, AMMO_COST_PRIMARY, CLASSNAME);

				CG_SetNextPrimaryAttack(weapon, GetGameTime() + (COOLDOWN_PRIMARY * 2.5));
				CG_SetNextSecondaryAttack(weapon, GetGameTime() + (COOLDOWN_PRIMARY * 2.5));
				
				LastCharged[client] = GetGameTime() + COOLDOWN_PRIMARY + COOLDOWN_PRIMARY;
			}
			//Override:
			else
			{
				//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_PRIMARY);
				setWeaponAmmo(client, (getWeaponAmmo(client) - AMMO_COST_PRIMARY), CLASSNAME);

				CG_SetNextPrimaryAttack(weapon, GetGameTime() + COOLDOWN_PRIMARY);
				CG_SetNextSecondaryAttack(weapon, GetGameTime() + COOLDOWN_PRIMARY);

			}
			
			LastFiredWeapon[client] = GetGameTime();
			
			StopFireSound(weapon);
			EmitGameSoundToAll("Weapon_Plasma.Single", weapon);
		}
	}
}

public void CG_OnSecondaryAttack(int client, int weapon)
{
	char cls[32];
	GetEntityClassname(weapon, cls, sizeof(cls));

	if(StrEqual(cls, CLASSNAME)){
		if(getWeaponAmmo(client) >= (AMMO_COST_SECONDARY))
		{
			FirePlasmaGun(client, 0.35, false);
			CG_PlayPrimaryAttack(weapon);

			int Ammo = getWeaponAmmo(client);

			//Check:
			if(Ammo - AMMO_COST_SECONDARY == 0)
			{
				//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_PRIMARY);
				setWeaponAmmo(client, AMMO_COST_PRIMARY, CLASSNAME);

				CG_SetNextPrimaryAttack(weapon, GetGameTime() + (COOLDOWN_PRIMARY + COOLDOWN_PRIMARY));
				CG_SetNextSecondaryAttack(weapon, GetGameTime() + COOLDOWN_SECONDARY);

				LastCharged[client] = GetGameTime() + COOLDOWN_SECONDARY;
			}

			//Override:
			else
			{
				//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_PRIMARY);
				setWeaponAmmo(client, (Ammo - AMMO_COST_SECONDARY), CLASSNAME);

				CG_SetNextPrimaryAttack(weapon, GetGameTime() + COOLDOWN_PRIMARY);
				CG_SetNextSecondaryAttack(weapon, GetGameTime() + COOLDOWN_SECONDARY);
			}
			EmitGameSoundToAll("Weapon_Plasma.Special", weapon);
			LastFiredWeapon[client] = GetGameTime();
		}
	}
}

public void FirePlasmaGun(int client, float forceScale, bool Primary)
{
	CG_SetPlayerAnimation(client, PLAYER_ATTACK1);

	int ent;
	
	if(Primary == true)
	{
		ent = CreateEntityByName("crossbow_bolt");

		//Set Owner Before Spawn:
		SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
		
		DispatchSpawn(ent);
	}
	else
	{
		ent = CreateEntityByName("grenade_ar2");

		DispatchSpawn(ent);
		
		SetEntPropEnt(ent, Prop_Data, "m_hThrower", client);
	}

	//Send:
	SetEntPropFloat(ent, Prop_Send, "m_flModelScale", 0.01);

	//Set Prop ClassName
	SetEntPropString(ent, Prop_Data, "m_iClassname", "Plasma_Bolt");

	SetEntityGravity(ent, 0.005);

	CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	
	float ang[3], pos[3], fwd[3], force[3];

	GetClientEyeAngles(client, ang);
	GetClientEyePosition(client, pos);

	GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

	ScaleVector(fwd, FIRE_FORCE * forceScale);
	force = fwd;

	CG_GetShootPosition(client, pos, 12.0, 8.0, -3.0);

	TeleportEntity(ent, pos, ang, force);
				
	int ent2 = CreateEntityByName("prop_physics_override");

	SetEntityModel(ent2, "models/effects/combineball.mdl");

	TeleportEntity(ent2, pos, ang, NULL_VECTOR);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(ent2, "SetParent", ent, ent2, 0);

	CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(ent2), TIMER_FLAG_NO_MAPCHANGE);

	float pos2[3];

	CG_GetShootPosition(client, pos2, 17.5, 10.0, -6.0);
	
	//Temp Ent Setup:
	TE_SetupGlowSprite(pos2, GlowSprite, 0.2, 0.35, 200);

	//Send To All Clients:
	TE_SendToAll();
				
	//Temp Ent:
	TE_SetupEnergySplash(pos2, NULL_VECTOR, true);

	//Show To Client:
	
	TE_SendToAll();		
	float viewPunch[3];
	
	//Check:
	if(Primary == true)
	{

		BoltLight[ent] = CreateCustomLight(ent, 1, 160, 160, 255, 0.7, "60", "80", "4", "1", "null");

		CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(BoltLight[ent]), TIMER_FLAG_NO_MAPCHANGE);

		int Color[4] = {160, 160, 255, 255};
	
		TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.6, 5.0, 0.5, 165, Color);

		//Show To All Clients:
		TE_SendToAll();
	
		TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.4, 2.5, 0.25, 65, Color);

		//Show To All Clients:
		TE_SendToAll();
		
		viewPunch[0] = GetRandomFloat( -3.5, 3.2 );
		viewPunch[1] = GetRandomFloat( -3.5, 3.5 );
		
		//Send:
		SetEntPropFloat(ent2, Prop_Send, "m_flModelScale", 0.5);

		float Offset[3] = {0.0,0.0,0.0};
		BoltSprite[ent] = CreateEnvSprite(ent, "null", "materials/effects/star_effect_muzzle.vmt", "0.2", Offset, 255, 255, 255);

		CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(BoltSprite[ent]), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	//Override:
	else
	{

		BoltLight[ent] = CreateCustomLight(ent, 1, 160, 160, 255, 0.7, "100", "80", "5", "1", "null");
	
		CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(BoltLight[ent]), TIMER_FLAG_NO_MAPCHANGE);

		int Color[4] = {100, 100, 255, 255};
	
		TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.6, 5.0, 0.5, 165, Color);

		//Show To All Clients:
		TE_SendToAll();
	
		TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.4, 2.5, 0.25, 65, Color);

		Color = {100, 100, 255, 255};
		
		//Show To All Clients:
		TE_SendToAll();
	
		TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.4, 7.5, 1.25, 245, Color);

		//Show To All Clients:
		TE_SendToAll();

		float Offset[3] = {0.0,0.0,0.0};
		BoltSprite[ent] = CreateEnvSprite(ent, "null", "materials/effects/star_effect_muzzle.vmt", "0.4", Offset, 255, 255, 255);

		CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(BoltSprite[ent]), TIMER_FLAG_NO_MAPCHANGE);
		
		viewPunch[0] = GetRandomFloat( -9.5, 9.2 );
		viewPunch[1] = GetRandomFloat( -9.5, 7.5 );

		//Initulize:
		IsChargedBolt[ent] = true;
	}

	pos[2] += 10.0;
	
	//TE Setup:
	TE_SetupDynamicLight(pos, 160, 160, 255, 8, 65.0, 0.4, 50.0);

	//Send:
	TE_SendToAll();

	//Set Ent Color:
	SetEntityRenderColor(ent, 255, 255, 255, 0);
	
	Tools_ViewPunch(client, viewPunch);

	// Register a muzzleflash for the AI
	SetEntPropFloat(client, Prop_Data, "m_flFlashTime", GetGameTime() + 0.5);

	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
	BoltOwner[ent] = client;
}

public Action explode(Handle timer, any data){
	if(IsValidEntity(data)){
		AcceptEntityInput(data, "Kill");
	}
}

// remove players from Vehicles before they are destroyed or the server will crash!
public OnEntityDestroyed(int Entity)
{
	//Check:
	if(IsValidEdict(Entity))
	{
		char cls[32];
		GetEntityClassname(Entity, cls, sizeof(cls));

		if(StrEqual(cls, "Plasma_Bolt"))
		{

			//Effect:
			CreateHitSurfaceEffect(Entity);
		}
	}
}

public void CreateHitSurfaceEffect(int Entity)
{

	//Is Valid:
	if(!IsValidEdict(Entity))
	{

		//Print:
		//PrintToServer("Invalid Plasma Bolt");
						
		//Return:
		return;
	}
	int client = BoltOwner[Entity];
	//int client = GetEntPropEnt(Entity, Prop_Data, "m_hOwnerEntity");

	//Check:
	if(client <= 0)
	{

		//Print:
		//PrintToServer("Plasma Bolt but no Client");
						
		//Return:
		return;
	}
	
	float Origin[3], Angels[3];

	GetEntPropVector(Entity, Prop_Data, "m_vecOrigin", Origin);
		
	GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angels);
	
	//Check:
	if(IsChargedBolt[Entity] == true)
	{

		CG_RadiusDamage(client, client, SECONDARY_BULLET_DAMAGE, DMG_SHOCK, 0, Origin, 165.0, client);

		//TE Setup:
		TE_SetupDynamicLight(Origin, 160, 160, 255, 8, 35.0, 0.4, 50.0);

		//Send:
		TE_SendToAll();

		physExplosion(Origin, 55.0, true);

		//Temp Ent:
		TE_SetupSparks(Origin, Angels, 5, 5);

		//Send:
		TE_SendToAll();

		int ent = CreateEntityByName("prop_combine_ball");
		DispatchSpawn(ent);

		TeleportEntity(ent, Origin, Angels, NULL_VECTOR);
	
		//Accept:
		AcceptEntityInput(ent, "explode");
	}
		
	//Override:
	else
	{

		CG_RadiusDamage(client, client, PRIMARY_BULLET_DAMAGE, DMG_SHOCK, 0, Origin, 50.0, client);

		//TE Setup:
		TE_SetupDynamicLight(Origin, 160, 160, 255, 8, 85.0, 0.4, 50.0);

		//Send:
		TE_SendToAll();

		physExplosion(Origin, 15.0, true);

		//Temp Ent:
		TE_SetupSparks(Origin, Angels, 5, 5);

		//Send:
		TE_SendToAll();

		//Emit Sound:
		EmitAmbientSound("weapons/plasmarifle/plasma_impact.wav", Origin, Entity);
	}

	//Check:
	if(IsValidEdict(BoltLight[Entity]))
	{

		//Accept:
		AcceptEntityInput(BoltLight[Entity], "Kill");

		//Initialize:
		BoltLight[Entity] = -1;
	}

	//Check:
	if(IsValidEdict(BoltProp[Entity]))
	{

		//Accept:
		AcceptEntityInput(BoltProp[Entity], "Kill");

		//Initialize:
		BoltLight[Entity] = -1;
	}
	
	//Check:
	if(IsValidEdict(BoltSprite[Entity]))
	{

		//Accept:
		AcceptEntityInput(BoltSprite[Entity], "Kill");

		//Initialize:
		BoltSprite[Entity] = -1;
	}
	

	UTIL_ImpactTrace(Origin, DMG_SHOCK, "ImpactGauss");
		
	//Temp Ent Setup:
	TE_SetupGlowSprite(Origin, GlowSprite, 0.2, 1.0, 255);

	//Send To All Clients:
	TE_SendToAll();

	//Print:
	//PrintToServer("Effect bolt type %i", IsChargedBolt[Entity]);
	
	//Initialize:
	IsChargedBolt[Entity] = false;

}

/**
 * Sets up a Dynamic Light effect
 *
 * @param vecOrigin        Position of the Dynamic Light
 * @param r            r color value
 * @param g            g color value
 * @param b            b color value
 * @param iExponent        ?
 * @param fTime            Duration
 * @param fDecay        Decay of dynamic light
 * @noreturn
 */
public void TE_SetupDynamicLight(float Origin[3], int R, int G, int B, int Exponent, float Radius , float Time, float Decay)
{

    TE_Start("Dynamic Light");
    TE_WriteVector("m_vecOrigin", Origin);
    TE_WriteNum("r",R);
    TE_WriteNum("g",G);
    TE_WriteNum("b",B);
    TE_WriteNum("exponent", Exponent);
    TE_WriteFloat("m_fRadius", Radius);
    TE_WriteFloat("m_fTime", Time);
    TE_WriteFloat("m_fDecay", Decay);
}
//CreateCustomLight(0, 1, 255, 255, 255, 0.5, "640", "80", "3", "0", "null")
public int CreateCustomLight(int Ent, int IsOn, int Red, int Green, int Blue, float Offset, const char[] Distance, const char[] SpotLightRadius, const char[] Brightness, const char[] Style, const char[] Attachment)
{

	//Declare:
	float EntOrigin[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", EntOrigin);

	//Edit Position:
	EntOrigin[2] += Offset;

	//Initulize::
	int Light = CreateEntityByName("light_dynamic");

	//Is Valid:
	if(IsValidEdict(Light))
	{

		//Declare:
		char LightColor[32];

		//Format:
		Format(LightColor, sizeof(LightColor), "%i %i %i", Red, Green, Blue);

		//Dispatch:
		DispatchKeyValue(Light, "_light", LightColor);

		DispatchKeyValue(Light, "distance", Distance);

		DispatchKeyValue(Light, "spotlight_radius", SpotLightRadius);

		DispatchKeyValue(Light, "brightness", Brightness);

		DispatchKeyValue(Light, "style", Style);

		//Declare:
		char SpawnOrg[50];

		//Format:
		Format(SpawnOrg, sizeof(SpawnOrg), "%f %f %f", EntOrigin[0], EntOrigin[1], EntOrigin[2]);

		//Dispatch:
		DispatchKeyValue(Light, "origin", SpawnOrg);

		//Spawn:
		DispatchSpawn(Light);

		//Activate
		ActivateEntity(Light);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Light, "SetParent", Ent, Light, 0);

		//Custom Attachment point!
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Light, "SetParentAttachment", Light , Light, 0);
		}

		SetEntPropEnt(Light, Prop_Data, "m_hOwnerEntity", Ent);

		//Return:
		return Light;
	}

	//Return:
	return -1;
}

public int HasClientWeapon(int Client, const char[] WeaponName)
{

	//Declare:
	int MaxGuns = 64;

	//Loop:
	for(int X = 0; X < MaxGuns; X = (X + 4))
	{

		//Declare:
		int WeaponId = GetEntDataEnt2(Client, WeaponOffset + X);

		//Is Valid:
		if(WeaponId > 0)
		{

			//Declare:
			char ClassName[32];

			//Initialize:
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual(ClassName, WeaponName))
			{

				//Return:
				return WeaponId;

			}
		}
	}

	//Return:
	return -1;
}
//CreateEnvSprite(Client, "null", "materials/bouncy/low_hp.vmt", "0.1", Offset, 255, 255, 255);
public int CreateEnvSprite(int Ent, char[] Attachment, char[] Model, char[] Scale, float Offset[3], int R, int G, int B)
{

	//Declare:
	int SpriteOrientaded = CreateEntityByName("env_sprite");

	//Create:
	if(IsValidEdict(SpriteOrientaded))
	{

		//Declare:
		char Color[32];

		//Format:
		Format(Color, sizeof(Color), "%i %i %i", R, G, B);

		//Dispatch:
		DispatchKeyValue(SpriteOrientaded, "rendercolor", Color);

		DispatchKeyValue(SpriteOrientaded, "rendermode", "5");

		DispatchKeyValue(SpriteOrientaded, "spawnflags", "1");

		DispatchKeyValue(SpriteOrientaded, "Scale", Scale);

		DispatchKeyValue(SpriteOrientaded, "model", Model);

		//Set Owner
		SetEntPropEnt(SpriteOrientaded, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(SpriteOrientaded);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		Position[0] += Offset[0];
		Position[1] += Offset[1];
		Position[2] += Offset[2];

		//Teleport:
		TeleportEntity(SpriteOrientaded, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SpriteOrientaded, "SetParent", Ent, SpriteOrientaded, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SpriteOrientaded, "SetParentAttachment", SpriteOrientaded ,SpriteOrientaded, 0);
		}

		//Accept:
		AcceptEntityInput(SpriteOrientaded, "enable");

		//Return:
		return SpriteOrientaded;
	}

	//Return:
	return - 1;
}
//CreateEnvSprite(Client, "null", "materials/bouncy/low_hp.vmt", "0.1", Offset, 255, 255, 255);
public int CreateEnvSpriteOther(int Ent, char[] Attachment, char[] Model, float Position[3], char[] Scale, int R, int G, int B)
{

	//Declare:
	int SpriteOrientaded = CreateEntityByName("env_sprite");

	//Create:
	if(IsValidEdict(SpriteOrientaded))
	{

		//Declare:
		char Color[32];

		//Format:
		Format(Color, sizeof(Color), "%i %i %i", R, G, B);

		//Dispatch:
		DispatchKeyValue(SpriteOrientaded, "rendercolor", Color);

		DispatchKeyValue(SpriteOrientaded, "rendermode", "5");

		DispatchKeyValue(SpriteOrientaded, "spawnflags", "1");

		DispatchKeyValue(SpriteOrientaded, "Scale", Scale);

		DispatchKeyValue(SpriteOrientaded, "model", Model);

		//Set Owner
		SetEntPropEnt(SpriteOrientaded, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(SpriteOrientaded);

		//Teleport:
		TeleportEntity(SpriteOrientaded, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SpriteOrientaded, "SetParent", Ent, SpriteOrientaded, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SpriteOrientaded, "SetParentAttachment", SpriteOrientaded ,SpriteOrientaded, 0);
		}

		//Accept:
		AcceptEntityInput(SpriteOrientaded, "enable");

		//Return:
		return SpriteOrientaded;
	}

	//Return:
	return - 1;
}

void StopFireSound(int weapon)
{
	StopSound(weapon, SNDCHAN_WEAPON, "weapons/plasmarifle/plasmarifle_fire.wav");
		
	//Print:
	//PrintToServer("stopsound %i", weapon);
}


void TE_SetupGaussExplosion(const float vecOrigin[3], int type, float direction[3])
{	
 	TE_Start("GaussExplosion");
	TE_WriteFloat("m_vecOrigin[0]", vecOrigin[0]);
	TE_WriteFloat("m_vecOrigin[1]", vecOrigin[1]);
	TE_WriteFloat("m_vecOrigin[2]", vecOrigin[2]);
	TE_WriteNum("m_nType", type);
	TE_WriteVector("m_vecDirection", direction);
}
