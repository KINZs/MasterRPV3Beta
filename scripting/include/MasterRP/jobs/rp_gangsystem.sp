//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_gangsystem_included_
  #endinput
#endif
#define _rp_gangsystem_included_

//Definitions:
#define MAXGANGPLAYERS 		15

//Misc:
char Gang[MAXPLAYERS + 1][32]; //Loaded from rp_player.sp
float GangCooldown[MAXPLAYERS + 1] = {0.0,...};

public void initGangSystem()
{

	//Commands:
	RegConsoleCmd("sm_creategang", Command_CreateGang);

	RegConsoleCmd("sm_removegang", Command_RemoveGang);

	RegConsoleCmd("sm_listgangs", Command_ListGangs);

	RegConsoleCmd("sm_leavegang", Command_LeaveGang);

	RegConsoleCmd("sm_kickgangmember", Command_KickGangMember);

	RegConsoleCmd("sm_gangs", Command_Gangs);

	RegConsoleCmd("sm_updategangtag", Command_UpdateGangTag);

	//Timer:
	CreateTimer(0.2, CreateSQLdbGangsystem);
}

//Create Database:
public Action CreateSQLdbGangsystem(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `GangSystem`");

	len += Format(query[len], sizeof(query)-len, " (`GangOwner` int(11) NULL, `GangName` varchar(32) NULL,");

	len += Format(query[len], sizeof(query)-len, " `DoorId` int(11) NULL, `GangLevel` int(11) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Respect` int(11) NULL, `GangTag` varchar(6) NULL, ");

	len += Format(query[len], sizeof(query)-len, " `GangTagColor` varchar(16) NULL);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

char GetGang(int Client)
{

	//return:
	return Gang[Client];
}

public void SetGang(int Client, const char[] Str)
{

	//Format:
	Format(Gang[Client], sizeof(Gang[]), "%s", Str);

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[32];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Gang = '%s' WHERE STEAMID = %i;", Gang[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetGangPlayerCount(int Client, char SearchGang[32])
{

	//Declare:
	int PlayerCount = 0;

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Player` WHERE STEAMID = %i AND Gang = '%s';", SteamIdToInt(Client), SearchGang);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Already Inserted:
		while(SQL_FetchRow(hQuery))
		{

			//Initulize:
			PlayerCount += 1;
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<int>(PlayerCount);
}

public int GetGangBaseDoor(int Client)
{

	//Declare:
	int BaseDoorId = 0;

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `GangSystem` WHERE GangOwner = %i;", SteamIdToInt(Client));

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Declare:
		bool Fetch = SQL_FetchRow(hQuery);

		//Already Inserted:
		if(Fetch)
		{

			//Database Field Loading Intiger:
			BaseDoorId = SQL_FetchInt(hQuery, 2);
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<int>(BaseDoorId);
}

public void UpdateGangBase(int Client, int DoorEnt)
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE GangSystem SET DoorId = %i WHERE GangOwner = %i;", DoorEnt, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public int RemoveGangFromPlayerDb(char SearchGang[32])
{

	//Declare:
	int PlayerCount = 0;

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Player` WHERE GangName = '%s';", SearchGang);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Declare:
		int SteamId = -1;

		//Already Inserted:
		while(SQL_FetchRow(hQuery))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hQuery, 0);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Player SET Gang = 'null' WHERE STEAMID = %i;", SteamId);

			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 54);
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<int>(PlayerCount);
}

public void SetGangDefault(int Client, const char[] Str)
{

	//Format:
	Format(Gang[Client], sizeof(Gang[]), "%s", Str);
}

//Create Gang:
public Action Command_CreateGang(int Client, int Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_creategang <gang>");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	if(!StrEqual(Gang[Client], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are currently in a gang");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Name[32];

	//Initialize:
	GetCmdArg(1, Name, 32);

	//Remove Harmfull Strings:
	SQL_EscapeString(GetGlobalSQL(), Name, Name, sizeof(Name));

	//Initulize:
	OnPlayerCreateGang(Client, Name);

	//Return:
	return Plugin_Handled;
}

