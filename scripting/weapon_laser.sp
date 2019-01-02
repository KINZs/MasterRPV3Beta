#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>

#define FIRE_FORCE 7500.0
#define MASS_SCALE 80.00.0
#define DELETE_AFTER 3.333333

#define CLASSNAME "weapon_laser"

#define AMMO_COST_PRIMARY 1
#define AMMO_MAX 6
#define COOLDOWN_PRIMARY 0.5343
#define PRIMARY_BULLET_DAMAGE 70.0

int LightSprite = -1;
int GlowSprite = -1;
int WeaponOffset = -1;

float LastFiredWeapon[MAXPLAYERS + 1] = {0.0,...};
float LastCharged[MAXPLAYERS + 1] = {0.0,...};
int BoltOwner[2047] = {-1,...};
int BoltLight[2047] = -1;
int BoltProp[2047] = -1;

//Plugin Info:
public Plugin myinfo =
{
	name = "Weapon_Laser",
	author = "Master(D)",
	description = "CustomGuns Weapon_Laser Extension",
	version = "00.00.01",
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

		BoltOwner[Entity] = -1;
		BoltLight[Entity] = -1;
		BoltProp[Entity] = -1;
	}
	LightSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	GlowSprite = PrecacheModel("materials/sprites/blueglow2.vmt", true);
	PrecacheSound("weapons/laser/holster.wav");
	PrecacheSound("weapons/laser/dep.wav");
	PrecacheSound("weapons/laser/reload.wav");
}

//Public Void OnClientPutInServer(int Client)
public void OnClientPostAdminCheck(int Client)
{
	LastFiredWeapon[Client] = 0.0;
	LastCharged[Client] = 0.0;
}

public void CG_OnHolster(int client, int weapon, int switchingTo)
{
	char ClassName[32];
	GetEntityClassname(weapon, ClassName, sizeof(ClassName));

	if(StrEqual(ClassName, CLASSNAME))
	{
		EmitGameSoundToAll("Weapon_Laser.Holster", weapon);
	}
}

public void CG_OnWeaponEquipt(int client, int weapon, int Sucess)
{
	char ClassName2[32];
	GetEntityClassname(weapon, ClassName2, sizeof(ClassName2));

	if(StrEqual(ClassName2, CLASSNAME))
	{
		EmitGameSoundToAll("Weapon_Laser.DeHolster", weapon);
	}
}

