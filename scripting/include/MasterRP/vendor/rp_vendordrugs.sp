//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendordrugs_included_
  #endinput
#endif
#define _rp_vendordrugs_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �
public void initVendorDrugBuy()
{

	//Commands:
	RegAdminCmd("sm_adddrugvendoritem", Command_AddDrugVendorItem, ADMFLAG_ROOT, "<Drug Type Id> <Item Id> - Add's Item to a vendor");

	RegAdminCmd("sm_removedrugvendoritem", Command_RemoveDrugVendorItem, ADMFLAG_ROOT, "<Drug Type Id> <Item Id> - Remove's Item from a vendor");

	RegAdminCmd("sm_viewdrugvendorlist", Command_ViewDrugVendorList, ADMFLAG_SLAY, "<Drug Type Id> - View's vendors sql item db");

	//Timer:
	CreateTimer(0.2, CreateSQLdbVendorDrugBuy);
}

//Create Database:
public Action CreateSQLdbVendorDrugBuy(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VendorDrugBuy`");

	len += Format(query[len], sizeof(query)-len, " (`DrugItemType` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Vendor Menus:
public void DrugVendorMenuBuy(int Client)
{

	//Has Crime
	if(GetBounty(Client) > 5000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Vendors will not speak with criminals!");

		//Return:
		return;
	}

	//Handle:
	Menu menu = CreateMenu(HandleDrugBuyType);

	//Title:
	menu.SetTitle("Select Drug Item type");

	//Menu Button:
	menu.AddItem("1", "Planting Supplies");

	//Menu Button:
	menu.AddItem("6", "Printing Supplies");

	//Menu Button:
	menu.AddItem("4", "Cocain Supplies");

	//Menu Button:
	menu.AddItem("2", "Meth Supplies");

	//Menu Button:
	menu.AddItem("3", "Pill Supplies");

	//Menu Button:
	menu.AddItem("5", "Misc Supplies");

	//Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Vendor Handle:
public int HandleDrugBuyType(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		int DrugTypeSelected = StringToInt(info);

		//Draw Menu
		DrugVendorMenuBuyType(Client, DrugTypeSelected);
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

//Vendor Menus:
public void DrugVendorMenuBuyType(int Client, int ItemType)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorDrugBuy WHERE DrugItemType = %i;", ItemType);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVendorDrugBuy, query, conuserid);

	//Return:
	return;
}

public void T_DBLoadVendorDrugBuy(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBLoadVendorDrugBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vendor Buy Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int ItemId; 

		//Handle:
		Menu menu = CreateMenu(HandleDrugBuy);

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 1);

			//Declare:
        	      	int Price = GetItemCost(ItemId);

			//Declare:
			char DisplayItem[64];

			//Less Char
			if(Price > 9999)
			{

				//New Price
				Price = Price / 1000;

				//Format:
				Format(DisplayItem, sizeof(DisplayItem), "[€k%i] %s", Price, GetItemName(ItemId));
			}

			//Override:
			else
			{

				//Format:
				Format(DisplayItem, sizeof(DisplayItem), "[€%i] %s", Price, GetItemName(ItemId));
			}

			//Declare:
			char ItemIndex[32];

			//Format:
			Format(ItemIndex, sizeof(ItemIndex), "%i", ItemId);

			//Menu Buttons:
			menu.AddItem(ItemIndex, DisplayItem);
		}

		//Title:
		menu.SetTitle("Hello, do you want to buy\nsome items for your inventory?");

		//Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF NPC is selling items");
	}
}

//Vendor Handle:
public int HandleDrugBuy(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		char MuchItem[255];

		//Initulize:
		SetSelectedItem(Client, StringToInt(info));

		int ItemId = GetSelectedItem(Client);

		//Handle:
		menu = CreateMenu(HandleBuyCashOrBank);

		//Title:
		menu.SetTitle("[%s] Select if you want to pay \n by Cash or by Card! (5% fee)", GetItemName(ItemId));

		//Format:
		Format(MuchItem, 255, "Cash [€%i]", GetItemCost(ItemId));

		//Menu Button:
		menu.AddItem("0", MuchItem);

		//Format:
		Format(MuchItem, 255, "Bank [€%i]", RoundFloat(GetItemCost(ItemId)*1.05));

		//Menu Button:
		menu.AddItem("1", MuchItem);

		//Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
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

//Vendor Handle:
public int HandleBuyDrugCashOrBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];
		int ItemId = GetSelectedItem(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int Result = StringToInt(info);

		//Declare:
		char bMax[64];
		char MuchItem[255];
		int Cost = GetItemCost(ItemId);

		if(Result == 0)
		{

			//Handle:
			menu = CreateMenu(MoreItemDrugMenuCash);

			//Title:
			menu.SetTitle("[%s] Select amount:", GetItemName(ItemId));

			//Declare:
			int SaveMoney = GetCash(Client);
			int iMax = 0;

			//Has Enough Money:
			if(SaveMoney == Cost )
			{

				//Initialize:
				iMax = 1;
			}

			//dont Have Enough Money:
			if(SaveMoney < Cost)
			{

				//Initialize:
				iMax = 0;
			}

			//Override:
			else
			{

				//Loop:
				for(int Max = 0; SaveMoney >= Cost; Max++)
				{

					//Initialize:
					if(SaveMoney < Cost) break;

					SaveMoney -= Cost;

					iMax = Max + 1;

					if(SaveMoney < Cost) break;
				}
			}

			//Format:
			Format(MuchItem, 255, "All %i x [€%i]", iMax, Cost * iMax);

			Format(bMax, 64, "%i", iMax);

			//Menu Button:
			menu.AddItem(bMax, MuchItem);

			//Format:
			Format(MuchItem, 255, "1 x [€%i]", Cost);

			//Menu Button:
			menu.AddItem("1", MuchItem);

			//Format:
			Format(MuchItem, 255, "5 x [€%i]", Cost * 5);

			//Menu Button:
			menu.AddItem("5", MuchItem);

			//Format:
			Format(MuchItem, 255, "10 x [€%i]", Cost * 10);

			//Menu Button:
			menu.AddItem("10", MuchItem);

			//Format:
			Format(MuchItem, 255, "20 x [€%i]", Cost * 20);

			//Menu Button:
			menu.AddItem("20", MuchItem);

			//Format:
			Format(MuchItem, 255, "50 x [€%i]", Cost * 50);

			//Menu Button:
			menu.AddItem("50", MuchItem);

			//Format:
			Format(MuchItem, 255, "100 x [€%i]", Cost * 100);

			//Menu Button:
			menu.AddItem("100", MuchItem);

			//Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Pay By Bank!
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(MoreItemDrugMenuBank);

			//Title:
			menu.SetTitle("[%s] Select amount:", GetItemName(ItemId));

			//Format:
			Format(MuchItem, 255, "1 x [€%i]", RoundFloat(Cost * 1.05));

			//Menu Button:
			menu.AddItem("1", MuchItem);

			//Format:
			Format(MuchItem, 255, "5 x [€%i]", RoundFloat((Cost * 5) * 1.05));

			//Menu Button:
			menu.AddItem("5", MuchItem);

			//Format:
			Format(MuchItem, 255, "10 x [€%i]", RoundFloat((Cost * 10) * 1.05));

			//Menu Button:
			menu.AddItem("10", MuchItem);

			//Format:
			Format(MuchItem, 255, "20 x [€%i]", RoundFloat((Cost * 20) * 1.05));

			//Menu Button:
			menu.AddItem("20", MuchItem);

			//Format:
			Format(MuchItem, 255, "50 x [€%i]", RoundFloat((Cost * 50) * 1.05));

			//Menu Button:
			menu.AddItem("50", MuchItem);

			//Format:
			Format(MuchItem, 255, "100 x [€%i]", RoundFloat((Cost * 100) * 1.05));

			//Menu Button:
			menu.AddItem("100", MuchItem);

			//Exit Button:
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

public int MoreItemDrugMenuCash(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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
			int ItemId = GetSelectedItem(Client);
			int SItemCost = (GetItemCost(ItemId) * Amount);

			//Has Enoug Money
			if(GetCash(Client) >= SItemCost && GetCash(Client) >= GetItemCost(ItemId) && GetCash(Client) != 0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) - SItemCost));

				// Dynamic Economy!
				AddServerSafeMoneyAll(SItemCost);

				//Set Menu State:
				CashState(Client, (SItemCost));

				//Initialize:
				SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) + Amount));

				//Save:
				SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF for \x0732CD32€%i\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Cash for this item");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't talk to this NPC anymore, because you too far away!");
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

public int MoreItemDrugMenuBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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
			int ItemId = GetSelectedItem(Client);
			int SItemCost = RoundFloat((GetItemCost(ItemId) * Amount) * 1.05);

			//Has Enoug Money
			if(GetBank(Client) >= SItemCost && GetBank(Client) >= GetItemCost(ItemId) && GetBank(Client) != 0)
			{

				//Initialize:
				SetBank(Client, (GetBank(Client) - SItemCost));

				//Set Menu State:
				BankState(Client, (SItemCost));

				//Initialize:
				SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) + Amount));

				//Save:
				SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", GetBank(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%i\x0732CD32\x07FFFFFF x \x0732CD32%s\x0732CD32\x07FFFFFF for \x0732CD32€%i\x0732CD32\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Cash for this item");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't talk to this NPC anymore, because you too far away!");
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

//Add Vendor Item:
public Action Command_AddDrugVendorItem(int Client, int Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_adddrugvendoritem <ItemType 1 - 6> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sDrugTypeId[255];
	char sItemId[255];

	//Initialize:
	GetCmdArg(1, sDrugTypeId, sizeof(sDrugTypeId));

	GetCmdArg(2, sItemId, sizeof(sItemId));

	//Declare:
	int DrugTypeId = StringToInt(sDrugTypeId);
	int ItemId = StringToInt(sItemId);

	//Check:
	if(DrugTypeId > 1 || DrugTypeId > 6)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_adddrugvendoritem <ItemType 1 - 6> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "INSERT INTO VendorDrugBuy (`DrugItemType`,`ItemId`) VALUES (,%i,%i);", DrugTypeId, ItemId);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Vendor #%s", GetItemName(ItemId), DrugTypeId);

	//Return:
	return Plugin_Handled;
}

//Remove Vendor Item:
public Action Command_RemoveDrugVendorItem(int Client, int Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removedrugvendoritem <npc id> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sVendorId[255];
	char sItemId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	GetCmdArg(2, sItemId, sizeof(sItemId));

	//Declare:
	int VendorId = StringToInt(sVendorId);
	int  ItemId = StringToInt(sItemId);
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorDrugBuy AND NpcId = %i AND ItemId = %i", VendorId, ItemId);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBSearchVendorDrugBuy, query, conuserid);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Vendor #%s", GetItemName(ItemId), VendorId);

	//Return:
	return Plugin_Handled;
}

public void T_DBSearchVendorDrugBuy(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBSearchVendorDrugBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Failed to remove Item from the DB!");

			//Return:
			return;
		}

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			int Id = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			int ItemId = SQL_FetchInt(hndl, 2);

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "DELETE FROM VendorDrugBuy WHERE AND NpcId = %i AND ItemId = %i", Id, ItemId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Item %s from vendor #%s", ItemId, Id);
		}
	}
}

//List Spawns:
public Action Command_ViewDrugVendorList(int Client, int Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_viewvendorlist <Drug Type 1 - 5>");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Vendor Buy List:");

	//Declare:
	char sVendorId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	//Declare:
	int VendorId = StringToInt(sVendorId);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorDrugBuy WHERE AND DrugItemType = %i", VendorId);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintVendorDrugBuy, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintVendorDrugBuy(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVendorDrugBuy: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ItemId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: %s", ItemId, GetItemName(ItemId));
		}
	}
}
public void VendorDrugSell(int Client, int Ent)
{

	//Initulize:
	SetMenuTarget(Client, Ent);

	int  AddCash = RoundFloat(float(GetHarvest(Client)) * 2.9);

	AddCash += RoundFloat(float(GetMeth(Client)) * 9.5);

	AddCash += RoundFloat(float(GetPills(Client)) * 30);

	AddCash += RoundFloat(float(GetCocain(Client)) * 100);

	AddCash += RoundFloat(float(GetRice(Client)) * 2.5);

	AddCash += GetResources(Client);

	int OldHarvest = GetHarvest(Client);

	OldHarvest += GetMeth(Client);

	OldHarvest += GetCocain(Client);

	OldHarvest += GetPills(Client);

	OldHarvest += GetRice(Client);

	OldHarvest += GetResources(Client);

	//Is In Gang:
	if(!StrEqual(GetGang(Client), "null"))
	{

		//Declare:
		int GangLevel = GetGangLevel(Client, GetGang(Client));
		float GangCash = float(GangLevel) / 100.0;
		GangCash += 1.0;

		//Multiply Cash By Level / 100:
		AddCash = RoundFloat(float(AddCash) * GangCash);
	}

	//Is In Time:
	if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && (GetHarvest(Client) > 0 || GetMeth(Client) > 0 || GetCocain(Client) > 0 || GetPills(Client) > 0 || GetRice(Client) > 0 || GetResources(Client) > 0))
	{

		//Check:
		if(GetServerSafeMoneyTotal() - AddCash > 1000)
		{


			//Give Respect for selling drugs
			OnPlayerSellDrugsGangCheck(Client, AddCash);

			// Dynamic Economy!
			TakeServerSafeMoneyAll(AddCash);

			SetCash(Client, (GetCash(Client) + AddCash));
	
			//Set Menu State:
			CashState(Client, AddCash);

			//Initulize:
			SetCrime(Client, (GetCrime(Client) + GetHarvest(Client) + (GetMeth(Client) * 5) + (GetPills(Client) * 10) + (GetResources(Client) / 2) + (GetCocain(Client) * 20)));

			//Initulize:
			SetHarvest(Client, 0);

			SetMeth(Client, 0);

			SetCocain(Client, 0);

			SetPills(Client, 0);

			SetRice(Client, 0);

			SetResources(Client, 0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFF Grams and made \x0732CD32%s\x07FFFFFF!", OldHarvest, IntToMoney(AddCash));
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - The server doesn't have enough cash to buy your drugs, Total Server Cash \x0732CD32%s\x07FFFFFF and your drugs are worth \x0732CD32%s\x07FFFFFF!", IntToMoney(GetServerSafeMoneyTotal()), IntToMoney(AddCash));
		}
	}

	//Override:
	if((GetHarvest(Client) > 0 || GetMeth(Client) > 0 || GetPills(Client) > 0 || GetRice(Client) > 0 || GetResources(Client) > 0 || GetCocain(Client) > 0))
	{


		//Declare:
		char FormatChat[255];

		//Format:
		Format(FormatChat, sizeof(FormatChat), "\x07FF4040|RP-Drug|\x07FFFFFF - Press \x0732CD32'use'\x07FFFFFF to quick sell \x0732CD32%ig\x07FFFFFF for \x0732CD32€%i\x07FFFFFF!", OldHarvest, AddCash);

		//Print:
		OverflowMessage(Client, FormatChat);

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Declare:
	char display[32];

	//Handle:
	Menu menu = CreateMenu(HandleDrugMenu);

	//Menu Button:
	menu.AddItem("1", "Buy Equiptment");

	//Check:
	if(GetHarvest(Client) != 0 || GetMeth(Client) != 0 || GetPills(Client) != 0 || GetRice(Client) != 0 || GetResources(Client) != 0 || GetCocain(Client) != 0)
	{

		//Format:
		Format(display, sizeof(display), "Sell all (€%i)", RoundFloat(float(GetHarvest(Client)) * 2.9) + RoundFloat(float(GetMeth(Client)) * 10.0) + RoundFloat(float(GetCocain(Client)) * 100.0) + RoundFloat(float(GetPills(Client)) * 30.0) + RoundFloat(float(GetRice(Client)) * 2.5) + GetResources(Client));

		//Menu Button:
		menu.AddItem("0", display);
	}

	//Menu Title:
	menu.SetTitle("This Npc Can exchange your\nbuy and sell drugs here");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleDrugMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

				//Has Harvest:
				if(GetHarvest(Client) != 0 || GetMeth(Client) != 0 || GetCocain(Client) != 0 || GetPills(Client) != 0 || GetRice(Client) != 0 || GetResources(Client) != 0)
				{

					//Initulize:
					int AddCash = RoundFloat(float(GetHarvest(Client)) * 2.9);

					AddCash += RoundFloat(float(GetMeth(Client)) * 9.5);

					AddCash += RoundFloat(float(GetCocain(Client)) * 100);

					AddCash += RoundFloat(float(GetPills(Client)) * 30);

					AddCash += RoundFloat(float(GetRice(Client)) * 2.5);

					AddCash += GetResources(Client);

					//Check:
					if(GetServerSafeMoneyTotal() - AddCash > 1000)
					{

						// Dynamic Economy!
						TakeServerSafeMoneyAll(AddCash);

						int OldHarvest = GetHarvest(Client);

						OldHarvest += GetCocain(Client);

						OldHarvest += GetMeth(Client);

						OldHarvest += GetPills(Client);

						OldHarvest += GetRice(Client);

						OldHarvest += GetResources(Client);

						SetCash(Client, (GetCash(Client) + AddCash));

						//Set Menu State:
						CashState(Client, AddCash);

						//Initulize:
						SetCrime(Client, (GetCrime(Client) + (GetHarvest(Client) * 2 + (GetMeth(Client) * 10) + (GetPills(Client) * 100) + (GetResources(Client) / 2) + (GetPills(Client) * 200))));

						//Initulize:
						SetHarvest(Client, 0);

						SetMeth(Client, 0);

						SetCocain(Client, 0);

						SetPills(Client, 0);

						SetRice(Client, 0);

						SetResources(Client, 0);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFF Grams and made \x0732CD32€%i\x07FFFFFF!", OldHarvest, AddCash);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - The server doesn't have enough cash to buy your drugs!");
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You do not have any Drugs harvested!");
				}
			}

			//Button Selected:
			if(Result == 1)
			{

				//Show Menu:
				DrugVendorMenuBuy(Client);
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
