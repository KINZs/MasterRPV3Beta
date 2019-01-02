#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <customguns>

#pragma newdecls required


#define CLASSNAME "weapon_gauss_old"
#define GAUSS_BEAM_SPRITE "sprites/laserbeam.vmt"

#define SPREAD 0.00873 // -> VECTOR_CONE_1DEGREES
#define AMMO_COST_PRIMARY 1
#define COOLDOWN_PRIMARY 0.25
#define COOLDOWN_SECONDARY 0.5
#define PLAYER_HIT_FORCE 10.0
#define CHARGELOOP_PITCH_START 50
#define CHARGELOOP_PITCH_END 250
#define GAUSS_CHARGE_TIME 0.3 // was 0.2
#define MAX_GAUSS_CHARGE_TIME 3.0
#define DANGER_GAUSS_CHARGE_TIME 10.0
#define GAUSS_CHARGE_DAMAGE_PERBULLET 20.0
#define GAUSS_DAMAGE_PERBULLET 30.0


float m_flChargeStartTime[MAXPLAYERS+1];
float m_flChargeTime[MAXPLAYERS+1];
bool m_bCharging[MAXPLAYERS+1];
bool m_bCharge[MAXPLAYERS+1];
int GaussAmmoConsumed[MAXPLAYERS + 1];
float m_flChargeTransitionTime[MAXPLAYERS+1];

bool teamplay;
int sprite;

public Plugin myinfo =
{
	name = "Weapon_Gauss",
	author = "Alienmario remade by Master(D)",
	description = "CustomGuns Weapon_Gauss Extension",
	version = "00.00.01",
	url = ""

};

public void OnPluginStart()
{
}

public void OnMapStart()
{
	teamplay = GetConVarBool(FindConVar("mp_teamplay"));
}

public void OnClientPutInServer(int client){
	resetVars(client);
}

void resetVars(int client){
	m_flChargeStartTime[client] = 0.0;
	m_flChargeTime[client] = 0.0;
	m_bCharging[client] = false;
	m_bCharge[client] = false;
	GaussAmmoConsumed[client] = 0
	m_flChargeTransitionTime[client] = 0.0;
}

public void OnConfigsExecuted(){
	sprite = PrecacheModel(GAUSS_BEAM_SPRITE);
}

public void CG_OnPrimaryAttack(int client, int weapon){
	char sWeapon[32];
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(StrEqual(sWeapon, CLASSNAME)){
		if(m_bCharging[client]){
			return;
		}
		int Ammo = getWeaponAmmo(client);	
		if(Ammo == 0)
		{
			return;
		}
		//CG_SetPlayerAnimation(client, PLAYER_ATTACK1);
		CG_PlayPrimaryAttack(weapon);
		
		CG_SetNextPrimaryAttack(weapon, GetGameTime() + COOLDOWN_PRIMARY);
		CG_SetNextSecondaryAttack(weapon, GetGameTime() + COOLDOWN_SECONDARY);

		EmitGameSoundToAll("Weapon_Gauss.Single", weapon);

		PrimaryFire(client, weapon);

		//CG_RemovePlayerAmmo(client, weapon, AMMO_COST_PRIMARY);
		setWeaponAmmo(client, (Ammo - AMMO_COST_PRIMARY), CLASSNAME);	
	}
}

public void CG_OnSecondaryAttack(int Client, int weapon){
	char sWeapon[32];
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(StrEqual(sWeapon, CLASSNAME))
	{
		int Ammo = getWeaponAmmo(Client);			
		if(Ammo == 0)
		{
				return;
		}
		
		if(m_bCharging[Client] == false)
		{

			//Start looping animation
			m_flChargeTransitionTime[Client] = GetGameTime() + CG_PlayActivity(weapon, ACT_VM_PULLBACK_LOW) - 0.1;

			// delay attacks indefinitely until this attack has finished!
			// CG_SetNextPrimaryAttack(weapon, FLT_IDKWHATSMAX);
			// CG_SetNextSecondaryAttack(weapon, FLT_IDKWHATSMAX);

			m_flChargeStartTime[Client] = GetGameTime();
			m_bCharging[Client] = true;
		}
	}
}

