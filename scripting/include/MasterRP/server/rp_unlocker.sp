//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_unlocker_included_
  #endinput
#endif
#define _rp_unlocker_included_

public void initUnlocker()
{

	//Hook Entity Output:
	HookEntityOutput("game_end", "EndGame",EntityOutput);

	HookEntityOutput("point_servercommand","Command",EntityOutput);

	HookEntityOutput("point_clientcommand","Command",EntityOutput);

	if(StrEqual(ServerMap(), "RP_City8_OutCast_MS"))
	{

		//Command:
		ServerCommand("sv_cheats 1");

		ServerCommand("ent_remove_all respawn");

		ServerCommand("ent_remove_all electichurt");

		ServerCommand("sv_cheats 0");

		//Print:
		PrintToServer("|RP| Found Bad Entities (Removed).");
	}

	if(StrEqual(ServerMap(), "rp_downtown_sp3a"))
	{

		//Command:
		ServerCommand("sv_cheats 1");

		ServerCommand("ent_remove_all yupthisisboring");

		ServerCommand("sv_cheats 0");

		//Print:
		PrintToServer("|RP| Found Bad Entities (Removed).");
	}

	//Declare:
	char Class[128];

	int Count = 0;

	//Loop:
	for(int Ent = 0; Ent < 4096; Ent++)
	{

		//Is Entity:
		if(IsValidEdict(Ent))
		{

			//Get Class Name Of All Entitys:
			GetEdictClassname(Ent, Class, sizeof(Class));

			//Is Harmfull Entity:
			if((StrEqual(Class, "game_end", false) || StrEqual(Class, "point_clientcommand", false) || StrEqual(Class, "point_servercommand", false) || StrEqual(Class, "trigger_remove", false) || StrEqual(Class, "trigger_once", false)) || StrEqual(Class, "func_tracktrain", false))
			{

				//Remove Entity:
				AcceptEntityInput(Ent, "kill");

				//Initulize:
				Count++;
			}
		}
	}

	if(Count != 0)
	{

		//Print:
		PrintToServer("|RP| %i Found Bad Entities (Removed).", Count);
	}

	if(Count == 0)
	{

		//Print:
		PrintToServer("|RP| No Bad Entities Found.");
	}
}

public void EntityOutput(const char[] output, int Caller, int Activator, float delay)
{

	//Declare:
	int Count = 0;

	//Is Valid Entity:
	if(IsValidEntity(Caller))
	{

		if(IsValidEntity(Caller))
		{

			//Remove:
			RemoveEdict(Caller);

			//Initulize:
			Count++;
		}

		//Remove:
		RemoveEdict(Activator);
	}

	if(Count != 0)
	{

		//Print:
		PrintToServer("|RP| %i Found Bad Entities (Removed)", Count);
	}
}

public Action OnLevelInit(const char[] mapName, char mapEntities[2097152])
{

	//Is Map:
	if(StrEqual(mapName, "rp_downtown_sp3a") || StrEqual(mapName, "rp_downtown_sp4a"))
	{

		//Replace:
		ReplaceString(mapEntities, sizeof(mapEntities), "vworldspawn", "worldspawn");

		//Declare:
		char Class[128];

		//Loop:
		for(int Ent = 0; Ent < 4096; Ent++)
		{

			//Is Entity:
			if(IsValidEdict(Ent))
			{

				//Get Class Name Of All Entitys:
				GetEdictClassname(Ent, Class, sizeof(Class));

				//Is Harmfull Entity:
				if(StrEqual(Class, "vworldspawn", false))
				{

					//Ent:
					SetEntPropString(Ent, Prop_Data, "m_iClassname", "worldspawn");
				}
			}
		}

		//Return:
		return Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}