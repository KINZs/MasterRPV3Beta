//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vipdoors_included_
  #endinput
#endif
#define _rp_vipdoors_included_

//Defines:
#define MAXVIPDOORS		10

//Vip Doors:
int VipDoors[MAXVIPDOORS + 1] = {-1,...};
int OwnsVipDoor[2047] = {-1,...};

public void initVipDoors()
{

	//Vip Doors:
	RegAdminCmd("sm_createvipdoor", Command_CreateVipDoor, ADMFLAG_ROOT, "- <1-10> - Create a default Vip door.");

	RegAdminCmd("sm_removevipdoor", Command_RemVipDoor, ADMFLAG_ROOT, "- <1-10> - Remove a default Vip door.");

	RegAdminCmd("sm_listvipdoors", Command_ListVipDoors, ADMFLAG_SLAY, "- <No Args> - List the default Vip doors.");

	//Beta
	RegAdminCmd("sm_wipevipdoors", Command_WipeVipDoors, ADMFLAG_ROOT, "<No Args> - Remove All SQL Data");

	//Vip Doors:
	RegAdminCmd("sm_createvipclaimdoor", Command_CreateVipClaimDoor, ADMFLAG_ROOT, "- <1-50> - Create a default Vip door.");

	RegAdminCmd("sm_removevipclaimdoor", Command_RemVipClaimDoor, ADMFLAG_ROOT, "- <1-50> - Remove a default Vip door.");

	RegAdminCmd("sm_listvipclaimdoors", Command_ListVipClaimDoors, ADMFLAG_SLAY, "- <No Args> - List the default Vip doors.");

	//Beta
	RegAdminCmd("sm_wipevipclaimdoors", Command_WipeVipClaimDoors, ADMFLAG_ROOT, "<No Args> - Remove All SQL Data");

	//Player Commands:
	RegConsoleCmd("sm_claimvip", Command_ClaimVip);

	RegConsoleCmd("sm_unclaimvip", Command_UnClaimVip);

	//Timer:
	CreateTimer(0.2, CreateSQLdbVipDoors);

	CreateTimer(0.2, CreateSQLdbVipClaimDoors);
}

public void ResetVipDoors()
{

	//Loop:
	for(int  i = 0; i <= MAXVIPDOORS; i++)
	{

		//Initulize:
		VipDoors[i] = -1;
	}

	//Loop:
	for(int  i = 0; i < 2047; i++)
	{

		//Initulize:
		OwnsVipDoor[i] = -1;
	}
}

//Create Database:
public Action CreateSQLdbVipDoors(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VipDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `EntId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 111);
}

//Create Database:
public Action CreateSQLdbVipClaimDoors(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VipClaimDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `EntId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `STEAMID` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 111);
}

//Create Database:
public Action LoadVipDoors(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VipDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVipDoors, query);
}

public void T_DBLoadVipDoors(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVipDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vip Doors Found in DB!");

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
			VipDoors[X] = Ent;
		}

		//Print:
		PrintToServer("|RP| - Vip Doors Loaded!");
	}
}

//Create Database:
public Action LoadVipClaimDoors(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VipClaimDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVipClaimDoors, query);
}

public void T_DBLoadVipClaimDoors(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVipClaimDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vip Claim Doors Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int Ent = 0;
		int SteamId = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 2);

			//Initulize:
			OwnsVipDoor[Ent] = SteamId;
		}

		//Print:
		PrintToServer("|RP| - Vip Claim Doors Loaded!");
	}
}

//Use Handle:
public void OnVipDoorFuncUse(int Client, int Ent)
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
public void OnVipDoorPropShift(int Client, int Ent)
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
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - You have just Locked this door!");
	}

	//Accept:
	AcceptEntityInput(Ent, "Toggle", Client);
}