//Think:
public void OnGameFrame()
{

	//Loop:
	for(int Entity = GetMaxClients() + 1; Entity < 2047; Entity++)
	{

		if(IsValidEdict(Entity))
		{

			char cls[32];
			GetEntityClassname(Entity, cls, sizeof(cls));

			if(StrEqual(cls, "Laser_Bolt"))
			{
				//Declare:
				float Origin[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_vecOrigin", Origin);

				//Declare:
				float Angels[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angels);

				//Temp Ent:
				TE_SetupEnergySplash(Origin, Angels, true);

				//Show To Client:
				TE_SendToAll();

				//Declare:
				float Velocity[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_vecVelocity", Velocity);

				//Check to see if Laser Bolt has stopped Moving:
				if(Velocity[0] == 0.0 || Velocity[1] == 0.0 || Velocity[2] == 0.0)
				{

					//Is Valid:
					if(!IsValidEdict(Entity))
					{

						//Print:
						//PrintToServer("Invalid Laser Bolt");
						
						//Return:
						return;
					}

					//Remove:
					RemoveEdict(Entity);
				}
			}
		}
	}
}

public void CG_OnPrimaryAttack(int client, int weapon)
{
	char cls[32];
	GetEntityClassname(weapon, cls, sizeof(cls));

	if(StrEqual(cls, CLASSNAME))
	{
		if(getWeaponAmmo(client) > 0)
		{
		
			FireLaser(client, 0.45);
			CG_PlaySecondaryAttack(weapon);

			CG_SetNextPrimaryAttack(weapon, GetGameTime() + COOLDOWN_PRIMARY);

			setWeaponAmmo(client, (getWeaponAmmo(client) - AMMO_COST_PRIMARY), CLASSNAME);
			//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_PRIMARY);

			EmitGameSoundToAll("Weapon_Laser.Single", weapon);
			LastFiredWeapon[client] = GetGameTime();
		}
	}
}

public void FireLaser(int client, float forceScale)
{
	CG_SetPlayerAnimation(client, PLAYER_ATTACK1);

	int ent = CreateEntityByName("grenade_ar2");
	//int ent = CreateEntityByName("prop_combine_ball");
	//int ent = CreateEntityByName("prop_physics_override");
	
	//SetEntityModel(ent, "models/items/ar2_grenade.mdl");
	
	//Dispatch:
	DispatchKeyValue(ent, "model", "models/effects/combineball.mdl");

	DispatchSpawn(ent);

	//Set Prop ClassName
	SetEntPropString(ent, Prop_Data, "m_iClassname", "Laser_Bolt");

	SetEntityGravity(ent, 0.005);

	CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);

	float ang[3], pos[3], fwd[3], force[3];

	GetClientEyeAngles(client, ang);
	GetClientEyePosition(client, pos);

	GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

	ScaleVector(fwd, FIRE_FORCE * forceScale);
	force = fwd;

	CG_GetShootPosition(client, pos, 12.0, 6.0, -3.0);

	TeleportEntity(ent, pos, ang, force);

	float viewPunch[3];

	int ent2 = CreateEntityByName("prop_combine_ball");

	SetEntityModel(ent2, "models/effects/combineball.mdl");

	TeleportEntity(ent2, pos, ang, NULL_VECTOR);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(ent2, "SetParent", ent, ent2, 0);

	CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(ent2), TIMER_FLAG_NO_MAPCHANGE);

	BoltLight[ent] = CreateCustomLight(ent, 1, 200, 20, 215, 0.7, "100", "80", "7", "1", "null");

	CreateTimer(DELETE_AFTER, explode, EntIndexToEntRef(BoltLight[ent]), TIMER_FLAG_NO_MAPCHANGE);

	int Color[4] = {60, 20, 215, 255};

	TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.6, 5.0, 0.5, 165, Color);

	//Show To All Clients:
	TE_SendToAll();

	TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.4, 2.5, 0.25, 65, Color);

	Color = {200, 20, 215, 255};

	//Show To All Clients:
	TE_SendToAll();

	TE_SetupBeamFollow(ent, LightSprite, GlowSprite, 0.4, 7.5, 1.25, 245, Color);

	//Show To All Clients:
	TE_SendToAll();

	viewPunch[0] = GetRandomFloat( -9.5, 9.2 );
	viewPunch[1] = GetRandomFloat( -9.5, 7.5 );

	pos[2] += 10.0;

	//TE Setup:
	TE_SetupDynamicLight(pos, 200, 20, 215, 8, 65.0, 0.4, 50.0);

	//Send:
	TE_SendToAll();

	//Set Ent Color:
	SetEntityRenderColor(ent, 200, 20, 215, 10);

	Tools_ViewPunch(client, viewPunch);

	// Register a muzzleflash for the AI
	SetEntPropFloat(client, Prop_Data, "m_flFlashTime", GetGameTime() + 0.5);

	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
	//SetEntPropEnt(ent, Prop_Data, "m_hThrower", client);
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

		if(StrEqual(cls, "Laser_Bolt"))
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
		//PrintToServer("Invalid Laser Bolt");

		//Return:
		return;
	}
	
	int client = BoltOwner[Entity];
	//int client = GetEntPropEnt(Entity, Prop_Data, "m_hOwnerEntity");

	//Check:
	if(client <= 0)
	{

		//Print:
		PrintToServer("Laser Bolt but no Client");

		//Return:
		return;
	}

	float Origin[3], Angels[3];

	GetEntPropVector(Entity, Prop_Data, "m_vecOrigin", Origin);
		
	GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angels);

	CG_RadiusDamage(client, client, PRIMARY_BULLET_DAMAGE, DMG_SHOCK, 0, Origin, 165.0, client);

	//TE Setup:
	TE_SetupDynamicLight(Origin, 200, 20, 215, 8, 55.0, 0.4, 50.0);

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

	UTIL_ImpactTrace(Origin, DMG_SHOCK, "ImpactGauss");
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
