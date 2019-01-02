//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorresell_included_
  #endinput
#endif
#define _rp_vendorresell_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Vendor Menus:
public void VendorMenuReSellSelectVendor(int Client, int Ent)
{

	//Initulize:
	SetMenuTarget(Client, Ent);

	//Handle:
	Menu menu = CreateMenu(HandlePlayerVendorReSellMenu);

	//Declare:
	char title[256];
	char FormatMenu[16];
	bool Show = false;

	//Format:
	Format(title, sizeof(title), "Choose an option: %N", Client);

	//Menu Title:
	menu.SetTitle(title);

	//Loop:
	for(int Y = 0; Y < MAXNPCS; Y++)
	{

		//Check:
		if(IsValidEdict(GetNpcEnt(2, Y)))
		{

			//Format:
			Format(FormatMenu, sizeof(FormatMenu), "%i", Y);

			//Menu Button:
			menu.AddItem(FormatMenu, GetNpcNotice(GetNpcEnt(2, Y)));

			//Initulize:
			Show = true;
		}
	}

	//Check:
	if(Show == true)
	{

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - there are currently no vendors");

		//Close:
		delete menu;
	}
}

//PlayerMenu Handle:
public int HandlePlayerVendorReSellMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Show Vendor Buy Menu
		VendorMenuReSell(Client, Result, Ent);
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

//Vendor Menus:
public void VendorMenuReSell(int Client, int VendorId, int Ent)
{

	//Has Crime
	if(GetBounty(Client) > 5000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Vendors will not speak with criminals!");

		//Return:
		return;
	}

	//Check:
	if(IsClientRobbingCashFromVendor(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - vendors won't sell you anything whilst you are robbing them!");
	}

	//Check:
	if(IsClientHackingCashFromBank(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - vendors won't sell you anything whilst you are Hacking them!");
	}

	//Initulize:
	SetMenuTarget(Client, Ent);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i;", ServerMap(), VendorId);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVendorReSell, query, conuserid);

	//Return:
	return;
}

public void T_DBLoadVendorReSell(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBLoadVendorBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vendor Re Sell Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int ItemId; 

		//Handle:
		Menu menu = CreateMenu(HandleResellMenu);

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 2);

			//Declare:
			int Price = RoundFloat(float(GetItemCost(ItemId)) / 1.1);

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
		menu.SetTitle("Hello, do you want to Sell\nsome items for your inventory?");

		//Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF NPC is selling items");
	}
}

//Vendor Handle:
public int HandleResellMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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
		menu = CreateMenu(HandleReSellCashOrBank);

		//Title:
		menu.SetTitle("[%s] Select if you want to pay \n Sell Cash or by Card! (5% fee)", GetItemName(ItemId));

		//Format:
		Format(MuchItem, 255, "Cash [€%i]", RoundFloat(float(GetItemCost(ItemId)) / 1.1));

		//Menu Button:
		menu.AddItem("0", MuchItem);

		//Format:
		Format(MuchItem, 255, "Bank [€%i]", RoundFloat(float(GetItemCost(ItemId)) / 1.15));

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
public int HandleReSellCashOrBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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
		int Cost = RoundFloat(float(GetItemCost(ItemId)) / 1.1);

		if(Result == 0)
		{

			//Handle:
			menu = CreateMenu(MoreItemReSellMenuCash);

			//Title:
			menu.SetTitle("[%s] Select amount:", GetItemName(ItemId));

			//Declare:
			int SItemCost = (RoundFloat(float(GetItemCost(ItemId)) / 1.1) * GetItemAmount(Client, ItemId));

			//Format:
			Format(MuchItem, 255, "All %i x [€%i]", GetItemAmount(Client, ItemId), SItemCost);

			Format(bMax, 64, "%i", GetItemAmount(Client, ItemId));

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
			menu = CreateMenu(MoreItemReSellMenuBank);

			//Declare:
			int SItemCost = (RoundFloat(float(GetItemCost(ItemId)) / 1.1) * GetItemAmount(Client, ItemId));

			//Format:
			Format(MuchItem, 255, "All %i x [€%i]", GetItemAmount(Client, ItemId), SItemCost);

			Format(bMax, 64, "%i", GetItemAmount(Client, ItemId));

			//Menu Button:
			menu.AddItem(bMax, MuchItem);

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

public int MoreItemReSellMenuCash(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//In Distance:
		if(IsInDistance(Client, Ent))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int Amount = StringToInt(info);
			int ItemId = GetSelectedItem(Client);
			int SItemCost = (RoundFloat(float(GetItemCost(ItemId)) / 1.1) * Amount);

			//Has Enoug Items:
			if(GetItemAmount(Client, ItemId) - Amount >= 0 && Amount != 0)
			{

				// Dynamic Economy!
				TakeServerSafeMoneyAll(SItemCost);

				//Initialize:
				SetCash(Client, (GetCash(Client) + SItemCost));

				// Dynamic Economy!
				AddServerSafeMoneyAll(SItemCost);

				//Save:
				SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - Amount));

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You have sold \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF for \x0732CD32€%i\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have %ix of \x0732CD32%s\x07FFFFFF(s)", Amount, GetItemName(ItemId));
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

public int MoreItemReSellMenuBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//In Distance:
		if(IsInDistance(Client, Ent))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int Amount = StringToInt(info);
			int ItemId = GetSelectedItem(Client);
			int SItemCost = (RoundFloat(float(GetItemCost(ItemId)) / 1.15) * Amount);

			//Has Enoug Items:
			if(GetItemAmount(Client, ItemId) - Amount >= 0 && Amount != 0)
			{

				// Dynamic Economy!
				TakeServerSafeMoneyAll(SItemCost);

				//Initialize:
				SetBank(Client, (GetBank(Client) + SItemCost));

				//Save:
				SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - Amount));

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You have sold \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF for \x0732CD32€%i\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have %ix of \x0732CD32%s\x07FFFFFF(s)", Amount, GetItemName(ItemId));
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