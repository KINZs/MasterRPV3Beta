//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_lottery_included_
  #endinput
#endif
#define _rp_lottery_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = � 

//need to add /lottery to view the actual lottery
//Deb
//Lottery:
int LotteryCheck = 0;
int LotteryTickets = 1;

public void initLottery()
{

	//Timer:
	CreateTimer(0.2, CreateSQLdbLottery);

	CreateTimer(0.2, CreateSQLdbLotteryWinners);

	CreateTimer(0.2, CreateSQLdbLotteryData);

	//Commands:
	RegConsoleCmd("sm_enter", Command_EnterLottery);

	//Commands:
	RegConsoleCmd("sm_lottery", Command_Lottery);
}

//Create Database:
public Action CreateSQLdbLottery(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Lottery`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action CreateSQLdbLotteryWinners(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `LotteryWinners`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11), `NAME` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `Amount` int(12) NULL, `Collected` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action CreateSQLdbLotteryData(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `LotteryData`");

	len += Format(query[len], sizeof(query)-len, " (`Ticker` int(12) NULL, `Tickets` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

}

public Action CheckLotteryWinners(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM LotteryData;");

	//Not Created Tables:
	SQL_TQuery(hDataBase, T_DBLoadLotteryDataCallback, query);
}

public void LoadLotteryTickets(int Client)
{
	//Declare:
	char query[255];

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Lottery` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLotteryCallback, query, conuserid);

	//Format:
	Format(query, sizeof(query), "SELECT Amount, Collected FROM `LotteryWinners` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLotteryCheckCallback, query, conuserid);
}

//ticket timer
public void initLotteryTimer()
{

	//Declare:
	char query[255];

	//Initulize:
	LotteryCheck += 1;

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = Ticker + 1;");

	//Not Created Tables:
	SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

	//24 hours:
	if(LotteryCheck >= GetLotteryDuration())
	{

		//Print:
		PrintToServer("|RP| - Starting Lottery");

		//Sql Strings:
		Format(query, sizeof(query), "SELECT * FROM `Lottery` ORDER BY RANDOM() LIMIT 1;");

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_LoadLotteryWinsCallBack, query, (LotteryTickets * GetLotterTicketPrice()));
	}

	if((GetLotteryDuration() / 2) == LotteryCheck)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Lottery|\x07FFFFFF - The Lottery for \x0732CD32%s\x07FFFFFF starts in %i Minutes!", IntToMoney((LotteryTickets * GetLotterTicketPrice())), (GetLotteryDuration() / 2));
	}

	if((GetLotteryDuration() - 10) == LotteryCheck)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Lottery|\x07FFFFFF - The Lottery for \x0732CD32%s\x07FFFFFF starts in %i Minutes!", IntToMoney((LotteryTickets * GetLotterTicketPrice())), 10);
	}

	if((GetLotteryDuration() - 5) == LotteryCheck)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Lottery|\x07FFFFFF - The Lottery starts for \x0732CD32%s\x07FFFFFF in %i Minutes!", IntToMoney((LotteryTickets * GetLotterTicketPrice())), 5);
	}

	//Declare:
	int Random = GetRandomInt(1, GetLotteryChance());

	//Check
	if(Random == 1)
	{

		//Initulize:
		LotteryTickets += 1;

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE LotteryData SET Tickets = %i;", LotteryTickets);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public Action Command_EnterLottery(int Client, int Args)
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
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "SELECT * FROM `Lottery` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLotteryTickets, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public Action Command_Lottery(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - The Lottery of \x0732CD32%s\x07FFFFFF Starts in %i Minutes, Tickets Cost \x0732CD32%s\x07FFFFFF!", IntToMoney((LotteryTickets * GetLotterTicketPrice())), (GetLotteryDuration() - LotteryCheck), IntToMoney(GetLotterTicketPrice()));

	CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - Type \x0732CD32!enter\x07FFFFFF in chat to buy a ticket!");

	//Return:
	return Plugin_Handled;
}