public bool IsOwnerOfGang(int Client, char Name[32])
{

	//Declare:
	char query[255];
	bool Result = false;

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `GangSystem` WHERE GangName = '%s';", Name);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Declare:
		int Owner = 0;

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hQuery))
		{

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hQuery, 0);

			//Is Owner:
			if(Owner == SteamIdToInt(Client))
			{

				//Initulize:
				Result = true;
			}
		}

	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<bool>(Result);
}

public void OnPlayerCreateGang(int Client, char Name[32])
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `GangSystem` WHERE GangName = '%s';", Name);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Not Player:
		if(SQL_GetRowCount(hQuery))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a gang using this name");
		}

		//Override:
		else
		{

			//Declare:
			int Amount = 150000;

			//Check:
			if(GetBank(Client) - Amount > 0)
			{

				//Initulize:
				SetBank(Client, (GetBank(Client) - Amount));

				//Format:
				Format(query, sizeof(query), "INSERT INTO GangSystem (`GangOwner`,`GangName`,`DoorId`,`GangLevel`,`Respect`,`GangTag`,`GangTagColor`) VALUES (%i,'%s',0,1,0,'null','null');", SteamIdToInt(Client), Name);

				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Gang:
				SetGang(Client, Name);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have created gang \x0732CD32%s\x07FFFFFF for \x0732CD32%s", Name, IntToMoney(Amount));
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - It costs \x0732CD32%s\x07FFFFFF to create a gang", IntToMoney(Amount));
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - failed to create gang \x0732CD32%s", Name);
	}

	//Close:
	CloseHandle(hQuery);
}

//Remove Gang:
public Action Command_RemoveGang(int Client, int Args)
{
	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	if(StrEqual(Gang[Client], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are currently not in a gang");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	else
	{

		//Initulize:
		OnPlayerRemoveGang(Client);
	}

	//Return:
	return Plugin_Handled;
}

public void OnPlayerRemoveGang(int Client)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM GangSystem WHERE GangName = '%s';", Gang[Client]);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadOnPlayerRemoveGang, query, conuserid);
}

public void T_DBLoadOnPlayerRemoveGang(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_GangSystem] T_DBLoadOnPlayerRemoveGang: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Gang Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int Owner = 0;

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 0);

			//Is Owner:
			if(Owner == SteamIdToInt(Client))
			{

				//Declare:
				int Count = GetGangPlayerCount(Client, Gang[Client]);
				int Amount = (Count * 50000);

				//Check:
				if(GetBank(Client) - Amount > 0)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Amount));

					//Declare:
					char query[255];

					//Sql String:
					Format(query, sizeof(query), "DELETE FROM GangSystem WHERE GangName = '%s';", Gang[Client]);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

					RemoveGangFromPlayerDb(Gang[Client]);

					SetGang(Client, "null");

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have removed your gang for \x0732CD32%s\x07FFFFFF", IntToMoney(Amount));
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough money to remove your gang, costs \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF per player", IntToMoney(Amount), IntToMoney(50000));
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have access to this command");
			}
		}

		//Print:
		PrintToServer("|RP| - Gang System Loaded!");
	}
}

//List Gangs:
public Action Command_ListGangs(int Client, int Args)
{	

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Declare:
	char query[512];

	//Print:
	PrintToConsole(Client, "Gang List:");

	//Format:
	Format(query, sizeof(query), "SELECT * FROM GangSystem;");

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintGangList, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintGangList(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_GangSystem] T_DBPrintGangList: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int Level = 0;
		int Owner = 0;
		char Name[32];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Level = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Name, 32);

			//Print:
			PrintToConsole(Client, "Gang Name %s, Level %i, Owner %i, ", Name, Level, Owner);
		}
	}
}

