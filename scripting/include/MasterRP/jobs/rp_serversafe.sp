//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_serversafe_included_
  #endinput
#endif
#define _rp_serversafe_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = €

#define	MAXSERVERSAFES		10

//Useable Item Models!
//char ServerMoneySafeModel[256] = "models/ice_dragon/grey_medium_safe.mdl";
char ServerMoneySafeModel[256] = "models/dragon/black_safe.mdl";

//Server Money Safe MAXSERVERSAFES
int ServerSafeEnt[MAXSERVERSAFES + 1] = {-1,...};
int ServerSafeMoney[MAXSERVERSAFES + 1] = {0,...};
int ServeSafeLocks[MAXPLAYERS + 1] = {0,...};
int ServerSafeRob[MAXSERVERSAFES + 1] = {0,...};
char ServerSafeName[MAXSERVERSAFES + 1][255];
int ServerSafeRobCash[MAXPLAYERS + 1] = {0,...};
int ServerSafeRobEnt[MAXPLAYERS + 1] = {-1,...};
int SafeReplenTimer = 0;

public void initServerMoneySafe()
{

	//Server Money Safes
	RegAdminCmd("sm_createservermoneysafe", CommandCreateServerMoneySafe, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removeservermoneysafe", CommandRemoveServerMoneySafe, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listservermoneysafe", CommandListServerMoneySafe, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_updateserversafeposition", CommandServerUpdateSafePosition, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_updateserversafemap", CommandServerUpdateSafeMap, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setserversafemoney", CommandServerSetSafeMoney, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setserversafelocks", CommandServerSetSafeLocks, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setserversafename", CommandServerSetSafeName, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Initialize:
		ServerSafeRob[X] = 600;
	}

	//Timers:
	CreateTimer(0.2, CreateSQLdbServerMoneySafe);

}
//Create Database:
public Action CreateSQLdbServerMoneySafe(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `ServerMoneySafe`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NULL, `SafeId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NULL, `Angles` varchar(32) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeMoney` int(11) NULL,  `SafeLocks` int(11) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeName` varchar(255) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 1012);

}

//Create Database:
public Action LoadServerMoneySafe(Handle Timer)
{

	//Loop:
	for(int X = 0; X <= MAXSERVERSAFES; X++)
	{

		//Initulize:
		ServerSafeEnt[X] = -1;

		ServerSafeMoney[X] = 0;

		ServeSafeLocks[X] = 0;

		ServerSafeRob[X] = 0;

		ServerSafeRobCash[X] = 0;

		ServerSafeName[X] = "No Name";
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM ServerMoneySafe WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadServerMoneySafe, query, 1013);
}

public void T_DBLoadServerMoneySafe(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadServerMoneySafe: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Server Money Safes Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		int Money = 0;
		int Locks = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, sizeof(Buffer));

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];
			float Angles[3];

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 32);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 32);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading Intiger:
			Money = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			Locks = SQL_FetchInt(hndl, 5);

			//Database Field Loading String:
			SQL_FetchString(hndl, 6, Buffer, 32);

			//Create Thumper:
			CreatePropServerMoneySafe(Position, Angles, X, Money, Locks, Buffer);
		}

		//Print:
		PrintToServer("|RP| - Server Money Safe Found!");
	}
}

public Action BeginServerRobberySafe(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || ServerSafeRobEnt[Client] < 1)
	{

		//Initulize::
		ServerSafeRobCash[Client] = 0;

		ServerSafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Cleared:
	if(ServerSafeRobCash[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Stopped Robbing A Server Money Safe!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Initulize::
		ServerSafeRobCash[Client] = 0;

		ServerSafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int X = ServerSafeRobEnt[Client];

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(ServerSafeEnt[X], Prop_Send, "m_vecOrigin", Position);

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	float Dist = GetVectorDistance(Position, ClientOrigin);
	
	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Is Getting Away!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Initulize::
		ServerSafeRobCash[Client] = 0;

		ServerSafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Random = 0;

	//Is Valid:
	if(StrContains(GetJob(Client), "Street Thug", false) != -1 || StrContains(GetJob(Client), "Root Admin", false) != -1)
	{

		//Initulize:
		Random = GetRandomInt(5, 10);
	}

	//Override:
	else
	{

		//Initulize:
		Random = GetRandomInt(2, 5);
	}

	//Cleared:
	if(ServerSafeMoney[X] - Random > 0)
	{

		//Initulize:
		ServerSafeRobCash[Client] -= Random;

		ServerSafeMoney[X] -= Random;

		//Initialize:
		SetCash(Client, (GetCash(Client) + Random));

		//Initialize:
		SetCrime(Client, (GetCrime(Client) + (Random + Random)));

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 24);

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i AND Map = '%s' AND SafeId = %i;", ServerSafeMoney[X], ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 25);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Is Getting Away!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Initulize::
		ServerSafeRobCash[Client] = 0;

		ServerSafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool IsValidServerSafe(int Ent)
{

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public void BeginRobbingVendorToSafe(int Client, int Amount)
{

	//Check:
	if(Amount <= 0)
	{

		//Return:
		return;
	}

	//Declare:
	int Random = Amount;

	//Loop:
	while (Random > 0)
	{

		//Loop:
		for(int X = 0; X <= GetMaxServerSafes(); X++)
		{

			//Is Valid:
			if(IsValidEdict(ServerSafeEnt[X]))
			{

				//Set Amount:
				SetServerSafeMoney(X, (ServerSafeMoney[X] - 1));

				//Initulize:
				Random -= 1;
			}

			//Check:
			if(Random == 0)
			{

				//Stop:
				break;
			}
		}
	}
}

public void BeginRobbingBankToSafe(int Client, int Amount)
{

	//Check:
	if(Amount <= 0)
	{

		//Return:
		return;
	}

	//Declare:
	int Random = Amount;

	//Loop:
	while (Random > 0)
	{

		//Loop:
		for(int X = 0; X <= GetMaxServerSafes(); X++)
		{

			//Is Valid:
			if(IsValidEdict(ServerSafeEnt[X]))
			{

				//Set Amount:
				SetServerSafeMoney(X, (ServerSafeMoney[X] - 1));

				//Initulize:
				Random -= 1;
			}

			//Check:
			if(Random == 0)
			{

				//Stop:
				break;
			}
		}
	}
}

public void BeginRobbingComputerToSafe(int Client, int Amount)
{

	//Check:
	if(Amount <= 0)
	{

		//Return:
		return;
	}

	//Declare:
	int Random = Amount;

	//Check:
	if(Random > 1)
	{

		//Return:
		return;
	}

	//Loop:
	while (Random > 0)
	{

		//Loop:
		for(int X = 0; X <= GetMaxServerSafes(); X++)
		{

			//Is Valid:
			if(IsValidEdict(ServerSafeEnt[X]))
			{

				//Set Amount:
				SetServerSafeMoney(X, (ServerSafeMoney[X] - 1));

				//Initulize:
				Random -= 1;
			}

			//Check:
			if(Random == 0)
			{

				//Stop:
				break;
			}
		}
	}
}

public void BeginRobbingEmployerToSafe(int Client, int Amount)
{

	//Check:
	if(Amount <= 0)
	{

		//Return:
		return;
	}

	//Declare:
	int Random = Amount;

	//Loop:
	while (Random > 0)
	{

		//Loop:
		for(int X = 0; X <= GetMaxServerSafes(); X++)
		{

			//Is Valid:
			if(IsValidEdict(ServerSafeEnt[X]))
			{

				//Set Amount:
				SetServerSafeMoney(X, (ServerSafeMoney[X] - 1));

				//Initulize:
				Random -= 1;
			}

			//Check:
			if(Random == 0)
			{

				//Stop:
				break;
			}
		}
	}
}

public int GetMaxServerSafes()
{

	//Return:
	return view_as<int>(MAXSERVERSAFES);
}

public int GetServerSafeEnt(int Id)
{

	//Return:
	return view_as<int>(ServerSafeEnt[Id]);
}

public int GetServerSafeMoney(int Id)
{

	//Return:
	return view_as<int>(ServerSafeMoney[Id]);
}

public int GetServerSafeMoneyTotal()
{

	//Declare:
	int Amount = 0;

	//Loop:
	for(int X = 0; X <= GetMaxServerSafes(); X++)
	{

		//Is Valid:
		if(ServerSafeMoney[X] > 0)
		{

			//Initulize:
			Amount += ServerSafeMoney[X];
		}
	}

	//Return:
	return view_as<int>(Amount);
}

public int GetServerSafeIdFromEnt(int Ent)
{

	//Loop:
	for(int X = 0; X <= GetMaxServerSafes(); X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent)
		{

			//Return:
			return view_as<int>(Ent);
		}
	}

	//Return:
	return view_as<int>(-1);
}

public void AddServerSafeMoneyAll(int Amount)
{

	//Declare:
	int ValidSafes = 0;

	//Loop:
	for(int X = 0; X <= GetMaxServerSafes(); X++)
	{

		//Is Valid:
		if(IsValidEdict(ServerSafeEnt[X]))
		{

			//Initulize:
			ValidSafes += 1;
		}
	}

	//Declare:
	int NewAmount = Amount / ValidSafes;

	//Loop:
	for(int X = 0; X <= GetMaxServerSafes(); X++)
	{

		//Is Valid:
		if(IsValidEdict(ServerSafeEnt[X]))
		{

			//Set Amount:
			SetServerSafeMoney(X, (ServerSafeMoney[X] + NewAmount));
		}
	}
}

public void TakeServerSafeMoneyAll(int Amount)
{

	//Check:
	if(Amount <= 0)
	{

		//Return:
		return;
	}

	//Declare:
	int ValidSafes = 0;

	//Loop:
	for(int X = 0; X <= GetMaxServerSafes(); X++)
	{

		//Is Valid:
		if(IsValidEdict(ServerSafeEnt[X]))
		{

			//Initulize:
			ValidSafes += 1;
		}
	}

	//Declare:
	int NewAmount = Amount / ValidSafes;

	//Loop:
	for(int X = 0; X <= GetMaxServerSafes(); X++)
	{

		//Is Valid:
		if(IsValidEdict(ServerSafeEnt[X]))
		{

			//Print:
			//PrintToServer("|RP| - safeid = %i amount = %i old balence = %i new safe balence = %i", ValidSafes, NewAmount, ServerSafeMoney[X], (ServerSafeMoney[X] - NewAmount));

			//Set Amount:
			SetServerSafeMoney(X, (ServerSafeMoney[X] - NewAmount));
		}
	}
}

public void SetServerSafeMoney(int Id, int Amount)
{

	//Initulize:
	ServerSafeMoney[Id] = Amount;

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i WHERE Map = '%s' AND SafeId = %i;", ServerSafeMoney[Id], ServerMap(), Id);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 29);
}

public void BeginServerSafeRob(int Client, int SafeCash, int X, int Ent)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "%s Press %s<<Shift>>%s Again to rob the Server Money Safe!", PREFIX, COLORGREEN, COLORWHITE);

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "%s You are cuffed you can't rob this Server Money Safe!", PREFIX);

		//Return:
		return;
	}

	//Is Robbing:
	else if(ServerSafeRobCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "%s You are already robbing!", PREFIX);

		//Return:
		return;
	}

	//Ready:
	else if(ServerSafeRob[X] > 0)
	{

		//Print:
		CPrintToChat(Client, "%s This Server Money Safe has been robbed too recently, (%s%i%s) Seconds left!", PREFIX, COLORGREEN, ServerSafeRob[X], COLORWHITE);

		//Return:
		return;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "%s Prevent crime, do not start it!", PREFIX);

		//Return:
		return;
	}


	//Cleared:
	else if(ServerSafeMoney[X] < 50)
	{

		//Print:
		CPrintToChat(Client, "%s This isn't worth robbing!", PREFIX);

		//Return:
		return;
	}

	
	//Override:
	else
	{

		//Initialize:
		ServerSafeRobEnt[Client] = X;

		//Save:
		ServerSafeRob[X] = 600;

		//Start:
		ServerSafeRobCash[Client] = SafeCash;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Is Robbing A Server Money Safe!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Timer:
		CreateTimer(1.0, BeginServerRobberySafe, Client, TIMER_REPEAT);
	}

	//Return:
	return;
}

public void iServerRobTimer()
{

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Check
		if(ServerSafeRob[X] != 0) ServerSafeRob[X] -= 1;
	}

	//Initulize:
	SafeReplenTimer += 1;

	//Check:
	if(SafeReplenTimer > 60)
	{

		//Initulize:
		SafeReplenTimer = 0;

		//Loop:
		for(int X = 0; X < MAXSERVERSAFES; X++)
		{

			//Valid Check:
			if(IsValidEdict(ServerSafeEnt[X]))
			{

				//Declare:
				int Random = 0;

				//Check:
				if(ServerSafeMoney[X] < 150000)
				{

					//Declare:
					Random = GetRandomInt(1500, 4000);

					//Initulize:
					ServerSafeMoney[X] += Random;
				}

				//Check:
				else if(ServerSafeMoney[X] < 150000)
				{

					//Declare:
					Random = GetRandomInt(1500, 4000);

					//Initulize:
					ServerSafeMoney[X] -= Random;
				}

				//Override:
				else if(ServerSafeMoney[X] > 30000)
				{

					//Declare:
					Random = GetRandomInt(2500, 5000);

					//Initulize:
					ServerSafeMoney[X] -= Random;
				}

				//Override:
				if(ServerSafeMoney[X] < 5000)
				{

					//Declare:
					Random = GetRandomInt(2500, 5000);

					//Initulize:
					ServerSafeMoney[X] += Random;
				}

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i WHERE Map = '%s' AND SafeId = %i;", ServerSafeMoney[X], ServerMap(), X);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 29);
			}
		}
	}
}

public void DrawServerMoneySafeMenu(int Client, int X)
{

	//Handle:
	Menu menu = CreateMenu(HandleServerMoneySafe);

	//Title:
	menu.SetTitle("safe Balence is €%i\nTotal Server Safe Balence€%i", ServerSafeMoney[X], GetServerSafeMoneyTotal());

	//Menu Button:
	menu.AddItem("0", "Deposit Cash");

	//Menu Button:
	menu.AddItem("1", "Withdraw Cash");

	//Menu Button:
	menu.AddItem("2", "Update Name");

	//Menu Button:
	menu.AddItem("3", "Add Locks");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 20);

	//Initulize:
	SetMenuTarget(Client, X);

	//Override:
	if(GetCash(Client) == 0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<ESC>>\x07FFFFFF for a menu!");
	}
}

//PlayerMenu Handle:
public int HandleServerMoneySafe(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];
		int X = GetMenuTarget(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Declare:
			char AllBank[32];
			char bAllBank[32];

			//Format:
			Format(AllBank, 32, "All (€%i)", GetCash(Client));

			Format(bAllBank, 32, "%i", GetCash(Client));

			//Handle:
			menu = CreateMenu(HandleServerMoneySafeDeposit);

			//Title:
			menu.SetTitle("Your safe Balence is €%i", ServerSafeMoney[X]);

			//Menu Buttons:
			menu.AddItem(bAllBank, AllBank);

			menu.AddItem("1", "1");

			menu.AddItem("5", "5");

			menu.AddItem("10", "10");

			menu.AddItem("20", "20");

			menu.AddItem("50", "50");

			menu.AddItem("100", "100");

			menu.AddItem("200", "200");

			menu.AddItem("500", "500");

			menu.AddItem("1000", "1000");

			menu.AddItem("5000", "5000");

			menu.AddItem("10000", "10000");

			menu.AddItem("50000", "50000");

			menu.AddItem("100000", "100000");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Declare:
			char AllBank[32];
			char bAllBank[32];

			//Format:
			Format(AllBank, 32, "All (€%i)", ServerSafeMoney[X]);

			Format(bAllBank, 32, "%i", ServerSafeMoney[X]);

			//Handle:
			menu = CreateMenu(HandleServerMoneySafeWithdraw);

			//Title:
			menu.SetTitle("Your safe Balence is €%i", ServerSafeMoney[X]);

			//Menu Buttons:
			menu.AddItem(bAllBank, AllBank);

			menu.AddItem("1", "1");

			menu.AddItem("5", "5");

			menu.AddItem("10", "10");

			menu.AddItem("20", "20");

			menu.AddItem("50", "50");

			menu.AddItem("100", "100");

			menu.AddItem("200", "200");

			menu.AddItem("500", "500");

			menu.AddItem("1000", "1000");

			menu.AddItem("5000", "5000");

			menu.AddItem("10000", "10000");

			menu.AddItem("50000", "50000");

			menu.AddItem("100000", "100000");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Declare:
			char query[512];
			char ClientName[255];
			char CNameBuffer[255];

			//Initialize:
			GetClientName(Client, ClientName, sizeof(ClientName));

			//Remove Harmfull Strings:
			SQL_EscapeString(GetGlobalSQL(), ClientName, CNameBuffer, sizeof(CNameBuffer));

			//Copy String From Buffer:
			strcopy(ServerSafeName[X], sizeof(ServerSafeName[]), ClientName);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeName = '%s' WHERE Map = '%s' AND SafeId = %i;", ServerSafeName[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 26);

			//Print:
			CPrintToChat(Client, "%s You have updated your ServerMoneySafe name!", PREFIX);
		}

		//Button Selected:
		if(Result == 3)
		{
/*
			//Declare:
			char AllLocks[32];
			char bAllLocks[32];

			//Format:
			Format(AllLocks, 32, "All (%i)", Item[Client][58]);

			Format(bAllLocks, 32, "%i", Item[Client][58]);

			//Handle:
			menu = CreateMenu(HandleServerMoneySafeAddLocks);

			//Title:
			menu.SetTitle("Your safe Balence is €%i\nyou can only add (1) Lock items", ServerSafeMoney[X]);

			//Menu Buttons:
			menu.AddItem(bAllLocks, AllLocks);

			menu.AddItem("1", "1");

			menu.AddItem("5", "5");

			menu.AddItem("10", "10");

			menu.AddItem("20", "20");

			menu.AddItem("50", "50");

			menu.AddItem("100", "100");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
*/
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


//PlayerMenu Handle:
public int HandleServerMoneySafeDeposit(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];
		int X = GetMenuTarget(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Check Is Server Owned:
		if(GetCash(Client) - Amount >= 0)
		{

			//Initialize:
			ServerSafeMoney[X] += Amount;

			SetCash(Client, (GetCash(Client) - Amount));

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i WHERE Map = '%s' AND SafeId = %i;", ServerSafeMoney[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 29);

			//Print:
			CPrintToChat(Client, "%s You have deposited %s%s%s into your ServerMoneySafe", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-ServerMoneySafe|\x07FFFFFF - You cannot deposit this amount!");
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

//PlayerMenu Handle:
public int HandleServerMoneySafeWithdraw(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];
		int X = GetMenuTarget(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Check Is Server Owned:
		if((ServerSafeMoney[X] - Amount >= 0))
		{				

			//Initialize:
			ServerSafeMoney[X] -= Amount;

			SetCash(Client, (GetCash(Client) + Amount));

			//Declare:
			char query[512];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i WHERE  Map = '%s' AND SafeId = %i;", ServerSafeMoney[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 30);

			//Print:
			CPrintToChat(Client, "%s You have Withdrawed %s%s%s from your ServerMoneySafe!!", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "%s You cannot Withdraw this amount!", PREFIX);
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
/*
//PlayerMenu Handle:
public int HandleServerMoneySafeAddLocks(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];
		int X = GetMenuTarget(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);
		int ItemId = 58;

		//Check Is Server Owned:
		if((Item[Client][ItemId] - Amount >= 0) && Amount != 0)
		{

			//Initialize:
			Item[Client][ItemId] -= Amount;

			ServeSafeLocks[X] += Amount;

			//Save:
			SaveItem(Client, ItemId, Item[Client][ItemId]);

			//Declare:
			char query[512];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeLocks = %i WHERE SafeId = %i;", ServeSafeLocks[X], X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 31);

			//Print:
			CPrintToChat(Client, "%s You have added %s%i%s Locks to your Server Money Safe!", PREFIX, COLORGREEN, Amount, COLORWHITE);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You don't have %s%i%s Locks!", PREFIX, COLORGREEN, Amount, COLORWHITE);
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
*/
//Create Thumper:
public Action CommandCreateServerMoneySafe(int Client, int Args)
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
		CPrintToChat(Client, "%s Usage: sm_createServerMoneySafe <id>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float ClientAngles[3];
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientAbsAngles(Client, ClientAngles);

	//Declare:
	char buffer[512];
	char Position[32];
	char Ang[32];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", ClientAngles[0], ClientAngles[1], ClientAngles[2]);

	//Spawn Already Created:
	if(ServerSafeEnt[StringToInt(SpawnId)] > 0)
	{

		//Print:
		CPrintToChat(Client, "%s There is already a Server Money Safe created with this id %i", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Override:
	else
	{

		//Format:
		Format(buffer, sizeof(buffer), "INSERT INTO ServerMoneySafe (`Map`,`SafeId`,`Position`,`Angles`,`SafeMoney`,`SafeLocks`,`SafeName`) VALUES ('%s',%i,'%s','%s',0,0,'null');", ServerMap(), StringToInt(SpawnId), Position, Ang);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 1016);

	//Instead if Map Change:
	CreatePropServerMoneySafe(ClientOrigin, ClientAngles, StringToInt(SpawnId), 0, 0, "New Safe");

	//Print:
	CPrintToChat(Client, "%s Created Server Money Safe #%s <%f, %f, %f>", PREFIX, SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action CommandRemoveServerMoneySafe(int Client, int Args)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s Invalid Entity", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Roleplay Map:
	if(!StrEqual(ClassName, "Prop_Server_Money_Safe"))
	{

		//Print:
		CPrintToChat(Client, "%s Server Money Safe Entity", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "DELETE FROM ServerMoneySafe WHERE SafeId = %i AND Map = '%s';", X, ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 33);
		
			//Print:
			CPrintToChat(Client, "%s Removed Server Money Safe (SAFEID #%i)", PREFIX, X);

			ServerSafeMoney[X] = -1;

			ServeSafeLocks[X] = -1;

			ServerSafeRob[X] = -1;

			ServerSafeName[X] = "null";

			ServerSafeEnt[X] = -1;

			//Request:
			RequestFrame(OnNextFrameKill, Ent);
		}
	}

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListServerMoneySafe(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "ServerMoneySafe List:");

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM ServerMoneySafe WHERE Map = '%s' AND SafeId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintServerMoneySafe, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Create Thumper:
public Action CommandServerUpdateSafePosition(int Client, int Args)
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
		CPrintToChat(Client, "%s Usage: sm_updatesafeposition <id>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	float Angles[3];
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientAbsAngles(Client, Angles);

	//Declare:
	char buffer[512];
	char Position[32];
	char Ang[32];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Spawn Already Created:
	if(ServerSafeEnt[StringToInt(SpawnId)] > 0)
	{

		//Format:
		Format(buffer, sizeof(buffer), "UPDATE ServerMoneySafe SET Position = '%s', Angles = '%s' WHERE Map = '%s' AND SafeId = %i;", Position, Ang, ServerMap(), StringToInt(SpawnId));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 1014);

		//Print:
		CPrintToChat(Client, "%s Server Money Safe #%s Updated Position <%f, %f, %f>", PREFIX, SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

		//Return:
		return Plugin_Handled;
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "%s Invalid Server Money Safe to update position", PREFIX);
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandServerUpdateSafeMap(int Client, int Args)
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
		CPrintToChat(Client, "%s Usage: sm_updatesafemap <id>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM ServerMoneySafe WHERE SafeId = %i;", ServerMap(), StringToInt(SpawnId));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_SQLLoadServerSafeID, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public Action CommandServerSetSafeName(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafename <name>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s Invalid Entity", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];

	//Declare:
	char CNameBuffer[32];

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent)
		{

			//Remove Harmfull Strings:
			SQL_EscapeString(GetGlobalSQL(), Arg, CNameBuffer, sizeof(CNameBuffer));

			//Copy String From Buffer:
			strcopy(ServerSafeName[X], sizeof(ServerSafeName[]), CNameBuffer);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeName = '%s' WHERE Map = '%s' AND SafeId = %i;", ServerSafeName[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 35);

			//Print:
			CPrintToChat(Client, "%s you have set '%s' name on this Server Money Safe", PREFIX, ServerSafeName[X]);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandServerSetSafeMoney(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafemoney <amount>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s Invalid Entity", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];
	int Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent)
		{

			//Initialize:
			ServerSafeMoney[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i WHERE Map = '%s' AND SafeId = %i;", ServerSafeMoney[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 36);

			//Print:
			CPrintToChat(Client, "%s you have set %s%s%s balence on this Server Money Safe", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandServerSetSafeLocks(int Client,int Args)
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
		CPrintToChat(Client, "%s sm_setsafelocks <amount>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s - Invalid Entity", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];
	int Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent)
		{

			//Initialize:
			ServeSafeLocks[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeLocks = %i WHERE Map = '%s' AND SafeId = %i;", ServeSafeLocks[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 37);

			//Print:
			CPrintToChat(Client, "%s you have set %i Locks on this Server Money Safe", PREFIX, ServeSafeLocks[X]);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintServerMoneySafe(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintServerMoneySafe: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		char Buffer[32];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 32);

			//Print:
			PrintToConsole(Client, "%i: <%s> (ServerID: #%i)", SpawnId, Buffer);
		}
	}
}

public void T_SQLLoadServerSafeID(Handle owner, Handle hndl, const char[] error, any data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core] T_SQLLoadServerSafeID: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "|RP| - Invalid Server Money Safe");

			//Return:
			return;
		}

		//Declare:
		int SpawnId = 0;
		float ClientOrigin[3];
		float Angles[3];
		char query[512];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Initialize:
			GetClientAbsOrigin(Client, ClientOrigin);

			GetClientAbsAngles(Client, Angles);

			//Declare:
			char Position[64];
			char Ang[64];

			//Sql String:
			Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

			//Sql String:
			Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

			//Format:
			Format(query, sizeof(query), "UPDATE ServerMoneySafe SET Position = '%s', Angles = '%s' Map = '%s' WHERE SafeId = %i;", Position, Ang, ServerMap(), SpawnId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 46);

			//Print:
			CPrintToChat(Client, "%s Server Money Safe #%i Updated Map <%f, %f, %f>", PREFIX, SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
		}

	}
}

public int CreatePropServerMoneySafe(float Pos[3], float Ang[3], int X, int Money, int Locks, const char[] Name)
{

	//Initulize::
	int Ent = CreateEntityByName("Prop_Physics_override");

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", ServerMoneySafeModel);

		//Declare:
		char Position[255];

		//Format:
		Format(Position, sizeof(Position), "%f %f %f", Pos[0], Pos[1], Pos[2]);

		//Dispatch:
		DispatchKeyValue(Ent, "origin", Position);

		//Format:
		Format(Position, sizeof(Position), "%f %f %f", Ang[0], Ang[1], Ang[2]);

		//Dispatch:
		DispatchKeyValue(Ent, "angles", Position);

		//Spawn:
		DispatchSpawn(Ent);

		//Initulize:
		Pos[2] += 16;

		//Teleport:
		TeleportEntity(Ent, Pos, Ang, NULL_VECTOR);

		//Set Damage:
		SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

		//Set Prop ClassName
		SetEntityClassName(Ent, "prop_Server_Money_Safe");

		//Accept:
		AcceptEntityInput(Ent, "disablemotion", Ent);

		//Initulize:
		ServerSafeEnt[X] = Ent;

		ServerSafeMoney[X] = Money;

		ServeSafeLocks[X] = Locks;

		//Copy String From Buffer:
		Format(ServerSafeName[X], sizeof(ServerSafeName[]), "%s", Name);
	}
}

public void OnServerMoneySafeRob(int Client, int Ent)
{

	//Not Valid Ent:
	if(!LookingAtWall(Client))
	{

		//Loop:
		for(int X = 0; X <= MAXSERVERSAFES; X++)
		{

			//Check
			if(ServerSafeEnt[X] == Ent && IsInDistance(Client, Ent))
			{

				//Check Locks:
				if(ServeSafeLocks[X] == 0)
				{

					//Rob:
					BeginServerSafeRob(Client, 500, X, Ent);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "%s This Safe has Added Locks!", PREFIX);

					//Initialize:
					SetLastPressedSH(Client, GetGameTime());
				}
			}
		}
	}
}

public void OnServerMoneySafeUse(int Client, int Ent)
{

	//Loop:
	for(int X = 0; X < MAXSERVERSAFES; X++)
	{

		//Is Valid:
		if(ServerSafeEnt[X] == Ent && IsInDistance(Client, Ent))
		{

			//Check:
			if(IsAdmin(Client))
			{

				//Declare:
				int Amount = GetCash(Client);

				//Is In Time:
				if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && GetCash(Client) > 0)
				{

					//Initialize:
					ServerSafeMoney[X] += Amount;

					SetCash(Client, 0);

					//Declare:
					char query[255];

					//Sql Strings:
					Format(query, sizeof(query), "UPDATE ServerMoneySafe SET SafeMoney = %i WHERE Map = '%s' AND SafeId = %i;", ServerSafeMoney[X], ServerMap(), X);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 47);

					//Print:
					CPrintToChat(Client, "%s You have deposited %s%s%s into your ServerMoneySafe", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);
				}

				//Override:
				else if(GetCash(Client) > 0)
				{

					//Print:
					CPrintToChat(Client, "%s Press %s<<Use>>%s to Quick deposit %s%s", PREFIX, COLORGREEN, COLORWHITE, COLORGREEN, IntToMoney(Amount), COLORWHITE);

					//Initulize:
					SetLastPressedE(Client, GetGameTime());
				}

				//Draw Menu:
				DrawServerMoneySafeMenu(Client, X);
			}

			//Override
			else
			{

				//Print:
				CPrintToChat(Client, "%s You can't use this Server Money Safe!", PREFIX);
			}
		}
	}
}

public void ServerMoneySafeHud(int Client, int Ent, float NoticeInterval)
{

	//Declare:
	char FormatMessage[255];
	int len = 0;

	//Clear Buffers:
	for(int X = 0; X <= MAXSERVERSAFES; X++)
	{

		//Check
		if(ServerSafeEnt[X] == Ent)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Server Money Safe:\nName: %s\nMoney: %s\nLocks: %i", ServerSafeName[X], IntToMoney(ServerSafeMoney[X]), ServeSafeLocks[X]);

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
	}
}

public bool IsClientRobbingCashFromServerSafe(int Client)
{

	//Check:
	if(ServerSafeRobCash[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}
