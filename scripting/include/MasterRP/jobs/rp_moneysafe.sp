//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_moneysafe_included_
  #endinput
#endif
#define _rp_moneysafe_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = €

//Useable Item Models!
//char MoneySafeModel[256] = "models/ice_dragon/grey_medium_safe.mdl";
char MoneySafeModel[256] = "models/dragon/black_safe.mdl";

//Money Safe:
int SafeEnt[MAXPLAYERS + 1];
int SafeMoney[MAXPLAYERS + 1];
int SafeLocks[MAXPLAYERS + 1];
int SafeOwner[MAXPLAYERS + 1];
int SafeRob[MAXPLAYERS + 1];
int SafeHarvest[MAXPLAYERS + 1];
int SafeMeth[MAXPLAYERS + 1];
int SafePills[MAXPLAYERS + 1];
int SafeCocain[MAXPLAYERS + 1];
int SafeMetal[MAXPLAYERS + 1];
int SafeResources[MAXPLAYERS + 1];
int SafeRobCash[MAXPLAYERS + 1] = {0,...};
int SafeRobEnt[MAXPLAYERS + 1] = {-1,...};
char SafeName[MAXPLAYERS + 1][255];

public void initMoneySafe()
{

	//Money Safes
	RegAdminCmd("sm_createmoneysafe", CommandCreateMoneySafe, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removemoneysafe", CommandRemoveMoneySafe, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listmoneysafe", CommandListMoneySafe, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_updatesafeposition", CommandUpdateSafePosition, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_updatesafemap", CommandUpdateSafeMap, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafemoney", CommandSetSafeMoney, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafeowner", CommandSetSafeOwner, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_takesafeowner", CommandTakeSafeOwner, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafesteamid", CommandSetSafeSteamId, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafelocks", CommandSetSafeLocks, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafename", CommandSetSafeName, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_viewsafeowner", CommandViewSafeOwner, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafeharvest", CommandSetSafeHarvest, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafemeth", CommandSetSafeMeth, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafecocain", CommandSetSafeCocain, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafepills", CommandSetSafePills, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafemetal", CommandSetSafeMetal, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsaferesources", CommandSetSafeResources, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Initialize:
		SafeRob[X] = 600;
	}

	//Timers:
	CreateTimer(0.2, CreateSQLdbMoneySafe);

}
//Create Database:
public Action CreateSQLdbMoneySafe(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `MoneySafe`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL,`Position` varchar(32) NOT NULL, ");

	len += Format(query[len], sizeof(query)-len, " `Angles` varchar(32) NOT NULL, `SafeMoney` int(11) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, "  `SafeLocks` int(11) NOT NULL, `SafeOwner` int(11) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeName` varchar(255) NULL, `SafeHarvest` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeMeth` varchar(255) NULL, `SafePills` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeCocain` int(12) NULL, `SafeMetal` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeResources` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 22);

}

//Create Database:
public void DBLoadMoneySafe(int Client)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MoneySafe WHERE Map = '%s' AND SafeOwner = %i;", ServerMap(), SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadMoneySafe, query, conuserid);
}

public void T_DBLoadMoneySafe(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBLoadMoneySafe: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Check:
		if(IsClientInGame(Client))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| Loading Money Safe...");
		}

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| No Money Safes Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int Money = 0;
		int Locks = 0;
		int Owner = 0;
		int SafeH = 0;
		int SafeM = 0;
		int SafeP = 0;
		int SafeC = 0;
		int SafeMet = 0;
		int SafeRes = 0;
		char Buffer[32];

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Buffer, sizeof(Buffer));

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
			SQL_FetchString(hndl, 2, Buffer, 32);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 32);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading Intiger:
			Money = SQL_FetchInt(hndl, 3);

			//Database Field Loading Intiger:
			Locks = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 5);

			//Database Field Loading String:
			SQL_FetchString(hndl, 6, Buffer, 32);

			//Database Field Loading Intiger:
			SafeH = SQL_FetchInt(hndl, 7);

			//Database Field Loading Intiger:
			SafeM = SQL_FetchInt(hndl, 8);

			//Database Field Loading Intiger:
			SafeP = SQL_FetchInt(hndl, 9);

			//Database Field Loading Intiger:
			SafeC = SQL_FetchInt(hndl, 10);

			//Database Field Loading Intiger:
			SafeMet = SQL_FetchInt(hndl, 11);

			//Database Field Loading Intiger:
			SafeRes = SQL_FetchInt(hndl, 12);

			//Create Thumper:
			CreatePropMoneySafe(Client, Position, Angles, Money, Locks, Owner, Buffer, SafeH, SafeM, SafeP, SafeC, SafeMet, SafeRes);

			//Print:
			PrintToConsole(Client, "|RP| Money Safe Found!");
		}
	}
}