//Remove Gang:
public Action Command_LeaveGang(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is In Gang:
	if(StrEqual(Gang[Client], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are currently not in a gang");

		//Return:
		return Plugin_Handled;
	}

	//Is Owner Of Gang:
	if(IsOwnerOfGang(Client, Gang[Client]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't leave your own gang you can only remove it");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Amount = 10000;

	//Check:
	if(GetBank(Client) - Amount < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have the money to leave this gang");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	else
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && StrEqual(Gang[i], Gang[Client]) && i != Client)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%i\x07FFFFFF has left the gang!", Client);
			}
		}

		//Initulize:
		SetGang(Client, "null");

		SetBank(Client, (GetBank(Client) - Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have left this gang for \x0732CD32%i\x07FFFFFF!", Amount);

	}

	//Return:
	return Plugin_Handled;
}

public void OnInvitePlayerToGang(int Client, int Player)
{

	//Initulize:
	if(GetGangPlayerCount(Client, Gang[Client]) >= MAXGANGPLAYERS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have reached the maximun amount of people you are allowed a gang, %i max", MAXGANGPLAYERS);
	}

	//Override:
	if(!StrEqual(Gang[Player], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is already in a gang!", Player);
	}

	//Initulize:
	else
	{

		//Initulize::
		SetMenuTarget(Player, Client);

		//Handle:
		Menu menu = CreateMenu(HandlePlayerInviteToGang);

		//Title:
		menu.SetTitle("%N\nHas gave you the option\nof offering a being\ninvited to there gang\n\nYour Answer...", Client);

		//Declare:
		char Bribe[32];

		//Format:
		Format(Bribe, sizeof(Bribe), "%i", 20000);

		//Declare:
		char Bribe2[32];

		//Format:
		Format(Bribe2, sizeof(Bribe2), "Accept %s", IntToMoney(20000));

		//Menu Button:
		menu.AddItem(Bribe, Bribe2);

		menu.AddItem("0", "no I wont accept");

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Player, 30);

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You inited \x0732CD32%N\x07FFFFFF to join your gang!", Player);
	}
}

//PlayerMenu Handle:
public int HandlePlayerInviteToGang(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Button Selected:
		if(Result != 0)
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Has Enough Cash:
				if(GetBank(Client) >= Result)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Result));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have joined gang \x0732CD32%s\x07FFFFFF!", Gang[Ent]);

					CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has accepted offer!", Client);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

					//Gang:
					SetGang(Client, Gang[Ent]);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
			}
		}

		//Override
		else
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have turned down \x0732CD32%N\x07FFFFFF's offer!", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has turned down your offer!", Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
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
	return view_as<bool>(true);
}