public Action OnPlayerRunCmd(int Client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{

	int Weapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");
	
	if(Client == 0 || Weapon == 0)
	{
		return;
	}

	if(m_flChargeStartTime[Client] > 0.0)
	{
	
		char sWeapon[32];
		GetClientWeapon(Client, sWeapon, sizeof(sWeapon));
				
		if(StrEqual(sWeapon, CLASSNAME))
		{

			if(!(buttons & IN_ATTACK2))
			{
				//Stop Charge Sound
				StopChargeSound(Client, Weapon);
					
				ChargedFire(Client, Weapon, GaussAmmoConsumed[Client]);
			}

			else
			{

				float curtime = GetGameTime();

				if(curtime >= m_flChargeTransitionTime[Client])
				{
					CG_PlayActivity(Weapon, ACT_VM_PULLBACK);
					m_flChargeTransitionTime[Client] = FLT_IDKWHATSMAX;
				}

				//Check:
				if(!IsPlayerAlive(Client))
				{

					//Stop Charge Sound
					StopChargeSound(Client, Weapon);
					
					/* Return to idle and reset everything! */
					CG_PlayActivity(Weapon, ACT_VM_IDLE);
					CG_Cooldown(Weapon, 1.3);
					m_flChargeStartTime[Client] = 0.0;
					m_bCharging[Client]  = false;
				}
				int Ammo = getWeaponAmmo(Client);	
				if(Ammo == 0)
				{
					return;
				}
				if(GaussAmmoConsumed[Client] < 10)
				{
					
					if (m_flChargeTime[Client] + (MAX_GAUSS_CHARGE_TIME / 10) < curtime)
					{
						m_flChargeTime[Client] = GetGameTime();
						GaussAmmoConsumed[Client] += 1;
						setWeaponAmmo(Client, (Ammo - AMMO_COST_PRIMARY), CLASSNAME);
					}
				}
				
				// Send charge-sound pitch updates to client
				
				float flChargeAmount = ( curtime - m_flChargeStartTime[Client] ) / MAX_GAUSS_CHARGE_TIME;
				if ( flChargeAmount <= 1.0 )
				{
					int newPitch = CHARGELOOP_PITCH_START + RoundToFloor((CHARGELOOP_PITCH_END - CHARGELOOP_PITCH_START) * flChargeAmount);
					EmitSoundToAll("weapons/gauss/chargeloop.wav", weapon, SNDCHAN_WEAPON, SNDLEVEL_GUNFIRE, SND_CHANGEPITCH|SND_CHANGEVOL, 0.75, newPitch);
					
					//Print:
					//PrintToServer("Test pitch = %i", newPitch);
				}
				if (m_flChargeTime[Client] + (DANGER_GAUSS_CHARGE_TIME - MAX_GAUSS_CHARGE_TIME) < GetGameTime())
				{
					//Damage the player
					EmitGameSoundToAll("Weapon_Gauss.OverCharged", Weapon);
							   
					// Add DMG_CRUSH because we don't want any physics force
					SDKHooks_TakeDamage(Client, Weapon, Weapon, 25.0, DMG_SHOCK | DMG_CRUSH);

					float Cooldown = GetRandomFloat( 1.5, 2.5 );
					m_flChargeStartTime[Client] = 0.0;
					m_bCharging[Client] = false;
					GaussAmmoConsumed[Client] = 0;
								
					CG_SetNextPrimaryAttack(Weapon, GetGameTime() + (COOLDOWN_PRIMARY + Cooldown));
					CG_SetNextSecondaryAttack(Weapon, GetGameTime() + (COOLDOWN_SECONDARY + Cooldown));
				}
			}
		}
	}
}

public void CG_OnHolster(int client, int weapon, int switchingTo){
	char sWeapon[32];
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(StrEqual(sWeapon, CLASSNAME)){
		StopChargeSound(client, weapon);
		resetVars(client);
	}
}

void PrimaryFire(int client, int weapon){
	float angles[3], startPos[3], endPos[3], vecDir[3], traceNormal[3], vecFwd[3], vecUp[3], vecRight[3];
	CG_GetShootPosition(client, startPos);
	GetClientEyeAngles(client, angles);
	GetAngleVectors(angles, vecFwd, vecRight, vecUp);
	
	float x, y, z;
	//Gassian spread
	do {
		x = GetRandomFloat(-0.5,0.5) + GetRandomFloat(-0.5,0.5);
		y = GetRandomFloat(-0.5,0.5) + GetRandomFloat(-0.5,0.5);
		z = x*x+y*y;
	} while (z > 1);
 
 	vecDir[0] = vecFwd[0] + x * SPREAD * vecRight[0] + y * SPREAD * vecUp[0];
	vecDir[1] = vecFwd[1] + x * SPREAD * vecRight[1] + y * SPREAD * vecUp[1];
	vecDir[2] = vecFwd[2] + x * SPREAD * vecRight[2] + y * SPREAD * vecUp[2];
	
	GetVectorAngles(vecDir, angles);
	
	TR_TraceRayFilter(startPos, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilter, client);
	TR_GetEndPosition(endPos);
	TR_GetPlaneNormal(null, traceNormal);
	int entityHit = TR_GetEntityIndex();

	//TE Setup:
	TE_SetupDynamicLight(startPos, 255, 100, 10, 8, 25.0, 0.2, 50.0);

	//Send:
	TE_SendToAll();

	//Temp Ent:
	TE_SetupEnergySplash(endPos, angles, true);

	//Show To Client:
	TE_SendToAll();

	//TE Setup:
	TE_SetupDynamicLight(endPos, 255, 100, 10, 8, 25.0, 0.2, 50.0);

	//Send:
	TE_SendToAll();

	physExplosion(endPos, 20.0, true);
	
	if(entityHit == 0) { // hit world
		
		DrawBeam( startPos, endPos, 1.6, weapon);

		TE_SetupGaussExplosion(endPos, 0, traceNormal);
		TE_SendToAll();
		
		CG_RadiusDamage(client, client, GAUSS_DAMAGE_PERBULLET, DMG_SHOCK, weapon, endPos, 30.0, client);
		UTIL_ImpactTrace(startPos, DMG_SHOCK, "ImpactGauss");
		
		float hitAngle = -GetVectorDotProduct(traceNormal, vecDir);
		if ( hitAngle < 0.5 )
		{
			float vReflection[3];
			vReflection[0] = 2.0 * traceNormal[0] * hitAngle + vecDir[0];
			vReflection[1] = 2.0 * traceNormal[1] * hitAngle + vecDir[1];
			vReflection[2] = 2.0 * traceNormal[2] * hitAngle + vecDir[2];
			GetVectorAngles(vReflection, angles);
			
			startPos = endPos;
			
			TR_TraceRayFilter(startPos, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilter, client);
			TR_GetEndPosition(endPos);
			entityHit = TR_GetEntityIndex();
			
			//Temp Ent:
			TE_SetupEnergySplash(startPos, angles, true);

			//Show To Client:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupEnergySplash(endPos, angles, true);

			//Send:
			TE_SendToAll();

			//TE Setup:
			TE_SetupDynamicLight(endPos, 255, 100, 10, 8, 25.0, 0.2, 50.0);

			//Show To Client:
			TE_SendToAll();

			if (entityHit > 0)
			{
 				if(IsPlayer(entityHit))
				{
					if(!teamplay || GetClientTeam(entityHit) != GetClientTeam(client))
					{
						float dmgForce[3];
						NormalizeVector(vReflection, dmgForce);
						ScaleVector(dmgForce, PLAYER_HIT_FORCE);
						SDKHooks_TakeDamage(entityHit, client, client, GAUSS_DAMAGE_PERBULLET, DMG_SHOCK, weapon, dmgForce, endPos);
					}
				}
				else
				{
					CG_RadiusDamage(client, client, GAUSS_DAMAGE_PERBULLET, DMG_SHOCK, weapon, endPos, 20.0, client);
				}
			}
			DrawBeam(startPos, endPos, 0.4);
		}
	}
	else if (entityHit != -1)
	{
		if(IsPlayer(entityHit))
		{
			if(!teamplay || GetClientTeam(entityHit) != GetClientTeam(client))
			{
				float dmgForce[3];
				NormalizeVector(vecDir, dmgForce);
				ScaleVector(dmgForce, PLAYER_HIT_FORCE);
				SDKHooks_TakeDamage(entityHit, client, client, GAUSS_DAMAGE_PERBULLET, DMG_SHOCK, weapon, dmgForce, endPos);
			}
		}
		else 
		{
			CG_RadiusDamage(client, client, GAUSS_DAMAGE_PERBULLET, DMG_SHOCK, weapon, endPos, 30.0, client);
		}
		
		DrawBeam(startPos, endPos, 1.6, weapon);
		
		TE_SetupGaussExplosion(endPos, 0, traceNormal);
		TE_SendToAll();

		UTIL_ImpactTrace(startPos, DMG_SHOCK, "ImpactGauss");
	}

	float viewPunch[3];
	viewPunch[0] = GetRandomFloat( -0.5, -0.2 );
	viewPunch[1] = GetRandomFloat( -0.5,  0.5 );
	Tools_ViewPunch(client, viewPunch);
	m_flChargeStartTime[client] = 0.0;

	// Register a muzzleflash for the AI
	SetEntPropFloat(client, Prop_Data, "m_flFlashTime", GetGameTime() + 0.5);
}

void ChargedFire(int client, int weapon, int Amount)
{

	//Stop Charge Sound
	StopChargeSound(client, weapon);

	//bool penetrated = false;
	EmitGameSoundToAll("Weapon_Gauss.Single", weapon);
	
	//CG_SetPlayerAnimation(client, PLAYER_ATTACK1);
	CG_PlayActivity(weapon, ACT_VM_SECONDARYATTACK);

	m_bCharging[client] = false;
	GaussAmmoConsumed[client] = 0;
	m_flChargeStartTime[client] = 0.0;

	float curtime = GetGameTime();
	CG_SetNextPrimaryAttack(weapon, curtime + COOLDOWN_PRIMARY);
	CG_SetNextSecondaryAttack(weapon, curtime + COOLDOWN_SECONDARY);

	//Shoot a shot straight out
	float angles[3], startPos[3], endPos[3], traceNormal[3], vecFwd[3];
	CG_GetShootPosition(client, startPos);
	GetClientEyeAngles(client, angles);
	GetAngleVectors(angles, vecFwd, NULL_VECTOR, NULL_VECTOR);
	
	TR_TraceRayFilter(startPos, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilter, client);
	TR_GetEndPosition(endPos);
	TR_GetPlaneNormal(null, traceNormal);
	
	//Find how much damage to do
	float flChargeAmount = ( curtime - m_flChargeStartTime[client] ) / MAX_GAUSS_CHARGE_TIME;

	//Clamp this
	if ( flChargeAmount > 1.0 ){
		flChargeAmount = 1.0;
	}

	UTIL_ImpactTrace(startPos, DMG_SHOCK, "ImpactGauss");
	
	float PuchMin = float((Amount / 2) - (Amount / 2) - (Amount / 2));
	if(PuchMin > -1.0) PuchMin = -1.0;
	if(PuchMin < -4.0) PuchMin = -4.0;
	float PuchMax = float(Amount - Amount - Amount)
	if(PuchMin > -1.0) PuchMin = -1.5;
	if(PuchMin < -8.0) PuchMin = -8.0;
	float viewPunch[3];
	viewPunch[0] = GetRandomFloat( PuchMin, PuchMax );
	viewPunch[1] = GetRandomFloat( -0.25,  0.25 );
	Tools_ViewPunch(client, viewPunch);

	if(Amount == 1)
		DrawBeam(startPos, endPos, 1.6, weapon);
	else
		DrawBeam(startPos, endPos, float(Amount), weapon);
	
	//Recoil push
	float scale = float(Amount) / 3.5;
	ScaleVector(vecFwd, -(float(Amount) * GAUSS_CHARGE_DAMAGE_PERBULLET * scale));
	vecFwd[2] += 30.0 * scale;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecFwd);

	TE_SetupGaussExplosion(endPos, 0, traceNormal);
	TE_SendToAll();

	CG_RadiusDamage(client, client, (Amount * GAUSS_CHARGE_DAMAGE_PERBULLET), DMG_SHOCK, weapon, endPos, 200.0, client);

	// Register a muzzleflash for the AI
	SetEntPropFloat(client, Prop_Data, "m_flFlashTime", curtime + 0.5);

	//TE Setup:
	TE_SetupDynamicLight(endPos, 255, 100, 10, 8, 25.0, 0.2, 50.0);

	//Send:
	TE_SendToAll();
	
	//Temp Ent:
	TE_SetupEnergySplash(endPos, angles, true);

	//Send:
	TE_SendToAll();
}

