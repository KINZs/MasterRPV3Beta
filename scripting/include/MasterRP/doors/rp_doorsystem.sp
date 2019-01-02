//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_doorsysten_included_
  #endinput
#endif
#define _rp_doorsystem_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

int MainOwner[2047] = {0,...};
bool HasKey[2047][MAXPLAYERS + 1];

public void initDoorSystem()
{

	//Commands:
	RegAdminCmd("sm_setdoorowner", Command_SetDoorOwner, ADMFLAG_SLAY, "- <Name> - Give a player ownership of a door.");

	RegAdminCmd("sm_removedoorowner", Command_RemoveDoorOwner, ADMFLAG_SLAY, "- <Name> - removed a players ownership of a door.");

	RegAdminCmd("sm_listdoorkeys", Command_ListDoorKeys, ADMFLAG_SLAY, "- <No Args> - List the All Door keys stored in db.");

	//Beta
	RegAdminCmd("sm_wipedoorKeys", Command_WipeDoorkeys, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_resetdoorowner", Command_ResetDoorOwner, ADMFLAG_ROOT, "");

	//Player Commands:
	RegConsoleCmd("sm_buydoor", Command_Buydoor);

	RegConsoleCmd("sm_selldoor", Command_Selldoor);

	RegConsoleCmd("sm_givekey", Command_GiveKey);

	RegConsoleCmd("sm_takekey", Command_TakeKey);

	RegConsoleCmd("sm_door", Command_Door);

	RegConsoleCmd("sm_doorname", Command_DoorName);

	RegConsoleCmd("sm_doordesc", Command_DoorDesc);

	RegConsoleCmd("sm_doormenu", Command_DoorMenu);

	RegConsoleCmd("sm_peak", Command_Peak);

	//Timer:
	CreateTimer(0.2, CreateSQLdbDoorKeys);

	CreateTimer(0.4, CreateSQLdbDoorSystem);
}

//Create Database:
public Action CreateSQLdbDoorKeys(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorKeys`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `STEAMID` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `DoorId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 97);
}

//Create Database:
public Action CreateSQLdbDoorSystem(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorSystem`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `STEAMID` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `DoorId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 97);
}

//Reset After Map Change:
public void OnMapStart_ResetDoorSystem()
{

	//Loop:
	for(int DoorId = 0; DoorId < 2047; DoorId++)
	{

		//Initulize:
		MainOwner[DoorId] = 0;

		//Loop:
		for(int Client = 0; Client <= GetMaxClients(); Client++)
		{

			//Initulize:
			HasKey[DoorId][Client] = false;
		}
	}
}

//Load:
public Action LoadDoorMainOwners(Handle Timer)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadMainOwnerCallback, query);
}

//Load:
public Action DBLoadKeys(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorKeys WHERE Map = '%s' AND STEAMID = %i;", ServerMap(), SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadKeysCallback, query, conuserid);
}

//Load:
public Action DBLoadOwner(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s' AND STEAMID = %i;", ServerMap(), SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadOwnerCallback, query, conuserid);
}

public void T_DBLoadOwnerCallback(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Player] T_DBLoadKeysCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Check:
		if(IsClientInGame(Client))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| Loading player Main Doors...");
		}

		//Declare:
		int DoorId = 0;
		int SteamId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Fetch SQL Data:
			SteamId = SQL_FetchInt(hndl, 1);

			//Fetch SQL Data:
			DoorId = SQL_FetchInt(hndl, 2);

			//Initulize:
			MainOwner[DoorId] = SteamId;
		}

		//CPrint:
		PrintToConsole(Client, "|RP| Your Main Owner door have loaded!");
	}
}

public void T_DBLoadKeysCallback(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Player] T_DBLoadKeysCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Check:
		if(IsClientInGame(Client))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| Loading player Door Keys...");
		}

		//Declare:
		int DoorId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Fetch SQL Data:
			DoorId = SQL_FetchInt(hndl, 2);

			//Initulize:
			HasKey[DoorId][Client] = true;
		}

		//CPrint:
		PrintToConsole(Client, "|RP| Your door keys have loaded!");
	}
}

public void T_DBLoadMainOwnerCallback(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Player] T_DBLoadMainOwnerCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Door Owners Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int DoorId = 0;
		int SteamId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Fetch SQL Data:
			SteamId = SQL_FetchInt(hndl, 1);

			//Fetch SQL Data:
			DoorId = SQL_FetchInt(hndl, 2);

			//Initulize:
			MainOwner[DoorId] = SteamId;
		}

		//Print:
		PrintToServer("|RP| - Door Owners Loaded!");
	}
}