public void VendorMenuLottery(int Client)
{

	//Declare:
	char FormatTitle[255];

	//Format:
	Format(FormatTitle, sizeof(FormatTitle), "Would you like to buy a\nlottery ticket?\nCurrent Lottery %s", IntToMoney((LotteryTickets * GetLotterTicketPrice())));

	//Handle:
	Menu menu = CreateMenu(HandleLotteryMenu);

	//Menu Title:
	menu.SetTitle(FormatTitle);

	//Menu Button:
	menu.AddItem("0", "View Winners");

	//Declare:
	char FormatMenu[50];

	//Format:
	Format(FormatMenu, 50, "[€%i] Lottery Ticket", GetLotterTicketPrice());

	//Menu Button:
	menu.AddItem("1", FormatMenu);

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleLotteryMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int Result = StringToInt(info);

			//Declare:
			char query[255];

			//Button Selected:
			if(Result == 0)
			{

				//Sql Strings:
				Format(query, sizeof(query), "SELECT Name, Amount FROM `LotteryWinners` ORDER BY Amount DESC LIMIT 15;");

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLLoadRPWinners, query, conuserid);

				//CPrint:
				PrintToConsole(Client, "|RP| Loading Lottery Winners.");
			}

			//Button Selected:
			if(Result == 1)
			{

				//Sql Strings:
				Format(query, sizeof(query), "SELECT * FROM `Lottery` WHERE STEAMID = %i;", SteamIdToInt(Client));

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_DBLoadLotteryTickets, query, conuserid);
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

public int T_DBLoadLotteryTickets(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Lottery] T_DBLoadLotteryTickets: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Check:
		if(IsClientInGame(Client))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| Loading player stats...");
		}

		//Declare:
		int ClientOwnedTickets = 0;

		//Not Player:
		if(SQL_GetRowCount(hndl))
		{

			//Initulize:
			ClientOwnedTickets += 1;
		}

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Initulize:
			ClientOwnedTickets += 1;
		}

		//Check:
		if(ClientOwnedTickets == 10)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - You can only enter into the lottery 10 times, you have \x0732CD32%s\x07FFFFFF entries currently!", IntToMoney((LotteryTickets * GetLotterTicketPrice())));
		}

		//Enough Cash:
		else if(GetBank(Client) - GetLotterTicketPrice() > 0 && GetBank(Client) != 0)
		{

			//Initialize:
			SetBank(Client, (GetBank(Client) - GetLotterTicketPrice()));

			//Initulize:
			LotteryTickets += 1;

			//Declare:
			char query[255];

			//Sql String:
			Format(query, sizeof(query), "INSERT INTO Lottery (`STEAMID`) VALUES (%i);", SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE LotteryData SET Tickets = %i;", LotteryTickets);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Check:
			if(ClientOwnedTickets >= 2)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - This is your %i Entry into the Lottery for \x0732CD32%s\x07FFFFFF!", ClientOwnedTickets, IntToMoney((LotteryTickets * GetLotterTicketPrice())));
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - You have been entered into the Lottery for \x0732CD32%s\x07FFFFFF!", IntToMoney((LotteryTickets * GetLotterTicketPrice())));
			}

			//Reload Menu:
			VendorMenuLottery(Client);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - You dont have enougn cash to be entered into the RP Lottery!");
		}
	}
}

public void SQLLoadRPWinners(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Lottery] SQLLoadRPWinners: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		char FormatMessage[2048];
		char WinnerName[15][32];
		int AmountWon[15];

		//Declare:
		int len = 0;
		int i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Lottery Winners:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, WinnerName[i], 32);

			//Database Field Loading Intiger:
			AmountWon[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (€%i)\n", WinnerName[i], AmountWon[i]);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public void T_LoadLotteryWinsCallBack(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_LoadLotteryWinsCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP-Lottery|\x07FFFFFF - No one has eneterd the lottery of \x0732CD32%s\x07FFFFFF!", IntToMoney((LotteryTickets * GetLotterTicketPrice())));

			//Initulize:
			LotteryCheck = 0;

			LotteryTickets = 1;

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = 0, Tickets = 0;");

			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

			//Sql Strings:
			Format(query, sizeof(query), "DELETE FROM Lottery;");

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Declare:
			char query[255];

			//Declare:
			int SteamId = SQL_FetchInt(hndl, 0);
			int FoundPlayer = -1;

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(SteamId == SteamIdToInt(i))
					{

						//Initulize:
						FoundPlayer = 1;

						SetBank(i, (GetBank(i) + data));

						//Declare:
						char ClientName[255];
						char CNameBuffer[255];

						//Initialize:
						GetClientName(i, ClientName, sizeof(ClientName));

						//Remove Harmfull Strings:
						SQL_EscapeString(hDataBase, ClientName, CNameBuffer, sizeof(CNameBuffer));

						//Sql String:
						Format(query, sizeof(query), "INSERT INTO LotteryWinners (`NAME`,`STEAMID`,`Amount`,`Collected`) VALUES ('%s',%i,%i,1);", CNameBuffer, SteamIdToInt(i), data);

						//Not Created Tables:
						SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - Congratulations you have won the lottery!");

						//Print:
						CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%s\x07FFFFFF Has won the lottery! €\x0732CD32%i\x07FFFFFF rewarded!", ClientName, data);

						//Initulize:
						LotteryCheck = 0;

						LotteryTickets = 1;

						//Sql Strings:
						Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = 0, Tickets = 0;");

						//Not Created Tables:
						SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

						//Sql Strings:
						Format(query, sizeof(query), "DELETE FROM Lottery;");

						//Not Created Tables:
						SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
					}
				}
			}

			//Save in DB:
			if(FoundPlayer == -1)
			{

				//Handle:
				DataPack pack = new DataPack();

				//Write
				pack.WriteCell(SteamId);

				pack.WriteCell(data);

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME FROM `Player` Where STEAMID = %i;", SteamId);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_LoadLotterySaveWinnerCallBack, query, pack);
			}
		}
	}
}

