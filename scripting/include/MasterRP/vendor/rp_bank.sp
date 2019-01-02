//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bank_included_
  #endinput
#endif
#define _rp_bank_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

//Hud Handles
Handle CashTimer[MAXPLAYERS + 1] = {INVALID_HANDLE,...};
Handle BankTimer[MAXPLAYERS + 1] = {INVALID_HANDLE,...};

//Money System:
int Bank[MAXPLAYERS + 1] = {0,...};
int Cash[MAXPLAYERS + 1] = {0,...};

//Menu Effect:
char AddedBank[MAXPLAYERS + 1][32];
char AddedCash[MAXPLAYERS + 1][32];

public void initBank()
{

	//Commands
	RegAdminCmd("sm_setbank", Command_SetBank, ADMFLAG_ROOT, "- <Name> <Amount> - Sets the Bank of the Client");

	RegAdminCmd("sm_setcash", Command_SetCash, ADMFLAG_ROOT, "- <Name> <Amount> - Sets the Cash of the Client");

	RegConsoleCmd("sm_locatebank", Command_LocateBank);

	RegConsoleCmd("sm_deposit", Command_Deposit);

	RegConsoleCmd("sm_withdraw", Command_Withdraw);
}

public void DrawBankMenu(int Client, int Ent)
{

	//Check:
	if(IsClientRobbingCashFromBank(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't access the bank because you are robbing a banker!");
	}

	//Check:
	if(IsClientHackingCashFromBank(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't access the bank because you are hacking the bank system!");
	}

	//Override:
	else
	{

		//Is In Time:
		if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && Cash[Client] > 0)
		{

			//Declare:
			int Amount = Cash[Client];

			//Initialize:
			SetBank(Client, (Bank[Client] + Amount));

			SetCash(Client, 0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have deposited \x0732CD32%s\x07FFFFFF in the bank!", IntToMoney(Amount));

			//Set Menu State:
			BankState(Client, Amount);

			//Play Sound:
			EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

			//Initulize:
			SetLastPressedE(Client, 0.0);
		}

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Prop Garbage Can:
			if(StrContains(ClassName, "npc_", false) == 0)
			{

				//Override:
				if(Cash[Client] != 0)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'use'\x07FFFFFF to quick deposit %s!", IntToMoney(Cash[Client]));

					//Initulize:
					SetLastPressedE(Client, GetGameTime());
				}

				//Override:
				else
				{

					//Print:
					OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
				}
			}
		}

		//Declare:
		int Salary = 0;

		//Is Cop:
		if(IsCop(Client) || IsAdmin(Client))
		{

			//Initulize::
			Salary = ((GetJobSalary(Client) * 2));
		}

		//Override:
		else
		{

			//Initulize::
			Salary = ((GetJobSalary(Client) * 2));
		}

		//Declare:
		char title[512]; Format(title, sizeof(title), "Select an option:\n\nBank: €%i\nCash: €%i\nJobSalary: €%i\n\n This menu allows you to manage all\n your money as well as store money\n in your bank account:", Bank[Client], Cash[Client], Salary);

		//Handle:
		Menu menu = CreateMenu(HandleBank);

		//Menu Title:
		menu.SetTitle(title);

		//Menu Button:
		menu.AddItem("1", "Withdraw Cash");

		//Menu Button:
		menu.AddItem("2", "Deposit Cash");

		//Menu Button:
		menu.AddItem("3", "Transfer To Player");

		//Menu Button:
		menu.AddItem("4", "Top Players");

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);

		//Initulize:
		SetMenuTarget(Client, Ent);
	}
}
//BankMenu Handle:
public int HandleBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

		//Button Selected:
		if(Result == 1)
		{

			//Show Menu:
			DrawWithdrawMenu(Client);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			DrawDepositMenu(Client);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Show Menu:
			DrawTransactMenu(Client);
		}

		//Button Selected:
		if(Result == 4)
		{

			//Show Menu:
			DrawTopMenu(Client);
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

public void DrawWithdrawMenu(int Client)
{

	//Declare:
	char display[32];
	char info[32];

	//Convert:
	IntToString(Bank[Client], info, sizeof(info));

	//Handle:
	Menu menu = CreateMenu(Withdrawl);

	//Declare:
	char title[256]; Format(title, sizeof(title), "Select an amount to withdraw:\n\nThis menu allows you to select\n an amount to withdrawl from\n the bank:\n\nYou have €%i to withdraw", Bank[Client]);

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", Bank[Client]);

	//Menu Button:
	menu.AddItem(info, display);

	//Menu Button:
	menu.AddItem("1", "1");

	//Menu Button:
	menu.AddItem("2", "2");

	//Menu Button:
	menu.AddItem("5", "5");

	//Menu Button:
	menu.AddItem("10", "10");

	//Menu Button:
	menu.AddItem("25", "25");

	//Menu Button:
	menu.AddItem("50", "50");

	//Menu Button:
	menu.AddItem("100", "100");

	//Menu Button:
	menu.AddItem("250", "250");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2500", "2500");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Menu Button:
	menu.AddItem("100000", "100000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public void DrawDepositMenu(int Client)
{

	//Declare:
	char display[32];
	char info[32];

	//Convert:
	IntToString(Cash[Client], info, sizeof(info));

	//Handle:
	Menu menu = CreateMenu(Deposits);

	//Declare:
	char title[256]; Format(title, sizeof(title), "Select an amount to Deposit:\n\nThis menu allows you to select\n an amount to deposit into\n the bank:\n\nYou have €%i to deposit", Cash[Client]);

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", Cash[Client]);

	//Menu Button:
	menu.AddItem(info, display);

	//Menu Button:
	menu.AddItem("1", "1");

	//Menu Button:
	menu.AddItem("2", "2");

	//Menu Button:
	menu.AddItem("5", "5");

	//Menu Button:
	menu.AddItem("10", "10");

	//Menu Button:
	menu.AddItem("25", "25");

	//Menu Button:
	menu.AddItem("50", "50");

	//Menu Button:
	menu.AddItem("100", "100");

	//Menu Button:
	menu.AddItem("250", "250");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2500", "2500");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Menu Button:
	menu.AddItem("100000", "100000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public void DrawTransactMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleTransfer);

	//Declare:
	char title[256]; Format(title, sizeof(title), "Transfer cash?\n\n Remember when transfering\n Cash through the bank\n has a 10 percent\n Intrest rate:");

	//Menu Title:
	menu.SetTitle(title);

	//Declare:
	char name[65];
	char ID[25];

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientInGame(i))
		{

			//Initialize:
			continue;
		}

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
	menu.Display(Client, 30);
}

public void DrawTransactCashMenu(int Client)
{

	//Declare:
	char AllBank[32];
	char bAllBank[32];

	//Format:
	Format(AllBank, 32, "All (€%i)", Bank[Client]);

	Format(bAllBank, 32, "%i", Bank[Client]);

	//Handle:
	Menu menu = CreateMenu(HandleTransferDeposit);

	//Declare:
	char title[256]; Format(title, sizeof(title), "How Much To Transfer:\nTransfer Rate: €10/€9");

	//Menu Title:
	menu.SetTitle(title);

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
	menu.Display(Client, 30);
}

public void DrawTopMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleTopMenu);

	//Declare:
	char title[256]; Format(title, sizeof(title), "This menu allows you to see\nthe top stats/rank for all players!");

	//Menu Title:
	menu.SetTitle(title);

	//Menu Button:
	menu.AddItem("1", "Richest Player");

	//Menu Button:
	menu.AddItem("2", "Most Wanted");

	//Menu Button:
	menu.AddItem("3", "Most Online");

	//Menu Button:
	menu.AddItem("4", "Highest Wages");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public int Deposits(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, GetMenuTarget(Client)))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Amount = StringToInt(info);

			//Can Transact:
			if(!(GetCash(Client) - Amount < 0 || GetBank(Client) + Amount < 0) && GetCash(Client) != 0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) - Amount));

				SetBank(Client, (GetBank(Client) + Amount));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have deposited \x0732CD32€%i\x07FFFFFF in the bank!", Amount);

				//Set Menu State:
				CashState(Client, Amount);

				BankState(Client, Amount);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Show Menu:
				DrawDepositMenu(Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You don't have that much Cash with you!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC/Player anymore, because you too far away");
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
public int Withdrawl(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, GetMenuTarget(Client)))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:				
			int Amount = StringToInt(info);

			//Can Transact:
			if(!(Cash[Client] + Amount < 0 || Bank[Client] - Amount < 0) && Bank[Client] !=0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) + Amount));

				SetBank(Client, (GetBank(Client) - Amount));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have withdrawn \x0732CD32€%i\x07FFFFFF from the bank!", Amount);

				//Set Menu State:
				CashState(Client, Amount);

				BankState(Client, Amount);

				//Show Menu:
				DrawWithdrawMenu(Client);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You don't have that much cash on your bank.");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC anymore, because you too far away!");
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