//Reset Player Keys after Disconnect:
public void ResetKeys(int Client)
{

	//Loop:
	for(int DoorId = 0; DoorId < 2047; DoorId++)
	{

		//Initulize:
		HasKey[DoorId][Client] = false;
	}
}

//Function to get how many doors a Client owns:
public int GetClientDoorsAlreadyOwn(int Client)
{

	//Declare:
	int Result = 0;

	//Loop:
	for(int DoorId = 0; DoorId < 2047; DoorId++)
	{

		//Check:
		if(MainOwner[DoorId] == SteamIdToInt(Client))
		{

			//Initulize:
			Result += 1;
		}
	}

	//Return:
	return view_as<int>(Result);
}

//Reset Player Keys
public void DBResetDoorKeys(int DoorId)
{

	//Declare:
	char query[512];

	//Loop:
	for(int Client = 0; Client <= GetMaxClients(); Client++)
	{

		//Initulize:
		HasKey[DoorId][Client] = false;

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM DoorKeys WHERE DoorId = %i AND Map = '%s';", DoorId, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 98);
	}
}


//List Spawns:
public Action Command_ListDoorKeys(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Door Key List: %s", ServerMap());

	//Print:
	PrintToConsole(Client, "Main Owner Steam Id: %i", MainOwner[Ent]);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorKeys WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintDoorKeys, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeDoorkeys(int Client, int Args)
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
		Format(query, sizeof(query), "DELETE FROM DoorKeys WHERE DoorId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 99);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintDoorKeys(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintDoorsPrice: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SteamId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 1);

			//Print:
			PrintToConsole(Client, "Key Owner SteamId: %i", SteamId);
		}
	}
}

public void T_DBLoadDoorSteamId(Handle owner, Handle hndl, const char[] error, any data)
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
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadDoorSteamId: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SteamId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 1);

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", ServerMap(), SteamId);

			//Declare:
			int conuserid = GetClientUserId(Client);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBPrintNameFromSteamId, query, conuserid);
		}
	}
}

public void T_DBPrintNameFromSteamId(Handle owner, Handle hndl, const char[] error, any data)
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
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Player] T_DBPrintNameFromSteamId: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		char Buffer[255];
		int SteamId = 0;

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Buffer, sizeof(Buffer));

			//Print:
			PrintToConsole(Client, "%s (SteamId:%i)", Buffer, SteamId);
		}
	}
}

//Allows an admin to give a ownership of a door to a player
public Action Command_SetDoorOwner(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_setdoorowner <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door Already has an owner!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Price = GetDoorPrice(Ent);

	//Is Valid:
	if(Price == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "INSERT INTO DoorSystem (`Map`,`DoorId`,`Steamid`) VALUES ('%s',%i,%i);", ServerMap(), Ent, SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 100);

	//Initulize:
	HasKey[Ent][Player] = true;

	MainOwner[Ent] = SteamIdToInt(Player);

	//SetDoor:
	SetDoorBuyable(Ent, false);

	//Sql Strings:
	Format(query, sizeof(query), "%N", Client);

	//Reset Door Notice:
	SetNoticeName(Ent, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have give ownership of this door \x0732CD32%i\x07FFFFFF to\x0732CD32%N\x07FFFFFF!", Ent, Player);

	//Return:
	return Plugin_Handled;
}

//Remove players ownership if connected!
public Action Command_RemoveDoorOwner(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_removedoorowner <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(MainOwner[Ent] != SteamIdToInt(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have ownership of this door!", Player);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	HasKey[Ent][Player] = false;

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i And STEAMID = %i;", ServerMap(), Ent, SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 101);

	//Print:
	CPrintToChat(Player, "\x07FF4040|RP-Door|\x07FFFFFF - Your ownership for door \x0732CD32#%i\x07FFFFFF! has been removed!", Ent);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have taken \x0732CD32%N\x07FFFFFF ownership for door \x0732CD32#%i\x07FFFFFF!", Player, Ent);

	//Return:
	return Plugin_Handled;
}

//Removes ownership of a door if player disconnected
public Action Command_ResetDoorOwner(int Client, int Args)
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
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has no owner!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	DBResetDoorKeys(Ent);

	MainOwner[Ent] = 0;

	//SetDoor:
	SetDoorBuyable(Ent, true);

	//Reset Door Notice:
	RemoveNotice(Ent);

	RemoveNoticeName(Ent);

	RemoveNoticeDesc(Ent);

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		if(GetMainDoorId(X) == Ent)
		{

			//Reset Door Notice:
			RemoveNotice(Ent);

			RemoveNoticeName(Ent);

			RemoveNoticeDesc(Ent);
		}
	}

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 102);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF This door has been Reset!");

	//Return:
	return Plugin_Handled;
}