void StopChargeSound(int client, int weapon)
{
	if(m_bCharging[client]){
		//int channel; int soundLevel; float volume; int oldpitch; char sample[PLATFORM_MAX_PATH];
		//GetGameSoundParams("Weapon_Gauss.ChargeLoop", channel, soundLevel, volume, oldpitch, sample, sizeof(sample));
		//EmitSoundToAll(sample, weapon, SNDCHAN_WEAPON, SNDLEVEL_GUNFIRE, SND_CHANGEVOL, 0.01, 5);
		StopSound(weapon, SNDCHAN_WEAPON, "weapons/gauss/chargeloop.wav");
		//Print:
		PrintToServer("stopsound");
	}
}

public bool TraceEntityFilter(int entity, int mask, any data){
	if (entity == data)
		return false;
	return true;
}

void TE_SetupGaussExplosion(const float vecOrigin[3], int type, float direction[3]){	
 	TE_Start("GaussExplosion");
	TE_WriteFloat("m_vecOrigin[0]", vecOrigin[0]);
	TE_WriteFloat("m_vecOrigin[1]", vecOrigin[1]);
	TE_WriteFloat("m_vecOrigin[2]", vecOrigin[2]);
	TE_WriteNum("m_nType", type);
	TE_WriteVector("m_vecDirection", direction);
}

