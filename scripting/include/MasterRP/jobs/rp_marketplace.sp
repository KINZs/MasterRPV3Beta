//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_marketplace_included_
  #endinput
#endif
#define _rp_marketplace_included_

//Euro - € dont remove this!
//€ = �

public void initMarketPlace()
{

	//Beta
	RegConsoleCmd("sm_marketplace", Command_MarketPlace);

	//Timers:
	CreateTimer(0.2, CreateSQLdbMarketPlace);
}

public void intCheckMarketPlace()
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE Time <= %i;", GetTime());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadMarketPlaceFinishedItems, query);
}

//Create Database:
public Action CreateSQLdbMarketPlace(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `MarketPlace`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL, `ItemId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Amount` int(12) NULL, `BuyItNow` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Bids` int(12) NULL, `Time` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `BidderSteamId` int(12) NULL);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Gang:
public Action Command_MarketPlace(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsClientInTrading(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	MarketPlace(Client);

	//Return:
	return Plugin_Handled;
}

public void MarketPlace(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleMarketPlace);

	//Add Menu Item:
	menu.AddItem("0", "View MarketPlace");

	//Add Menu Item:
	menu.AddItem("1", "Your MarketPlace Items");

	//Add Menu Item:
	menu.AddItem("2", "Sell Items To MarketPlace");

	//Menu Title:
	menu.SetTitle("MarketPlace:\nAllows players to buy and sell items!");

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleMarketPlace(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Result = StringToInt(info);

			//Check:
			if(Result == 0)
			{

				//MarketPlace:
				LoadMarketPlace(Client);
			}

			//Check:
			if(Result == 1)
			{

				//MarketPlace:
				ViewPlayersItemsMarketPlace(Client);
			}

			//Check:
			if(Result == 2)
			{


				//MarketPlace:
				SellItemsSortMarketPlace(Client);
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");
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

public void LoadMarketPlace(int Client)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE Time >= %i;", GetTime());

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadItemSortMarketPlace, query, conuserid);
}

public void T_DBLoadItemSortMarketPlace(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_marketplace] T_DBLoadItemSortMarketPlace: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There are no items for sale on the marketplace!");

			//Return:
			return;
		}

		//Declare:
		bool MenuDisplay = false;

		int ItemActionAmount = 0;

		int MenuShow[20] = {0,...};

		//Handle:
		Menu menu = CreateMenu(HandleSortItemsMarketPlace);

		//Declare:
		int X = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Initialize:
			MenuDisplay = true;

			//Old Items
			if(GetItemGroup(X) == 0 && MenuShow[0] != 1)
			{

				//Add Menu Item:
				menu.AddItem("0", "Old Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[0] = 1;
			}

			//Weapons
			if(GetItemGroup(X) == 1 && MenuShow[1] != 1)
			{

				//Add Menu Item:
				menu.AddItem("1", "Weapons");

				//Initialize:
				ItemActionAmount++;

				MenuShow[1] = 1;
			}

			//Illegal Items:
			if(GetItemGroup(X) == 2 && MenuShow[2] != 1)
			{

				//Add Menu Item:
				menu.AddItem("2", "Illegal Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[2] = 1;
			}

			//Food Drink Energy:
			if(GetItemGroup(X) == 3 && MenuShow[3] != 1)
			{

				//Add Menu Item:
				menu.AddItem("3", "Food Drink Energy");

				//Initialize:
				ItemActionAmount++;

				MenuShow[3] = 1;
			}

			//Lockpick/DoorHack:
			if(GetItemGroup(X) == 4 && MenuShow[4] != 1)
			{

				//Add Menu Item:
				menu.AddItem("4", "Lockpick/DoorHack");

				//Initialize:
				ItemActionAmount++;

				MenuShow[4] = 1;
			}

			//Furniture:
			if(GetItemGroup(X) == 5 && MenuShow[5] != 1)
			{

				//Add Menu Item:
				menu.AddItem("5", "Furniture");

				//Initialize:
				ItemActionAmount++;

				MenuShow[5] = 1;
			}

			//Health Kits:
			if(GetItemGroup(X) == 6 && MenuShow[6] != 1)
			{

				//Add Menu Item:
				menu.AddItem("6", "Health Kits");

				//Initialize:
				ItemActionAmount++;

				MenuShow[6] = 1;
			}

			//Other Items:
			if(GetItemGroup(X) == 7 && MenuShow[7] != 1)
			{

				//Add Menu Item:
				menu.AddItem("7", "Other Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[7] = 1;
			}

			//Models and Hats:
			if(GetItemGroup(X) == 8 && MenuShow[8] != 1)
			{

				//Add Menu Item:
				menu.AddItem("8", "Models and Hats");

				//Initialize:
				ItemActionAmount++;

				MenuShow[8] = 1;
			}

			//Drugs and Alcohol:
			if(GetItemGroup(X) == 9 && MenuShow[9] != 1)
			{

				//Add Menu Item:
				menu.AddItem("9", "Drugs and Alcohol");

				//Initialize:
				ItemActionAmount++;

				MenuShow[9] = 1;
			}

			//Misc Items:
			if(GetItemGroup(X) == 10 && MenuShow[10] != 1)
			{

				//Add Menu Item:
				menu.AddItem("10", "Misc Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[10] = 1;
			}

			//Door Items:
			if(GetItemGroup(X) == 11 && MenuShow[11] != 1)
			{

				//Add Menu Item:
				menu.AddItem("11", "Door Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[11] = 1;
			}

			//Police Items:
			if(GetItemGroup(X) == 12 && MenuShow[12] != 1)
			{

				//Add Menu Item:
				menu.AddItem("12", "Police Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[12] = 1;
			}

			//JetPack Items:
			if(GetItemGroup(X) == 13 && MenuShow[13] != 1)
			{

				//Add Menu Item:
				menu.AddItem("13", "JetPack Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[13] = 1;
			}

			//Job Items:
			if(GetItemGroup(X) == 14 && MenuShow[14] != 1)
			{

				//Add Menu Item:
				menu.AddItem("14", "Job Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[14] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 15 && MenuShow[15] != 1)
			{

				//Add Menu Item:
				menu.AddItem("15", "Trail Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[15] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 16 && MenuShow[16] != 1)
			{

				//Add Menu Item:
				menu.AddItem("16", "Vehicle Inventory");

				//Initialize:
				ItemActionAmount++;

				MenuShow[16] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 17 && MenuShow[17] != 1)
			{

				//Add Menu Item:
				menu.AddItem("17", "Hacking Software");

				//Initialize:
				ItemActionAmount++;

				MenuShow[17] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 18 && MenuShow[18] != 1)
			{

				//Add Menu Item:
				menu.AddItem("18", "Trash");

				//Initialize:
				ItemActionAmount++;

				MenuShow[18] = 1;
			}
		}

		//Show Menu:
		if(MenuDisplay)
		{

			//Add Menu Item:
			menu.AddItem("-1", "[Back]");

			//Menu Title:
			menu.SetTitle("Select an item group to find the item\nyour looking for!");

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Close:
			delete menu;
		}

		//Print:
		PrintToConsole(Client, "|RP| - MarketPlace Items Found!");
	}
}

//Item Handle:
public int HandleSortItemsMarketPlace(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Result = StringToInt(info);

			//Check:
			if(Result == -1)
			{

				//Show Menu:
				MarketPlace(Client);
			}

			//Override:
			else
			{
				//Initialize:
				SetSelectedItem(Client, Result);

				//Declare:
				char query[512];

				//Format:
				Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE Time >= %i;", GetTime());

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_DBLoadSortItemsGroupMarketPlace, query, conuserid);
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");
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

public void T_DBLoadSortItemsGroupMarketPlace(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_marketplace] T_DBLoadSortItemsGroupMarketPlace: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There are no items for sale on the marketplace!");

			//Return:
			return;
		}

		//Declare:
		bool MenuDisplay = false;

		//Handle:
		Menu menu = CreateMenu(HandleSortItemsMarketPlaceSelectItem);

		//Declare:
		int SteamId = 0;
		int X = 0;
		int Amount = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Amount = SQL_FetchInt(hndl, 2);

			//Selected Group:
			if(GetItemGroup(X) == GetSelectedItem(Client))
			{

				//Declare:
				char ActionItemId[255];
				char MenuItemName[32];

				//Format:
				Format(MenuItemName, 32, "[x%i] %s", Amount, GetItemName(X));

				//Format:
				Format(ActionItemId, 255, "%i^%i^%i", SteamId, X, Amount);

				//Add Menu Item:
				menu.AddItem(ActionItemId, MenuItemName);

				//Initialize:
				MenuDisplay = true;
			}
		}

		//Show Menu:
		if(MenuDisplay)
		{

			//Add Menu Item:
			menu.AddItem("0^0^0", "[Back]");

			//Menu Title:
			menu.SetTitle("Select an item group to find the item\nyour looking for!");

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Close:
			delete menu;
		}

	}
}

//Item Handle:
public int HandleSortItemsMarketPlaceSelectItem(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client))
		{

			//Declare:
			char info[255];
			char sDump[3][255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Convert:
			ExplodeString(info, "^", sDump, 3, 255);

			//Declare:
			int Dump[3];

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Dump[Y] = StringToInt(sDump[Y]);
			}

			//Check:
			if(Dump[0] == 0)
			{

				//Show Menu:
				MarketPlace(Client);
			}

			//Override:
			else
			{

				//Declare:
				char query[512];

				//Format:
				Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", Dump[0], Dump[1], Dump[2]);

				//Declare:
				int conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_DBLoadSortItemsMarketPlaceSelectedItem, query, conuserid);
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");
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

public void T_DBLoadSortItemsMarketPlaceSelectedItem(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_marketplace] T_DBLoadMarketPlaceSelectedItem: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no items for sale on the marketplace!");

			//Return:
			return;
		}

		//Declare:
		int SteamId;
		int X;
		int Amount;
		int BuyItNow;
		int Bids;
		int Time;

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Amount = SQL_FetchInt(hndl, 2);

			//Database Field Loading Intiger:
			BuyItNow = SQL_FetchInt(hndl, 3);

			//Database Field Loading Intiger:
			Bids = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			Time = SQL_FetchInt(hndl, 5);
		}

		//Check:
		if(Time - GetTime() >= 0)
		{

			//Handle:
			Menu menu = CreateMenu(HandleMarketPlaceSelectedItemMenu);

			//Declare:
			char ActionItemId[255];
			char MenuTitle[255];
			char MenuName[32];

			//Check:
			if(BuyItNow > 0)
			{

				//Check:
				if(BuyItNow > 9999)
				{

					//Format:
					Format(MenuName, sizeof(MenuName), "[%ik] Buy it now", BuyItNow / 1000);
				}

				//Override:
				else
				{

					//Format:
					Format(MenuName, sizeof(MenuName), "[%s] Buy it now", IntToMoney(BuyItNow));
				}

				//Format:
				Format(ActionItemId, 255, "%i^%i^%i^0^%i", SteamId, X, Amount, BuyItNow);

				//Add Menu Item:
				menu.AddItem(ActionItemId, MenuName);
			}

			//Check:
			if(Bids > 9999)
			{

				//New Price
				Bids = Bids / 1000;

				//Format:
				Format(MenuName, sizeof(MenuName), "[€k%i] bids", Bids / 1000);
			}

			//Override:
			else
			{

				//Format:
				Format(MenuName, sizeof(MenuName), "[€%i] bids", Bids);
			}

			//Format:
			Format(ActionItemId, 255, "%i^%i^%i^1^%i", SteamId, X, Amount, Bids);

			//Add Menu Item:
			menu.AddItem(ActionItemId, MenuName);

			//Add Menu Item:
			menu.AddItem("0^0^0^-1^0", "[Back]");

			Time = Time - GetTime();
			int Days = Time / 86400;
			Time %= 86400;
			int Hours = Time / 3600;
			Time %= 3600;
			int Minutes = Time / 60;
			Time %= 60;
			int Seconds = Time % 60;

			//Format:
			Format(MenuTitle, sizeof(MenuTitle), "[x%i] - %s\nTime left: %id:%ih:%im:%is", Amount, GetItemName(X), Days, Hours, Minutes, Seconds);

			//Menu Title:
			menu.SetTitle(MenuTitle);

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item has already finished \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF!", X, GetItemName(X));
		}
	}
}

//Item Handle:
public int HandleMarketPlaceSelectedItemMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client))
		{

			//Declare:
			char info[255];
			char sDump[5][255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Convert:
			ExplodeString(info, "^", sDump, 5, 255);

			//Declare:
			int Dump[5];

			//Loop:
			for(int Y = 0; Y <= 4; Y++)
			{

				//Initulize:
				Dump[Y] = StringToInt(sDump[Y]);
			}

			//Back:
			if(Dump[3] == -1)
			{

				//Show Menu:
				LoadMarketPlace(Client);
			}

			//Check:
			else if(!IsItemStillOnMarketPlace(SteamIdToInt(Client), Dump[1], Dump[2]))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF has already been sold!", Dump[2], GetItemName(Dump[1]));
			}

			//Is Valid:
			else if(Dump[0] == SteamIdToInt(Client))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot buy your own items or bit up your own items!");
			}

			//Action Buy It Now:
			else if(Dump[3] == 0)
			{

				//Check:
				if(GetBank(Client) - Dump[4] > 0)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Dump[4]));

					SaveItem(Client, Dump[1], (GetItemAmount(Client, Dump[1]) + Dump[2]));

					//Declare:
					int FoundPlayer = -1;

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have bought \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Dump[1], GetItemName(Dump[1]), IntToMoney(Dump[4]));

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i ++)
					{

						//Connected:
						if(IsClientConnected(i) && IsClientInGame(i))
						{

							//Is Valid:
							if(Dump[0] == SteamIdToInt(i))
							{

								//Initulize:
								SetBank(i, (GetBank(i) - Dump[4]));

								//Print:
								CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Dump[1], GetItemName(Dump[1]), IntToMoney(Dump[4]));

								//Initulize:
								FoundPlayer = i;
							}
						}
					}

					//Check:
					if(FoundPlayer == -1)
					{

						//Handle:
						DataPack pack = new DataPack();

						//Write
						pack.WriteCell(Dump[0]);
						pack.WriteCell(Dump[4]);

						//Declare:
						char query[255];

						//Sql Strings:
						Format(query, sizeof(query), "SELECT Bank FROM `Player` Where STEAMID = %i;", Dump[0]);

						//Not Created Tables:
						SQL_TQuery(GetGlobalSQL(), T_LoadPlayerBankSoldItemMarketPlace, query, pack);
					}

					//Declare:
					char query[512];

					//Format:
					Format(query, sizeof(query), "DELETE FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", Dump[0], Dump[1], Dump[2]);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough to buy \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Dump[1], GetItemName(Dump[1]), IntToMoney(Dump[4]));
				}
			}

			//Action Bids:
			else if(Dump[3] == 1)
			{

				//Check:
				if(GetBank(Client) - (Dump[4] + 100) > 0)
				{

					//Initulize:
					Dump[4] = Dump[4] + 100;

					//Declare:
					char query[255];

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have bidded %ix %s for %s!", Dump[1], GetItemName(Dump[1]), IntToMoney(Dump[4]));

					//Sql Strings:
					Format(query, sizeof(query), "UPDATE MarketPlace SET Bids = %i, BidderSteamId = %i WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", Dump[4], SteamIdToInt(Client), Dump[0], Dump[1], Dump[2]);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i ++)
					{

						//Connected:
						if(IsClientConnected(i) && IsClientInGame(i))
						{

							//Is Valid:
							if(Dump[0] == SteamIdToInt(i))
							{

								//Print:
								CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - Someone has bidded \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Dump[1], GetItemName(Dump[1]), IntToMoney(Dump[4]));
							}
						}
					}

					//Format:
					Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", Dump[0], Dump[1], Dump[2]);

					//Declare:
					int conuserid = GetClientUserId(Client);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), T_DBLoadSortItemsMarketPlaceSelectedItem, query, conuserid);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough to bid \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Dump[1], GetItemName(Dump[1]), IntToMoney(Dump[4]));
				}
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");
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

public void T_LoadPlayerBankSoldItemMarketPlace(Handle owner, Handle hndl, const char[] error, any pack)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_MarketPlace] T_LoadPlayerBankSoldItemMarketPlace: Query failed! %s", error);
	}

	//Override:
	else 
	{


		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			int PlayerBank = SQL_FetchInt(hndl, 0);

			//Read:
			ResetPack(pack);

			//Declare:
			int SteamId = ReadPackCell(pack);
			int Amount = ReadPackCell(pack);

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", (PlayerBank + Amount), SteamId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}
	}
}

public void SellItemsSortMarketPlace(int Client)
{

	//Check:
	if(!IsClientInTrading(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

		//Return:
		return;
	}

	//Declare:
	bool MenuDisplay = false;

	int ItemActionAmount = 0;

	int MenuShow[20] = {0,...};

	//Handle:
	Menu menu = CreateMenu(HandleSellItemsSortMarketPlace);

	//Loop:
	for(int X = 0; X < 500; X++)
	{

		//Has Items:
		if(GetItemAmount(Client, X) > 0)
		{

			//Initialize:
			MenuDisplay = true;

			//Old Items
			if(GetItemGroup(X) == 0 && MenuShow[0] != 1)
			{

				//Add Menu Item:
				menu.AddItem("0", "Old Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[0] = 1;
			}

			//Weapons
			if(GetItemGroup(X) == 1 && MenuShow[1] != 1)
			{

				//Add Menu Item:
				menu.AddItem("1", "Weapons");

				//Initialize:
				ItemActionAmount++;

				MenuShow[1] = 1;
			}

			//Illegal Items:
			if(GetItemGroup(X) == 2 && MenuShow[2] != 1)
			{

				//Add Menu Item:
				menu.AddItem("2", "Illegal Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[2] = 1;
			}

			//Food Drink Energy:
			if(GetItemGroup(X) == 3 && MenuShow[3] != 1)
			{

				//Add Menu Item:
				menu.AddItem("3", "Food Drink Energy");

				//Initialize:
				ItemActionAmount++;

				MenuShow[3] = 1;
			}

			//Lockpick/DoorHack:
			if(GetItemGroup(X) == 4 && MenuShow[4] != 1)
			{

				//Add Menu Item:
				menu.AddItem("4", "Lockpick/DoorHack");

				//Initialize:
				ItemActionAmount++;

				MenuShow[4] = 1;
			}

			//Furniture:
			if(GetItemGroup(X) == 5 && MenuShow[5] != 1)
			{

				//Add Menu Item:
				menu.AddItem("5", "Furniture");

				//Initialize:
				ItemActionAmount++;

				MenuShow[5] = 1;
			}

			//Health Kits:
			if(GetItemGroup(X) == 6 && MenuShow[6] != 1)
			{

				//Add Menu Item:
				menu.AddItem("6", "Health Kits");

				//Initialize:
				ItemActionAmount++;

				MenuShow[6] = 1;
			}

			//Other Items:
			if(GetItemGroup(X) == 7 && MenuShow[7] != 1)
			{

				//Add Menu Item:
				menu.AddItem("7", "Other Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[7] = 1;
			}

			//Models and Hats:
			if(GetItemGroup(X) == 8 && MenuShow[8] != 1)
			{

				//Add Menu Item:
				menu.AddItem("8", "Models and Hats");

				//Initialize:
				ItemActionAmount++;

				MenuShow[8] = 1;
			}

			//Drugs and Alcohol:
			if(GetItemGroup(X) == 9 && MenuShow[9] != 1)
			{

				//Add Menu Item:
				menu.AddItem("9", "Drugs and Alcohol");

				//Initialize:
				ItemActionAmount++;

				MenuShow[9] = 1;
			}

			//Misc Items:
			if(GetItemGroup(X) == 10 && MenuShow[10] != 1)
			{

				//Add Menu Item:
				menu.AddItem("10", "Misc Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[10] = 1;
			}

			//Door Items:
			if(GetItemGroup(X) == 11 && MenuShow[11] != 1)
			{

				//Add Menu Item:
				menu.AddItem("11", "Door Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[11] = 1;
			}

			//Police Items:
			if(GetItemGroup(X) == 12 && MenuShow[12] != 1)
			{

				//Add Menu Item:
				menu.AddItem("12", "Police Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[12] = 1;
			}

			//JetPack Items:
			if(GetItemGroup(X) == 13 && MenuShow[13] != 1)
			{

				//Add Menu Item:
				menu.AddItem("13", "JetPack Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[13] = 1;
			}

			//Job Items:
			if(GetItemGroup(X) == 14 && MenuShow[14] != 1)
			{

				//Add Menu Item:
				menu.AddItem("14", "Job Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[14] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 15 && MenuShow[15] != 1)
			{

				//Add Menu Item:
				menu.AddItem("15", "Trail Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[15] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 16 && MenuShow[16] != 1)
			{

				//Add Menu Item:
				menu.AddItem("16", "Vehicle Inventory");

				//Initialize:
				ItemActionAmount++;

				MenuShow[16] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 17 && MenuShow[17] != 1)
			{

				//Add Menu Item:
				menu.AddItem("17", "Hacking Software");

				//Initialize:
				ItemActionAmount++;

				MenuShow[17] = 1;
			}

			//Trail Items:
			if(GetItemGroup(X) == 18 && MenuShow[18] != 1)
			{

				//Add Menu Item:
				menu.AddItem("18", "Trash");

				//Initialize:
				ItemActionAmount++;

				MenuShow[18] = 1;
			}
		}
	}

	//Show Menu:
	if(MenuDisplay)
	{

		//Add Menu Item:
		menu.AddItem("-1", "[Back]");

		//Menu Title:
		menu.SetTitle("Select an item group to sell an item!");

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Override:
	else
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have any items!");

		//Close:
		delete menu;
	}
}

//Item Handle:
public int HandleSellItemsSortMarketPlace(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(!IsClientInTrading(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

			//Return:
			return true;
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int  Result = StringToInt(info);
		bool ShowMenu = false;

		//Check:
		if(Result == -1)
		{

			//Show Menu:
			MarketPlace(Client);

			//Return:
			return true;
		}

		//Handle:
		menu = CreateMenu(HandleSellItemsMarketPlaceSelectItem);

		//Loop:
		for(int X = 0; X < 500; X++)
		{

			//Has Items:
			if(GetItemAmount(Client, X) > 0)
			{

				//Selected Group:
				if(GetItemGroup(X) == Result)
				{

					//Declare:
					char ActionItemId[255];
					char MenuItemName[32];
					char ItemId[255];

					//Format:
					Format(MenuItemName, 32, "[x%i] %s", GetItemAmount(Client, X), GetItemName(X));

					//Convert:
					IntToString(X, ItemId, 255);

					//Format:
					Format(ActionItemId, 255, "%s", ItemId);

					//Add Menu Item:
					menu.AddItem(ActionItemId, MenuItemName);

					//Initialize:
					ShowMenu = true;
				}
			}
		}

		//Show:
		if(ShowMenu == true)
		{

			//Add Menu Item:
			menu.AddItem("-1", "[Back]");

			//Menu Title:
			menu.SetTitle("Select an item that you want to sell");

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Close:
			delete menu;
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
public int HandleSellItemsMarketPlaceSelectItem(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsClientInTrading(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

			//Return:
			return true;
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Check:
		if(Result == -1)
		{

			//Show Menu:
			MarketPlace(Client);
		}

		//Override:
		else
		{

			//Initialize:
			SetSelectedItem(Client, Result);

			//Check:
			SelectAmountSellToMarketPlace(Client);
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

public void SelectAmountSellToMarketPlace(int Client)
{

	//Declare:
	int ItemId = GetSelectedItem(Client);

	//Handle:
	Menu menu = CreateMenu(HandleSelectAmountSellToMarketPlace);

	//Declare:
	char title[256];

	//Format:
	Format(title, sizeof(title), "[x%i] - %s\nSelect how many you wish to sell", GetItemAmount(Client, ItemId), GetItemName(ItemId));

	//Menu Title:
	menu.SetTitle(title);

	//Declare:
	char FormatMenu[64];
	char FormatMenu2[64];

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "All (x%i)", GetItemAmount(Client, ItemId));

	//Format:
	Format(FormatMenu2, sizeof(FormatMenu2), "%i", GetItemAmount(Client, ItemId));

	//Menu Button:
	menu.AddItem(FormatMenu2, FormatMenu);

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
	menu.AddItem("200", "200");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2000", "2000");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleSelectAmountSellToMarketPlace(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsClientInTrading(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

			//Return:
			return true;
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Declare:
		int ItemId = GetSelectedItem(Client);

		//Check:
		if(GetItemAmount(Client, ItemId) - Result >= 0)
		{

			//Show Menu:
			SelectBuyItNowSellToMarketPlace(Client, Result);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have this amount of items!");

			//Show Menu:
			SelectAmountSellToMarketPlace(Client);
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

public void SelectBuyItNowSellToMarketPlace(int Client, int Amount)
{

	//Declare:
	int ItemId = GetSelectedItem(Client);

	SetMenuTarget(Client, Amount);

	//Handle:
	Menu menu = CreateMenu(HandleSellToMarketPlaceSelectBuyItNow);

	//Declare:
	char title[256];

	//Format:
	Format(title, sizeof(title), "[x%i] - %s\nSelect your Buy it now price", Amount, GetItemName(ItemId));

	//Menu Title:
	menu.SetTitle(title);

	//Menu Button:
	menu.AddItem("0", "0");

	//Menu Button:
	menu.AddItem("200", "200");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2000", "2000");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Menu Button:
	menu.AddItem("20000", "20000");

	//Menu Button:
	menu.AddItem("50000", "50000");

	//Menu Button:
	menu.AddItem("70000", "70000");

	//Menu Button:
	menu.AddItem("100000", "100000");

	//Menu Button:
	menu.AddItem("150000", "150000");

	//Menu Button:
	menu.AddItem("200000", "200000");

	//Menu Button:
	menu.AddItem("300000", "300000");

	//Menu Button:
	menu.AddItem("500000", "500000");

	//Menu Button:
	menu.AddItem("750000", "750000");

	//Menu Button:
	menu.AddItem("1000000", "1000000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleSellToMarketPlaceSelectBuyItNow(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsClientInTrading(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

			//Return:
			return true;
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		SelectBidsSellToMarketPlace(Client, Result);

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

public void SelectBidsSellToMarketPlace(int Client, int Amount)
{

	//Declare:
	int ItemId = GetSelectedItem(Client);

	SetTargetPlayer(Client, Amount);

	//Handle:
	Menu menu = CreateMenu(HandleSellToMarketPlaceSelectBids);

	//Declare:
	char title[256];

	//Format:
	Format(title, sizeof(title), "[x%i] - %s\nSelect your Bids price\nBuyItNow: %s", GetMenuTarget(Client), GetItemName(ItemId), IntToMoney(GetTargetPlayer(Client)));

	//Menu Title:
	menu.SetTitle(title);

	//Menu Button:
	menu.AddItem("0", "0");

	//Menu Button:
	menu.AddItem("200", "200");

	//Menu Button:
	menu.AddItem("500", "500");

	//Menu Button:
	menu.AddItem("1000", "1000");

	//Menu Button:
	menu.AddItem("2000", "2000");

	//Menu Button:
	menu.AddItem("5000", "5000");

	//Menu Button:
	menu.AddItem("10000", "10000");

	//Menu Button:
	menu.AddItem("20000", "20000");

	//Menu Button:
	menu.AddItem("50000", "50000");

	//Menu Button:
	menu.AddItem("70000", "70000");

	//Menu Button:
	menu.AddItem("100000", "100000");

	//Menu Button:
	menu.AddItem("150000", "150000");

	//Menu Button:
	menu.AddItem("200000", "200000");

	//Menu Button:
	menu.AddItem("300000", "300000");

	//Menu Button:
	menu.AddItem("500000", "500000");

	//Menu Button:
	menu.AddItem("750000", "750000");

	//Menu Button:
	menu.AddItem("1000000", "1000000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleSellToMarketPlaceSelectBids(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsClientInTrading(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

			//Return:
			return true;
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		SelectBidsSellToMarketPlaceFinal(Client, Result);
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

public void SelectBidsSellToMarketPlaceFinal(int Client, int Amount)
{

	//Declare:
	int ItemId = GetSelectedItem(Client);

	//Handle:
	Menu menu = CreateMenu(HandleSellToMarketPlaceFinal);

	//Declare:
	char title[256];
	char FormatMenu[64];

	//Format:
	Format(title, sizeof(title), "[x%i] - %s\nSelect your Bids price\nBuyItNow: %s\nBids: %s\nThere is a %s fee", GetMenuTarget(Client), GetItemName(ItemId), IntToMoney(GetTargetPlayer(Client)), IntToMoney(Amount), IntToMoney(100));

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%i", Amount);

	//Menu Button:
	menu.AddItem(FormatMenu, "Put On Market?");

	//Menu Button:
	menu.AddItem("-1", "No");

	//Menu Button:
	menu.AddItem("-2", "[Back]");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleSellToMarketPlaceFinal(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Check:
		if(!IsClientInTrading(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");

			//Return:
			return true;
		}

		//Declare:
		int ItemCount = GetPlayerItemsForSaleTotalCount(SteamIdToInt(Client));

		//Check:
		if(ItemCount >= 15)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only sell 15 item lots at one time!");

			//Return:
			return true;
		}

		//Declare:
		int ItemId = GetSelectedItem(Client);
		int Amount = GetMenuTarget(Client);

		//Check:
		if(IsItemStillOnMarketPlace(SteamIdToInt(Client), ItemId, Amount))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot duplicate an item already on the marketplace!");

			//Return:
			return true;
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Check:
		if(Result == -2)
		{

			//Show Menu:
			SellItemsSortMarketPlace(Client);
		}

		//Check:
		else if(Result != -1)
		{

			//Check:
			if(GetBank(Client) - 100 > 0)
			{

				int BuyItNow = GetTargetPlayer(Client);
				int Bids = Result;

				//On Store for 7 days:
				int Time = GetTime() + (86400 * 7);

				//Initulize:
				SetBank(Client, (GetBank(Client) - 100));

				SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - Amount));

				//Declare:
				char query[255];

				//Sql String:
				Format(query, sizeof(query), "INSERT INTO MarketPlace (`STEAMID`,`ItemId`,`Amount`,`BuyItNow`,`Bids`,`Time`,`BidderSteamId`) VALUES (%i,%i,%i,%i,%i,%i,0);", SteamIdToInt(Client), ItemId, Amount, BuyItNow, Bids, Time);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 530);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have put \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF on the marketplace! BuyItNow: \x0732CD32%s\x07FFFFFF Bids: \x0732CD32%s\x07FFFFFF!", Amount, GetItemName(ItemId), IntToMoney(BuyItNow), IntToMoney(Bids));
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - It Costs \x0732CD32%s\x07FFFFFF to sell items on the marketplace!", IntToMoney(100));
			}
		}

		//Override:
		else
		{

			//Show Menu:
			MarketPlace(Client);
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

public void ViewPlayersItemsMarketPlace(int Client)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadPlayerItemsMarketPlace, query, conuserid);
}

public void T_DBLoadPlayerItemsMarketPlace(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_marketplace] T_DBLoadPlayerItemsMarketPlace: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have any items on the marketplace!");

			//Return:
			return;
		}

		//Declare:
		bool MenuDisplay = false;

		//Handle:
		Menu menu = CreateMenu(HandleLoadPlayerItemsMarketPlace);

		//Declare:
		int X = 0;
		int Amount = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Amount = SQL_FetchInt(hndl, 2);

			//Declare:
			char ActionItemId[255];
			char MenuItemName[32];

			//Format:
			Format(MenuItemName, 32, "[x%i] %s", Amount, GetItemName(X));

			//Format:
			Format(ActionItemId, 255, "%i^%i", X, Amount);

			//Add Menu Item:
			menu.AddItem(ActionItemId, MenuItemName);

			//Initialize:
			MenuDisplay = true;
		}

		//Show Menu:
		if(MenuDisplay)
		{

			//Add Menu Item:
			menu.AddItem("0^0", "[Back]");

			//Menu Title:
			menu.SetTitle("List of items you have put\non the marketplace!");

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have any items on the marketplace!");

			//Close:
			delete menu;
		}

	}
}

//Item Handle:
public int HandleLoadPlayerItemsMarketPlace(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client))
		{

			//Declare:
			char info[255];
			char sDump[3][255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Convert:
			ExplodeString(info, "^", sDump, 2, 255);

			//Declare:
			int Dump[2];

			//Loop:
			for(int Y = 0; Y <= 1; Y++)
			{

				//Initulize:
				Dump[Y] = StringToInt(sDump[Y]);
			}

			//Check:
			if(Dump[0] == 0)
			{

				//Show Menu:
				MarketPlace(Client);
			}

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", SteamIdToInt(Client), Dump[0], Dump[1]);

			//Declare:
			int conuserid = GetClientUserId(Client);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBLoadPlayerSelectItemMarketPlace, query, conuserid);
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");
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

public void T_DBLoadPlayerSelectItemMarketPlace(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_marketplace] T_DBLoadPlayerSelectItemMarketPlace: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no items for sale on the marketplace!");

			//Return:
			return;
		}

		//Declare:
		int SteamId;
		int X;
		int Amount;
		int BuyItNow;
		int Bids;
		int Time;

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Amount = SQL_FetchInt(hndl, 2);

			//Database Field Loading Intiger:
			BuyItNow = SQL_FetchInt(hndl, 3);

			//Database Field Loading Intiger:
			Bids = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			Time = SQL_FetchInt(hndl, 5);
		}

		//Check:
		if(Time - GetTime() >= 0)
		{

			//Handle:
			Menu menu = CreateMenu(HandlePlayerRemoveItemFromMarketPlace);

			//Declare:
			char ActionItemId[255];
			char MenuTitle[255];
			char MenuName[32];

			//Format:
			Format(MenuName, sizeof(MenuName), "Remove %s", IntToMoney(500));

			//Format:
			Format(ActionItemId, 255, "%i^%i^%i", SteamId, X, Amount);

			//Add Menu Item:
			menu.AddItem(ActionItemId, MenuName);

			//Add Menu Item:
			menu.AddItem("0^0^0", "[Back]");

			Time = Time - GetTime();
			int Days = Time / 86400;
			Time %= 86400;
			int Hours = Time / 3600;
			Time %= 3600;
			int Minutes = Time / 60;
			Time %= 60;
			int Seconds = Time % 60;

			//Format:
			Format(MenuTitle, sizeof(MenuTitle), "[x%i] - %s\nBuyItNow: %s\nBids: %s\nTime left: %id:%ih:%im:%is\nRemoval Fee %s", Amount, GetItemName(X), IntToMoney(BuyItNow), IntToMoney(Bids), Days, Hours, Minutes, Seconds, IntToMoney(500));

			//Menu Title:
			menu.SetTitle(MenuTitle);

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item has already finished \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF!", X, GetItemName(X));
		}
	}
}

//Item Handle:
public int HandlePlayerRemoveItemFromMarketPlace(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client))
		{

			//Check:
			if(GetBank(Client) - 500 > 0)
			{

				//Declare:
				char info[255];
				char sDump[3][255];

				//Get Menu Info:
				menu.GetItem(Parameter, info, sizeof(info));

				//Convert:
				ExplodeString(info, "^", sDump, 3, 255);

				//Declare:
				int Dump[3];

				//Loop:
				for(int Y = 0; Y <= 2; Y++)
				{

					//Initulize:
					Dump[Y] = StringToInt(sDump[Y]);
				}

				if(Dump[0] == 0)
				{

					//Show Menu:
					ViewPlayersItemsMarketPlace(Client);
				}

				//Override:
				else
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - 500));

					//Declare:
					char query[255];

					//Sql String:
					Format(query, sizeof(query), "DELETE FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", Dump[0], Dump[1], Dump[2]);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

					SaveItem(Client, Dump[1], (GetItemAmount(Client, Dump[1]) + Dump[2]));
	
					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have taken \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF off the marketplace!", Dump[2], GetItemName(Dump[1]));
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough money to remove your items from the marketplace!");
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You need to be in the trading zone to use this action!");
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

public void T_DBLoadMarketPlaceFinishedItems(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_marketplace] T_DBLoadMarketPlaceFinishedItems: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Return:
			return;
		}

		//Declare:
		int SteamId;
		int X;
		int Amount;
		int Bids;
		int BidderSteamId = 0;

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Amount = SQL_FetchInt(hndl, 2);

			//Database Field Loading Intiger:
			Bids = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			BidderSteamId = SQL_FetchInt(hndl, 6);
		}

		//Check:
		if(BidderSteamId == 0)
		{

			//Declare:
			char query[255];

			//Sql String:
			Format(query, sizeof(query), "DELETE FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i;", SteamId, X, Amount);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Declare:
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

						SaveItem(i, X, (GetItemAmount(i, X) + Amount));

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - Your Item \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for never sold on the marketplace!", Amount, GetItemName(X));

						//Initulize:
						FoundPlayer = i;
					}
				}
			}

			//Check:
			if(FoundPlayer == -1)
			{

				//Return Item:
				AddItemSteamId(SteamId, X, Amount);
			}
		}

		//Override:
		else
		{

			//Declare:
			int FoundPlayer = -1;

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(BidderSteamId == SteamIdToInt(i))
					{

						//Check:
						if(GetBank(i) - Bids > 0)
						{

							SaveItem(i, X, (GetItemAmount(i, X) + Amount));

							//Initulize:
							SetBank(i, (GetBank(i) - Bids));

							//Print:
							CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - You have bought \x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF from the marketplace!", Amount, GetItemName(X), IntToMoney(Bids));

						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32%s\x07FFFFFF for\x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF!", IntToMoney(Bids), Amount, GetItemName(X));

							//Loop:
							for(int Y = 1; Y <= GetMaxClients(); Y ++)
							{

								//Connected:
								if(IsClientConnected(Y) && IsClientInGame(Y))
								{

									//Is Valid:
									if(SteamId == SteamIdToInt(Y))
									{

										//Print:
										CPrintToChat(Y, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF didn't have enough money to pay for\x0732CD32%i\x07FFFFFFx \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF from the marketplace!", i, Amount, GetItemName(X), IntToMoney(Bids));
									}
								}
							}
						}

						//Initulize:
						FoundPlayer = -1;
					}
				}
			}

			//Check:
			if(FoundPlayer == -1)
			{

				//Return Item:
				AddItemSteamId(SteamId, X, Amount);
			}
		}
	}
}

public bool IsItemStillOnMarketPlace(int SteamId, int ItemId, int Amount)
{

	//Declare:
	bool Result = false;
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE STEAMID = %i AND ItemId = %i AND Amount = %i AND Time >= %i;", SteamId, ItemId, Amount, GetTime());

	//Declare:
	Handle hQuery = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hQuery)
	{

		//Restart SQL:
		SQL_Rewind(hQuery);

		//Already Inserted:
		if(SQL_FetchRow(hQuery))
		{

			//Initulize:
			Result = true;
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<bool>(Result);
}

public int GetPlayerItemsForSaleTotalCount(int SteamId)
{

	//Declare:
	int Result = 0;
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MarketPlace WHERE STEAMID = %i;", SteamId);

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
			Result += 1;
		}
	}

	//Close:
	CloseHandle(hQuery);

	//Return:
	return view_as<int>(Result);
}