public int HandleTransfer(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int Player = StringToInt(info);

		//Is Actual Player:
		if(Player > 0 && Client != Player && IsClientConnected(Player) && IsClientInGame(Player))
		{

			//Initialize:
			SetMenuTarget(Client, Player);

			//Show Menu:
			DrawTransactCashMenu(Client);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - This Player is unavailable or disconnected");
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

public int HandleTransferDeposit(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, GetMenuTarget(Client)))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int Amount = StringToInt(info);

			int Ent = GetMenuTarget(Client);

			//Connected:
			if(Ent > 0 && Client != Ent && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Has Enough Cash:
				if(Bank[Client] - Amount > 0 && Bank[Client] != 0 && Amount > 0)
				{

					//Declare:
					int NewAmount = RoundFloat(float(Amount)*0.90);

					//Initialize:
					SetBank(Client, (GetBank(Client) - Amount));

					SetBank(Ent, (GetBank(Ent) + NewAmount));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You just put \x0732CD32€%i\x07FFFFFF (\x0732CD32-€%i intrest\x07FFFFFF) in \x0732CD32%N\x07FFFFFF bank.", Amount, NewAmount, Ent);

					CPrintToChat(Ent, "\x07FF4040|RP-Bank|\x07FFFFFF - \x0732CD32%N\x07FFFFFF just put \x0732CD32€%i\x07FFFFFF (\x0732CD32-€%i intrest\x07FFFFFF) into your bank.", Client, Amount, NewAmount);

					//Set Menu State:
					BankState(Client, Amount);

					BankState(Ent, (Amount + Amount-(Amount/10)));

					//Draw Menu:
					DrawTransactMenu(Client);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);	
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You cannot target this player!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC anymore, because you too far away!");
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
public int HandleTopMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
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
			if(Result == 1)
			{

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Bank, Cash FROM `Player` ORDER BY Bank + Cash DESC LIMIT 15;");

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopBank, query, conuserid);
			}

			//Button Selected:
			if(Result == 2)
			{

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Crime FROM `Player` ORDER BY Crime DESC LIMIT 15;");

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopCriminals, query, conuserid);
			}

			//Button Selected:
			if(Result == 3)
			{

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Rase FROM `Player` ORDER BY Rase DESC LIMIT 15;");

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopOnline, query, conuserid);
			}

			//Button Selected:
			if(Result == 4)
			{

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, JobSalary FROM `Player` ORDER BY JobSalary DESC LIMIT 15;");

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopWages, query, conuserid);
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

