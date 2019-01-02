//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_publicdoors_included_
  #endinput
#endif
#define _rp_publicdoors_included_

//Defines:
#define MAXPUBLICDOORS		50

//Public Doors:
int PublicDoors[MAXPUBLICDOORS + 1] = {-1,...};

public void ResetPublicDoors()
{

	//Loop:
	for(int  i = 0; i <= MAXPUBLICDOORS; i++)
	{

		//Initulize:
		PublicDoors[i] = -1;
	}
}

public void initPublicDoors()
{

	//Vip Doors:
	RegAdminCmd("sm_createpublicdoor", Command_CreatePublicDoor, ADMFLAG_ROOT, "- <1-50> - Create a default Public door.");

	RegAdminCmd("sm_removepublicdoor", Command_RemPublicDoor, ADMFLAG_ROOT, "- <1-50> - Remove a default Public door.");

	RegAdminCmd("sm_listpublicdoors", Command_ListPublicDoors, ADMFLAG_SLAY, "- <No Args> - List the default Public doors.");

	//Beta
	RegAdminCmd("sm_wipepublicvoors", Command_WipePublicDoors, ADMFLAG_ROOT, "<No Args> - Remove All SQL Data");

	//Timer:
	CreateTimer(0.2, CreateSQLdbPublicDoors);
}

//Create Database:
public Action CreateSQLdbPublicDoors(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PublicDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `EntId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 111);
}

//Create Database:
public Action LoadPublicDoors(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM PublicDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadPublicDoors, query);
}

public void T_DBLoadPublicDoors(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadPublicDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Public Doors Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		int Ent = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 2);

			//Initulize:
			PublicDoors[X] = Ent;
		}

		//Print:
		PrintToServer("|RP| - Public Doors Loaded!");
	}
}

//Use Handle:
public void OnPublicDoorFuncUse(int Client, int Ent)
{

	//Check To Prevent Spam:
	if(!IsDoorOpening(Ent))
	{

		//Set:
		SetIsDoorOpening(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Unlock", Client);

		//Accept:
		AcceptEntityInput(Ent, "Toggle", Client);
/*
		//Declare:
		float Origin[3]; 
		decl Sound[128];

		//Format:
		Format(Sound, sizeof(Sound), "buttons/button3.wav");

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_vecVelocity", Origin);

		//Play Sound:
		EmitAmbientSound(Sound, Origin, Ent, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
*/
	}
}

//Use Handle:
public void OnPublicDoorPropShift(int Client, int Ent)
{

	//Set:
	SetIsDoorOpening(Ent, true);

	//Is Door Locked:
	if(GetDoorLocked(Ent))
	{

		//Initulize:
		SetDoorLocked(Ent, false);

		//Accept:
		AcceptEntityInput(Ent, "Unlock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - You have just Locked this door!");
	}

	//Accept:
	AcceptEntityInput(Ent, "Toggle", Client);
}

public bool NativeIsPublicDoor(int Ent)
{

	//Loop:
	for(int i = 0; i <= MAXPUBLICDOORS; i++)
	{

		//Is Public Door:
		if(PublicDoors[i] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action Command_CreatePublicDoor(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Wrong Parameter Usage: sm_createpublicdoor <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Var = StringToInt(Arg1);

	//Is Valid:
	if(Var > MAXPUBLICDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Usage: sm_createpublicdoor <\x0732CD320-%i\x07FFFFFF>", MAXPUBLICDOORS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Valid Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	bool alreadyadded = false;

	//Loop:
	for(int i = 0; i <= MAXPUBLICDOORS; i++)
	{

		//Is Public Door:
		if(PublicDoors[i] == Entdoor)
		{

			//Initulize:
			alreadyadded = true;
		}
	}

	//Check:
	if(alreadyadded)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Spawn Already Created:
	if(PublicDoors[Var] > -1)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE PublicDoors SET EntId = %i WHERE Map = '%s' AND DoorId = %i;", Entdoor, ServerMap(), Var);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO PublicDoors (`Map`,`DoorId`,`EntId`) VALUES ('%s',%i,%i);", ServerMap(), Var, Entdoor);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 112);

	//Initialize:
	PublicDoors[Var] = Entdoor;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default Public door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemPublicDoor(int Client, int Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removepublicdoor <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Var = StringToInt(Arg1);

	//Is Valid:
	if(Var > MAXPUBLICDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removepublicdoor <\x0732CD320-%i\x07FFFFFF>", 200);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(PublicDoors[Var] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Door #%i isn't a Public door!", Var);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	PublicDoors[Var] = -1;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM PublicDoors WHERE DoorId = %i AND Map = '%s';", Var, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 113);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-PublicDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default Public door database", Var);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListPublicDoors(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Public Door List:");

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM PublicDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintPublicDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipePublicDoors(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXPUBLICDOORS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM PublicDoors WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 114);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintPublicDoors(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintPublicDoors: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int DoorId = 0;
		int EntId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			DoorId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			EntId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: <%i>", DoorId, EntId);
		}
	}
}