//Remove Gang:
public Action Command_KickGangMember(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Error:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_kickgangmember <Name>");

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
		CPrintToChat(Client, "%s - No matching client found!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	OnPlayerKickMemberOutOfGang(Client, Player);

	//Return:
	return Plugin_Handled;
}

public void OnPlayerKickMemberOutOfGang(int Client, int Player)
{

	//Check:
	if(Client == Player)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't kick your self");
	}

	//Is In Gang:
	if(StrEqual(Gang[Client], "null", false))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are currently not in a gang");
	}

	//Check:
	else if(!IsOwnerOfGang(Client, Gang[Client]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have access to this command");
	}

	//Is Medic:
	else if(!StrEqual(Gang[Client], Gang[Player], false))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is not in your gang", Player);
	}

	//Declare:
	int Amount = 10000;

	//Has Enough Cash:
	if(GetBank(Client) - Amount < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough money to kick \x0732CD32%N\x07FFFFFF, costs \x0732CD32%s\x07FFFFFF", Player, IntToMoney(Amount));
	}

	//Override:
	else
	{


		//Initulize:
		SetBank(Client, (GetBank(Client) - Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have kicked \x0732CD32%N\x07FFFFFF from your gang costing \x0732CD32%s\x07FFFFFF", Player, IntToMoney(Amount));

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has kicked you from there gang", Client);
	}
}

public void OnPlayerKilledGangCheck(int Client, int Attacker)
{

	//Declare:
	int ClientGangRespect = GetGangRespect(Client, Gang[Client]);
	int AttackerGangRespect = GetGangRespect(Attacker, Gang[Attacker]);
	int Amount = 0;

	//Both In a gang:
	if(!StrEqual(Gang[Client], "null") && StrEqual(Gang[Attacker], "null") && !StrEqual(Gang[Client], Gang[Attacker]) && !IsCop(Attacker) && !IsCop(Client))
	{

		//Initulize:
		Amount = 5;

		//Check:
		if(ClientGangRespect - Amount > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect - Amount));
		}

		//Override
		else if(ClientGangRespect > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], 0);
		}

		//Initulize:
		SetGangRespect(Attacker, Gang[Attacker], (AttackerGangRespect + Amount));
	}

	//Client Not in gang but Attacker is:
	if(StrEqual(Gang[Client], "null") && StrEqual(Gang[Attacker], "null") && !StrEqual(Gang[Client], Gang[Attacker]) && !IsCop(Attacker) && !IsCop(Client))
	{

		//Initulize:
		Amount = 3;

		//Initulize:
		SetGangRespect(Attacker, Gang[Attacker], (AttackerGangRespect + Amount));
	}

	//Client in a gang but attacker not:
	if(!StrEqual(Gang[Client], "null") && StrEqual(Gang[Attacker], "null") && !StrEqual(Gang[Client], Gang[Attacker]) && !IsCop(Attacker) && !IsCop(Client))
	{

		//Initulize:
		Amount = 3;

		//Check:
		if(ClientGangRespect - Amount > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect - Amount));
		}

		//Override
		else if(ClientGangRespect > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], 0);
		}
	}

	//Client in a gang but attacker is cop:
	if(!StrEqual(Gang[Client], "null") && IsCop(Attacker) && !IsCop(Client))
	{

		//Initulize:
		Amount = 5;

		//Check:
		if(ClientGangRespect - Amount > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect - Amount));
		}

		//Override
		else if(ClientGangRespect > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], 0);
		}

	}
}

public int GetGangRespect(int Client, char SearchGang[32])
{

	//Declare:
	int Respect = 0;

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `GangSystem` WHERE GangName = '%s';", SearchGang);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hQuery))
		{

			//Database Field Loading Intiger:
			Respect = SQL_FetchInt(hQuery, 4);
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<int>(Respect);
}

public void SetGangRespect(int Client, char SearchGang[32], int Amount)
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE GangSystem SET Respect = %i WHERE GangName = '%s'", Amount, SearchGang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public void OnPlayerCuffGangCheck(int Client, int Attacker)
{

	//Both In a gang:
	if(!StrEqual(Gang[Client], "null") && IsCop(Attacker))
	{

		//Declare:
		int ClientGangRespect = GetGangRespect(Client, Gang[Client]);
		int Amount = 2;

		//Check:
		if(ClientGangRespect - Amount > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect - Amount));
		}

		//Override
		else if(ClientGangRespect > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], 0);
		}
	}
}

public void initGangOwner(int Client)
{

	//Is Gang Owner:
	if(IsOwnerOfGang(Client, Gang[Client]))
	{

		//Declare:
		int ClientGangRespect = GetGangRespect(Client, Gang[Client]);
		int ClientGangLevel = GetGangLevel(Client, Gang[Client]);

		int NextLevel = ClientGangLevel * 125 * ClientGangLevel;

		//Check:
		if(ClientGangRespect >= NextLevel)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect - NextLevel));

			SetGangLevel(Client, Gang[Client], (ClientGangLevel + 1));

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i) && StrEqual(Gang[i], Gang[Client]))
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF Your gang has recieved a promotion, you are now level, \x0732CD32%i\x07FFFFFF!", Gang[Client], (ClientGangLevel + 1));
				}
			}
		}
	}
}