public void T_SQLLoadRPTopBank(Handle owner, Handle hndl, const char[] error, any data)
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
		int PlayerCash[15];
		int PlayerBank[15];
		char PlayerName[15][32];

		//Declare:
		int len = 0;
		int i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Top Bank:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerCash[i] = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			PlayerBank[i] = SQL_FetchInt(hndl, 2);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%s)\n", PlayerName[i], IntToMoney(PlayerBank[i] + PlayerCash[i]));

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public void T_SQLLoadRPTopCriminals(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Top] T_SQLLoadRPTopCriminals: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		char FormatMessage[2048];
		int PlayerCrime[15];
		char PlayerName[15][32];

		//Declare:
		int len = 0;
		int i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Most Wanted Players:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerCrime[i] = SQL_FetchInt(hndl, 1);

			//Check:
			if(PlayerCrime[i] > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%i)\n", PlayerName[i], RoundFloat(float(PlayerCrime[i]) / 1000));
			}

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public void T_SQLLoadRPTopOnline(Handle owner, Handle hndl, const char[] error, any data)
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

		//Declare:
		char FormatMessage[2048];
		int PlayerOnline[15];
		char PlayerName[15][32];

		//Declare:
		int len = 0;
		int i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Most Online Players:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerOnline[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%i)\n", PlayerName[i], RoundFloat(float(PlayerOnline[i]) / 60));

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public void T_SQLLoadRPTopWages(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Top] T_SQLLoadRPTopOnline: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		char FormatMessage[2048];
		int PlayerSalary[15];
		char PlayerName[15][32];

		//Declare:
		int len = 0;
		int i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Highest Waged player:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerSalary[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%i)\n", PlayerName[i], PlayerSalary[i]);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public void BankState(int Client, int Amount)
{

	//Is Negative:
	if(Amount < 0)
	{

		//Format:
		Format(AddedBank[Client], sizeof(AddedBank[]), " - %s", IntToMoney(Amount));
	}

	//Is Negative:
	else
	{

		//Format:
		Format(AddedBank[Client], sizeof(AddedBank[]), " + %s", IntToMoney(Amount));
	}

	if(BankTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(BankTimer[Client]);

		//Initialize:
		BankTimer[Client] = INVALID_HANDLE;
	}

	//Timer:
	BankTimer[Client] = CreateTimer(3.0, RefreshBankState, Client);
}

