//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vortigaunt_included_
  #endinput
#endif
#define _rp_vortigaunt_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXVORTIGAUNTSPAWNS	10

int VortigauntTime = 0;
int Vortigaunt[MAXVORTIGAUNTSPAWNS + 1] = -1;
float VortigauntSpawn[MAXVORTIGAUNTSPAWNS + 1][3];

public void initVortigaunt()
{

	//Commands:
	RegAdminCmd("sm_createvortigauntspawn", Command_CreateVortigauntZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removevortigauntspawn", Command_RemoveVortigauntZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listVortigauntpawns", Command_ListVortigauntSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipevortigauntspawn", Command_WipeVortigauntZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testvortigauntspawn", Command_TestVortigauntZone, ADMFLAG_ROOT, "<id> - Test Vortigaunt Spawn");

	//Public Commands:
	RegConsoleCmd("sm_vortigaunt", Command_Vortigaunt);

	//Timers:
	CreateTimer(0.2, CreateSQLdbVortigauntSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXVORTIGAUNTSPAWNS; Z++)
	{

		//Initulize:
		Vortigaunt[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			VortigauntSpawn[Z][i] = 69.0;
		}
	}
}

//Create Database:
public Action CreateSQLdbVortigauntSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VortigauntSpawn`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadVortigauntSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXVORTIGAUNTSPAWNS; Z++)
	{

		//Initulize:
		Vortigaunt[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			VortigauntSpawn[Z][i] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VortigauntSpawn WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVortigauntSpawn, query);
}

public void T_DBLoadVortigauntSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVortigauntSpawn: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vortigaunt Zones Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			VortigauntSpawn[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Vortigaunt Zones Found!");
	}
}

public void T_DBPrintVortigauntSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintVortigauntSpawn: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ZoneId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

public void initVortigauntTimer()
{

	//Check:
	if(VortigauntTime > 0)
	{

		//Initulize:
		VortigauntTime -= 1;

		//Switch:
		switch(VortigauntTime)
		{

			//Activate Vortigaunt:
			case 1:
			{

				//Deactivate:
				RemoveVortigaunt();
			}

			//Activate Vortigaunt:
			case 80:
			{

				//Print:
				VortigauntAlarmSound();
			}


			//Activate Vortigaunt:
			case 160:
			{

				//Print:
				VortigauntAlarmSound();
			}


			//Activate Vortigaunt:
			case 220:
			{

				//Print:
				VortigauntAlarmSound();
			}

			//Activate Vortigaunt:
			case 300:
			{

				//Activate:
				SpawnVortigaunt();
			}
		}
	}
}

public void SparkVortigauntEffects()
{

	//Loop:
	for(int X = 0; X <= MAXVORTIGAUNTSPAWNS; X++)
	{

		//Check:
		if(IsValidEdict(Vortigaunt[X]))
		{

			//Declare:
			int Effect = GetEntAttatchedEffect(Vortigaunt[X], 0);

			//Check:
			if(IsValidEdict(Effect))
			{

				//Spark:
				AcceptEntityInput(Effect, "DoSpark");
			}
		}
	}
}

public void StartVortigaunt(int Client)
{

	//Initulize:
	VortigauntTime = 360;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - Vortigaunts will spawn in 60 seconds!", Client);
}

public void SpawnVortigaunt()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Vortigaunts has now been Spawned!");

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Spawn:
	initVortigauntSpawns();

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void RemoveVortigaunt()
{

	//Print:
	//CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Vortigaunts has now been Deactivated!");
}

public void VortigauntAlarmSound()
{

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void initVortigauntSpawns()
{

	//Declare:
	int Random = GetRandomInt(0, MAXVORTIGAUNTSPAWNS);

	//Check:
	if(VortigauntSpawn[Random][0] != 69.0 && Vortigaunt[Random] == -1)
	{

		//Create NPCS!
		CreateVortigaunt(Random);
	}
}

public int CreateVortigaunt(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return view_as<int>(-1);
	}

	//Declare:
	float Origin[3] = {0.0, 0.0, 0.0};

	//Check
	if(Var > MAXVORTIGAUNTSPAWNS)
	{

		//Initulize:
		GetEntPropVector(Var, Prop_Send, "m_vecOrigin", Origin);

		//Do Math:
		Origin[0] = Origin[0] + GetRandomFloat(-200.0, 200.0);
		Origin[1] = Origin[1] + GetRandomFloat(-200.0, 200.0);
		Origin[2] = Origin[2] + GetRandomFloat(50.0, 200.0);
	}

	//Override:
	else
	{

		//Initulize:
		Origin = VortigauntSpawn[Var];
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(Origin))
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn Vortigaunt due to outside of world");

		//Return:
		return view_as<int>(-1);
	}

	//Check
	if(Var <= MAXVORTIGAUNTSPAWNS)
	{

		//Check:
		if(Vortigaunt[Var] > 0)
		{

			//Print:
			PrintToServer("|RP| - Unable to Spawn Vortigaunt Already Spawned");

			//Return:
			return view_as<int>(-1);
		}
	}

	//Check:
	if(GetGame() == 1)
	{

		//Declare:
		int Ent = CreateNpcVortigaunt("null", Origin, Angles, 2000);

		//Initulize Effects:
		int Effect = CreatePointTesla(Ent, "null", "183 232 127");

		SetEntAttatchedEffect(Ent, 0, Effect);

		//Added Effect:
		Effect = CreateLight(Ent, 1, 183, 232, 127, "null");

		SetEntAttatchedEffect(Ent, 1, Effect);

		//Check
		if(Var <= MAXVORTIGAUNTSPAWNS)
		{

			//Initulize:
			Vortigaunt[Var] = Ent;
		}

		//Print:
		//PrintToServer("|RP| -  Spawned Vortigaunt");

		//Return:
		return view_as<int>(Ent);
	}

	//Print:
	PrintToServer("|RP| - Unable to Spawn Vortigaunt due to Wrong Game!");

	//Return:
	return view_as<int>(-1);
}

public Action Command_Vortigaunt(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you don't have access to this command.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(VortigauntTime > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another Vortigaunt whilst we're still in one!");

		//Return:
		return Plugin_Handled;
	}

	//Start:
	StartVortigaunt(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateVortigauntZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createvortigauntspawn <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createvortigauntspawn <0-%i>", MAXVORTIGAUNTSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(VortigauntSpawn[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE VortigauntSpawn SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO VortigauntSpawn (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	VortigauntSpawn[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Vortigaunt npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveVortigauntZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeVortigauntspawn <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removevortigauntspawn <0-%i>", MAXVORTIGAUNTSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(VortigauntSpawn[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	VortigauntSpawn[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM VortigauntSpawn WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Vortigaunt npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListVortigauntSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Vortigaunt Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXVORTIGAUNTSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM VortigauntSpawn WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintVortigauntSpawn, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeVortigauntZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Vortigaunt Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXVORTIGAUNTSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM VortigauntSpawn WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestVortigauntZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testvortigauntspawn <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXVORTIGAUNTSPAWNS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testvortigauntspawn <0-%i>", MAXVORTIGAUNTSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	CreateVortigaunt(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, VortigauntSpawn[Id][0], VortigauntSpawn[Id][1], VortigauntSpawn[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsVortigauntActive()
{

	//Check:
	if(VortigauntTime > 0)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public void OnVortigauntNPCDestroyedCheck(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXVORTIGAUNTSPAWNS; X++)
	{

		//Check:
		if(Vortigaunt[X] == Entity)
		{

			//Initulize:
			Vortigaunt[X] = -1;
		}
	}
}

public void RemoveVortigauntNPC(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXVORTIGAUNTSPAWNS; X++)
	{

		//Check:
		if(IsValidEdict(Vortigaunt[X]))
		{

			//Request:
			RequestFrame(OnNextFrameKill, Vortigaunt[X]);
		}

		//Initulize:
		Vortigaunt[X] = -1;
	}
}

public bool IsValidVortigauntNPC(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXVORTIGAUNTSPAWNS; X++)
	{

		//Check:
		if(Vortigaunt[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public void SetVortigauntIndex(int Index, int Entity)
{

	//Initulize:
	Vortigaunt[Index] = Entity;
}

public int GetVortigauntIndex(int Index)
{

	//Initulize:
	return view_as<int>(Vortigaunt[Index]);
}