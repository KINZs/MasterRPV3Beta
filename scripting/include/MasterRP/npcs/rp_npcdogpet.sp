//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcDogPet_included_
  #endinput
#endif
#define _rp_npcDogPet_included_
#if defined HL2DM
public void initNpcDogPet()
{

	//NPC Beta:
	RegAdminCmd("sm_testDogPet", Command_CreateNpcDogPet, ADMFLAG_ROOT, "<No Arg>");
}

//Event Damage:
public Action OnDogPetDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(10.0, 15.0);
}

//Event Damage:
public Action OnClientDamageDogPet(int Entity, int &Client, int &inflictor, float &damage, int &damageType)
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
public void OnDogPetDied(const char[] Output, int Caller, int Activator, float Delay)
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
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has took out DogPet!", Activator);
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
public Action Command_CreateNpcDogPet(int Client, int Args)
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
	//GetClientAbsOrigin(Client, Position);
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

	CreateNpcDogPet(Client, "npc_metropolice", "Models/dog.mdl", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcDogPet(int Client, const char[] sNpc, const char[] Model, float Position[3], float Angles[3], int Health)
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

		DispatchKeyValue(NPC, "ClassName", "npc_PetDog");

		DispatchKeyValue(NPC, "additionalequipment", "weapon_smg1");

		//Spawn & Send:
		DispatchSpawn(NPC);

		//Accept:
		AcceptEntityInput(NPC, "EnableManhackToss");

		//Accept:
		AcceptEntityInput(NPC, "ActivateBaton");

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}


		//Send:

		//SetEntPropFloat(NPC, Prop_Send, "m_flModelScale", 0.8);


		//Invincible:
		SetEntProp(NPC, Prop_Data, "m_takedamage", 0, 1);

		//Debris:
		int Collision = GetEntSendPropOffs(NPC, "m_CollisionGroup");

		//Send:
		SetEntData(NPC, Collision, 1, 1, true);

		//Declare:
		char ClientIndex[32];

		if(IsAdmin(Client))
		{

			//Format:
			Format(ClientIndex, sizeof(ClientIndex), "Admin%i D_HT", Client);
		}

		else if(IsCop(Client))
		{

			//Format:
			Format(ClientIndex, sizeof(ClientIndex), "Admin%i D_HT", Client);
		}

		else 
		{

			//Format:
			Format(ClientIndex, sizeof(ClientIndex), "Admin%i D_HT", Client);
		}


		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(NPC, "setrelationship");

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Death Hook:
		HookSingleEntityOutput(NPC, "OnDeath", OnDogPetDied, true);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageDogPet);

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
#endif