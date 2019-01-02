/////////////////////////////////////////////////////////////////////
/////			      Database:				/////
/////////////////////////////////////////////////////////////////////

/** Double-include prevention */
#if defined _rp_spawns_included_
  #endinput
#endif
#define _rp_spawns_included_

//Max Spawns:
#define MAXSPAWNS		32

//Spawns:
float SpawnPoints[MAXSPAWNS + 1][2][3];
bool ValidSpawn[MAXSPAWNS + 1][2];

public void initSpawn()
{

	//Commands:
	RegAdminCmd("sm_createspawn", CommandCreateSpawn, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removespawn", CommandRemoveSpawn, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_spawnlist", CommandListSpawns, ADMFLAG_SLAY, "Lists all the Spawnss in the database");

	//Timer:
	CreateTimer(0.2, CreateSQLdbSpawnPoints);

	//Reset:
	ResetSpawns();
}

public void ResetSpawns()
{

	//Loop:
	for(int Z = 0; Z <= MAXSPAWNS; Z++)
	{

		//Initulize:
		ValidSpawn[Z][0] = false;

		ValidSpawn[Z][1] = false;

		//Loop:
		for(int B = 0; B < 2; B++) for(int i = 0; i < 3; i++)
		{

			//Initulize:
			SpawnPoints[Z][B][i] = 69.0;
		}
	}
}

public void InitSpawnPos(int Client, int Effect)
{

	//Get Job Type:
	int Type;

	//Check:
	if(IsCop(Client))
	{

		//Initulize:
		Type = 1;
	}

	//Override:
	else
	{

		//Initulize:
		Type = 0;
	}

	//Spawn:
	RandomizeSpawn(Client, Type);

	//Added Spawn Effect:
	if(Effect == 1) InitSpawnEffect(Client);
}

public void InitSpawnEffect(int Client)
{

	//Set Ent:
	SetEntProp(Client, Prop_Send, "m_iFOVStart", 150);
	SetEntPropFloat(Client, Prop_Send, "m_flFOVTime", GetGameTime());
	SetEntPropFloat(Client, Prop_Send, "m_flFOVRate", 3.0);

	//Declare:
	int Tesla = -1;

	//Is Cop:
	if(IsCop(Client)) Tesla = CreatePointTesla(Client, "eyes", "50 50 250");

	//Is Admin:
	else if(IsAdmin(Client)) Tesla = CreatePointTesla(Client, "eyes", "50 250 50");

	//Is Player:
	else Tesla = CreatePointTesla(Client, "eyes", "250 50 50");

	//Set Client ClassName
	SetClientClass(Client); //rp_npcdynamic.sp

	//Timer:
	CreateTimer(1.5, RemoveSpawnEffect, Tesla);
}

//Remove Effect:
public Action RemoveSpawnEffect(Handle Timer, any Ent)
{

	//Is Valid:
	if(Ent > -1 && IsValidEdict(Ent))
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);
	}
}

//Create Database:
public Action CreateSQLdbSpawnPoints(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `SpawnPoints`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `Type` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SpawnId` int(12) NULL, `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadSpawnPoints(Handle Timer)
{

	//Reset:
	ResetSpawns();

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM SpawnPoints WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSpawnPoints, query);
}

public void T_DBLoadSpawnPoints(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadSpawnPoints: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Spawns Found in DB!");

			//Initulize:
			ValidSpawn[0][0] = true;
			ValidSpawn[0][1] = true;

			//Loop:
			for(int X = 0; X <= 2; X++)
			{

				//Initulize:
				SpawnPoints[0][0][0] = 0.0;
				SpawnPoints[0][0][1] = 0.0;
				SpawnPoints[0][0][2] = 0.0;

				SpawnPoints[0][1][0] = 0.0;
				SpawnPoints[0][1][1] = 0.0;
				SpawnPoints[0][1][2] = 0.0;
			}

			//Print:
			PrintToServer("|RP| - Spawn #01 has been activated");

			//Return:
			return;
		}

		//Declare:
		int Type = 0;
		int Spawns = 0;
		int SpawnId = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 2);

			//Weapon Check:
			if(SpawnId >= 0 && SpawnId <= MAXSPAWNS)
			{

				//Initulize:
				Spawns += 1;

				//Database Field Loading Intiger:
				Type = SQL_FetchInt(hndl, 1);

				//Declare:
				char Dump[3][64];
				float Position[3];

				//Database Field Loading String:
				SQL_FetchString(hndl, 3, Buffer, 64);

				//Convert:
				ExplodeString(Buffer, "^", Dump, 3, 64);

				//Loop:
				for(int X = 0; X <= 2; X++)
				{

					//Initulize:
					Position[X] = StringToFloat(Dump[X]);
				}

				//Initulize:
				SpawnPoints[SpawnId][Type] = Position;

				//Check:
				if(!TR_PointOutsideWorld(Position))
				{

					//Initulize:
					ValidSpawn[SpawnId][Type] = true;
				}
			}
		}

		//Print:
		PrintToServer("|RP| - %i Spawns Loaded!", Spawns);
	}
}

