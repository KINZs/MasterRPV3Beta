//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcheadcrabblack_included_
  #endinput
#endif
#define _rp_npcheadcrabblack_included_
#if defined HL2DM
public void initNpcHeadCrabBlack()
{

	//NPC Beta:
	RegAdminCmd("sm_testheadcrabblack", Command_CreateNpcHeadCrabBlack, ADMFLAG_ROOT, "<No Arg>");
}

//Event Damage:
public Action OnHeadCrabBlackDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(75.0, 135.0);

	damageType = DMG_POISON;
}

//Event Damage:
public Action OnClientDamageHeadCrabBlack(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
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
public void OnHeadCrabBlackDied(const char[] Output, int Caller, int Activator, float Delay)
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
public Action Command_CreateNpcHeadCrabBlack(int Client, int Args)
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

	CreateNpcHeadCrabBlack("null", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcHeadCrabBlack(const char[] Model, float Position[3], float Angles[3], int Health)
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
	int NPC = CreateEntityByName("npc_Headcrab_Black");

	//Is Valid:
	if(NPC > 0)
	{

		DispatchKeyValue(NPC, "ClassName", "npc_HeadcrabBlack");

		//Spawn & Send:
		DispatchSpawn(NPC);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Set Relationship Status To Players:
		SetNPCRelationShipStatus(NPC, false, false, false);

		SetHateAntLionRelationshipStatus(NPC);

		SetHateCombineRelationshipStatus(NPC);

		SetLikeZombieRelationshipStatus(NPC);

		SetHateVortigauntRelationshipStatus(NPC);

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageHeadCrabBlack);

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnHeadCrabBlackDied, true);

		//Initulize:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
#endif