void DrawBeam(const float[3] startPos, const float[3] endPos, float width, int startEntity = -1){
	//UTIL_Tracer( startPos, endPos, 0, TRACER_DONT_USE_ATTACHMENT, 6500.0, false, "GaussTracer" );
	int beam = CreateEntityByName("beam");
	if(beam != -1){

		if(startEntity != -1){
			Beam_PointEntInit(beam, endPos, startEntity);
			SetEntPropFloat(beam, Prop_Data, "m_fWidth", width / 4.0);
			SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", width);
		} else {
			Beam_PointPointInit(beam, startPos, endPos);
			SetEntPropFloat(beam, Prop_Data, "m_fWidth", width);
			SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", width / 4.0);
		}
		
		SetEntityRenderColor(beam, 255, 145 +GetRandomInt(-16, 16), 0, 255);
		DispatchKeyValue(beam, "model", GAUSS_BEAM_SPRITE);
		SetEntProp(beam, Prop_Data, "m_nModelIndex", sprite);
			
		SetVariantString("OnUser1 !self:kill::0.1:-1")
		AcceptEntityInput(beam, "addoutput");
		AcceptEntityInput(beam, "FireUser1");
		
		DispatchSpawn(beam);
		ActivateEntity(beam);
	}
	
	//Draw electric bolts along shaft
	for ( int i = 0; i < 3; i++ )
	{
		beam = CreateEntityByName("beam");
		if(beam != -1){
			if(startEntity != -1){
				Beam_PointEntInit(beam, endPos, startEntity);
			} else {
				Beam_PointPointInit(beam, startPos, endPos);
			}
			
			SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", 1.6 * i);
			
			SetEntPropFloat(beam, Prop_Data, "m_fWidth", width/2.0 + i);
			SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", 0.1);
			
			SetEntityRenderColor(beam, 255, 255, 150 + GetRandomInt(0, 64));
			DispatchKeyValue(beam, "model", GAUSS_BEAM_SPRITE);
			SetEntProp(beam, Prop_Data, "m_nModelIndex", sprite);
				
			SetVariantString("OnUser1 !self:kill::0.1:-1")
			AcceptEntityInput(beam, "addoutput");
			AcceptEntityInput(beam, "FireUser1");
			
			DispatchSpawn(beam);
			ActivateEntity(beam);
		}
	}
}