//allows player to buy a door
public Action Command_Buydoor(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetOwnsVipDoor(Ent) >= 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You can't buy this Vip door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door is already bought!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Price = GetDoorPrice(Ent);

	//Is Valid:
	if(Price == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetClientDoorsAlreadyOwn(Client) >= GetMaxDoorsOwn())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You already own the maximun amount of doors allowed!");

		//Return:
		return Plugin_Handled;
	}

	//Has Money:
	if(GetBank(Client) >= Price)
	{


		// Dynamic Economy!
		AddServerSafeMoneyAll(Price);

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "INSERT INTO DoorSystem (`Map`,`DoorId`,`STEAMID`) VALUES ('%s',%i,%i);", ServerMap(), Ent, SteamIdToInt(Client), SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 103);

		//Initulize:
		HasKey[Ent][Client] = true;

		MainOwner[Ent] = SteamIdToInt(Client);

		//SetDoor:
		SetDoorBuyable(Ent, false);

		//Sql Strings:
		Format(query, sizeof(query), "%N", Client);

		//Reset Door Notice:
		SetNoticeName(Ent, query);

		//Initulize:
		SetBank(Client, (GetBank(Client) - Price));

		//Set Menu State:
		BankState(Client, Price);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You bought this door successful for \x0732CD32%s\x07FFFFFF!", IntToMoney(Price));
	}

	//Override:
	else
	{

		//Return:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have enough money to purchase this door.");

	}

	//Return:
	return Plugin_Handled;
}

//allows player to Sell a door
public Action Command_Selldoor(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetOwnsVipDoor(Ent) >= 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You can't buy this Vip door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has no owner!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Price = GetDoorPrice(Ent);

	//Is Valid:
	if(Price == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled!");

		//Return:
		return Plugin_Handled;
	}

	//Owner Check:
	if(MainOwner[Ent] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Check
	if(GetGangBaseDoor(Client) == Ent)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You can't sell this door untill you have removed the gang base!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	int SellPrice = RoundToFloor(Price * 0.9);

	//Check:
	if(SellPrice - GetServerSafeMoneyTotal() > 0)
	{

		// Dynamic Economy!
		TakeServerSafeMoneyAll(SellPrice);
	}

	//Override:
	else
	{

		// Dynamic Economy!
		TakeServerSafeMoneyAll(GetServerSafeMoneyTotal());
	}

	DBResetDoorKeys(Ent);

	MainOwner[Ent] = 0;

	//SetDoor:
	SetDoorBuyable(Ent, true);

	//Initulize:
	SetBank(Client, (GetBank(Client) + SellPrice));

	//Set Menu State:
	BankState(Client, Price);

	//Reset Door Notice:
	RemoveNotice(Ent);

	RemoveNoticeName(Ent);

	RemoveNoticeDesc(Ent);

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		if(GetMainDoorId(X) == Ent)
		{

			//Reset Door Notice:
			RemoveNotice(Ent);

			RemoveNoticeName(Ent);

			RemoveNoticeDesc(Ent);
		}
	}

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 104);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF This door has been sold succesful for \x0732CD32%s\x07FFFFFF!", IntToMoney(SellPrice));

	//Return:
	return Plugin_Handled;
}