public bool NativeIsVipDoor(int Ent)
{

	//Loop:
	for(int i = 0; i <= MAXVIPDOORS; i++)
	{

		//Is Vip Door:
		if(VipDoors[i] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action Command_CreateVipDoor(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_createvipdoor <ID>");

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
	if(Var > MAXVIPDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Usage: sm_createvipdoor <\x0732CD320-%i\x07FFFFFF>", MAXVIPDOORS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	bool alreadyadded = false;

	//Loop:
	for(int i = 0; i <= MAXVIPDOORS; i++)
	{

		//Is Vip Door:
		if(VipDoors[i] == Entdoor)
		{

			//Initulize:
			alreadyadded = true;
		}
	}

	//Check:
	if(alreadyadded)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Spawn Already Created:
	if(VipDoors[Var] > -1)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE VipDoors SET EntId = %i WHERE Map = '%s' AND DoorId = %i;", Entdoor, ServerMap(), Var);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO VipDoors (`Map`,`DoorId`,`EntId`) VALUES ('%s',%i,%i);", ServerMap(), Var, Entdoor);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 112);

	//Initialize:
	VipDoors[Entdoor] = 0;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default Vip door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemVipDoor(int Client, int Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removevipdoor <ID>");

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
	if(Var > MAXVIPDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removevipdoor <\x0732CD320-%i\x07FFFFFF>", 200);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(VipDoors[Var] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i isn't a Vip door!", Var);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	VipDoors[Var] = -1;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM VipDoors WHERE DoorId = %i AND Map = '%s';", Var, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 113);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default Vip door database", Var);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListVipDoors(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Vip Door List:");

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VipDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintVipDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeVipDoors(int Client, int Args)
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
	for(int X = 1; X < MAXVIPDOORS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM VipDoors WHERE DoorId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 114);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintVipDoors(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVipDoors: Query failed! %s", error);
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

public bool IsOwnsVipDoor(int Client, int Ent)
{

	//Is Vip Door:
	if(OwnsVipDoor[Ent] == SteamIdToInt(Client))
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public bool IsVipClaimDoor(int Ent)
{

	//Is Vip Door:
	if(OwnsVipDoor[Ent] != -1)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}


public int GetVipClaimDoor(int Ent)
{

	//Return:
	return view_as<int>(OwnsVipDoor[Ent]);
}

public Action Command_CreateVipClaimDoor(int Client, int Args)
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
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(OwnsVipDoor[Entdoor] >= 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "INSERT INTO VipClaimDoors (`Map`,`EntId`,`STEAMID`) VALUES ('%s',%i,%i);", ServerMap(), Entdoor, 0);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 112);

	//Initialize:
	OwnsVipDoor[Entdoor] = 0;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default Vip door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemVipClaimDoor(int Client, int Args)
{

	//Declare:
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(OwnsVipDoor[Entdoor] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	OwnsVipDoor[Entdoor] = -1;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM VipClaimDoors WHERE DoorId = %i AND Map = '%s';", Entdoor, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 113);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default Vip door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListVipClaimDoors(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Vip Claim Door List:");

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VipClaimDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintVipClaimDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeVipClaimDoors(int Client, int Args)
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
	for(int X = 1; X < 2047; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM VipClaimDoors WHERE EntId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 114);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintVipClaimDoors(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVipClaimDoors: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int EntId = 0;
		int SteamId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			EntId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: <%i>", EntId, SteamId);
		}
	}
}

public Action Command_ClaimVip(int Client, int Args)
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
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetDonator(Client) > 1 && !IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you don't have accces to this command!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(OwnsVipDoor[Entdoor] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i Has already been claimed!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Check:
	if(OwnsVipDoor[Entdoor] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Vip Door!");

		//Return:
		return Plugin_Handled;	
	}

	//Check:
	if(HasPlayerAlreadyClaimedVipDoor(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - You have already claimed your Vip door!");

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "UPDATE VipClaimDoors SET STEAMID = %i WHERE Map = '%s' AND EntId = %i;", SteamIdToInt(Client), ServerMap(), Entdoor);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 1120);

	//Initialize:
	OwnsVipDoor[Entdoor] = SteamIdToInt(Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - you have claimed vip Door \x0732CD32#%i\x07FFFFFF!", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_UnClaimVip(int Client, int Args)
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
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetDonator(Client) > 1 && !IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you don't have accces to this command!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(OwnsVipDoor[Entdoor] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i is unclaimable!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "UPDATE VipClaimDoors SET STEAMID = %i WHERE Map = '%s' AND EntId = %i;", 0, ServerMap(), Entdoor);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 1121);

	//Initialize:
	OwnsVipDoor[Entdoor] = 0;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - you have unclaimed vip Door \x0732CD32#%i\x07FFFFFF!", Entdoor);

	//Return:
	return Plugin_Handled;
}

public void ClaimDoorHud(int Client, int Ent, float NoticeInterval)
{

	//Declare:
	char FormatMessage[255];

	//Declare:
	int len = 0;

	//VIP Door:
	if(GetVipClaimDoor(Ent) == 0)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "VIP Door:");

		//Check:
		if(GetDonator(Client) == 2)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nThis door is unclaimed!");
		}

		//Override:
		else
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nA donation is required to own this door!");
		}
	}

	//Override:
	else
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "VIP Door:");

		//Notice:
		if(!StrEqual(GetNotice(Ent), "null"))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nNotice:\n%s", GetNotice(Ent));
		}

		//Notice Name:
		if(!StrEqual(GetNoticeName(Ent), "null"))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nName: %s", GetNoticeName(Ent));
		}

		//Notice:
		if(!StrEqual(GetNoticeDesc(Ent), "null"))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\n%s", GetNoticeDesc(Ent));
		}

		//Locks
		if(DoorLocks[Ent] > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nLocks : %i", GetDoorLocks(Ent));
		}
	}

	//Declare:
	float Pos[2] = {-1.0, -0.805};
	int Color[4];

	//Initulize:
	Color[0] = GetEntityHudColor(Client, 0);
	Color[1] = GetEntityHudColor(Client, 1);
	Color[2] = GetEntityHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 1, Pos, Color, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 1, Pos, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
	}
}


public int GetOwnsVipDoor(int Ent)
{

	//Return:
	return OwnsVipDoor[Ent];
}

public bool HasPlayerAlreadyClaimedVipDoor(int Client)
{

	//Declare:
	int SteamId = SteamIdToInt(Client);
	bool Result = false;

	//Loop:
	for(int X = GetMaxClients() + X; X < 2047; X++)
	{

		//Check:
		if(OwnsVipDoor[X] == SteamId)
		{

			//Initulize:
			Result = true;
		}
	}

	//Return:
	return view_as<bool>(Result);
}