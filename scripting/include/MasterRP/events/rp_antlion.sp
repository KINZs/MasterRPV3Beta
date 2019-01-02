//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_antlion_included_
  #endinput
#endif
#define _rp_antlion_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXANTLIONSSPAWNS	10

int AntLionTime = 0;
int AntLion[MAXANTLIONSSPAWNS + 1] = -1;
float AntLionSpawn[MAXANTLIONSSPAWNS + 1][3];

public void initAntLion()
{

	//Commands:
	RegAdminCmd("sm_createantlionspawn", Command_CreateAntLionZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removeantlionspawn", Command_RemoveAntLionZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listantlionpawns", Command_ListAntLionSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipeantlionspawn", Command_WipeAntLionZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testantlionspawn", Command_TestAntLionZone, ADMFLAG_ROOT, "<id> - Test AntLion Spawn");

	//Public Commands:
	RegConsoleCmd("sm_antlion", Command_AntLion);

	//Timers:
	CreateTimer(0.2, CreateSQLdbAntLionSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXANTLIONSSPAWNS; Z++)
	{

		//Initulize:
		AntLion[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			AntLionSpawn[Z][i] = 69.0;
		}
	}
}

//Create Database:
public Action CreateSQLdbAntLionSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `AntLionSpawn`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadAntLionSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXANTLIONSSPAWNS; Z++)
	{

		//Initulize:
		AntLion[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			AntLionSpawn[Z][i] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM AntLionSpawn WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadAntLionSpawn, query);
}

public void T_DBLoadAntLionSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadAntLionSpawn: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No AntLion Zones Found in DB!");

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
			AntLionSpawn[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - AntLion Zones Found!");
	}
}

public void T_DBPrintAntLionSpawn(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintAntLionSpawn: Query failed! %s", error);
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

public void initAntLionTimer()
{

	//Check:
	if(AntLionTime > 0)
	{

		//Initulize:
		AntLionTime -= 1;

		//Switch:
		switch(AntLionTime)
		{

			//Activate AntLion:
			case 1:
			{

				//Deactivate:
				RemoveAntLion();
			}

			//Activate AntLion:
			case 80:
			{

				//Print:
				AntLionAlarmSound();
			}


			//Activate AntLion:
			case 160:
			{

				//Print:
				AntLionAlarmSound();
			}


			//Activate AntLion:
			case 220:
			{

				//Print:
				AntLionAlarmSound();
			}

			//Activate AntLion:
			case 300:
			{

				//Activate:
				SpawnAntLion();
			}
		}
	}
}

public void SparkAntlionEffects()
{

	//Loop:
	for(int X = 0; X <= MAXANTLIONSSPAWNS; X++)
	{

		//Check:
		if(IsValidEdict(AntLion[X]))
		{

			//Declare:
			int Effect = GetEntAttatchedEffect(AntLion[X], 0);

			//Check:
			if(IsValidEdict(Effect))
			{

				//Spark:
				AcceptEntityInput(Effect, "DoSpark");
			}
		}
	}
}

public void StartAntLion(int Client)
{

	//Initulize:
	AntLionTime = 360;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - AntLions will spawn in 60 seconds!", Client);
}

public void SpawnAntLion()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - AntLions has now been Spawned!");

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Spawn:
	initAntLionSpawns();

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void RemoveAntLion()
{

	//Print:
	//CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - AntLions has now been Deactivated!");
}

public void AntLionAlarmSound()
{

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void initAntLionSpawns()
{

	//Declare:
	int Random = GetRandomInt(0, MAXANTLIONSSPAWNS);

	//Check:
	if(AntLionSpawn[Random][0] != 69.0 && AntLion[Random] == -1)
	{

		//Create NPCS!
		CreateAntLion(Random);
	}
}

public int CreateAntLion(int Var)
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
	if(Var > MAXANTLIONSSPAWNS)
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
		Origin = AntLionSpawn[Var];
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(Origin))
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn AntLion due to outside of world");

		//Return:
		return view_as<int>(-1);
	}

	//Check
	if(Var <= MAXANTLIONSSPAWNS)
	{

		//Check:
		if(AntLion[Var] > 0)
		{

			//Print:
			PrintToServer("|RP| - Unable to Spawn AntLion Already Spawned");

			//Return:
			return view_as<int>(-1);
		}
	}

	//Check:
	if(GetGame() == 1)
	{

		//Declare:
		int Ent = CreateNpcAntLion("null", Origin, Angles, 1000);

		//Initulize Effects:
		int Effect = CreatePointTesla(Ent, "null", "51 120 255");

		SetEntAttatchedEffect(Ent, 0, Effect);

		//Added Effect:
		Effect = CreateLight(Ent, 1, 51, 120, 255, "null");

		SetEntAttatchedEffect(Ent, 1, Effect);

		//Initulize:
		Effect = CreateEnvSmokeTrail(Ent, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "75", "20", "50", "150", "0", "10 100 255", "5");

		SetEntAttatchedEffect(Ent, 2, Effect);

		//Set Ent Color:
		SetEntityRenderColor(Ent, 51, 120, 255, 255);

		//Check
		if(Var <= MAXANTLIONSSPAWNS)
		{

			//Initulize:
			AntLion[Var] = Ent;
		}

		//Print:
		//PrintToServer("|RP| -  Spawned AntLion");

		//Return:
		return view_as<int>(Ent);
	}

	//Print:
	PrintToServer("|RP| - Unable to Spawn AntLion due to Wrong Game!");

	//Return:
	return view_as<int>(-1);
}