//allows player to Give a key to another player
public Action Command_GiveKey(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_givekey <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(MainOwner[Ent] != SteamIdToInt(Client) && GetOwnsVipDoor(Ent) != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));
	
	//Deckare:
	int Player = FindTarget(Client, arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Valid Player:
	if(Player == Client)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You can't give keys to your self!");

		//Return:
		return Plugin_Handled;
	}

	//Valid Player:
	if(IsFakeClient(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You can't give keys to a bot!");

		//Return:
		return Plugin_Handled;
	}

	//Check Already has keys:
	if(HasKey[Ent][Player] == true)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Already has keys");

		//Return:
		return Plugin_Handled;
	}


	//Has Money:
	if(GetBank(Client) >= 2000)
	{

		//Declare:
		int Keys;
		char query[255];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `DoorLocked` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

		//Declare:
		Handle hDatabase = SQL_Query(GetGlobalSQL(), query);

		//Is Valid Query:
		if(hDatabase)
		{

			//Database Row Loading INTEGER:
			while(SQL_FetchRow(hDatabase))
			{

				//Initulize:
				Keys += 1;
			}
		}

		//Close:
		CloseHandle(hDatabase);

		//Check Has To Many Keys:
		if(Keys < 5)
		{

			//Initulize:
			HasKey[Ent][Player] = true;

			//Initulize:
			SetBank(Client, (GetBank(Client) - 2000));

			//Set Menu State:
			BankState(Client, -2000);

			//Sql Strings:
			Format(query, sizeof(query), "INSERT INTO DoorKeys (`Map`,`DoorId`,`STEAMID`) VALUES ('%s',%i,%i);", ServerMap(), Ent, SteamIdToInt(Player));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP-Door|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has gave you a key to his door for \x0732CD32€2000\x07FFFFFF!", Client);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have gave a key to \x0732CD32%N\x07FFFFFF for \x0732CD32€2000\x07FFFFFF!", Player);
		}

		//Override:
		else
		{
			//Return:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You already have given out too many keys (5 max)");
		}
	}

	//Override:
	else
	{
		//Return:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have enough money to give a key to \x0732CD32%N.", Player);
	}

	//Return:
	return Plugin_Handled;
}

