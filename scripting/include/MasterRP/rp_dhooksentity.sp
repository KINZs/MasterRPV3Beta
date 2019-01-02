//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dhooksentity_included_
  #endinput
#endif
#define _rp_dhookesntity_included_

public void OnVendorHardWareStoreHook(int Entity)
{

	//Client Hooking:
 	DHookEntity(hPreTouch, false, Entity);
}

// void Unknown...
public void OnEntityCreated(int Entity, const char[] ClassName)
{
#if defined HL2DM
	//Is Valid:
	if(StrContains(ClassName, "grenade") != -1 && !StrEqual(ClassName, "grenade_ar2"))
	{

		//Client Hooking:
 		DHookEntity(hPreStartTouch, false, Entity);

		//Client Hooking:
 		DHookEntity(hPreTouch, false, Entity);

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}

	//Is Valid
	if(StrContains(ClassName, "prop_combine_ball") != -1)
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}

	//Is Valid
	if(StrContains(ClassName, "crossbow_bolt") != -1)
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}

	//Is Valid:
	if(StrEqual(ClassName, "npc_Manhack") || StrEqual(ClassName, "npc_clawscanner"))
	{

		//Declare:
		int Flags = GetEntProp(Entity, Prop_Data, "m_iEFlags");

		//Send:
		SetEntProp(Entity, Prop_Data, "m_iEFlags", Flags|EFL_NO_PHYSCANNON_INTERACTION);
	}

	//Hooks:
	DHookEntity(hPreAcceptInput, false, 0);

	//Is Valid:
	if(StrEqual(ClassName, "env_explosion"))
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}
#endif
	//Is Valid
	if(StrContains(ClassName, "prop_ragdoll") != -1)
	{

		//SQL Load:
		CreateTimer(5.00, RemoveRagdoll, Entity);
	}

	//Is Valid
	if(StrContains(ClassName, "gib") != -1)
	{

		//SQL Load:
		CreateTimer(5.00, RemoveGibs, Entity);
	}

	//Is Valid:
	if(StrContains(ClassName, "prop_physics") != -1)
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}

	//Is Valid:
	if(StrEqual(ClassName, "npc_tripmine"))
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}

	//Is Valid:
	if(StrEqual(ClassName, "npc_satchel"))
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}
}

// void Unknown...
// remove players from Vehicles before they are destroyed or the server will crash!
public void OnEntityDeleted(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Remove Crate:
		OnCrateDestroyed(Entity);

		//Remove Bomb:
		OnBombDestroyed(Entity);

		//Remove Fire:
		OnFireDestroyed(Entity);

		//Remove Anomaly:
		OnAnomalyDestroyed(Entity);
#if defined HL2DM
		//Remove Lockdown NPCS!
		OnLockdownNPCDestroyedCheck(Entity);

		//Remove Weapon:
		OnWeaponsMapCheckDestroyed(Entity);

		//Remove Police Boss:
		OnPoliceBossNPCDestroyedCheck(Entity);

		//Remove AntLion Boss:
		OnAntLionBossNPCDestroyedCheck(Entity);

		//Remove AntLion NPCS:
		OnAntLionNPCDestroyedCheck(Entity);
#endif
		//Remove IronCannon:
		OnIonCannonDestroyed(Entity);

		//Remove SuitCase:
		OnSuitCaseDestroyed(Entity);

		//Declare:
		char ClassName[30];

		//Initulize:
		GetEdictClassname(Entity, ClassName, sizeof(ClassName));

		//Is Vehicle:
		if(StrContains(ClassName, "prop_vehicle", false) == 0 && !StrEqual(ClassName, "prop_vehicle_damaged"))
		{

			//Loop:
			for(int Client = 1; Client < GetMaxClients(); Client++)
			{

				//Connected:
				if(IsClientConnected(Client) && IsClientInGame(Client))
				{

					//Is Vehicle:
					if(GetPlayerVehicle(Client) == Entity)
					{

						//Initulize:
						SetPlayerVehicle(Client, -1);
					}
				}
			}

			//Declare:
			int Driver = GetEntPropEnt(Entity, Prop_Send, "m_hPlayer");

			//Has Driver:
			if(Driver != -1)
			{

				//Exit Car:
				ExitVehicle(Driver, Entity, true);
			}

			//Initulize:
			CheckOnCopCarDestroyed(Entity);
			CheckOnPrisonPodDestroyed(Entity);
		}
#if defined HL2DM
		//Is Valid
		if(StrEqual(ClassName, "crossbow_bolt"))
		{

			//Declare:
			float Origin[3];
			float Angles[3];

			//Initialize:
			GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Origin);

			GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angles);

			//Temp Ent:
			TE_SetupSparks(Origin, Angles, 5, 5);

			//Send:
			TE_SendToAll();

			//TE Setup:
			TE_SetupDynamicLight(Origin , 255, 100, 10, 8, 25.0, 0.2, 50.0);

			//Send:
			TE_SendToAll();
		}

		//Is Valid
		if(StrEqual(ClassName, "npc_grenade_frag") || StrEqual(ClassName, "grenade_ar2") || StrEqual(ClassName, "npc_contactgrenade") || StrEqual(ClassName, "npc_concussiongrenade"))
		{

			//Fake Env_Exposion:
			OnEnvExplosionPostSpawn(Entity, INVALID_HANDLE);

			//PrintToServer("|RP| - Fake Env_Explosion %s", ClassName);
		}
