//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_copranking_included_
  #endinput
#endif
#define _rp_copranking_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

public void CopRankingMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleJobCop);

	//Menu Title:
	menu.SetTitle("Select a button:\n\nCop Cuffs: %i\nCop Minutes: %i", GetCopCuffs(Client), GetCopMinutes(Client));

	//Add Menu Item:
	menu.AddItem("0", "Change Your Job!");

	menu.AddItem("1", "Lockdown Events!");

	menu.AddItem("2", "Sell Goods!");

	menu.AddItem("3", "Trade Cop Experience!");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//BankMenu Handle:
public int HandleJobCop(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));	

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Not Cop:
			if(IsCop(Client))
			{

				//Handle:
				menu = CreateMenu(HandleCopEmployer);

				//Menu Title:
				menu.SetTitle("Select a Police Job:\nCop Experience: %i\nCorporal (500)\nSergeant (2500)\nLieutenant (7500)\nCaptain (17500)\nMajor (34000)\nLt. Colonel (59000)", GetCopExperience(Client));

				//Menu Button:
				menu.AddItem("0", "Police Private");

				menu.AddItem("500", "Police Corporal");

				menu.AddItem("2500", "Police Sergeant");

				menu.AddItem("7500", "Police Lieutenant");

				menu.AddItem("17500", "Police Captain");

				menu.AddItem("34000", "Police Major");

				menu.AddItem("59000", "Police Lt. Colonel");

				menu.AddItem("82000", "SWAT");

				menu.AddItem("104000", "SWAT Leader");

				//Set Exit Button:
				menu.ExitButton = false;

				//Show Menu:
				menu.Display(Client, 30);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You need to be a cop in order to use this!");
			}
		}

		//Button Selected:
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(HandleCopLockdownEvents);

			//Menu Title:
			menu.SetTitle("Select an option");

			//Menu Button:
			menu.AddItem("0", "Lockdown");

			//Menu Button:
			menu.AddItem("1", "Police Boss");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Declare:
			int OldHarvest = GetResources(Client) + GetRice(Client) + GetMetal(Client);

			//Is In Time:
			if(OldHarvest > 0)
			{

				//Initulize:
				int AddCash = (GetResources(Client) * 2) + (GetRice(Client) * 2 + (GetMetal(Client) * 2));

				SetCash(Client, (GetCash(Client) + AddCash));

				//Set Menu State:
				CashState(Client, AddCash);

				//Initulize:
				SetRice(Client, 0);

				SetResources(Client, 0);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFF Grams and made \x0732CD32€%i\x07FFFFFF!", OldHarvest, AddCash);
			}

			//Override:
			else
			{


				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - you dont have anything to quick sell!");
			}
		}

		//Button Selected:
		if(Result == 3)
		{

			//Draw Menu:
			DrawCopTradeExpMenu(Client);
		}

		//Return:
		return true;
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

public int HandleCopEmployer(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Is Cop:
		if(IsCop(Client))
		{

			//Declare:
			char info[64];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Check:
			if(GetCopExperience(Client) >= StringToInt(info))
			{

				//Format:
				SetJob(Client, display);

				SetOrgJob(Client, display);

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Job = '%s' WHERE STEAMID = %i;", display, SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You job is now \x0732CD32%s\x07FFFFFF.", display);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You need \x0732CD32%i\x07FFFFFF Cop experience for this job.", StringToInt(info));
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

public void DrawCopTradeExpMenu(int Client)
{

	//Declare:
	char display[32];
	char info[32];

	//Convert:
	IntToString(GetCopExperience(Client), info, sizeof(info));

	//Handle:
	Menu menu = CreateMenu(HandleCopTradeExp);

	//Menu Title:
	menu.SetTitle("Select a button:\nCop Experience: %i\nCop Cuffs: %i\nCop Minutes: %i\n\n\nExchange Rate €15|1 CopEXP", GetCopExperience(Client), GetCopCuffs(Client), GetCopMinutes(Client));

	//Format:
	Format(display, sizeof(display), "All (€%i)", GetCopExperience(Client));

	//Menu Button:
	menu.AddItem(info, display);

	//Menu Button:
	menu.AddItem("1", "1");

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
}

public int HandleCopTradeExp(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info::
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Is Valid:
		if(GetCopExperience(Client) - Amount > 0 && GetCopExperience(Client) != 0)
		{

			//Initialize:
			int TradedXp = RoundToNearest(Amount*15.0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have traded \x0732CD32%i\x07FFFFFF xp for \x0732CD32€%i", Amount , TradedXp);

			//Initialize:
			SetBank(Client, (GetBank(Client) + TradedXp));

			SetCopExperience(Client, (GetCopExperience(Client) - Amount));

			//Set Menu State:
			BankState(Client, TradedXp);

			//Play Sound:
			EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much cop experience.");
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

//BankMenu Handle:
public int HandleCopLockdownEvents(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));	

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Handle:
			menu = CreateMenu(HandleCopLockdown);

			//Menu Title:
			menu.SetTitle("Select an option:\nLockdown costs:\nMetal: 3000\nResources: 1000");

			//Menu Button:
			menu.AddItem("1", "Start Lockdown");

			//Menu Button:
			menu.AddItem("0", "No!");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(HandleCopPoliceBoss);

			//Menu Title:
			menu.SetTitle("Select an option:\nPolice Boss costs:\nMetal: 10000\nResources: 5000");

			//Menu Button:
			menu.AddItem("1", "Start Police Boss");

			//Menu Button:
			menu.AddItem("0", "No!");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
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

//BankMenu Handle:
public int HandleCopLockdown(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));	

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 1)
		{

			//Check:
			if(!IsLockdownActive() && !IsPoliceBossActive())
			{

				//Check:
				if(GetGlobalCrime() > 20000 || IsAdmin(Client))
				{

					//Check:
					if(GetMetal(Client) - 3000 >= 0 && GetResources(Client) - 1000 >= 0)
					{

						//Initulize:
						SetMetal(Client, (GetMetal(Client) - 3000));
						SetResources(Client, (GetResources(Client) - 1000));

						//Start:
						StartLockdown(Client);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have the required materials! 3000g of metal and 1000g of resources required!");
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate a lockdown without the required crime on the server!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another lockdown whilst we're still in one!");
			}
		}

		//Button Selected:
		if(Result == 0)
		{

			//Return:
			return true;
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

//BankMenu Handle:
public int HandleCopPoliceBoss(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));	

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 1)
		{

			//Check:
			if(!IsLockdownActive() && !IsPoliceBossActive())
			{

				//Check:
				if(GetGlobalCrime() > 20000 || IsAdmin(Client))
				{

					//Check:
					if(GetMetal(Client) - 10000 >= 0 && GetResources(Client) - 5000 >= 0)
					{

						//Initulize:
						SetMetal(Client, (GetMetal(Client) - 10000));
						SetResources(Client, (GetResources(Client) - 5000));

						//Start:
						StartPoliceBoss(Client);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have the required materials! 10000g of metal and 5000g of resources required!");
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate a lockdown without the required crime on the server!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another lockdown whilst we're still in one!");
			}
		}

		//Button Selected:
		if(Result == 0)
		{

			//Return:
			return true;
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
