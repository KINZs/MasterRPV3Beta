//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jobsetup_included_
  #endinput
#endif
#define _rp_jobsetup_included_

//Roleplay Core:
char JobSetupPath[256];

//Misc:
char GlobalModel[MAXPLAYERS + 1][255];

public void initJobSetup()
{

	//Job Setup DB:
	BuildPath(Path_SM, JobSetupPath, 256, "data/roleplay/jobs_setup.txt");
	if(FileExists(JobSetupPath) == false) SetFailState("[SM] ERROR: Missing file '%s'", JobSetupPath);
}

public void SetupRoleplayJob(int Client)
{

	//Has Already been given Weapon:
	if(HasClientWeapon(Client, "weapon_physcannon", 0) == -1)
	{

		//Give Weapon:
		GiveClientWeapon(Client, "weapon_physcannon");
	}

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, JobSetupPath);

	//Declare:
	char Id[255];
	char JobId[32];
	char Buffer[255];
	int Health = 0;
	int Suit = 0;

	//Format:
	Format(JobId, sizeof(JobId), "%s", GetJob(Client));

	//Is Valid:
	if(StrEqual(GetJob(Client), "citizen", false))
	{

		//Random Medic Model:
		initRandomOther1Model(Client);
	}

	//Is Valid:
	if(StrEqual(GetJob(Client), "Brain Surgeon", false))
	{

		//Random Medic Model:
		initRandomMedicModel(Client);
	}

	//Is Valid:
	if(StrEqual(GetJob(Client), "Street Sweeper", false))
	{

		//Random Model:
		initRandomOtherModel(Client);
	}

	//Loop:
	for(int X = 0; X < 15; X++)
	{

		//Convert:
		IntToString(X, Id, 255);

		//Load:
		LoadString(Vault, JobId, Id, "null", Buffer);

		//Is Valid:
		if(!StrEqual(Buffer, "null", false))	
		{

			//Has Already been given Weapon:
			if(HasClientWeapon(Client, Buffer, 0) == -1)
			{

				//Close:
				CloseHandle(Vault);

				//Handle:
				Vault = CreateKeyValues("Vault");

				//Load:
				FileToKeyValues(Vault, GetWeaponModPath());

				//Get Value
				int IsCustomGuns = LoadInteger(Vault, Buffer, "CustomGuns", 0);

				//Close:
				CloseHandle(Vault);

				//Handle:
				Vault = CreateKeyValues("Vault");

				//Load:
				FileToKeyValues(Vault, JobSetupPath);

				//Check Is Custom Gun:
				if(IsCustomGuns == 1)
				{
#if defined HL2DM
					//Give Weapon:
					CG_GiveGun(Client, Buffer, true);
#endif
				}

				//Override:
				else
				{

					//Give Weapon:
					GiveClientWeapon(Client, Buffer);
				}
			}
		}
	}

	//Get Value
	Health = LoadInteger(Vault, JobId, "health", -1);

	//Valid Health:
	if(Health != -1)
	{

		//Set Prop:
		SetEntProp(Client, Prop_Data, "m_iHealth", Health);

		SetEntProp(Client, Prop_Data, "m_iMaxHealth", Health);
	}

	//Get Value
	Suit = LoadInteger(Vault, JobId, "suit", -1);

	//Valid Suit:
	if(Suit != -1)
	{

		//Set Armor:
		SetEntityArmor(Client, Suit);
	}

	//Is In Gang:
	if(!StrEqual(GetGang(Client), "null"))
	{

		//Declare:
		int GangLevel = GetGangLevel(Client, GetGang(Client));

		if(GangLevel >= 6)
		{

			//Has Client Got Same Weapon As Item:
			if(HasClientWeapon(Client, "weapon_crowbar", false) == -1)
			{

				//Give Weapon:
				GiveClientWeapon(Client, "weapon_crowbar");
			}
		}

		if(GangLevel >= 9)
		{

			//Has Client Got Same Weapon As Item:
			if(HasClientWeapon(Client, "weapon_pistol", false) == -1)
			{

				//Give Weapon:
				GiveClientWeapon(Client, "weapon_pistol");
			}

			//Declare:
			int ExtraHealth = GetEntProp(Client, Prop_Data, "m_iMaxHealth") + 10;

			//Set Prop:
			SetEntProp(Client, Prop_Data, "m_iHealth", ExtraHealth);

			SetEntProp(Client, Prop_Data, "m_iMaxHealth", ExtraHealth);
		}

		if(GangLevel >= 12)
		{

			//Has Client Got Same Weapon As Item:
			if(HasClientWeapon(Client, "weapon_shotgun", false) == -1)
			{

				//Give Weapon:
				GiveClientWeapon(Client, "weapon_shotgun");
			}

			//Declare:
			int ExtraHealth = GetEntProp(Client, Prop_Data, "m_iMaxHealth") + 10;

			//Set Prop:
			SetEntProp(Client, Prop_Data, "m_iHealth", ExtraHealth);

			SetEntProp(Client, Prop_Data, "m_iMaxHealth", ExtraHealth);
		}

		if(GangLevel >= 15)
		{

			//Has Client Got Same Weapon As Item:
			if(HasClientWeapon(Client, "weapon_357", false) == -1)
			{

				//Give Weapon:
				GiveClientWeapon(Client, "weapon_357");
			}

			//Declare:
			int ExtraHealth = GetEntProp(Client, Prop_Data, "m_iMaxHealth") + 10;

			//Set Prop:
			SetEntProp(Client, Prop_Data, "m_iHealth", ExtraHealth);

			SetEntProp(Client, Prop_Data, "m_iMaxHealth", ExtraHealth);
		}
	}

	//Load:
	LoadString(Vault, JobId, "Model", "null", Buffer);

	//Not Map:
	if(!StrEqual(Buffer, "null"))
	{

		//Set Model:
		SetModel(Client, Buffer);
	}
