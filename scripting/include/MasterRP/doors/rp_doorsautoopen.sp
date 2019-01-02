//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_doorsautoopen_included_
  #endinput
#endif
#define _rp_doorsautoopen_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

public void initDoorAutoOpen()
{

	//Remove Props:
	RegAdminCmd("sm_createdoorautoopen", Command_CreateDoorAutoOpen, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removedoorautoopen", Command_RemoveDoorAutoOpen, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listautoopendoors", Command_ListDoorAutoOpen, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_restoreallsavedmapprops", Command_RestoreAllMapProp, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	//Timers:
	CreateTimer(0.2, CreateSQLdbDoorAutoOpen);
}

//Create Database:
public Action CreateSQLdbDoorAutoOpen(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorAutoOpen`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadDoorAutoOpen(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorAutoOpen WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadDoorAutoOpen, query);
}

public void T_DBLoadDoorAutoOpen(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadDoorAutoOpen: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Auto Open Doors Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = -1;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Check:
			if(IsValidEdict(X))
			{

				//Accept:
				AcceptEntityInput(X, "Unlock");

				//Accept:
				AcceptEntityInput(X, "Toggle");

			}
		}

		//Print:
		PrintToServer("|RP| - Auto Open Doors Found!");
	}
}

//Create Thumper:
public Action Command_CreateDoorAutoOpen(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ClassName[32];

	//Initulize:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Check:
	if(StrContains(ClassName, "prop", false) == 0 || StrContains(ClassName, "func", false) == 0)
	{

		//Declare:
		char query[512];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `DoorAutoOpen` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

		//Declare:
		Handle hDatabase = SQL_Query(GetGlobalSQL(), query);

		//Is Valid Query:
		if(hDatabase)
		{

			//Restart SQL:
			SQL_Rewind(hDatabase);

			//Declare:
			bool fetch = SQL_FetchRow(hDatabase);

			//Already Inserted:
			if(fetch)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - #%i has already been added to the auto open door database!", Ent);
			}

			//Override:
			else
			{

				//Format:
				Format(query, sizeof(query), "INSERT INTO DoorAutoOpen (`Map`,`DoorId`) VALUES ('%s',%i);", ServerMap(), Ent);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - #%i Has been successfully been added to the auto open door database", Ent);
			}
		}

		//Close:
		CloseHandle(hDatabase);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop - %s", ClassName);
	}

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action Command_RemoveDoorAutoOpen(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removedoorsautoopen <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `DoorAutoOpen` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), SpawnId);

	//Declare:
	Handle hDatabase = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hDatabase)
	{

		//Restart SQL:
		SQL_Rewind(hDatabase);

		//Declare:
		bool fetch = SQL_FetchRow(hDatabase);

		//Already Inserted:
		if(fetch)
		{

			//Format:
			Format(query, sizeof(query), "DELETE FROM `DoorAutoOpen` WHERE Map = '%s' AND DoorsId = %i;", ServerMap(), SpawnId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - #%i Has been successfully restored", SpawnId);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - unable to find #%i in the database!", SpawnId);
		}
	}

	//Close:
	CloseHandle(hDatabase);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListDoorAutoOpen(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Map Props Removed: %s", ServerMap());

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorAutoOpen WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintDoorAutoOpen, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintDoorAutoOpen(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client = 0;

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
		LogError("[rp_Core_Spawns] T_DBPrintDoorAutoOpen: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Print:
			PrintToConsole(Client, "%i", SpawnId);
		}
	}
}
