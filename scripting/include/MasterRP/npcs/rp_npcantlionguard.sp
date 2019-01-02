//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcantlionguard_included_
  #endinput
#endif
#define _rp_npcantlionguard_included_
#if defined HL2DM
//Eplode Sound:
char AntLionShieldSound[255] = "ambient/levels/labs/electric_explosion5.wav";

public void initNpcAntLionGuard()
{

	//NPC Beta:
	RegAdminCmd("sm_testantlionguard", Command_CreateNpcAntLionGuard, ADMFLAG_ROOT, "<No Arg>");

	//Precache:
	PrecacheSound(AntLionShieldSound);
}

//Event Damage:
public Action OnAntLionGuardDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(IsValidAntLionBossNPC(attacker))
	{

		//Initialize:
		damage = GetRandomFloat(75.0, 200.0);

		damageType = DMG_DISSOLVE;
	}
}

//Event Damage:
public Action OnDamageAntLionGuard(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Initialize:
	damageType = DMG_DISSOLVE;

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public void OnAntLionGuardDied(const char[] Output, int Caller, int Activator, float Delay)
{

	//Is Valid:
	if(Activator > 0 && Activator <= GetMaxClients())
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(i > 0 && IsClientConnected(i) && IsClientInGame(i) && i != Activator)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has took out the Antlion Guard!", Activator);
			}
		}
	}

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(i > 0 && IsClientConnected(i) && IsClientInGame(i))
		{

			//Declare:
			int Amount = RoundFloat(GetDamage(i) * 5);

			//Check:
			if(Amount > 0)
			{

				//DamageCheck
				if(Amount > 10000) Amount = GetRandomInt(9500, 15000);

				//Initulize:
				SetBank(i, (GetBank(i) + Amount));

				//Bank State:
				BankState(i, Amount);

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - You have been rewarded %s!", IntToMoney(Amount));

				//Initulize:
				SetDamage(i, 0.0);
			}
		}
	}

	//Check:
	if(IsValidAttachedEffect(Caller))
	{

		//Remove:
		RemoveAttachedEffect(Caller);
	}

	//Check:
	if(IsValidLight(Caller))
	{

		//Remove Light:
		RemoveLight(Caller);
	}

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);

	SetNpcsOnMap((GetNpcsOnMap() - 1));

	//Print:
	//PrintToServer("|RP| - OnDeath Antlion Guard");
}