#if defined HL2DM
	if(IsCustomGunsLoaded())
	{
		//Give Weapon:
		CG_GiveGun(Client, "weapon_fists", true);
	}
#endif
	//Close:
	CloseHandle(Vault);
}

public void SetupMaxHealth(int Client)
{

	//Declare:
	char JobId[32];

	//Format:
	Format(JobId, sizeof(JobId), "%s", GetJob(Client));

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, JobSetupPath);

	//Get Value
	int Health = LoadInteger(Vault, JobId, "health", -1);

	//Valid Health:
	if(Health != -1)
	{

		//Set Prop:
		SetEntProp(Client, Prop_Data, "m_iMaxHealth", Health);
	}

	//Close:
	CloseHandle(Vault);
}

public void initRandomModel(int Client)
{

	//Declare:
	char Buffer[255];

	//Declare:
	int Random = GetRandomInt(1, 2);

	//Mail:
	if(Random == 1)
	{

		//Initulize:
		Random = GetRandomInt(1, 7);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group01/male_0%i.mdl", Random);
	}

	//Mail:
	if(Random == 2)
	{

		//Initulize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group01/female_0%i.mdl", Random);
	}

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Buffer);

	//Is PreCached:
	if(!IsModelPrecached(Buffer))
	{

		//PreCache:
		PrecacheModel(Buffer);
	}

	//Set Client Model:
	SetEntityModel(Client,  GlobalModel[Client]);
}

public void initRandomOtherModel(int Client)
{

	//Declare:
	char Buffer[255];

	//Declare:
	int Random = GetRandomInt(1, 2);

	//Mail:
	if(Random == 1)
	{

		//Initulize:
		Random = GetRandomInt(1, 7);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group02/male_0%i.mdl", Random);
	}

	//Mail:
	if(Random == 2)
	{

		//Initulize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group02/female_0%i.mdl", Random);
	}

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Buffer);

	//Is PreCached:
	if(!IsModelPrecached(Buffer))
	{

		//PreCache:
		PrecacheModel(Buffer);
	}

	//Set Client Model:
	SetEntityModel(Client,  GlobalModel[Client]);
}

public void initRandomOther1Model(int Client)
{

	//Declare:
	char Buffer[255];

	//Declare:
	int Random = GetRandomInt(1, 2);

	//Mail:
	if(Random == 1)
	{

		//Initulize:
		Random = GetRandomInt(1, 7);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group03/male_0%i.mdl", Random);
	}

	//Mail:
	if(Random == 2)
	{

		//Initulize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group03/female_0%i.mdl", Random);
	}

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Buffer);

	//Is PreCached:
	if(!IsModelPrecached(Buffer))
	{

		//PreCache:
		PrecacheModel(Buffer);
	}

	//Set Client Model:
	SetEntityModel(Client,  GlobalModel[Client]);
}


public void initRandomMedicModel(int Client)
{

	//Declare:
	char Buffer[255];

	//Declare:
	int Random = GetRandomInt(1, 2);

	//Mail:
	if(Random == 1)
	{

		//Initulize:
		Random = GetRandomInt(1, 7);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group03m/male_0%i.mdl", Random);
	}

	//Mail:
	if(Random == 2)
	{

		//Initulize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group03m/female_0%i.mdl", Random);
	}

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Buffer);

	//Is PreCached:
	if(!IsModelPrecached(Buffer))
	{

		//PreCache:
		PrecacheModel(Buffer);
	}

	//Set Client Model:
	SetEntityModel(Client,  GlobalModel[Client]);
}

public void SetModel(int Client, const char[] Str)
{

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Str);

	//Is PreCached:
	if(!IsModelPrecached(GlobalModel[Client]))
	{

		//PreCache:
		PrecacheModel(GlobalModel[Client]);
	}

	//Set Client Model:
	SetEntityModel(Client,  GlobalModel[Client]);

	//Declare:
	char query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Model = '%s' WHERE STEAMID = %i;", Str, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

char GetModel(int Client)
{

	//return:
	return GlobalModel[Client];
}

public bool GetClientChatColor(int Client, char Color[32])
{

	//Declare:
	char JobId[32];

	//Format:
	Format(JobId, sizeof(JobId), "%s", GetJob(Client));

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, JobSetupPath);

	//Declare:
	char Buffer[255];

	//Load:
	LoadString(Vault, JobId, "color", "null", Buffer);

	//Get KV:
	//KvGetString(Vault, Buffer, JobId, sizeof(JobId), "null");

	//Check
	if(StrEqual(Buffer, "null"))

	{

		//Return:
		return false;
	}

	//Format:
	Format(Color, sizeof(Color), "%s", Buffer);

	//Return:
	return true;
}