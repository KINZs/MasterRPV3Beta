//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcantlion_included_
  #endinput
#endif
#define _rp_npcAntLion_included_
#if defined HL2DM
public void initNpcAntLion()
{

	//NPC Beta:
	RegAdminCmd("sm_testantlion", Command_CreateNpcAntLion, ADMFLAG_ROOT, "<No Arg>");
}

//Event Damage:
public Action OnAntLionDamageClient(int Entity, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(IsValidAntLionNPC(Entity))
	{

		//Initulize:
		damageType = DMG_DISSOLVE;

		//Initialize:
		damage = GetRandomFloat(25.0, 35.0);
	}
}

//Event Damage:
public Action OnClientDamageAntLion(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
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

	//Check:
	if(!StrEqual(Classname, "npc_antlionguard"))
	{

		//Initulize:
		damageType = DMG_DISSOLVE;

		//Return:
		return Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}

//Ant Lion Died Event:
public void OnAntLionDied(const char[] Output, int Caller, int Activator, float Delay)
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
public Action Command_CreateNpcAntLion(int Client, int Args)
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

	Position[2] + 20;

	CreateNpcAntLion("models/antlion.mdl", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcAntLion(const char[] Model, float Position[3], float Angles[3], int Health)
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
	int NPC = CreateEntityByName("npc_AntLion");

	//Is Valid:
	if(NPC > 0)
	{

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

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iMaxHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageAntLion);

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnAntLionDied, true);

		//Initulize:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

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
public MRESReturn OnAntLionGuardKilledPlayer(int Client, Handle hParams, int &Attacker, int &Inflictor, int &Weapon, float &Damage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{
/*
	//Death Notice:
	CreatePlayerDeathNotice(Client, Inflictor, "world", false, 2);
*/
	//Return:
	return MRES_Ignored;
}
#endif