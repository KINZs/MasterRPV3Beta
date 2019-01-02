//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_AntLionBoss_included_
  #endinput
#endif
#define _rp_AntLionBoss_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXANTLIONSUMON		3
#define MAXANTLIONBOSSSPAWNS	10

int AntLionBoss = -1;
int AntLionBossTime = 0;
float AntLionBossSpawn[MAXANTLIONBOSSSPAWNS + 1][3];
int AntLionSumon[MAXANTLIONSUMON + 1] = -1;

public void initAntLionBoss()
{

	//Commands:
	RegAdminCmd("sm_createantlionbossspawn", Command_CreateAntLionBossZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removeantlionbossspawn", Command_RemoveAntLionBossZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listantlionbosspawns", Command_ListAntLionBossSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipeantlionbossspawn", Command_WipeAntLionBossZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testantlionbossspawn", Command_TestAntLionBossZone, ADMFLAG_ROOT, "<id> - Test AntLionBoss Spawn");

	//Public Commands:
	RegConsoleCmd("sm_antlionboss", Command_AntLionBoss);

	//Timers:
	CreateTimer(0.2, CreateSQLdbAntLionBossSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXANTLIONBOSSSPAWNS; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		AntLionBossSpawn[Z][i] = 69.0;
	}

	//Loop:
	for(int i = 0; i < 3; i++)
	{

		//Initulize:
		AntLionSumon[i] = -1;
	}

	//Initulize:
	AntLionBoss = -1;
}

//Create Database:
public Action CreateSQLdbAntLionBossSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `AntLionBossSpawn`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadAntLionBossSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXANTLIONBOSSSPAWNS; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		AntLionBossSpawn[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM AntLionBossSpawn WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadAntLionBossSpawn, query);
}

public void T_DBLoadAntLionBossSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadAntLionBossSpawn: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No AntLionBoss Zones Found in DB!");

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
			AntLionBossSpawn[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - AntLionBoss Zones Found!");
	}
}

public void T_DBPrintAntLionBossSpawn(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintAntLionBossSpawn: Query failed! %s", error);
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

public void initAntLionBossTimer()
{

	//Check:
	if(AntLionBossTime > 0)
	{

		//Initulize:
		AntLionBossTime -= 1;

		//Switch:
		switch(AntLionBossTime)
		{

			//Activate AntLionBoss:
			case 1:
			{

				//Deactivate:
				RemoveAntLionBoss();
			}

			//Activate AntLionBoss:
			case 30:
			{

				//Print:
				AntLionBossAlarmSound();
			}


			//Activate AntLionBoss:
			case 60:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 90:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 120:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 150:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 180:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 210:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 240:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 270:
			{

				//Print:
				AntLionBossAlarmSound();
			}

			//Activate AntLionBoss:
			case 300:
			{

				//Activate:
				SpawnAntLionBoss();

				//Print:
				AntLionBossAlarmSound();
			}
		}
	}
}

public void StartAntLionBoss(int Client)
{

	//Initulize:
	AntLionBossTime = 360;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - AntLion Boss will spawn in 60 seconds!", Client);
}

public void SpawnAntLionBoss()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - AntLionBoss has now been Spawned!");

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Spawn:
	initAntLionBossSpawns();

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void RemoveAntLionBoss()
{

	//Check:
	if(IsValidEdict(AntLionBoss))
	{

		//Accept:
		AcceptEntityInput(AntLionBoss, "kill");

		//Request:
		RequestFrame(OnNextFrameKill, AntLionBoss);

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - You have failed to defeat the AntLion Boss!");
	}

	//Initulize:
	AntLionBoss = -1;

	//Loop:
	for(int i = 0; i < 3; i++)
	{

		//Check:
		if(IsValidEdict(AntLionSumon[i]))
		{

			//Request:
			RequestFrame(OnNextFrameKill, AntLionSumon[i]);
		}

		//Initulize:
		AntLionSumon[i] = -1;
	}
}

public void AntLionBossAlarmSound()
{

	//Check:
	if(AntLionBoss > 0)
	{

		//Declare:
		float Origin[3] = {0.0, 0.0, 500.0};

		//Play Sound:
		EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Check:
			if(!IsValidEdict(AntLionSumon[i]) && GetAntLionIndex(i) == -1)
			{

				//Create:
				int Ent = CreateAntLion(AntLionBoss);

				if(IsValidEdict(Ent))
				{

					//Initulize:
					AntLionSumon[i] = Ent;

					//Set for Effect in other plugin!
					SetAntLionIndex(i, Ent);

					//Initialize:
					GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

					//TE Setup:
					TE_SetupDynamicLight(Origin , 10, 100, 255, 8, 250.0, 1.0, 50.0);

					//Send:
					TE_SendToAll();
				}
			}
		}
	}
}