//Create NPC:
public Action Command_CreateNpcAntLionGuard(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3]; 
	float Angles[3] = {0.0,...};

	//Initulize:
	GetCollisionPoint(Client, Position);

	CreateNpcAntLionGuard("null", Position, Angles, 10000, 1);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcAntLionGuard(const char[] Model, float Position[3], float Angles[3], int Health, int Custom)
{

	//Check:
	if(!IsModelPrecached(Model))
	{

		//PreCache:
		PrecacheModel(Model);
	}

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	int NPC = CreateEntityByName("npc_AntlionGuard");

	//Is Valid:
	if(NPC > 0)
	{

		//Dispatch
		DispatchKeyValue(NPC, "spawnflags", "512");
		//DispatchKeyValue(NPC, "cavern breed", "1");

		DispatchKeyValue(NPC, "ClassName", "npc_AntlionGuard");

		//Spawn & Send:
		DispatchSpawn(NPC);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		SetEntProp(NPC, Prop_Data, "m_iMaxHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnDamageAntLionGuard);

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnAntLionGuardDied, true);

		//Initulizse:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Check:
		if(Custom == 1)
		{

			//Initulize Effects:
			int Effect = CreatePointTesla(NPC, "0", "51 120 255");

			SetEntAttatchedEffect(NPC, 0, Effect);

			Effect = CreatePointTesla(NPC, "1", "51 120 255");

			SetEntAttatchedEffect(NPC, 1, Effect);

			//Set Ent Color:
			SetEntityRenderColor(NPC, 51, 120, 255, 255);

			//Initulize:
			SetIsCritical(NPC, true);

			//Initulize:
			SetEntitySpecialEffects(NPC, CreateTimer(0.5, InitCritical, NPC, TIMER_REPEAT));

			//Added Effect:
			Effect = CreateLight(NPC, 1, 51, 120, 255, "0");

			SetEntAttatchedEffect(NPC, 2, Effect);

			//Added Effect:
			Effect = CreateLight(NPC, 1, 51, 120, 255, "1");

			SetEntAttatchedEffect(NPC, 3, Effect);

			//Initulize:
			Effect = CreateEnvSmokeTrail(NPC, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "150", "50", "50", "100", "0", "50 50 255", "5");

			SetEntAttatchedEffect(NPC, 4, Effect);
		}

		//Set Relationship Status To Players:
		SetNPCRelationShipStatus(NPC, false, false, false);

		SetLikeAntLionRelationshipStatus(NPC);

		SetHateCombineRelationshipStatus(NPC);

		SetHateZombieRelationshipStatus(NPC);

		SetHateVortigauntRelationshipStatus(NPC);

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}

public Action InitCritical(Handle Timer, any Ent)
{

	//Check & Is Alive::
	if(!IsValidEdict(Ent) || (GetEntHealth(Ent) <= 0))
	{

		//Kill:
		KillTimer(GetEntitySpecialEffects(Ent));

		//Initulize:
		SetEntitySpecialEffects(Ent, INVALID_HANDLE);
	}

	//Override:
	else
	{

		//Declare:
		int TempEnt = GetEntAttatchedEffect(Ent, 0);

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(TempEnt, ClassName, sizeof(ClassName));

		//Is Valid NPC:
		if(StrEqual(ClassName, "point_tesla"))
		{

			//Accept:
			AcceptEntityInput(TempEnt, "TurnOn");

			AcceptEntityInput(TempEnt, "DoSpark");

			//Timer:
			CreateTimer(0.25, DelayEffect, Ent);
		}

		//Declare:
		float ClientOrigin[3];
		float Origin[3];
		float Damage = 0.0;

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, ClientOrigin);

				//In Distance:
				if(Dist <= 225 && IsTargetInLineOfSight(Ent, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					//Has Shield Near By:
					if(IsShieldInDistance(i))
					{

						//Shield Forward:
						OnClientShieldDamage(i, Damage);
					}

					//Check:
					else if(IsPlayerAlive(i))
					{

						//Check:
						if(GetClientHealth(i) - RoundFloat(Damage) <= 0)
						{

							//Damage Client:
							SDKHooks_TakeDamage(i, Ent, Ent, Damage, DMG_DISSOLVE);

							//Forward:
							OnClientDied(i, Ent, Ent, DMG_DISSOLVE);
						}

						//Override:
						else
						{

							//Damage Client:
							SDKHooks_TakeDamage(i, Ent, Ent, Damage, DMG_DISSOLVE & DMG_PREVENT_PHYSICS_FORCE);
						}
					}
				}
			}
		}

		//Declare:
		int Random = GetRandomInt(1, 50);

		//Check:
		if(Random == 1)
		{

			//Create Special Effect:
			CreateAntLionBomb(Ent, Origin);
		}
	}
}


public Action DelayEffect(Handle Timer, any Ent)
{

	//Declare:
	int TempEnt = GetEntAttatchedEffect(Ent, 1);

	//Check & Is Alive::
	if(IsValidEdict(TempEnt))
	{

		//Accept:
		AcceptEntityInput(TempEnt, "TurnOn");

		AcceptEntityInput(TempEnt, "DoSpark");
	}
}

public Action CreateAntLionBomb(int Ent, float Origin[3])
{

	//Initulize:
	Origin[2] += 30;

	//Temp Ent Setup:
	TE_SetupGlowSprite(Origin, GlowBlue(), 5.0, 10.0, 100);

	//Send To All Clients:
	TE_SendToAll();

	//TE Setup:
	TE_SetupDynamicLight(Origin, 10, 100, 255, 8, 350.0, 0.4, 50.0);

	//Send:
	TE_SendToAll();

	//Emit:
	EmitAmbientSound(AntLionShieldSound, Origin, Ent, SNDLEVEL_NORMAL);

	//Declare:
	int EntHealth = GetEntHealth(Ent);

	int MaxHealth = GetEntMaxHealth(Ent);

	//Check:
	if(GetEntHealth(Ent) != GetEntMaxHealth(Ent))
	{

		if(EntHealth + 100 < MaxHealth)
		{

			//Set Health:
			SetEntHealth(Ent, (EntHealth + 100));
		}

		//Override:
		else
		{

			//Set Health:
			SetEntHealth(Ent, GetEntMaxHealth(Ent));
		}
	}
}
#endif