//allows player to take away a key from another player
public Action Command_TakeKey(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_takekey <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(MainOwner[Ent] != SteamIdToInt(Client) && GetOwnsVipDoor(Ent) != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Valid Player:
	if(IsFakeClient(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You can't give keys to a bot!");

		//Return:
		return Plugin_Handled;
	}

	//Has Money:
	if(GetBank(Client) < 1000)
	{

		//Return:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have enough money to take a key from \x0732CD32%N.", Player);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	HasKey[Ent][Player] = false;

	//Set Menu State:
	BankState(Client, -1000);

	//Initulize:
	SetBank(Client, (GetBank(Client) - 1000));

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorKeys WHERE Map = '%s' AND DoorId = %i And STEAMID = %i;", ServerMap(), Ent, SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 106);

	//Print:
	CPrintToChat(Player, "\x07FF4040|RP-Door|\x07FFFFFF - %N has taken your key to his door for \x0732CD32€1000\x07FFFFFF!", Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have taken a key from \x0732CD32%N\x07FFFFFF for \x0732CD32€1000\x07FFFFFF!", Player);

	//Return:
	return Plugin_Handled;
}

//Load door owner and who owns a key to the door!
public Action Command_Door(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	int Ent = GetClientAimTarget(Client, false);

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && !LookingAtWall(Client) && IsValidEdict(Ent))
	{

		//Is Door:
		if(IsValidDoor(Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - See console for output.");

			//Print:
			PrintToConsole(Client, "DoorID: = #%i", Ent);

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

			//Declare:
			int  conuserid = GetClientUserId(Client);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBLoadDoorSteamId, query, conuserid);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - See console for output.");

			//Print:
			PrintToConsole(Client, "EnityID: = #%i", Ent);
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Entity");
	}

	//Return:
	return Plugin_Handled;
}

//Notice:
public Action Command_DoorName(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Usage: sm_doorname <text>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Owner Check:
	if(MainOwner[Ent] != SteamIdToInt(Client) || MainOwner[GetMainDoorId(Ent)] != SteamIdToInt(Client) || GetOwnsVipDoor(Ent) != SteamIdToInt(Client) || !IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[255];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Remove Harmfull Strings:
	SQL_EscapeString(GetGlobalSQL(), Arg1, Arg1, sizeof(Arg1));

	//Initulize:
	SetNoticeName(Ent, Arg1);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%i\x07FFFFFF on #%i!", Arg1, Ent);

	//Return:
	return Plugin_Handled;
}

//Notice:
public Action Command_DoorDesc(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Usage: sm_noticedesc <text>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Owner Check:
	if(MainOwner[Ent] != SteamIdToInt(Client) || MainOwner[GetMainDoorId(Ent)] != SteamIdToInt(Client) || GetOwnsVipDoor(Ent) != SteamIdToInt(Client) || !IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[255];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Remove Harmfull Strings:
	SQL_EscapeString(GetGlobalSQL(), Arg1, Arg1, sizeof(Arg1));

	//Initulize:
	SetNoticeDesc(Ent, Arg1);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%i\x07FFFFFF on #%i!", Arg1, Ent);

	//Return:
	return Plugin_Handled;
}

//Door Manage Menu!
public Action Command_DoorMenu(int Client, int Args)
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
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - No door selected.");

		//Return:
		return Plugin_Handled;
	}

	//Valid Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door.");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	SetMenuTarget(Client, Ent);

	//Declare:
	char Buffer[256];

	//Format:
	Format(Buffer, sizeof(Buffer), "Choose an option for this door:\n\nDoor ID: #%i\nDoor Price: €%i\nSell Price: €%i\nLocks #%i", Ent, GetDoorPrice(Ent), RoundToFloor(GetDoorPrice(Ent)*0.9), GetDoorLocked(Ent));

	//Buyable:
	if(GetDoorPrice(Ent) != 0)
	{

		//Is Owner:
		if(MainOwner[Ent] == SteamIdToInt(Client))
		{

			//Declare:
			Menu menu = CreateMenu(HandleOwnDoor);

			//Title:
			menu.SetTitle(Buffer);

			//Menu Button:
			menu.AddItem("0", "Manage Door");

			menu.AddItem("1", "Manage Keys");

			menu.AddItem("2", "Manage Locks");

			menu.AddItem("3", "View Online Owners");

			//Is Owner Of Gang:
			if(IsOwnerOfGang(Client, GetGang(Client)))
			{

				//Declare:
				int GangDoor = GetGangBaseDoor(Client);

				//Is Main Gang Door:
				if(GangDoor == Ent)
				{

					//Menu Button:
					menu.AddItem("7", "remove gang base");

					menu.AddItem("4", "Peak");
				}

				//Check:
				else if(GangDoor == 0)
				{

					//Menu Button:
					menu.AddItem("6", "Convert to gang base");
				}

				//Print:
				//PrintToConsole(Client, "Gang Door: = #%i", GangDoor);
			}

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Has Keys But Not Main Owner:
		else if(MainOwner[Ent] != SteamIdToInt(Client) && HasKey[Ent][Client] == true)
		{

			//Declare:
			Menu menu = CreateMenu(HandleOwnDoor);

			//Title:
			menu.SetTitle(Buffer);

			//Menu Button:
			menu.AddItem("3", "View Online Owners");

			//Declare:
			int GangDoor = GetGangBaseDoor(Client);

			//Is Main Gang Door:
			if(GangDoor == Ent)
			{

				//Menu Button:
				menu.AddItem("4", "Peak");
			}

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Handle:
			Menu menu = CreateMenu(HandleBuydoor);

			//Title:
			menu.SetTitle(Buffer);

			//Owns Key:
			if(HasKey[Ent][Client] == true)
			{

				//Menu Button:
				menu.AddItem("0", "Key Info");
			}

			//Override:
			if(IsDoorBuyable(Ent))
			{

				//Menu Button:
				menu.AddItem("1", "Buy Door");
			}

			//Menu Button:
			menu.AddItem("3", "View Locks");

			menu.AddItem("4", "View Door Price");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}

	//Door has Parent
	else if(MainOwner[GetMainDoorId(Ent)] == SteamIdToInt(Client))
	{

		//Handle:
		Menu menu = CreateMenu(HandleOwnDoor);

		//Title:
		menu.SetTitle(Buffer);

		//Menu Button:
		menu.AddItem("2", "Manage Locks");

		menu.AddItem("3", "View Online Owners");

		menu.AddItem("5", "Update Name");

		menu.AddItem("4", "Peak");

		//Is Owner Of Gang:
		if(IsOwnerOfGang(Client, GetGang(Client)))
		{

			//Declare:
			int GangDoor = GetGangBaseDoor(Client);

			//Is Main Gang Door:
			if(GangDoor == Ent)
			{

				//Menu Button:
				menu.AddItem("7", "remove gang base");

				menu.AddItem("4", "Peak");
			}

			//Check:
			else if(GangDoor == 0)
			{

				//Menu Button:
				menu.AddItem("6", "Convert to gang base");
			}
		}

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}

	//Check:
	else if(GetOwnsVipDoor(Ent) == SteamIdToInt(Client) || HasKey[Ent][Client] == true)
	{

		//Is Owner:
		if(GetOwnsVipDoor(Ent) == SteamIdToInt(Client))
		{

			//Declare:
			Menu menu = CreateMenu(HandleOwnDoor);

			//Title:
			menu.SetTitle(Buffer);

			//Menu Button:
			menu.AddItem("0", "Manage Door");

			menu.AddItem("1", "Manage Keys");

			menu.AddItem("2", "Manage Locks");

			menu.AddItem("3", "View Online Owners");

			menu.AddItem("4", "Peak");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Has Keys But Not Main Owner:
		else
		{

			//Declare:
			Menu menu = CreateMenu(HandleOwnDoor);

			//Title:
			menu.SetTitle(Buffer);

			//Menu Button:
			menu.AddItem("3", "View Online Owners");

			//Menu Button:
			menu.AddItem("4", "Peak");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled.");
	}

	//Return:
	return Plugin_Handled;
}

//Item Handle:
public int HandleOwnDoor(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Initialize:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				char info[64];

				//Get Menu Info:
				menu.GetItem(Parameter, info, sizeof(info));

				//Initialize:
				int Result = StringToInt(info);

				//Button Selected:
				if(Result == 0)
				{

					//Handle:
					menu = CreateMenu(HandleManageDoor);

					//Title:
					menu.SetTitle("Choose an option for your door:");

					//Check
					if(GetDoorPrice(Ent) > 0)
					{

						//Menu Button:
						menu.AddItem("0", "Sell Door");
					}

					menu.AddItem("1", "Update Name");

					//Check
					if(GetDoorPrice(Ent) > 0)
					{

						//Menu Button:
						menu.AddItem("2", "View Door Price");
					}

					//Set Exit Button:
					menu.ExitButton = false;

					//Show Menu:
					menu.Display(Client, 30);
				}

				//Button Selected:
				if(Result == 1)
				{

					//Handle:
					menu = CreateMenu(HandleManageKeys);

					//Title:
					menu.SetTitle("Choose an option for your door:");

					//Menu Button:
					menu.AddItem("0", "Give Key");

					menu.AddItem("1", "Take Key");

					menu.AddItem("2", "Key Info");

					//Set Exit Button:
					menu.ExitButton = false;

					//Show Menu:
					menu.Display(Client, 30);
				}

				//Button Selected:
				if(Result == 2)
				{

					//Handle:
					menu = CreateMenu(HandleManageLocks);

					//Title:
					menu.SetTitle("Choose an option for your door:");

					//Menu Button:
					menu.AddItem("0", "Add Locks");

					menu.AddItem("1", "View Locks");

					menu.AddItem("2", "Remove Lock");

					//Set Exit Button:
					menu.ExitButton = false;

					//Show Menu:
					menu.Display(Client, 30);
				}

				//Button Selected:
				if(Result == 3)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF DoorID: = #%i", Ent);

					//Print:
					PrintToConsole(Client, "DoorID: = #%i",Ent);

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i++)
					{

						//Connected
						if(IsClientConnected(i) && !IsFakeClient(i))
						{

							if(MainOwner[Ent] == SteamIdToInt(i))
							{

								//Print:
								PrintToConsole(Client, "Door Owner: %N", i);
							}
						}
					}

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i++)
					{

						//Connected
						if(IsClientConnected(i) && !IsFakeClient(i))
						{

							if(GetOwnsVipDoor(Ent) == SteamIdToInt(i))
							{

								//Print:
								PrintToConsole(Client, "Vip Door Owner: %N", i);
							}
						}
					}

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i++)
					{

						//Connected
						if(IsClientConnected(i))
						{

							if(HasKey[Ent][i] == true && MainOwner[Ent] == SteamIdToInt(i))
							{

								//Print:
								PrintToConsole(Client, "Owns Key: %N", i);
							}
						}
					}
				}

				//Button Selected:
				if(Result == 4)
				{

					//Command:
					ClientCommand(Client, "sm_peak");
				}

				//Button Selected:
				if(Result == 5)
				{

					//Declare:
					char ClientName[255];

					//Initialize:
					GetClientName(Client, ClientName, sizeof(ClientName));

					//Remove Harmfull Strings:
					SQL_EscapeString(GetGlobalSQL(), ClientName, ClientName, sizeof(ClientName));

					//Initulize:
					SetNoticeName(Ent, ClientName);

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have updated this Door Name");
				}

				//Button Selected:
				if(Result == 6)
				{

					//Initialize:
					int Amount = 100000;

					//Can Transact:
					if(GetBank(Client) - Amount > 0)
					{

						//Update GangBase:
						UpdateGangBase(Client, Ent);

						//Initulize:
						SetBank(Client, (GetBank(Client) - Amount));

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have made this door your gang base door for \x0732CD32%s", IntToMoney(Amount));	
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You dont have enough money to convert this door into a gang base costs \x0732CD32%s", IntToMoney(Amount));
					}
				}

				//Button Selected:
				if(Result == 7)
				{

					//Initialize:
					int Amount = 20000;

					//Can Transact:
					if(GetBank(Client) - Amount > 0)
					{

						//Update GangBase:
						UpdateGangBase(Client, 0);

						//Initulize:
						SetBank(Client, (GetBank(Client) - Amount));

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You removed your gang base door for \x0732CD32%s", IntToMoney(Amount));	
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You dont have enough money to remove gang base costs \x0732CD32%s", IntToMoney(Amount));
					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//Item Handle:
public int HandleManageDoor(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Button Selected:
				if(Parameter == 0)
				{

					//Command:
					ClientCommand(Client, "sm_selldoor");
				}

				//Button Selected:
				if(Parameter == 1)
				{

					//Declare:
					char ClientName[255];

					//Initialize:
					GetClientName(Client, ClientName, sizeof(ClientName));

					//Remove Harmfull Strings:
					SQL_EscapeString(GetGlobalSQL(), ClientName, ClientName, sizeof(ClientName));

					//Initulize:
					SetNoticeName(Ent, ClientName);

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have updated this Door Name");
				}

				//Button Selected:
				if(Parameter == 2)
				{

					//Check
					if(GetDoorPrice(Ent) > 0)
					{

						//Pring:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - this door is \x0732CD32€%i\x07FFFFFF to buy.", GetDoorPrice(Ent));
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled.");
					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//Item Handle:
public int HandleManageKeys(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Button Selected:
				if(Parameter == 0)
				{

					//Handle:
					menu = CreateMenu(HandleManageGivekey);

					//Menu Title:
					menu.SetTitle("Give a key to?");

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i++)
					{

						//Connected:
						if(!IsClientInGame(i))
						{

							//Initialize:
							continue;
						}

						//Declare:
						char name[65];
						char ID[25];

						//Initialize:
						GetClientName(i, name, sizeof(name));

						//Convert:
						IntToString(i, ID, sizeof(ID));

						//Menu Button:
						menu.AddItem(ID, name);
					}

					//Set Exit Button:
					menu.ExitButton = false;

					//Show Menu:
					menu.Display(Client, 20);
				}

				//Button Selected:
				if(Parameter == 1)
				{

					//Handle:
					menu = CreateMenu(HandleManageTakekey);

					//Menu Title:
					menu.SetTitle("Take key to?");

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i++)
					{

						//Connected:
						if(!IsClientInGame(i))
						{

							//Initialize:
							continue;
						}

						//Declare:
						char name[65];
						char ID[25];

						//Initialize:
						GetClientName(i, name, sizeof(name));

						//Convert:
						IntToString(i, ID, sizeof(ID));

						//Menu Button:
						menu.AddItem(ID, name);
					}

					//Set Exit Button:
					menu.ExitButton = false;

					//Show Menu:
					menu.Display(Client, 20);
				}

				//Button Selected:
				if(Parameter == 2)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Keys cost \x0732CD32€%i\x07FFFFFF for each key, you have a maxinun of \x0732CD325\x07FFFFFF keys.", 5000);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//PlayerMenu Handle:
public int HandleManageGivekey(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				char info[255];

				//Get Menu Info:
				menu.GetItem(Parameter, info, 255);

				//Initialize:
				int Player = StringToInt(info);

				//Declare:
				char PlayerName[32];

				//Initialize:
				GetClientName(Player, PlayerName, sizeof(PlayerName));

				//Command:
				ClientCommand(Client, "sm_givekey \"%s\"", PlayerName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//PlayerMenu Handle:
public int HandleManageTakekey(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				char info[255];

				//Get Menu Info:
				menu.GetItem(Parameter, info, 255);

				//Initialize:
				int Player = StringToInt(info);

				//Declare:
				char PlayerName[32];

				//Initialize:
				GetClientName(Player, PlayerName, sizeof(PlayerName));

				//Command:
				ClientCommand(Client, "sm_takekey \"%s\"", PlayerName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//Item Handle:
public int HandleManageLocks(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				char info[64];

				//Get Menu Info:
				menu.GetItem(Parameter, info, sizeof(info));

				//Initialize:
				int Result = StringToInt(info);

				//Button Selected:
				if(Result == 0)
				{

					//Handle:
					menu = CreateMenu(HandleDoorAddLocks);

					//Title:
					menu.SetTitle("Your door has %i Locks", GetDoorLocks(Ent));

					//Menu Buttons:
					menu.AddItem("1", "1");

					menu.AddItem("5", "5");

					menu.AddItem("10", "10");

					menu.AddItem("20", "20");

					menu.AddItem("50", "50");

					menu.AddItem("100", "100");

					menu.AddItem("200", "200");

					menu.AddItem("500", "500");

					menu.AddItem("1000", "1000");

					//Set Exit Button:
					menu.ExitButton = false;

					//Show Menu:
					menu.Display(Client, 20);
				}

				//Button Selected:
				if(Result == 1)
				{


					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Your door has \x0732CD32%i\x07FFFFFF Locks", GetDoorLocks(Ent)); 
				}

				//Button Selected:
				if(Result == 2)
				{

					//Declare:
					int Amount = GetDoorLocks(Ent);

					//Enough Locks:
					if(Amount > 0)
					{

						//Initulize:
						SetCash(Client, (GetCash(Client) + (Amount * 800)));

						SetDoorLocks(Ent, 0);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have removed %i locks for %s", Amount, IntToMoney((Amount * 800)));
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you cannot take anymore locks of this door.");
					}
				}

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//PlayerMenu Handle:
public int HandleDoorAddLocks(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255]; 
		int Ent = GetMenuTarget(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Can Transact:
		if(!(GetBank(Client) + (Amount * 1000) < 0 || GetBank(Client) - (Amount * 1000) < 0) && GetBank(Client) !=0)
		{

			//Initialize:
			SetDoorLocks(Ent, (GetDoorLocks(Ent) + Amount));

			SetBank(Client, (GetBank(Client) - (Amount * 1000)));		

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have added %i \x0732CD32Locks\x07FFFFFF to your door!", Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have \x0732CD32%i\x07FFFFFF Locks!", Amount);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//Item Handle:
public int HandleBuydoor(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			int Ent = GetMenuTarget(Client);

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				char info[64];

				//Get Menu Info:
				menu.GetItem(Parameter, info, sizeof(info));

				//Initialize:
				int Result = StringToInt(info);

				//Button Selected:
				if(Result == 1)
				{

					//Command:
					ClientCommand(Client, "sm_buydoor");
				}

				//Button Selected:
				if(Result == 0 && HasKey[Ent][Client] == true)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Keys cost \x0732CD32€%i\x07FFFFFF for each key, you have a maxinun of \x0732CD325\x07FFFFFF keys.", 5000);
				}

				//Button Selected:
				if(Result == 3)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has \x0732CD32%i\x07FFFFFF Locks", GetDoorLocks(Ent)); 
				}

				//Button Selected:
				if(Result == 4)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - this door is \x0732CD32%s\x07FFFFFF to buy.", IntToMoney(GetDoorPrice(Ent))); 
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

//Notice:
public Action Command_Peak(int Client, int Args)
{

	//Declare:
	int Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Player Owners Door:
	if(GetMainDoorOwner(Ent) == SteamIdToInt(Client) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client) || GetGangBaseDoor(Client) == Ent || GetOwnsVipDoor(Ent) == SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Peak for 5 seconds!");

		//Set Client Render:
		SetEntityRenderMode(Ent, RENDER_TRANSCOLOR);

		//Set Client Color:
		SetEntityRenderColor(Ent, 50, 255, 50, 100);

		//Timer:
		CreateTimer(5.0, ResetPeak, Ent);
	}

	//Return:
	return Plugin_Handled;
}

//Create Database:
public Action ResetPeak(Handle Timer, any Ent)
{

	//Check:
	if(IsValidEdict(Ent))
	{

		//Set Client Render:
		SetEntityRenderMode(Ent, RENDER_NORMAL);

		//Set Client Color:
		SetEntityRenderColor(Ent, 255, 255, 255, 255);
	}
}

//Use Handle:
public Action OnClientDoorFuncUse(int Client, int Ent)
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
		char Sound[128];

		//Format:
		Format(Sound, sizeof(Sound), "buttons/button3.wav");

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_vecVelocity", Origin);

		//Play Sound:
		EmitAmbientSound(Sound, Origin, Ent, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
*/
	}

	//Return:
	return Plugin_Changed;
}

//Use Handle:
public Action OnClientDoorPropShift(int Client, int Ent)
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
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have just Locked this door!");
	}

	//Return:
	return Plugin_Changed;
}

public int GetMainDoorOwner(int Ent)
{

	//Return:
	return MainOwner[Ent];
}

public bool HasDoorKeys(int Ent, int Client)
{

	//Return:
	return HasKey[Ent][Client];
}