public Action Command_AntLion(int Client, int Args)
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
	if(AntLionTime > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another AntLion whilst we're still in one!");

		//Return:
		return Plugin_Handled;
	}

	//Start:
	StartAntLion(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateAntLionZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createantlionspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createantlionspawn <0-%i>", MAXANTLIONSSPAWNS);

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
	if(AntLionSpawn[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE AntLionSpawn SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO AntLionSpawn (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	AntLionSpawn[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created AntLion npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveAntLionZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeanlionspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeanlionspawn <0-%i>", MAXANTLIONSSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(AntLionSpawn[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	AntLionSpawn[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM AntLionSpawn WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed AntLion npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListAntLionSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "AntLion Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXANTLIONSSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM AntLionSpawn WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintAntLionSpawn, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeAntLionZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "AntLion Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXANTLIONSSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM AntLionSpawn WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestAntLionZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testantlionspawn <id>");

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
	if(Id < 0 || Id > MAXANTLIONSSPAWNS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testanlionspawn <0-%i>", MAXANTLIONSSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	CreateAntLion(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, AntLionSpawn[Id][0], AntLionSpawn[Id][1], AntLionSpawn[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsAntLionActive()
{

	//Check:
	if(AntLionTime > 0)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public void OnAntLionNPCDestroyedCheck(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXANTLIONSSPAWNS; X++)
	{

		//Check:
		if(AntLion[X] == Entity)
		{

			//Initulize:
			AntLion[X] = -1;
		}
	}
}

public void RemoveAntLionNPC(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXANTLIONSSPAWNS; X++)
	{

		//Check:
		if(IsValidEdict(AntLion[X]))
		{

			//Request:
			RequestFrame(OnNextFrameKill, AntLion[X]);
		}

		//Initulize:
		AntLion[X] = -1;
	}
}

public bool IsValidAntLionNPC(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXANTLIONSSPAWNS; X++)
	{

		//Check:
		if(AntLion[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public void SetAntLionIndex(int Index, int Entity)
{

	//Initulize:
	AntLion[Index] = Entity;
}

public int GetAntLionIndex(int Index)
{

	//Initulize:
	return view_as<int>(AntLion[Index]);
}