//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcadvisor_included_
  #endinput
#endif
#define _rp_npcAdvisor_included_
#if defined HL2DM
public void initNpcAdvisor()
{

	//NPC Beta:
	RegAdminCmd("sm_testadvisor", Command_CreateNpcAdvisor, ADMFLAG_ROOT, "<No Arg>");
}

//Event Damage:
public Action OnAdvisorDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(25.0, 35.0);

	damageType = DMG_DISSOLVE;
}

//Event Damage:
public Action OnClientDamageAdvisor(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Initulize:
	damageType = DMG_DISSOLVE;

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public void OnAdvisorDied(const char[] Output, int Caller, int Activator, float Delay)
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

	//Check:
	if(IsValidPoliceBoss(Caller))
	{

		//Forward To rp_policeboss.sp
		OnAdvisorBossDied(Caller, Activator);
	}

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);

	SetNpcsOnMap((GetNpcsOnMap() - 1));
}

//Create NPC:
public Action Command_CreateNpcAdvisor(int Client, int Args)
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

	Position[2] + 100;

	//Create:
	CreateNpcAdvisor("models/advisor_ragdoll.mdl", Position, Angles, 2000);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcAdvisor(const char[] Model, float Position[3], float Angles[3], int Health)
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Check:
	if(!IsModelPrecached(Model))
	{

		//PreCache:
		PrecacheModel(Model);
	}

	//Initialize:
	int  NPC = CreateEntityByName("npc_clawscanner");

	//Is Valid:
	if(NPC > 0)
	{

		DispatchKeyValue(NPC, "name", "npc_Advisor");

		//Spawn & Send:
		DispatchSpawn(NPC);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Set Relationship Status To Players:
		SetNPCRelationShipStatus(NPC, false, true, false);

		SetLikeAntLionRelationshipStatus(NPC);

		SetHateCombineRelationshipStatus(NPC);

		SetHateZombieRelationshipStatus(NPC);

		SetHateVortigauntRelationshipStatus(NPC);

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		DispatchKeyValue(NPC, "classname", "npc_Advisor");


		DispatchKeyValue(NPC, "OnFoundPlayer", "!caller,equipmine,,0,-1");


		DispatchKeyValue(NPC, "OnFoundPlayer", "!caller,deploymine,,5,-1");

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageAdvisor);

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnAdvisorDied, true);

		//Initulize:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
#endif