public void CashState(int Client, int Amount)
{

	//Is Negative:
	if(Amount < 0)
	{

		//Format:
		Format(AddedCash[Client], sizeof(AddedCash[]), " - %s", IntToMoney(Amount));
	}

	//Is Negative:
	else
	{

		//Format:
		Format(AddedCash[Client], sizeof(AddedCash[]), " + %s", IntToMoney(Amount));
	}

	//Check:
	if(CashTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(CashTimer[Client]);

		//Initialize:
		CashTimer[Client] = INVALID_HANDLE;
	}

	//Timer:
	CashTimer[Client] = CreateTimer(3.0, RefreshCashState, Client);
}

//Timer:
public Action RefreshBankState(Handle Timer, any Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Initialize:
		AddedBank[Client] = "";
	}

	//Initialize:
	BankTimer[Client] = INVALID_HANDLE;
}

//Timer:
public Action RefreshCashState(Handle Timer, any Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Initialize:
		AddedCash[Client] = "";
	}

	//Initialize:
	CashTimer[Client] = INVALID_HANDLE;
}

char GetCashState(int Client)
{

	//Return:
	return AddedCash[Client];
}

//char GetBankState(int Client)
//{

	//Return:
//	return AddedBank[Client];
//}

public int GetBank(int Client)
{

	//Return:
	return Bank[Client];
}