public void initAntLionBossSpawns()
{

	//Declare:
	int Random = GetRandomInt(0, MAXANTLIONBOSSSPAWNS);

	//Check:
	if(AntLionBossSpawn[Random][0] != 69.0 && AntLionBoss == -1)
	{

		//Create NPCS!
		CreateAntLionBoss(Random);
	}
}

public int CreateAntLionBoss(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(AntLionBossSpawn[Var]))
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn AntLion Boss due to outside of world");

		//Return:
		return -1;
	}

	//Check:
	if(AntLionBoss > 0)
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn AntLion Boss Already Spawned");

		//Return:
		return -1;
	}

	//Check:
	if(GetGame() == 1)
	{

		//Declare:
		int Ent = CreateNpcAntLionGuard("null", AntLionBossSpawn[Var], Angles, 10000, 1);

		//Initulize:
		AntLionBoss = Ent;

		//Print:
		PrintToServer("|RP| -  Spawned AntLion Boss");

		//Return:
		return Ent;
	}

	//Override:
	else
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn AntLion Boss due to outside of world");
	}

	//Return:
	return -1;
}

public Action Command_AntLionBoss(int Client, int Args)
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
	if(AntLionBossTime > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another AntLionBoss whilst we're still in one!");

		//Return:
		return Plugin_Handled;
	}

	//Start:
	StartAntLionBoss(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateAntLionBossZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createantlionbossspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createantlionbossspawn <0-%i>", MAXANTLIONBOSSSPAWNS);

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
	if(AntLionBossSpawn[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE AntLionBossSpawn SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO AntLionBossSpawn (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	AntLionBossSpawn[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created AntLionBoss npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveAntLionBossZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeantlionbossspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeantlionbossspawn <0-%i>", MAXANTLIONBOSSSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(AntLionBossSpawn[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	AntLionBossSpawn[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM AntLionBossSpawn WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed AntLionBoss npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListAntLionBossSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "AntLion Boss Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXANTLIONBOSSSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM AntLionBossSpawn WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintAntLionBossSpawn, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeAntLionBossZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "AntLion Boss Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXANTLIONBOSSSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM AntLionBossSpawn WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestAntLionBossZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testantlionbossspawn <id>");

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
	if(Id < 0 || Id > MAXANTLIONBOSSSPAWNS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeantlionbossspawn <0-%i>", MAXANTLIONBOSSSPAWNS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	CreateAntLionBoss(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, AntLionBossSpawn[Id][0], AntLionBossSpawn[Id][1], AntLionBossSpawn[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsAntLionBossActive()
{

	//Check:
	if(AntLionBossTime > 0)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public void OnAntLionBossNPCDestroyedCheck(int Entity)
{

	//Check:
	if(AntLionBoss == Entity)
	{

		//Initulize:
		AntLionBoss = -1;
	}

	//Loop:
	for(int i = 0; i < 3; i++)
	{

		//Check:
		if(AntLionSumon[i] > 0)
		{

			//Initulize:
			AntLionSumon[i] = -1;
		}
	}
}

public void RemoveAntLionBossNPC(int Ent)
{

	//Initulize:
	AntLionBoss = -1;
}

public bool IsValidAntLionBossNPC(int Ent)
{

	//Check:
	if(AntLionBoss == Ent)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}