public void T_LoadLotterySaveWinnerCallBack(Handle owner, Handle hndl, const char[] error, any pack)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_LoadLotterySaveWinnerCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{


		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			char ClientName[255];

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, ClientName, sizeof(ClientName));

			//Read:
			ResetPack(pack);

			//Declare:
			int SteamId = ReadPackCell(pack);
			int AmountWon = ReadPackCell(pack);

			//Declare:
			char query[255];

			//Sql String:
			Format(query, sizeof(query), "INSERT INTO LotteryWinners (`NAME`,`STEAMID`,`Amount`,`Collected`) VALUES ('%s',%i,%i,0);", ClientName, SteamId, AmountWon);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF Has won the lottery! �\x0732CD32%i\x07FFFFFF rewarded!", ClientName, AmountWon);

			//Initulize:
			LotteryCheck = 0;

			LotteryTickets = 1;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = 0, Tickets = 0;");

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Sql Strings:
			Format(query, sizeof(query), "DELETE FROM Lottery;");

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}
	}
}

public void T_DBLoadLotteryDataCallback(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_LotteryData] T_DBLoadLotteryDataCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Declare:
			char buffer[255];

			//Sql String:
			Format(buffer, sizeof(buffer), "INSERT INTO LotteryData (`Ticker`, `Tickets`) VALUES (0,0);");

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

			//Print:
			PrintToServer("|RP| - Created new Lottery Data");
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			LotteryCheck = SQL_FetchInt(hndl, 0);

			//Database Field Loading INTEGER:
			LotteryTickets = SQL_FetchInt(hndl, 1);

			//Print:
			PrintToServer("|RP| - Lottery Data Loaded");
		}
	}
}

public void T_DBLoadLotteryCallback(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Lottery] T_DBLoadLotteryCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading Lottery Tickets...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| No Lottery Tickets Found.");
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| Lottery Tickets Found.");
		}
	}
}

public void T_DBLoadLotteryCheckCallback(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Lottery] T_DBLoadLotteryCheckCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Checking Lottery Data...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| You haven't won the lottery!");
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Declare:
			int Collected = SQL_FetchInt(hndl, 1);

			//Is Valid:
			if(Collected == 0)
			{

				//Declare:
				int Winnings = SQL_FetchInt(hndl, 0);

				//Initulize:
				Bank[Client] += Winnings;

				//Declare:
				char query[512];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE LotteryWinners SET Collected = 1 WHERE STEAMID = %i;", SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", Bank[Client], SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//CPrint:
				CPrintToChatAll("\x07FF4040|RP - Lottery|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has won the lottery! they reseaved \x0732CD32%i\x07FFFFFF!", Client, Winnings);
			}

			//Override:
			else
			{

				//Print:
				PrintToConsole(Client, "|RP| Winnings already collected!");
			}
		}
	}
}

public void UpdateLotteryWinnerTable(int Client, char NewName[32])
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "UPDATE LotteryWinners SET NAME = '%s' WHERE STEAMID = %i;", NewName, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