#endif
		if(IsValidFindBomb(Entity))
		{

			//Check to see if we need to respawn bomb:
			OnFindBombDestroyed(Entity);
		}

		//Check:
		if(IsValidAttachedEffect(Entity))
		{

			//Remove:
			RemoveAttachedEffect(Entity);
		}

		//Check:
		if(GetDroppedMoneyValue(Entity) > 0)
		{

			//Initulize:
			SetDroppedMoneyValue(Entity, 0);
		}

		//Check:
		if(GetDroppedDrugValue(Entity) > 0)
		{

			//Initulize:
			SetDroppedDrugValue(Entity, 0);
		}

		//Check:
		if(GetDroppedMethValue(Entity) > 0)
		{

			//Initulize:
			SetDroppedMethValue(Entity, 0);
		}

		//Check:
		if(GetDroppedPillsValue(Entity) > 0)
		{

			//Initulize:
			SetDroppedPillsValue(Entity, 0);
		}

		//Check:
		if(GetDroppedCocainValue(Entity) > 0)
		{

			//Initulize:
			SetDroppedCocainValue(Entity, 0);
		}
	}
}
#if defined HL2DM
public MRESReturn OnGrenadePostSpawn(int Entity, Handle hParams)
{

	//Set Entity Model:
	SetEntityModel(Entity, "models/props_c17/doll01.mdl");

	//GetOwner
	int Client = GetEntPropEnt(Entity, Prop_Data, "m_hOwnerEntity");

	if(Client < 1 || Client >= GetMaxClients())
	{

		//GetThrower
		Client = GetEntPropEnt(Entity, Prop_Data, "m_hThrower");

		if(Client < 1 || Client >= GetMaxClients())
		{

			//Return:
			return MRES_Ignored;
		}
	}

	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		int Effect = -1;

		//Check:
		if(IsCop(Client))
		{

			//Added Effect:
			Effect = CreateLight(Entity, 1, 120, 120, 255, "null");
		}

		//Check:
		else if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Added Effect:
			Effect = CreateLight(Entity, 1, 255, 255, 120, "null");
		}

		//Override:
		else
		{

			//Added Effect:
			Effect = CreateLight(Entity, 1, 255, 120, 120, "null");
		}

		//Initulize:
		SetEntAttatchedEffect(Entity, 0, Effect);
	}

	//Print:
	//PrintToServer("|RP| - attached Light to Grenade!");

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPropCombineBallPostSpawn(int Entity, Handle hParams)
{

	//Added Effect:
	int Effect = CreateLight(Entity, 1, 120, 120, 255, "null");

	SetEntAttatchedEffect(Entity, 0, Effect);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPropCrossbowBoltPostSpawn(int Entity, Handle hParams)
{

	//Declare:

	int Client = GetEntPropEnt(Entity, Prop_Send, "m_hOwnerEntity");


	//Declare:
	//char WeaponName[32];

	if(Client > 0)
	{

		int Weapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

		if(Weapon > 0)
		{

			//Get Entity Info:
			//GetEntityClassname(Weapon, WeaponName, sizeof(WeaponName));
		}

		//Print:
		//PrintToServer("|RP| - Client %i, Weapon %i!", Client, Weapon);
	}

	//Check: needs to be -1 as hEntityOwner is set after entity has post spawned!
	if(Client == -1)
	{

		//Added Effect:
		int Effect = CreateFireSmoke(Entity, "null", "200", "700", "0", "Natural");
		//int Effect = CreateInfoParticleSystemOther(Entity, "null", "env_fire_small_coverage_smoke", 0.0, Offset, Angles);

		SetEntAttatchedEffect(Entity, 0, Effect);

		//Print:
		PrintToServer("|RP| - attached firesmoke to Crossbow Bolt!");
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPropPostSpawn(int Entity, Handle hParams)
{

	//Declare:
	char ClassName[30];

	//Initulize:
	GetEdictClassname(Entity, ClassName, sizeof(ClassName));

	//Is Valid:
	if(StrContains(ClassName, "prop_physics") != -1)
	{

		//Declare:
		char ModelName[128];

		//Initialize:
		GetEntPropString(Entity, Prop_Data, "m_ModelName", ModelName, 128);

		//Is Valid:
		if(StrContains(ModelName, "gib", false) != -1)
		{

			//Is Garbage Can:
			if(StrContains(ModelName, "metal", false) != -1)
			{
			}

			//Override:
			else
			{

				//SQL Load:
				CreateTimer(5.00, RemoveGibs, Entity);
			}
		}
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnEnvExplosionPostSpawn(int Entity, Handle hParams)
{

	//Check: to prevent console errors!
	if(!IsMapRunning())
	{

		//Return:
		return MRES_Ignored;
	}

	//Declare:
	float Angles[3];
	float Offset[3] = {0.0, 0.0, 2.0};

	//Get Prop Data:
	GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angles);

	//Create Fire Effect!
	int Effect = CreateInfoParticleSystemOther(Entity, "null", "Fire_Large_01", 0.2, Offset, Angles);


	//Accept:

	AcceptEntityInput(Effect, "ClearParent", Entity);

	Effect = CreateInfoParticleSystemOther(Entity, "null", "striderbuster_break_flechette", 0.2, Offset, Angles);

	//Accept:

	AcceptEntityInput(Effect, "ClearParent", Entity);

	//Initulize:
	GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Offset);

	//TE Setup:
	TE_SetupDynamicLight(Offset, 255, 100, 10, 8, 150.0, 0.4, 50.0);

	//Send:
	TE_SendToAll();

	//Print:
	//PrintToServer("|RP| - attached Effects to Env_Explosion!");

	//Return:
	return MRES_Ignored;
}

#endif
//Spawn Timer:
public Action RemoveRagdoll(Handle Timer, any Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > GetMaxClients())
	{

		//Dessolve:
		EntityDissolve(Ent, 1);
	}
}

//Spawn Timer:
public Action RemoveGibs(Handle Timer, any Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > GetMaxClients())
	{

		//Kill:
		AcceptEntityInput(Ent, "kill");
	}
}

public MRESReturn OnEntityOnTakeDamage(int Entity, Handle hParams, Handle hReturn, int &Attacker, int &Inflictor, int &Weapon, float &Damage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnTripMinePostSpawn(int Entity, Handle hParams)
{

	//Declare:
	int TripMines = GetTripMinesOnMap();

	if(TripMines > 20)
	{

		//Clean up tripmines!
		ExplodeTripMinesOnMap();
	}

	//Print:
	//PrintToServer("|RP| - TripMines = %i", TripMines);

	//Return:
	return MRES_Ignored;
}

public int GetTripMinesOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_satchel")) != -1)
	{

		//Initulize:
		Amount += 1;
	}

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_tripmine")) != -1)
	{


		//Initulize:
		Amount += 1;
	}

	//Return:
	return view_as<int>(Amount);
}

public int ExplodeTripMinesOnMap()
{

	//Declare:
	int Props = -1;
	int Amount = 0;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_satchel")) != -1)
	{

		//Accept:
		AcceptEntityInput(Props, "explode");
	}

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_tripmine")) != -1)
	{

		//Accept:
		AcceptEntityInput(Props, "explode");
	}

	//Return:
	return view_as<int>(Amount);
}
