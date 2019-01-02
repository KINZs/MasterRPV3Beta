//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcmetropolice_included_
  #endinput
#endif
#define _rp_npcmetropolice_included_
#if defined HL2DM
public void initNpcMetroPolice()
{

	//NPC Beta:
	RegAdminCmd("sm_testmetropolice", Command_CreateNpcMetroPolice, ADMFLAG_ROOT, "<No Arg>");
}

//Event Damage:
public Action OnMetroPoliceDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(25.0, 35.0);

	damageType = DMG_DISSOLVE;
}

//Event Damage:
public Action OnClientDamageMetroPolice(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Declare:
	char Classname[64];

	//Initialize:
	GetEdictClassname(Client, Classname, sizeof(Classname));

	if(!StrEqual(Classname, "npc_antlionguard"))
	{

		//Initulize:
		damageType = DMG_DISSOLVE;
	}

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public void OnMetroPoliceDied(const char[] Output, int Caller, int Activator, float Delay)
{

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

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);

	SetNpcsOnMap((GetNpcsOnMap() - 1));
}

//Create NPC:
public Action Command_CreateNpcMetroPolice(int Client, int Args)
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
	//GetCollisionPoint(Client, Position);
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

	CreateNpcMetroPolice("models/police_cheaple.mdl", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcMetroPolice(const char[] Model, float Position[3], float Angles[3], int Health)
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
	int NPC = CreateEntityByName("npc_MetroPolice");

	//Is Valid:
	if(NPC > 0)
	{

		DispatchKeyValue(NPC, "ClassName", "npc_MetroPolice");

		DispatchKeyValue(NPC, "additionalequipment", "weapon_stunstick");

		//DispatchKeyValue(NPC, "additionalequipment", "weapon_pistol");

		DispatchKeyValue(NPC, "EnableManhackToss", "1");

		//Spawn & Send:
		DispatchSpawn(NPC);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Accept:
		AcceptEntityInput(NPC, "EnableManhackToss");

		//Accept:
		AcceptEntityInput(NPC, "ActivateBaton");

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Set Relationship Status To Players:
		SetNPCRelationShipStatus(NPC, false, true, false);

		SetHateAntLionRelationshipStatus(NPC);

		SetLikeCombineRelationshipStatus(NPC);

		SetHateZombieRelationshipStatus(NPC);

		SetHateVortigauntRelationshipStatus(NPC);

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageMetroPolice);

		//Think Hook:
		//SDKHook(NPC, SDKHook_ThinkPost, OnMetroPolicePostThink);

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnMetroPoliceDied, true);

		//Initulize:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}

public void OnMetroPolicePostThink(int Entity)
{
/*
	//Declare:
	float Origin[3];
	float ClientOrigin[3];

	//Initulize:
	GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Origin);

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
			if(Dist <= 600 && IsTargetInLineOfSight(Entity, i))
			{

				SetEntProp(Entity, Prop_Send, "m_nSequence", 80);

				//Declare:
				float Push[3];

				//Initulize:
				GetPushBetweenEntities(Entity, 250.0, Push);

				//Teleport:
				TeleportEntity(Entity, NULL_VECTOR, NULL_VECTOR, Push);
			}
		}
	}
*/
}

#endif