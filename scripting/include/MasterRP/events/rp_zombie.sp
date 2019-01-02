//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_zombie_included_
  #endinput
#endif
#define _rp_zombie_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXZOMBIESPAWNS		10

int ZombieTime = 0;
int Zombie[MAXZOMBIESPAWNS + 1] = -1;
float ZombieSpawn[MAXZOMBIESPAWNS + 1][3];

public void initZombie()
{

	//Commands:
	RegAdminCmd("sm_createzombiespawn", Command_CreateZombieZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removezombiespawn", Command_RemoveZombieZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listzombiepawns", Command_ListZombieSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipezombiespawn", Command_WipeZombieZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testzombiespawn", Command_TestZombieZone, ADMFLAG_ROOT, "<id> - Test Zombie Spawn");

	//Public Commands:
	RegConsoleCmd("sm_zombie", Command_Zombie);

	//Timers:
	CreateTimer(0.2, CreateSQLdbZombieSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXZOMBIESPAWNS; Z++)
	{

		//Initulize:
		Zombie[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			ZombieSpawn[Z][i] = 69.0;
		}
	}
}

//Create Database:
public Action CreateSQLdbZombieSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `ZombieSpawn`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadZombieSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXZOMBIESPAWNS; Z++)
	{

		//Initulize:
		Zombie[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			ZombieSpawn[Z][i] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM ZombieSpawn WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadZombieSpawn, query);
}

public void T_DBLoadZombieSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadZombieSpawn: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Zombie Zones Found in DB!");

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
			ZombieSpawn[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Zombie Zones Found!");
	}
}

public void T_DBPrintZombieSpawn(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintZombieSpawn: Query failed! %s", error);
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

public void initZombieTimer()
{

	//Check:
	if(ZombieTime > 0)
	{

		//Initulize:
		ZombieTime -= 1;

		//Switch:
		switch(ZombieTime)
		{

			//Activate Zombie:
			case 1:
			{

				//Deactivate:
				RemoveZombie();
			}

			//Activate Zombie:
			case 80:
			{

				//Print:
				ZombieAlarmSound();

				//Initulize:
				initZombieSpawns();
			}


			//Activate Zombie:
			case 160:
			{

				//Print:
				ZombieAlarmSound();

				//Initulize:
				initZombieSpawns();
			}


			//Activate Zombie:
			case 220:
			{

				//Print:
				ZombieAlarmSound();

				//Initulize:
				initZombieSpawns();
			}

			//Activate Zombie:
			case 300:
			{

				//Activate:
				SpawnZombie();
			}
		}
	}
}

public void SparkZombieEffects()
{
/*
	//Loop:
	for(int X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Check:
		if(IsValidEdict(Zombie[X]))
		{

		}
	}
*/
}

public void StartZombie(int Client)
{

	//Initulize:
	ZombieTime = 360;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - Zombies will spawn in 60 seconds!", Client);
}

public void SpawnZombie()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Zombies has now been Spawned!");

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Spawn:
	initZombieSpawns();

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void RemoveZombie()
{

	//Print:
	//CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Zombies has now been Deactivated!");
}

public void ZombieAlarmSound()
{

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void initZombieSpawns()
{

	//Loop:
	for(int X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Check:
		if(ZombieSpawn[X][0] != 69.0 && Zombie[X] == -1)
		{

			//Create NPCS!
			CreateZombie(X);
		}
	}
}

public int CreateZombie(int Var)
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
	if(Var > MAXZOMBIESPAWNS)
	{

		//Initulize:
		GetEntPropVector(Var, Prop_Send, "m_vecOrigin", Origin);

		//Do Math:
		Origin[0] = ZombieSpawn[Var][0] + GetRandomFloat(-200.0, 200.0);
		Origin[1] = ZombieSpawn[Var][1] + GetRandomFloat(-200.0, 200.0);
		Origin[2] = ZombieSpawn[Var][2] + GetRandomFloat(50.0, 200.0);
	}

	//Override:
	else
	{

		//Initulize:
		Origin = ZombieSpawn[Var];
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(Origin))
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn Zombie due to outside of world");

		//Return:
		return view_as<int>(-1);
	}

	//Check
	if(Var <= MAXZOMBIESPAWNS)
	{

		//Check:
		if(Zombie[Var] > 0)
		{

			//Print:
			PrintToServer("|RP| - Unable to Spawn Zombie Already Spawned");

			//Return:
			return view_as<int>(-1);
		}
	}

	//Check:
	if(GetGame() == 1)
	{

		//Declare:
		int Ent = CreateNpcZombie("null", Origin, Angles, 2000);

		//Check
		if(Var <= MAXZOMBIESPAWNS)
		{

			//Initulize:
			Zombie[Var] = Ent;
		}

		//Print:
		//PrintToServer("|RP| -  Spawned Zombie");

		//Return:
		return view_as<int>(Ent);
	}

	//Print:
	PrintToServer("|RP| - Unable to Spawn Zombie due to Wrong Game!");

	//Return:
	return view_as<int>(-1);
}

public Action Command_Zombie(int Client, int Args)
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
	if(ZombieTime > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another Zombie whilst we're still in one!");

		//Return:
		return Plugin_Handled;
	}

	//Start:
	StartZombie(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateZombieZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createzombiespawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createzombiespawn <0-%i>", MAXZOMBIESPAWNS);

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
	if(ZombieSpawn[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE ZombieSpawn SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO ZombieSpawn (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	ZombieSpawn[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Zombie npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveZombieZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removezombiespawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removezombiespawn <0-%i>", MAXZOMBIESPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(ZombieSpawn[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	ZombieSpawn[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM ZombieSpawn WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Zombie npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListZombieSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Zombie Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM ZombieSpawn WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintZombieSpawn, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeZombieZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Zombie Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM ZombieSpawn WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestZombieZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testzombiespawn <id>");

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
	if(Id < 0 || Id > MAXZOMBIESPAWNS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testzombiespawn <0-%i>", MAXZOMBIESPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	CreateZombie(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ZombieSpawn[Id][0], ZombieSpawn[Id][1], ZombieSpawn[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsZombieActive()
{

	//Check:
	if(ZombieTime > 0)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public void OnZombieNPCDestroyedCheck(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Check:
		if(Zombie[X] == Entity)
		{

			//Initulize:
			Zombie[X] = -1;
		}
	}
}

public void RemoveZombieNPC(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Check:
		if(IsValidEdict(Zombie[X]))
		{

			//Request:
			RequestFrame(OnNextFrameKill, Zombie[X]);
		}

		//Initulize:
		Zombie[X] = -1;
	}
}

public bool IsValidZombieNPC(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXZOMBIESPAWNS; X++)
	{

		//Check:
		if(Zombie[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public void SetZombieIndex(int Index, int Entity)
{

	//Initulize:
	Zombie[Index] = Entity;
}

public int GetZombieIndex(int Index)
{

	//Initulize:
	return view_as<int>(Zombie[Index]);
}