public int SetBank(int Client, int Amount)
{

	//Initulize:
	Bank[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", Bank[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Bank[Client];
}

public int GetCash(int Client)
{

	//Return:
	return Cash[Client];
}

public int SetCash(int Client, int Amount)
{

	//Initulize:
	Cash[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", Cash[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Cash[Client];
}

public Action Command_SetCash(int Client, int Args)
{

	//Is Valid:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_setcash <USER> <Cash>");

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
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Initialize:
	SetCash(Player, iAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set the Cash for \x0732CD32%N\x07FFFFFF to \x0732CD32€%i", Player, iAmount);

	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Your Cash has been set to \x0732CD32€%i\x07FFFFFF by \x0732CD32%N", iAmount, Client);
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set %N's Cash to \"€%i\"", Client, Player, iAmount); 
#endif

	//Return:
	return Plugin_Handled; 
}

public Action Command_SetBank(int Client, int Args)
{

	//Is Valid:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_setbank <USER> <Cash>");

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
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Initialize:
	SetBank(Player, iAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set the Bank for \x0732CD32%N\x07FFFFFF to \x0732CD32€%i", Player, iAmount);

	CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Your Bank has been set to \x0732CD32€%i\x07FFFFFF by \x0732CD32%N", iAmount, Client);
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set %N's bank to \"€%i\"", Client, Player, iAmount); 
#endif

	//Return:
	return Plugin_Handled; 
}

public void DrawDropCashMenu(int Client)
{

	//Declare:
	char display[32];
	char info[32];

	//Convert:
	IntToString(Cash[Client], info, sizeof(info));

	//Handle:
	Menu menu = CreateMenu(HandleDropMoney);

	//Declare:
	char title[256]; Format(title, sizeof(title), "Select an amount of cash\nthat you would like to drop.");

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", Cash[Client]);

	//Menu Button:
	menu.AddItem(info, display);

	//Menu Button:
	menu.AddItem("1", "1");

	//Menu Button:
	menu.AddItem("2", "2");

	//Menu Button:
	menu.AddItem("5", "5");

	//Menu Button:
	menu.AddItem("10", "10");

	//Menu Button:
	menu.AddItem("25", "25");

	//Menu Button:
	menu.AddItem("50", "50");

	//Menu Button:
	menu.AddItem("100", "100");

	//Menu Button:
	menu.AddItem("250", "250");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2500", "2500");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Menu Button:
	menu.AddItem("100000", "100000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleDropMoney(Menu menu, MenuAction HandleAction, int Client, int Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Can Drop:
			if(IsPlayerAlive(Client) && !IsCuffed(Client) && !GetIsCritical(Client))
			{

				//Declare:
				char info[64];

				//Get Menu Info:
				menu.GetItem(Parameter, info, sizeof(info));

				//Declare:
				int Amount = StringToInt(info);

				//Can Transact:
				if(!(Cash[Client] - Amount < 0) && Cash[Client] != 0)
				{

					//EntCheck:
					if(CheckMapEntityCount() > 2047)
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());

						//Return:
						return true;
					}

					//Declare:
					int Props = GetMoneyPropsOnMap();

					//Check:
					if(Props >= 100)
					{

						//Can Replace Prop:
						if(ReplaceMoneyProp() == false)
						{

							//Return:
							return true;
						}

						//Remove:
						RemoveLowMoneyCountProps();
					}

					//Declare:
					float Position[3];
					char Model[64];

					//Initialize:
					Model = "models/props_c17/briefcase001a.mdl";

					SetCash(Client, (GetCash(Client) - Amount));

					//Is Precached:
					if(!IsModelPrecached(Model))
					{

						//Precache:
						PrecacheModel(Model);
					}

					//Declare:
					int Ent = CreateEntityByName("prop_physics_override");

					//Is Ent
					if(IsValidEntity(Ent))
					{

						//Values:
						DispatchKeyValue(Ent, "model", Model);

						//Spawn:
						DispatchSpawn(Ent);

						//Initialize:
						GetClientAbsOrigin(Client, Position);

						//Set Origin:
						Position[2] += 10.0;

						//Declare:
						int Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

						//Set End Data:
						SetEntData(Ent, Collision, 1, 1, true);

						//Teleport:
		   			 	TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);

						//Initialize:
						SetDroppedMoneyValue(Ent, Amount);

						//Set do default classname
						SetEntityClassName(Ent, "prop_Money");

#if defined DEBUG
						//Loggng:
						LogMessage("%N Dropped €%i", Client, Amount);
#endif
						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have dropped \x0732CD32€%i\x07FFFFFF.", Amount);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you do not have enough cash.");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not allowed to drop cash.");
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

public Action Command_LocateBank(int Client, int Args)
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
	float Position[3];
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
	Position[2] += 25.0;

	//Declare:
	float LastDistance = 0.0;
	int FindEnt = -1;
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_Banker")) != -1)
	{

		//Initialize:
		GetEntPropVector(Props, Prop_Send, "m_vecOrigin", Origin);

		//Declare:
		float Dist = GetVectorDistance(Position, Origin);

		//In Distance:
		if(Dist <= LastDistance || LastDistance == 0.0)
		{

			//Initulize:
			LastDistance = Dist;
			FindEnt = Props;
		}
	}

	//Check:
	if(!IsValidEdict(FindEnt))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no bank vendor currently spawned on the map");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	GetEntPropVector(FindEnt, Prop_Send, "m_vecOrigin", Origin);
	Origin[2] += 25.0;

	//Declare:
	int BeamColor[4] = {255, 255, 255, 225};

	TE_SetupBeamPoints(Position, Origin, Laser(), 0, 0, 66, 1.0, 1.0, 1.0, 0, 0.0, BeamColor, 0);

	TE_SendToClient(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_Deposit(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_deposit <Cash>");

		//Return:
		return Plugin_Handled;      
	}

	//Declare:
	float Position[3];
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
	Position[2] += 25.0;

	//Declare:
	float LastDistance = 0.0;
	int FindEnt = -1;
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_Banker")) != -1)
	{

		//Initialize:
		GetEntPropVector(Props, Prop_Send, "m_vecOrigin", Origin);

		//Declare:
		float Dist = GetVectorDistance(Position, Origin);

		//In Distance:
		if(Dist <= LastDistance || LastDistance == 0.0)
		{

			//Initulize:
			LastDistance = Dist;
			FindEnt = Props;
		}
	}

	//Check:
	if(!IsValidEdict(FindEnt))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no bank vendor currently spawned on the map");

		//Return:
		return Plugin_Handled;
	}


	//In Distance:
	if(!IsInDistance(Client, FindEnt))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC/Player anymore, because you too far away");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Initialize:
	int Amount;

	//Prop Garbage Can:
	if(StrEqual(Arg1, "all"))
	{

		//Initialize:
		Amount = GetCash(Client);
	}

	//Override:
	else
	{

		//Initialize:
		Amount = StringToInt(Arg1);
	}

	//Initialize:
	if(GetCash(Client) - Amount > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You dont have that much cash on you!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	SetBank(Client, (GetBank(Client) + Amount));
	SetCash(Client, (GetCash(Client) - Amount));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have deposited \x0732CD32%s\x07FFFFFF in the bank!", IntToMoney(Amount));

	//Return:
	return Plugin_Handled;
}

public Action Command_Withdraw(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_withdraw <Cash>");

		//Return:
		return Plugin_Handled;      
	}

	//Declare:
	float Position[3];
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
	Position[2] += 25.0;

	//Declare:
	float LastDistance = 0.0;
	int FindEnt = -1;
	int Props = -1;

	//Switch:
	while ((Props = FindEntityByClassname(Props, "npc_Banker")) != -1)
	{

		//Initialize:
		GetEntPropVector(Props, Prop_Send, "m_vecOrigin", Origin);

		//Declare:
		float Dist = GetVectorDistance(Position, Origin);

		//In Distance:
		if(Dist <= LastDistance || LastDistance == 0.0)
		{

			//Initulize:
			LastDistance = Dist;
			FindEnt = Props;
		}
	}

	//Check:
	if(!IsValidEdict(FindEnt))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no bank vendor currently spawned on the map");

		//Return:
		return Plugin_Handled;
	}


	//In Distance:
	if(!IsInDistance(Client, FindEnt))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC/Player anymore, because you too far away");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Initialize:
	int Amount;

	//Prop Garbage Can:
	if(StrEqual(Arg1, "all"))
	{

		//Initialize:
		Amount = GetBank(Client);
	}

	//Override:
	else
	{

		//Initialize:
		Amount = StringToInt(Arg1);
	}

	//Initialize:
	if(GetBank(Client) - Amount > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You dont have that in the bank!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	SetBank(Client, (GetBank(Client) - Amount));
	SetCash(Client, (GetCash(Client) + Amount));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have withdrawed \x0732CD32%s\x07FFFFFF from the bank!", IntToMoney(Amount));

	//Return:
	return Plugin_Handled;
}