//Create Database:
public void RemoveMoneySafeOnDisconnect(int Client)
{

	//Is Valid:
	if(IsValidEdict(SafeEnt[Client]) && SafeEnt[Client] > 0)
	{

		//Accept:
		AcceptEntityInput(SafeEnt[Client], "kill");

		//Request:
		RequestFrame(OnNextFrameKill, SafeEnt[Client]);
	}

	//Defaults:
	SafeEnt[Client] = -1;

	SafeMoney[Client] = 0;

	SafeLocks[Client] = 0;

	SafeOwner[Client] = 0;

	SafeRob[Client] = 0;

	SafeHarvest[Client] = 0;

	SafeMeth[Client] = 0;

	SafePills[Client] = 0;

	SafeCocain[Client] = 0;

	SafeRobCash[Client] = 0;

	SafeName[Client] = "No Owner";

	SafeRobEnt[Client] = -1;

	SafeMetal[Client] = 0;

	SafeResources[Client] = 0;
}

public Action BeginRobberySafe(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsValidEdict(SafeRobEnt[Client]))
	{

		//Initulize::
		SafeRobCash[Client] = 0;

		SafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Cleared:
	if(SafeRobCash[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Stopped Robbing A Money Safe!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Initulize::
		SafeRobCash[Client] = 0;

		SafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(SafeRobEnt[Client], Prop_Send, "m_vecOrigin", Position);

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
		SafeRobCash[Client] = 0;

		SafeRobEnt[Client] = -1;

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

	//Declare:
	int X = GetSafeIdFromEnt(SafeRobEnt[Client]);

	//Cleared:
	if(SafeMoney[X] - Random > 0)
	{

		//Initulize:
		SafeRobCash[Client] -= Random;

		SafeMoney[X] -= Random;

		//Initialize:
		SetCash(Client, (GetCash(Client) + Random));

		//Initialize:
		SetCrime(Client, (GetCrime(Client) + (Random + Random)));

		//Set Menu State:
		CashState(Client, Random);

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 24);

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMoney[X], SafeOwner[X], ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 25);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Is Getting Away!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Initulize::
		SafeRobCash[Client] = 0;

		SafeRobEnt[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool IsValidSafe(int Ent)
{

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public void BeginSafeRob(int Client, int Ent, int SafeCash, int X)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "%s Press %s<<Shift>>%s Again to rob the Money Safe!", PREFIX, COLORGREEN, COLORWHITE);

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "%s You are cuffed you can't rob this money safe!", PREFIX);

		//Return:
		return;
	}

	//Is Robbing:
	else if(SafeRobCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "%s You are already robbing!", PREFIX);

		//Return:
		return;
	}

	//Ready:
	else if(SafeRob[X] > 0)
	{

		//Print:
		CPrintToChat(Client, "%s This Money Safe has been robbed too recently, (%s%i%s) Seconds left!", PREFIX, COLORGREEN, SafeRob[X], COLORWHITE);

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

	//Override:
	else
	{

		//Declare:
		float Origin[3];

		//Ent Origin:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

		//Initialize:
		SafeRobEnt[Client] = Ent;

		//Save:
		SafeRob[X] = 600;

		//Start:
		SafeRobCash[Client] = SafeCash;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Print:
		CPrintToChatAll("%s |%sATTENTION%s| - %s%N%s Is Robbing A Money Safe!", PREFIX, COLORRED, COLORWHITE, COLORGREEN, Client, COLORWHITE);

		//Timer:
		CreateTimer(1.0, BeginRobberySafe, Client, TIMER_REPEAT);
	}

	//Return:
	return;
}

public void iRobTimer()
{

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Check
		if(SafeRob[X] != 0) SafeRob[X] -= 1;
	}
}

public void DrawMoneySafeMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleMoneySafe);

	//Title:
	menu.SetTitle("Your safe Balence is €%i\n\nDrugs\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %i\n\nMaterials\nMetal: %ig\nResources: %ig", SafeMoney[Client], SafeHarvest[Client], SafeMeth[Client], SafeCocain[Client], SafePills[Client], SafeMetal[Client], SafeResources[Client]);

	//Menu Button:
	menu.AddItem("0", "Deposit Cash");

	//Menu Button:
	menu.AddItem("1", "Withdraw Cash");

	//Menu Button:
	menu.AddItem("4", "Storage");

	//Menu Button:
	menu.AddItem("2", "Update Name");

	//Menu Button:
	menu.AddItem("3", "Add Locks");

	//Menu Button:
	menu.AddItem("5", "Remove Locks");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 20);

	//Override:
	if(GetCash(Client) == 0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<ESC>>\x07FFFFFF for a menu!");
	}
}