//
// CBeam stuff
//
//

enum 
{
	BEAM_POINTS = 0,
	BEAM_ENTPOINT,
	BEAM_ENTS,
	BEAM_HOSE,
	BEAM_SPLINE,
	BEAM_LASER,
	NUM_BEAM_TYPES
};

void Beam_PointEntInit(int beam, const float start[3], int endEntity){
	SetEntProp(beam, Prop_Send, "m_nBeamType", BEAM_ENTPOINT);
	SetEntProp(beam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntPropVector(beam, Prop_Send, "m_vecOrigin", start);
	
	//SetEndEntity
	int offset = FindDataMapInfo(beam, "m_hAttachEntity");
	SetEntDataEnt2(beam, offset+4, endEntity);
	
	SetEntPropEnt(beam, Prop_Data, "m_hEndEntity", endEntity);
	
	//SetEndAttachment
	offset = FindDataMapInfo(beam, "m_nAttachIndex");
	SetEntData(beam, offset+4, 1);
} 

void Beam_PointPointInit(int beam, const float start[3], const float end[3]){
	SetEntProp(beam, Prop_Send, "m_nBeamType", BEAM_POINTS);
	SetEntProp(beam, Prop_Send, "m_nNumBeamEnts", 2);
	TeleportEntity(beam, start, NULL_VECTOR, NULL_VECTOR);
	SetEntPropVector(beam, Prop_Send, "m_vecEndPos", end);
}/**
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