public int GetGangLevel(int Client, char SearchGang[32])
{

	//Declare:
	int Level = 0;

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `GangSystem` WHERE GangName = '%s';", SearchGang);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hQuery))
		{

			//Database Field Loading Intiger:
			Level = SQL_FetchInt(hQuery, 3);
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<int>(Level);
}

public void SetGangLevel(int Client, char SearchGang[32], int Amount)
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE GangSystem SET GangLevel = %i WHERE GangName = '%s'", Amount, SearchGang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public void OnPlayerSellDrugsGangCheck(int Client, int Amount)
{

	//Both In a gang:
	if(!StrEqual(Gang[Client], "null") && !IsCop(Client))
	{

		//Declare:
		int ClientGangRespect = GetGangRespect(Client, Gang[Client]);
		Amount = RoundFloat(float(Amount) / 2000.0);

		//Check:
		if(Amount > 0)
		{

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect + Amount));
		}
	}
}

//Remove Gang:
public Action Command_Gangs(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Show Menu:
	DrawTopGangMenu(Client);

	//Return:
	return Plugin_Handled;
}

public void DrawTopGangMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleTopGangMenu);

	//Declare:
	char title[256]; Format(title, sizeof(title), "This menu allows you to see\nthe top stats/rank for all players!");

	//Menu Title:
	menu.SetTitle(title);

	//Menu Button:
	menu.AddItem("0", "Top Gangs");

	//Is In Gang:
	if(!StrEqual(Gang[Client], "null"))
	{

		//Is Owner Of Gang:
		if(IsOwnerOfGang(Client, Gang[Client]))
		{

			//Menu Button:
			menu.AddItem("1", "Change Tag Color");
		}
	}

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleTopGangMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
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

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT GangName, GangLevel FROM `GangSystem` ORDER BY GangLevel DESC LIMIT 15;");

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopGangs, query, conuserid);
			}

			//Button Selected:
			if(Result == 1)
			{

				//Forward:
				DrawGangChangeTagColorMenu(Client);
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

public void T_SQLLoadRPTopGangs(Handle owner, Handle hndl, const char[] error, any data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Top] T_SQLLoadRPWinners: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		char FormatMessage[2048];
		int GangLevel[15];
		char GangName[15][32];

		//Declare:
		int len = 0;
		int i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Top Gangs:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, GangName[i], 32);

			//Database Field Loading Intiger:
			GangLevel[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (Level %i)\n", GangName[i], GangLevel[i]);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public void DrawGangChangeTagColorMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleTopGangColorMenu);

	//Declare:
	char title[256]; Format(title, sizeof(title), "Change the color of your tag!");

	//Menu Title:
	menu.SetTitle(title);

	//Menu Button:
	menu.AddItem("20000", "red");

	//Menu Button:
	menu.AddItem("20000", "green");

	//Menu Button:
	menu.AddItem("20000", "blue");

	//Menu Button:
	menu.AddItem("20000", "orange");

	//Menu Button:
	menu.AddItem("40000", "silver");

	//Menu Button:
	menu.AddItem("60000", "gold");

	//Menu Button:
	menu.AddItem("80000", "purple");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleTopGangColorMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];
			char display[16];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Initialize:
			int Amount = StringToInt(info);

			//Declare:
			char Color[16];

			//Format:
			Format(Color, sizeof(Color), "{%s}", display);

			//Check:
			if(GetBank(Client) - Amount > 0)
			{

				//Initulize:
				SetBank(Client, (GetBank(Client) - Amount));

				//Change Tag Color
				OnPlayerUpdateGangTagColor(Client, Color);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed the %sColor\x07FFFFFF of your tag costing \x0732CD32%s", Color, IntToMoney(Amount));
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough for this %sColor\x07FFFFFF costing \x0732CD32%s", Color, IntToMoney(Amount));
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

public void OnPlayerGangDropCrime(int Client, int Player)
{

	//Connected:
	if(IsClientConnected(Player) && IsClientInGame(Player))
	{

		//Check:
		if(GetCrime(Client) >= 2000)
		{

			//Check:
			if(GetCrime(Player) <= 5000)
			{

				//Is Disabled:
				if(GangCooldown[Client] > (GetGameTime() - 30))
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wait some time and try again.");
				}

				//Override:
				else
				{

					//Declare:
					int NewCrime = GetCrime(Client) / 5;

					//Set Crime:
					SetCrime(Client, (GetCrime(Client) - NewCrime));

					//Set Crime:
					SetCrime(Player, (GetCrime(Player) + NewCrime));

					//Initialize:
					GangCooldown[Client] = GetGameTime();

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have dropped some crime on \x0732CD32%N\x07FFFFFF!", Player);

					//Print:
					CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF have dropped some crime on you!", Client);

					//Declare:
					int ClientGangRespect = GetGangRespect(Client, Gang[Client]);

					//Initulize:
					SetGangRespect(Client, Gang[Client], (ClientGangRespect + 2));
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This player already has too much crime");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enouch crime to drop");
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This player is no longer available");
	}
}

public void OnPlayerGangPoison(int Client, int Player)
{

	//Connected:
	if(IsClientConnected(Player) && IsClientInGame(Player))
	{

		//Is Disabled:
		if(GangCooldown[Client] > (GetGameTime() - 120))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wait some time and try again.");
		}

		//Override:
		else
		{

			//Initialize:
			GangCooldown[Client] = GetGameTime();

			//Set Crime:
			SetCrime(Client, (GetCrime(Client) + 2000));

			//SDKHooks Forward:
			SDKHooks_TakeDamage(Player, Client, Client, 95.0, (1 << 17));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have poisoned \x0732CD32%N\x07FFFFFF!", Player);

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Has Poisoned you!", Client);

			//Declare:
			int ClientGangRespect = GetGangRespect(Client, Gang[Client]);

			//Initulize:
			SetGangRespect(Client, Gang[Client], (ClientGangRespect + 2));
		}
	}
}

//Remove Gang:
public Action Command_UpdateGangTag(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is In Gang:
	if(StrEqual(Gang[Client], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are currently not in a gang");

		//Return:
		return Plugin_Handled;
	}

	//Is Owner Of Gang:
	if(!IsOwnerOfGang(Client, Gang[Client]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have access to this command!");

		//Return:
		return Plugin_Handled;
	}
	//Is Valid:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updategangtag <tag> 6 char max");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Name[6];

	//Initialize:
	GetCmdArg(1, Name, 6);

	//Remove Harmfull Strings:
	SQL_EscapeString(GetGlobalSQL(), Name, Name, sizeof(Name));

	//Initulize:
	OnPlayerUpdateGangTag(Client, Name);

	//Return:
	return Plugin_Handled;
}

public void OnPlayerUpdateGangTag(int Client, char Tag[6])
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE GangSystem SET GangTag = '%s' WHERE GangOwner = %i;", Tag, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public void OnPlayerUpdateGangTagColor(int Client, char TagColor[16])
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE GangSystem SET GangTagColor = '%s' WHERE GangOwner = %i;", TagColor, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

char GetGangTag(int Client)
{

	//Declare:
	char Tag[6] = "null";

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT GangTag FROM `GangSystem` WHERE GangName = '%s';", Gang[Client]);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Declare:
		bool Fetch = SQL_FetchRow(hQuery);

		//Already Inserted:
		if(Fetch)
		{

			//Database Field Loading String:
			SQL_FetchString(hQuery, 0, Tag, 6);
		}
	}

	//Return:
	return view_as<char>(Tag);
}

char GetGangTagColor(int Client)
{

	//Declare:
	char TagColor[16] = "null";

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT GangTagColor FROM `GangSystem` WHERE GangName = '%s';", Gang[Client]);

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Declare:
		bool Fetch = SQL_FetchRow(hQuery);

		//Already Inserted:
		if(Fetch)
		{

			//Database Field Loading String:
			SQL_FetchString(hQuery, 0, TagColor, 16);
		}
	}

	//Return:
	return view_as<char>(TagColor);
}