//PlayerMenu Handle:
public int HandleMoneySafe(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

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
			menu = CreateMenu(HandleMoneySafeDeposit);

			//Title:
			menu.SetTitle("Your safe Balence is €%i\n", SafeMoney[Client]);

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
			Format(AllBank, 32, "All (€%i)", SafeMoney[Client]);

			Format(bAllBank, 32, "%i", SafeMoney[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeWithdraw);

			//Title:
			menu.SetTitle("Your safe Balence is €%i", SafeMoney[Client]);

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
			strcopy(SafeName[Client], sizeof(SafeName[]), ClientName);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeName = '%s' WHERE SafeOwner = %i AND Map = '%s';", SafeName[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 26);

			//Print:
			CPrintToChat(Client, "%s You have updated your MoneySafe name!", PREFIX);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeAddLocks);

			//Title:
			menu.SetTitle("Your money safe has %i Locks", SafeLocks[Client]);

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
		if(Result == 4)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorage);

			//Title:
			menu.SetTitle("Drugs\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %i\n\nMaterials\nMetal: %ig\nResources: %i", SafeHarvest[Client], SafeMeth[Client], SafeCocain[Client], SafePills[Client], SafeMetal[Client], SafeResources[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Drugs");

			menu.AddItem("2", "Materials");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected:
		if(Result == 5)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeRemoveLocks);

			//Title:
			menu.SetTitle("Your money safe has %i Locks", SafeLocks[Client]);

			//Declare:
			char AllHarvest[32];
			char bAllHarvest[32];

			//Format:
			Format(AllHarvest, 32, "All (%i)", SafeLocks[Client]);

			Format(bAllHarvest, 32, "%i", SafeLocks[Client]);

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
public int HandleMoneySafeStorage(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageDrugs);

			//Title:
			menu.SetTitle("Harvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeHarvest[Client], SafeMeth[Client], SafeCocain[Client], SafePills[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Take drugs from safe");

			menu.AddItem("2", "Put drugs in safe");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageMaterials);

			//Title:
			menu.SetTitle("Metal: %ig\nResources: %ig", SafeMetal[Client], SafeResources[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Take materials from safe");

			menu.AddItem("2", "Put materials in safe");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);

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
public int HandleMoneySafeStorageDrugs(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeDrugs);

			//Title:
			menu.SetTitle("Harvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeHarvest[Client], SafeMeth[Client], SafeCocain[Client], SafePills[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Harvest");

			menu.AddItem("2", "Pills");

			menu.AddItem("3", "Meth");

			menu.AddItem("4", "Cocain");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutDrugs);

			//Title:
			menu.SetTitle("Harvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeHarvest[Client], SafeMeth[Client], SafeCocain[Client], SafePills[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Harvest");

			menu.AddItem("2", "Pills");

			menu.AddItem("3", "Meth");

			menu.AddItem("4", "Cocain");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
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
public int HandleMoneySafeStorageTakeDrugs(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Check
			if(SafeHarvest[Client] == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any harvest in your money safe", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllHarvest[32];
			char bAllHarvest[32];

			//Format:
			Format(AllHarvest, 32, "All (%ig)", SafeHarvest[Client]);

			Format(bAllHarvest, 32, "%i", SafeHarvest[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeHarvestAmount);

			//Title:
			menu.SetTitle("Harvest: %ig", SafeHarvest[Client]);

			//Menu Buttons:
			menu.AddItem(bAllHarvest, AllHarvest);

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

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Check
			if(SafePills[Client] == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Pills in your money safe", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllPills[32];
			char bAllPills[32];

			//Format:
			Format(AllPills, 32, "All (%ig)", SafePills[Client]);

			Format(bAllPills, 32, "%i", SafePills[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakePillsAmount);

			//Title:
			menu.SetTitle("Pills: %i", SafePills[Client]);

			//Menu Buttons:
			menu.AddItem(bAllPills, AllPills);

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

		//Button Selected Store Drugs:
		if(Result == 3)
		{

			//Check
			if(SafeMeth[Client] == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Meth in your money safe", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllMeth[32];
			char bAllMeth[32];

			//Format:
			Format(AllMeth, 32, "All (%ig)", SafeMeth[Client]);

			Format(bAllMeth, 32, "%i", SafeMeth[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeMethAmount);

			//Title:
			menu.SetTitle("Meth: %ig", SafeMeth[Client]);

			//Menu Buttons:
			menu.AddItem(bAllMeth, AllMeth);

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

		//Button Selected Store Drugs:
		if(Result == 4)
		{

			//Check
			if(SafeCocain[Client] == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Cocain in your money safe", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllCocain[32];
			char bAllCocain[32];

			//Format:
			Format(AllCocain, 32, "All (%ig)", SafeCocain[Client]);

			Format(bAllCocain, 32, "%i", SafeCocain[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeCocainAmount);

			//Title:
			menu.SetTitle("Cocain: %ig", SafeCocain[Client]);

			//Menu Buttons:
			menu.AddItem(bAllCocain, AllCocain);

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
public int HandleMoneySafeStorageTakeHarvestAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Harvest:
		if(SafeHarvest[Client] - Amount >= 0)
		{

			//Initulize:
			SetHarvest(Client, (GetHarvest(Client) + Amount));

			//Initulize:
			SafeHarvest[Client] -= Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeHarvest = %i WHERE SafeOwner = %i AND Map = '%s';", SafeHarvest[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have Taken %i grams of cHarvest from your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Harvest in your money safe!", PREFIX);
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
public int HandleMoneySafeStorageTakePillsAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Pills:
		if(SafePills[Client] - Amount >= 0)
		{

			//Initulize:
			SetPills(Client, (GetPills(Client) + Amount));

			//Initulize:
			SafePills[Client] -= Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafePills = %i WHERE SafeOwner = %i AND Map = '%s';", SafePills[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have Taken %i Pills from your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Pills in your money safe!", PREFIX);
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
public int HandleMoneySafeStorageTakeMethAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Meth:
		if(SafeMeth[Client] - Amount >= 0)
		{

			//Initulize:
			SetMeth(Client, (GetMeth(Client) + Amount));

			//Initulize:
			SafeMeth[Client] -= Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMeth = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMeth[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have Taken %i grams of Meth from your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Meth in your money safe!", PREFIX);
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
public int HandleMoneySafeStorageTakeCocainAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Cocain:
		if(SafeCocain[Client] - Amount >= 0)
		{

			//Initulize:
			SetCocain(Client, (GetCocain(Client) + Amount));

			//Initulize:
			SafeCocain[Client] -= Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeCocain = %i WHERE SafeOwner = %i AND Map = '%s';", SafeCocain[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have Taken %i grams of cocain from your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Cocain in your money safe!", PREFIX);
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
public int HandleMoneySafeStoragePutDrugs(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Check
			if(GetHarvest(Client) == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any harvest", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllHarvest[32];
			char bAllHarvest[32];

			//Format:
			Format(AllHarvest, 32, "All (%ig)", GetHarvest(Client));

			Format(bAllHarvest, 32, "%i", GetHarvest(Client));

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutHarvestAmount);

			//Title:
			menu.SetTitle("Harvest: %ig", SafeHarvest[Client]);

			//Menu Buttons:
			menu.AddItem(bAllHarvest, AllHarvest);

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

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Check
			if(GetPills(Client) == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Pills", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllPills[32];
			char bAllPills[32];

			//Format:
			Format(AllPills, 32, "All (%ig)", GetPills(Client));

			Format(bAllPills, 32, "%i", GetPills(Client));

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutPillsAmount);

			//Title:
			menu.SetTitle("Pills: %i", SafePills[Client]);

			//Menu Buttons:
			menu.AddItem(bAllPills, AllPills);

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

		//Button Selected Store Drugs:
		if(Result == 3)
		{

			//Check
			if(GetMeth(Client) == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Meth", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllMeth[32];
			char bAllMeth[32];

			//Format:
			Format(AllMeth, 32, "All (%ig)", GetMeth(Client));

			Format(bAllMeth, 32, "%i", GetMeth(Client));

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutMethAmount);

			//Title:
			menu.SetTitle("Meth: %ig", SafeMeth[Client]);

			//Menu Buttons:
			menu.AddItem(bAllMeth, AllMeth);

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

		//Button Selected Store Drugs:
		if(Result == 4)
		{

			//Check
			if(GetCocain(Client) == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Cocain", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllCocain[32];
			char bAllCocain[32];

			//Format:
			Format(AllCocain, 32, "All (%ig)", GetCocain(Client));

			Format(bAllCocain, 32, "%i", GetCocain(Client));

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutCocainAmount);

			//Title:
			menu.SetTitle("Cocain: %ig", SafeCocain[Client]);

			//Menu Buttons:
			menu.AddItem(bAllCocain, AllCocain);

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
public int HandleMoneySafeStoragePutHarvestAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Harvest:
		if(GetHarvest(Client) - Amount >= 0)
		{

			//Initulize:
			SetHarvest(Client, (GetHarvest(Client) - Amount));

			//Initulize:
			SafeHarvest[Client] += Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeHarvest = %i WHERE SafeOwner = %i AND Map = '%s';", SafeHarvest[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have put %i grams of harvest in your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Harvest in your money safe!", PREFIX);
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
public int HandleMoneySafeStoragePutPillsAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Pills:
		if(GetPills(Client) - Amount >= 0)
		{

			//Initulize:
			SetPills(Client, (GetPills(Client) - Amount));

			//Initulize:
			SafePills[Client] += Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafePills = %i WHERE SafeOwner = %i AND Map = '%s';", SafePills[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have put %i Pills in your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Pills in your money safe!", PREFIX);
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
public int HandleMoneySafeStoragePutMethAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Meth:
		if(GetMeth(Client) - Amount >= 0)
		{

			//Initulize:
			SetMeth(Client, (GetMeth(Client) - Amount));

			//Initulize:
			SafeMeth[Client] += Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMeth = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMeth[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have put %i grams of Meth in your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Meth in your money safe!", PREFIX);
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
public int HandleMoneySafeStoragePutCocainAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Cocain:
		if(GetCocain(Client) - Amount >= 0)
		{

			//Initulize:
			SetCocain(Client, (GetCocain(Client) - Amount));

			//Initulize:
			SafeCocain[Client] += Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeCocain = %i WHERE SafeOwner = %i AND Map = '%s';", SafeCocain[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have put %i grams of Cocain in your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Cocain in your money safe!", PREFIX);
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
public int HandleMoneySafeStorageMaterials(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeMaterials);

			//Title:
			menu.SetTitle("Metal: %ig\nResources: %ig", SafeMetal[Client], SafeResources[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Metal");

			menu.AddItem("2", "Resources");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutMaterials);

			//Title:
			menu.SetTitle("Metal: %ig\nResources: %ig", SafeMetal[Client], SafeResources[Client]);

			//Menu Buttons:
			menu.AddItem("1", "Metal");

			menu.AddItem("2", "Resources");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
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
public int HandleMoneySafeStorageTakeMaterials(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Check
			if(SafeMetal[Client] == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Metal in your money safe", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllMetal[32];
			char bAllMetal[32];

			//Format:
			Format(AllMetal, 32, "All (%ig)", SafeMetal[Client]);

			Format(bAllMetal, 32, "%i", SafeMetal[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeMetalAmount);

			//Title:
			menu.SetTitle("Metal: %ig", SafeMetal[Client]);

			//Menu Buttons:
			menu.AddItem(bAllMetal, AllMetal);

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

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Check
			if(SafeResources[Client] == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Resources in your money safe", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllResources[32];
			char bAllResources[32];

			//Format:
			Format(AllResources, 32, "All (%ig)", SafeResources[Client]);

			Format(bAllResources, 32, "%i", SafeResources[Client]);

			//Handle:
			menu = CreateMenu(HandleMoneySafeStorageTakeResourcesAmount);

			//Title:
			menu.SetTitle("Resources: %ig", SafeResources[Client]);

			//Menu Buttons:
			menu.AddItem(bAllResources, AllResources);

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
public int HandleMoneySafeStorageTakeMetalAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Metal:
		if(SafeMetal[Client] - Amount >= 0)
		{

			//Initulize:
			SetMetal(Client, (GetMetal(Client) + Amount));

			//Initulize:
			SafeMetal[Client] -= Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMetal = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMetal[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have Taken %i grams of cMetal from your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Metal in your money safe!", PREFIX);
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
public int HandleMoneySafeStorageTakeResourcesAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Resources:
		if(SafeResources[Client] - Amount >= 0)
		{

			//Initulize:
			SetResources(Client, (GetResources(Client) + Amount));

			//Initulize:
			SafeResources[Client] -= Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeResources = %i WHERE SafeOwner = %i AND Map = '%s';", SafeResources[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have Taken %i grams of cResources from your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Resources in your money safe!", PREFIX);
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
public int HandleMoneySafeStoragePutMaterials(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Check
			if(GetMetal(Client) == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Metal", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllMetal[32];
			char bAllMetal[32];

			//Format:
			Format(AllMetal, 32, "All (%ig)", GetMetal(Client));

			Format(bAllMetal, 32, "%i", GetMetal(Client));

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutMetalAmount);

			//Title:
			menu.SetTitle("Metal: %ig", SafeMetal[Client]);

			//Menu Buttons:
			menu.AddItem(bAllMetal, AllMetal);

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

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Check
			if(GetResources(Client) == 0)
			{

				//Print:
				CPrintToChat(Client, "%s You dont have any Resources", PREFIX);

				//Return:
				return view_as<bool>(true);
			}

			//Declare:
			char AllResources[32];
			char bAllResources[32];

			//Format:
			Format(AllResources, 32, "All (%ig)", GetResources(Client));

			Format(bAllResources, 32, "%i", GetResources(Client));

			//Handle:
			menu = CreateMenu(HandleMoneySafeStoragePutResourcesAmount);

			//Title:
			menu.SetTitle("Resources: %ig", SafeResources[Client]);

			//Menu Buttons:
			menu.AddItem(bAllResources, AllResources);

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
public int HandleMoneySafeStoragePutMetalAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Metal:
		if(GetMetal(Client) - Amount >= 0)
		{

			//Initulize:
			SetMetal(Client, (GetMetal(Client) - Amount));

			//Initulize:
			SafeMetal[Client] += Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMetal = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMetal[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have put %i grams of Metal in your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Metal in your money safe!", PREFIX);
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
public int HandleMoneySafeStoragePutResourcesAmount(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu. GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Has Resources:
		if(GetResources(Client) - Amount >= 0)
		{

			//Initulize:
			SetResources(Client, (GetResources(Client) - Amount));

			//Initulize:
			SafeResources[Client] += Amount;

			//Declare:
			char query[256];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeResources = %i WHERE SafeOwner = %i AND Map = '%s';", SafeResources[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 27);

			//Print:
			CPrintToChat(Client, "%s You have put %i grams of Resources in your safe!", PREFIX, Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "%s You do not have any Resources in your money safe!", PREFIX);
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
public int HandleMoneySafeDeposit(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Check Is Server Owned:
		if(GetCash(Client) - Amount >= 0)
		{

			//Initialize:
			SafeMoney[Client] += Amount;

			SetCash(Client, (GetCash(Client) - Amount));

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMoney[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 29);

			//Print:
			CPrintToChat(Client, "%s You have deposited %s%s%s into your moneysafe", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You cannot deposit this amount!");
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
public int HandleMoneySafeWithdraw(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Check Is Server Owned:
		if((SafeMoney[Client] - Amount >= 0))
		{				

			//Initialize:
			SafeMoney[Client] -= Amount;

			SetCash(Client, (GetCash(Client) + Amount));

			//Declare:
			char query[512];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMoney[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 30);

			//Print:
			CPrintToChat(Client, "%s You have Withdrawed %s%s%s from your moneysafe!!", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);
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

//PlayerMenu Handle:
public int HandleMoneySafeAddLocks(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);
		int Cost = Amount * 1000;

		//Check Is Server Owned:
		if(GetBank(Client) - Cost >= 0)
		{

			//Initialize:
			SafeLocks[Client] += Amount;

			//Save:
			SetBank(Client, (GetBank(Client) - Cost));

			//Declare:
			char query[512];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeLocks = %i WHERE SafeOwner = %i AND Map = '%s';", SafeLocks[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 31);

			//Print:
			CPrintToChat(Client, "%s You have added %s%i%s Locks to your money safe for %s%s%s!", PREFIX, COLORGREEN, Amount, COLORWHITE, COLORGREEN, IntToMoney(Cost), COLORWHITE);
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

//PlayerMenu Handle:
public int HandleMoneySafeRemoveLocks(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsInDistance(Client, SafeEnt[Client]))
		{

			//Print:
			CPrintToChat(Client, "%s You are too faw away to use your moneysafe!", PREFIX);

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);
		int Cost = Amount * 800;

		//Check Is Server Owned:
		if(SafeLocks[Client] - Amount >= 0)
		{

			//Initialize:
			SafeLocks[Client] -= Amount;

			//Save:
			SetBank(Client, (GetBank(Client) + Cost));

			//Declare:
			char query[512];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeLocks = %i WHERE SafeOwner = %i AND Map = '%s';", SafeLocks[Client], SteamIdToInt(Client), ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 31);

			//Print:
			CPrintToChat(Client, "%s You have Removed %s%i%s Locks from your money safe for %s%s%s!", PREFIX, COLORGREEN, Amount, COLORWHITE, COLORGREEN, IntToMoney(Cost), COLORWHITE);
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

//Create Thumper:
public Action CommandCreateMoneySafe(int Client, int Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "%s Usage: sm_createmoneysafe <SteamNumberId>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];
	int SteamId = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	SteamId = StringToInt(Arg);

	//Check:
	if(SteamId > 0)
	{

		//Loop:
		for(int i = 0; i <= GetMaxClients(); i++)
		{

			//Is Valid:
			if(SafeOwner[i] == SteamId)
			{

				//Print:
				CPrintToChat(Client, "%s SteamId %i already has a safe", PREFIX, SteamId);

				//Return:
				return Plugin_Handled;
			}
		}
	}

	//Declare:
	float Origin[3];
	float Angles[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	GetClientAbsAngles(Client, Angles);

	//Declare:
	char Position[32];
	char Ang[32];

	//Declare:
	char query[512];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Format:
	Format(query, sizeof(query), "INSERT INTO MoneySafe (`Map`,`Position`,`Angles`,`SafeOwner`,`SafeMoney`,`SafeLocks`,`SafeName`) VALUES ('%s','%s','%s',%i,0,0,'null');", ServerMap(), Position, Ang, SteamId);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 32);

	//Print:
	CPrintToChat(Client, "%s Created Money Safe <%f, %f, %f>", PREFIX, Origin[0], Origin[1], Origin[2]);

	//Create Thumper:
	CreatePropMoneySafe(Client, Origin, Angles, 0, 0, SteamId, "Update Name!", 0, 0, 0, 0, 0, 0);

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action CommandRemoveMoneySafe(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "%s Usage: sm_removemoneysafe <id>", PREFIX);

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
	char query[512];

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "DELETE FROM MoneySafe WHERE SafeOwner = %i  AND Map = '%s';", SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 33);
		
			//Print:
			CPrintToChat(Client, "%s Removed Money Safe (OWNERID #%i)", PREFIX, SafeOwner[X]);

			SafeOwner[X] = -1;

			SafeMoney[X] = -1;

			SafeLocks[X] = -1;

			SafeRob[X] = -1;

			SafeName[X] = "null";

			SafeEnt[X] = -1;

			//Request:
			RequestFrame(OnNextFrameKill, Ent);
		}
	}

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListMoneySafe(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "MoneySafe List:");

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM MoneySafe WHERE Map = '%s';", ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintMoneySafe, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Create Thumper:
public Action CommandUpdateSafePosition(int Client, int Args)
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
	char Arg[32];
	int SteamId = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	SteamId = StringToInt(Arg);

	//Declare:
	float ClientOrigin[3];
	float Angles[3];

	//Initialize:
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

	//Format:
	Format(buffer, sizeof(buffer), "UPDATE MoneySafe SET Position = '%s', Angles = '%s' WHERE SafeOwner = %i, Map = '%s';", Position, Ang, ServerMap(), SteamId);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 34);

	//Print:
	CPrintToChat(Client, "%s Money Safe #%s Updated Position <%f, %f, %f>", PREFIX, SteamId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action CommandUpdateSafeMap(int Client, int Args)
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
		CPrintToChat(Client, "%s Usage: sm_updatesafemap <SteamId>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];
	int SteamId = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	SteamId = StringToInt(Arg);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MoneySafe WHERE SafeOwner = %i WHERE SafeOwner = %i;", ServerMap(), SteamId);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_SQLLoadSafeID, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeName(int Client, int Args)
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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Remove Harmfull Strings:
			SQL_EscapeString(GetGlobalSQL(), Arg, CNameBuffer, sizeof(CNameBuffer));

			//Copy String From Buffer:
			strcopy(SafeName[X], sizeof(SafeName[]), CNameBuffer);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeName = '%s' WHERE SafeOwner = %i AND Map = '%s';", SafeName[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 35);

			//Print:
			CPrintToChat(Client, "%s you have set '%s' name on this money safe", PREFIX, SafeName[X]);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeMoney(int Client, int Args)
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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeMoney[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMoney[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 36);

			//Print:
			CPrintToChat(Client, "%s you have set %s%s%s balence on this money safe", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeLocks(int Client,int Args)
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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeLocks[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeLocks = %i WHERE SafeOwner = %i AND Map = '%s';", SafeLocks[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 37);

			//Print:
			CPrintToChat(Client, "%s you have set %i Locks on this money safe", PREFIX, SafeLocks[X]);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeOwner(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafeowner <Name>", PREFIX);

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
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("%s No matching client found!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeOwner = %i WHERE SafeOwner = %i AND Map = '%s';", SteamIdToInt(Player), SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 38);

			//Initialize:
			SafeOwner[X] = SteamIdToInt(Player);

			//Print:
			CPrintToChat(Client, "%s You have give %s%N%s ownership to money safe #%i",PREFIX, COLORGREEN, Player, COLORWHITE, X);

			//Check:
			if(Client != Player) CPrintToChat(Player, "%s %s%N%s has give you ownership to money safe #%i", PREFIX, COLORGREEN, Client, COLORWHITE, X);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandTakeSafeOwner(int Client,int Args)
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
		CPrintToChat(Client, "%s sm_takesafeowner <Name>", PREFIX);

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
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("%s No matching client found!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Has Ownership Already:
			if(SteamIdToInt(Player) == SafeOwner[X])
			{

				//Random:
				int Random = GetRandomInt(100000, 999999);

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE MoneySafe SET SafeOwner = %i WHERE SafeOwner = %i AND Map = '%s';", Random, SafeOwner[X], ServerMap());

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 39);

				//Initialize:
				SafeOwner[X] = Random;

				//Print:
				CPrintToChat(Client, "%s You have taken %s%N%s ownership to money safe #%i", PREFIX, COLORGREEN, Player, COLORWHITE, X);

				//Check:
				if(Client != Player) CPrintToChat(Player, "%s %s%N%s has taken ownership to money safe #%i", PREFIX, COLORGREEN, Client, COLORWHITE, X);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "%s %s%N%s doesn't have ownership to money safe #%i", PREFIX, COLORGREEN, Player, COLORWHITE, X);
			}

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeSteamId(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafesteamid <SteamId>", PREFIX);

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
	char SteamId[32];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeOwner = %i WHERE SafeOwner = %i AND Map = '%s'", StringToInt(SteamId), SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 40);

			//Initialize:
			SafeOwner[X] = StringToInt(SteamId);

			//Print:
			CPrintToChat(Client, "%s You have set %s%s%s steamid ownership to money safe #%i", PREFIX, COLORGREEN, SteamId, COLORWHITE, X);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandViewSafeOwner(int Client, int Args)
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
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s Invalid Entity", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Player = -1;

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Print:
			CPrintToChat(Client, "%s %i Steamid #%i ", PREFIX, SafeOwner[X]);

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(SafeOwner[X] == SteamIdToInt(i))
					{

						//Initialize:
						Player = i;

						//Stop:
						break;
					}
				}
			}

			//Stop:
			break;
		}
	}

	//Found Player Online:
	if(Player != -1)
	{

		//Print:
		CPrintToChat(Client, "%s %s%N%s has ownership over this safe", PREFIX, COLORGREEN, Player, COLORWHITE);
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeHarvest(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafeharvest <amount>", PREFIX);

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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeHarvest[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeHarvest = %i WHERE SafeOwner = %i AND Map = '%s';", SafeHarvest[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 42);

			//Print:
			CPrintToChat(Client, "%s you have set %s%i%sg of Harvest on this money safe", PREFIX, COLORGREEN, Amount, COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeMeth(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafemeth <amount>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s - Invalid Entity");

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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeHarvest[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMeth = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMeth[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 43);

			//Print:
			CPrintToChat(Client, "%s you have set %s%i%sg of Meth on this money safe", PREFIX, COLORGREEN, Amount, COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeCocain(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafecocain <amount>", PREFIX);

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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeCocain[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeCocain = %i WHERE SafeOwner = %i AND Map = '%s';", SafeCocain[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 44);

			//Print:
			CPrintToChat(Client, "%s you have set %s%i%sg of Cocain on this money safe", PREFIX, COLORGREEN, Amount, COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafePills(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafepills <amount>", PREFIX);

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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafePills[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafePills = %i WHERE SafeOwner = %i AND Map = '%s';", SafePills[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 45);

			//Print:
			CPrintToChat(Client, "%s you have set %s%i%s Pills on this money safe", PREFIX, COLORGREEN, Amount, COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeMetal(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsafemetal <amount>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s - Invalid Entity");

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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeHarvest[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMetal = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMetal[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 43);

			//Print:
			CPrintToChat(Client, "%s you have set %s%i%sg of Metal on this money safe", PREFIX, COLORGREEN, Amount, COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandSetSafeResources(int Client, int Args)
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
		CPrintToChat(Client, "%s sm_setsaferesources <amount>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "%s - Invalid Entity");

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
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeHarvest[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeResources = %i WHERE SafeOwner = %i AND Map = '%s';", SafeResources[X], SafeOwner[X], ServerMap());

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 43);

			//Print:
			CPrintToChat(Client, "%s you have set %s%i%sg of Resources on this money safe", PREFIX, COLORGREEN, Amount, COLORWHITE);

			//Stop:
			break;
		}
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintMoneySafe(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintMoneySafe: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int Owner = 0;
		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 5);

			//Print:
			PrintToConsole(Client, "SteamNumberId (%i)", Owner);
		}
	}
}

public void T_SQLLoadSafeID(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Top] T_SQLLoadRPTopOnline: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "|RP| - Invalid Money safe");

			//Return:
			return;
		}

		//Declare:
		int SpawnId = 0;
		int Owner = 0;
		float ClientOrigin[3];
		float Angles[3];
		char query[512];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 6);

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
			Format(query, sizeof(query), "UPDATE MoneySafe SET Position = '%s', Angles = '%s' Map = '%s' WHERE SafeOwner = %i;", Position, Ang, ServerMap(), Owner);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 46);

			//Print:
			CPrintToChat(Client, "%s Money Safe #%i Updated Map <%f, %f, %f>", PREFIX, SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
		}

	}
}

public int CreatePropMoneySafe(int Client, float Pos[3], float Ang[3], int Money, int Locks, int Owner, const char[] Name, int SafeH, int SafeM, int SafeP, int SafeC, int SafeMet, int SafeRes)
{

	//Initulize::
	int Ent = CreateEntityByName("Prop_Physics_override");

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", MoneySafeModel);

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
		SetEntityClassName(Ent, "prop_Money_Safe");

		//Accept:
		AcceptEntityInput(Ent, "disablemotion", Ent);

		//Initulize:
		SafeEnt[Client] = Ent;

		SafeMoney[Client] = Money;

		SafeLocks[Client] = Locks;

		SafeOwner[Client] = Owner;

		SafeHarvest[Client] = SafeH;

		SafeMeth[Client] = SafeM;

		SafePills[Client] = SafeP;

		SafeCocain[Client] = SafeC;

		SafeMetal[Client] = SafeMet;

		SafeResources[Client] = SafeRes;

		//Copy String From Buffer:
		Format(SafeName[Client], sizeof(SafeName[]), "%s", Name);
	}
}

public void OnMoneySafeRob(int Client, int Ent)
{

	//Not Valid Ent:
	if(!LookingAtWall(Client))
	{

		//Loop:
		for(int X = 0; X <= GetMaxClients(); X++)
		{

			//Check
			if(SafeEnt[X] == Ent)
			{

				//Check Locks:
				if(SafeLocks[X] == 0)
				{

					//Check Owner:
					if(SteamIdToInt(Client) != SafeOwner[X])
					{

						//Rob:
						BeginSafeRob(Client, Ent, 500, X);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "%s You can't rob your own money safe!", PREFIX);
					}
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

public void OnMoneySafeUse(int Client, int Ent)
{

	//Loop:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Check
			if(SafeOwner[X] == SteamIdToInt(Client))
			{

				//Declare:
				int Amount = GetCash(Client);

				//Is In Time:
				if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && GetCash(Client) > 0)
				{

					//Initialize:
					SafeMoney[X] += Amount;

					SetCash(Client, 0);

					//Declare:
					char query[255];

					//Sql Strings:
					Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s';", SafeMoney[X], SteamIdToInt(Client), ServerMap());

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 47);

					//Print:
					CPrintToChat(Client, "%s You have deposited %s%s%s into your moneysafe", PREFIX, COLORGREEN, IntToMoney(Amount), COLORWHITE);
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
				DrawMoneySafeMenu(Client);
			}

			//Override
			else
			{

				//Print:
				CPrintToChat(Client, "%s You can't use this money safe!", PREFIX);
			}
		}
	}
}

public void MoneySafeHud(int Client, int Ent, float NoticeInterval)
{

	//Declare:
	char FormatMessage[255];
	int len = 0;

	//Clear Buffers:
	for(int X = 0; X <= GetMaxClients(); X++)
	{

		//Check
		if(SafeEnt[X] == Ent)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Money Safe:\nName: %s\nMoney: %s\nLocks: %i", SafeName[X], IntToMoney(SafeMoney[X]), SafeLocks[X]);

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

public int GetSafeIdFromEnt(int Ent)
{

	//Loop:
	for(int i = 0; i <= GetMaxClients(); i++)
	{

		//Is Valid:
		if(SafeEnt[i] == Ent)
		{

			//Return:
			return view_as<int>(i);
		}
	}

	//Return:
	return view_as<int>(-1);
}

public bool IsClientRobbingCashFromSafe(int Client)
{

	//Check:
	if(SafeRobCash[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}