//Random Spawn:
public void RandomizeSpawn(int Client, int SpawnType)
{

	//Declare:
	int Roll = GetRandomInt(0, MAXSPAWNS);

	//Invalid Spawn:
	if(ValidSpawn[Roll][SpawnType] == true)
	{

		//Declare:
		float RandomAngles[3];

		//Initialize:
		GetClientAbsAngles(Client, RandomAngles);

		RandomAngles[1] = GetRandomFloat(0.0, 360.0);

		//Teleport:
		TeleportEntity(Client, SpawnPoints[Roll][SpawnType], RandomAngles, NULL_VECTOR);
	}

	//Override:
	else
	{

		//Set Spawn:
		RandomizeSpawn(Client, SpawnType);
	}
}

//Create NPC:
public Action CommandCreateSpawn(int Client, int Args)
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
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createspawn <id> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	char sSpawnId[32];
	char Type[32];

	//Initialize:
	GetCmdArg(1, sSpawnId, sizeof(sSpawnId));

	GetCmdArg(2, Type, sizeof(Type));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[64];
	int SpawnId = StringToInt(sSpawnId);
	int IsCopSpawn = StringToInt(Type);

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Check:
	if(IsCopSpawn < 0 || IsCopSpawn > 2 || SpawnId < 0 || SpawnId > MAXSPAWNS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createspawn <1-%i> <0-1>", GetMaxClients());

		//Return:
		return Plugin_Handled;
	}

	//Spawn Already Created:
	if(SpawnPoints[SpawnId][IsCopSpawn][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE SpawnPoints SET Position = '%s' WHERE Map = '%s' AND Type = %i AND SpawnId = %i;", Position, ServerMap(), IsCopSpawn, SpawnId);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO SpawnPoints (`Map`,`Type`,`SpawnId`,`Position`) VALUES ('%s',%i,%i,'%s');", ServerMap(), IsCopSpawn, SpawnId, Position);
	}

	//Initulize:
	SpawnPoints[SpawnId][IsCopSpawn] = ClientOrigin;

	//Initulize:
	ValidSpawn[SpawnId][IsCopSpawn] = true;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action CommandRemoveSpawn(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removespawn <id> <Type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sSpawnId[32];
	char Type[32];

	//Initialize:
	GetCmdArg(1, sSpawnId, sizeof(sSpawnId));

	GetCmdArg(2, Type, sizeof(Type));

	//Declare:
	char query[512];
	int SpawnId = StringToInt(sSpawnId);
	int IsCopSpawn = StringToInt(Type);

	//Check:
	if(IsCopSpawn < 0 || IsCopSpawn > 2 || SpawnId < 1 || SpawnId > MAXSPAWNS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createspawn <1-%i> <0-1>", GetMaxClients());

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	ValidSpawn[IsCopSpawn][SpawnId] = false;

	//Loop:
	for(int i = 0; i < 3; i++)
	{

		//Initulize:
		SpawnPoints[IsCopSpawn][SpawnId][i] = 69.0;
	}

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM SpawnPoints WHERE SpawnId = %i AND Type = %i AND Map = '%s';", SpawnId, IsCopSpawn, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Spawn (ID #\x0732CD32%i\x07FFFFFF  TYPE #\x0732CD32%s\x07FFFFFF)", SpawnId, Type);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListSpawns(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Spawns:");

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM SpawnPoints WHERE Type = 0 AND Map = '%s' AND SpawnId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintSpawnList, query, conuserid);
	}

	//Timer:
	CreateTimer(1.5, CopList, Client);
		
	//Return:
	return Plugin_Handled;
}

//Load Spawn:
public Action CopList(Handle Timer, any Client)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Cop Spawns:");

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM SpawnPoints WHERE Type = 1 AND Map = '%s' AND SpawnId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintSpawnList, query, conuserid);
	}
}

public void T_DBPrintSpawnList(Handle owner, Handle hndl, const char[] error, any data)
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
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintSpawnList: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", SpawnId, Buffer);
		}
	}
}

public bool GetRandomSpawnPosition(int Team, float Position[3])
{

	//Declare:
	int Roll = GetRandomInt(0, MAXSPAWNS);

	//Invalid Spawn:
	if(ValidSpawn[Roll][Team] == true)
	{

		//Initulize:
		Position[0] = SpawnPoints[Roll][Team][0];
		Position[1] = SpawnPoints[Roll][Team][1];
		Position[2] = SpawnPoints[Roll][Team][2];

		//Return:
		return true;
	}

	//Return:
	return false;
}
