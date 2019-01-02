//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcDog_included_
  #endinput
#endif
#define _rp_npcDog_included_
#if defined HL2DM
public void initNpcDog()
{

	//NPC Beta:
	RegAdminCmd("sm_testdog", Command_CreateNpcDog, ADMFLAG_ROOT, "<No Arg>");
}

//Event Damage:
public Action OnDogDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(10.0, 15.0);
}

//Event Damage:
public Action OnClientDamageDog(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public void OnDogDied(const char[] Output, int Caller, int Activator, float Delay)
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
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has took out Dog!", Activator);
			}
		}
	}

	//Loop:
	for(int  i = 1; i <= GetMaxClients(); i++)
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
}

//Create NPC:
public Action Command_CreateNpcDog(int Client, int Args)
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
	GetClientAbsOrigin(Client, Position);

	CreateNpcDog("npc_dog", "null", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcDog(const char[] sNpc, const char[] Model, float Position[3], float Angles[3], int Health)
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
	int NPC = CreateEntityByName(sNpc);

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

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnDogDied, true);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageDog);

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
#endif