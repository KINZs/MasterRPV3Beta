//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_trading_included_
  #endinput
#endif
#define _rp_trading_included_

//Defines:
#define MAXTRADINGZONES		5

//Euro - € dont remove this!
//€ = �

//Trading Zones!
float TradingZones[MAXTRADINGZONES + 1][3];
bool InTrading[MAXPLAYERS + 1] = {false,...};

public void initTrading()
{

	//Commands:
	RegAdminCmd("sm_createtradingzone", Command_CreateTradingZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removetradingzone", Command_RemoveTradingZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listtradingzones", Command_ListTradingZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipetradingzones", Command_WipeTradingZones, ADMFLAG_ROOT, "");

	RegConsoleCmd("sm_locatetrading", Command_LocateTrading);

	//Timers:
	CreateTimer(0.2, CreateSQLdbTradingZones);

	//Loop:
	for(int Z = 0; Z <= MAXTRADINGZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		TradingZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbTradingZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `TradingZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadTradingZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXTRADINGZONES; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		TradingZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM TradingZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadTradingZones, query);
}

public void T_DBLoadTradingZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadTradingZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Trading Zones Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			TradingZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Trading Zones Found!");
	}
}

public void T_DBPrintTradingZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintTradingZones: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ZoneId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

//Create Garbage Zone:
public Action Command_CreateTradingZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createtradingzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXTRADINGZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createtradingzone <0-%i>", MAXTRADINGZONES);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(TradingZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE tradingzones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO TradingZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	TradingZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Trading Zones spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveTradingZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removetradingzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > MAXTRADINGZONES)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removetradingzone <0-%i>", MAXTRADINGZONES);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(TradingZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	TradingZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM TradingZones WHERE ZoneId = %i AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed tradingzones Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListTradingZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Trading Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXTRADINGZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM TradingZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintTradingZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeTradingZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Trading Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXTRADINGZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM TradingZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void CheckClientIsInTrading(int Client)
{

	//Declare:
	float Position[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

	//Declare:
	float Dist = GetVectorDistance(TradingZones[1], Position);

	//In Distance:
	if(Dist <= 155)
	{

		//Check:
		if(InTrading[Client] == false)
		{

			//Initulize:
			InTrading[Client] = true;

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have entered the trading zone!");
		}

		//Declare:
		int Random = GetRandomInt(1, 7);

		//Declare:
		int BeamColor[4] = {255, 100, 100, 225};

		switch(Random)
		{

			case 1:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 100;
				BeamColor[2] = 100;
				BeamColor[3] = 225;
			}

			case 2:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 225;
				BeamColor[2] = 100;
				BeamColor[3] = 225;
			}

			case 3:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 225;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 4:
			{

				//Initulize:
				BeamColor[0] = 100;
				BeamColor[1] = 225;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 5:
			{

				//Initulize:
				BeamColor[0] = 100;
				BeamColor[1] = 100;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 6:
			{

				//Initulize:
				BeamColor[0] = 255;
				BeamColor[1] = 100;
				BeamColor[2] = 225;
				BeamColor[3] = 225;
			}

			case 7:
			{

				//Initulize:
				BeamColor[0] = 100;
				BeamColor[1] = 225;
				BeamColor[2] = 100;
				BeamColor[3] = 225;
			}
		}

		//Draw Trading:
		DrawTradingBeamBoxToClient(Client, Laser(), 0, 0, 66, 1.0, 1.0, 1.0, 0, 0.0, BeamColor, 0);
	}

	//In Distance:
	if(Dist > 155)
	{

		//Check:
		if(InTrading[Client] == true)
		{

			//Initulize:
			InTrading[Client] = false;

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have left the trading zone!");
		}
	}
}

public void DrawTradingBeamBoxToClient(int Client, int modelIndex, int haloIndex, int startFrame, int frameRate, float life, float width, float endWidth, int fadeLength, float amplitude, int Color[4], int speed)
{

	TE_SetupBeamPoints(TradingZones[2], TradingZones[3], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupBeamPoints(TradingZones[2], TradingZones[4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupBeamPoints(TradingZones[5], TradingZones[3], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupBeamPoints(TradingZones[5], TradingZones[4], modelIndex, haloIndex, startFrame, frameRate, life, width, endWidth, fadeLength, amplitude, Color, speed);

	TE_SendToClient(Client);

	TE_SetupDynamicLight(TradingZones[1], Color[0], Color[1], Color[2], 8, 100.0, 1.5, 50.0);

	TE_SendToClient(Client);
}


public bool IsClientInTrading(int Client)
{

	//Return:
	return view_as<bool>(InTrading[Client]);
}

public void SetInTrading(int Client, bool Result)
{

	//Initulize:
	InTrading[Client] = Result;
}

public void OnClientTradeMenu(int Client, int Player)
{

	//Check:
	if(IsClientInTrading(Client) && IsClientInTrading(Player))
	{

		//Declare:
		bool MenuDisplay = false;

		int ItemActionAmount = 0;

		int MenuShow[20] = {0,...};

		//Handle:
		Menu menu = CreateMenu(HandleSortItemsTrading);

		//Loop:
		for(int X = 0; X < 500; X++)
		{

			//Has Items:
			if(GetItemAmount(Player, X) > 0)
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
			}
		}

		//Show Menu:
		if(MenuDisplay)
		{

			//Menu Title:
			menu.SetTitle("Select an item you want to trade!");

			//Show Menu:
			menu.Display(Client, 30);

			//Initulize:
			SetTargetPlayer(Client, Player);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have any items!");

			//Close:
			delete menu;
		}
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");
	}
}

//Item Handle:
public int HandleSortItemsTrading(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

		//Declare:
		int Player = GetTargetPlayer(Client);

		//Check:
		if(!IsClientConnected(Player) || !IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Player is no longer avaiable!");

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client) && IsClientInTrading(Player))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Result = StringToInt(info);
			bool MenuDisplay = false;

			//Handle:
			menu = CreateMenu(HandleItemsTrading);

			//Loop:
			for(int X = 0; X < 500; X++)
			{

				//Has Items:
				if(GetItemAmount(Player, X) > 0)
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
						MenuDisplay = true;
					}
				}
			}

			//Show:
			if(MenuDisplay == true)
			{

				//Menu Title:
				menu.SetTitle("Select an item you want to trade!");

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

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");
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
public int HandleItemsTrading(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

		//Declare:
		int Player = GetTargetPlayer(Client);

		//Check:
		if(!IsClientConnected(Player) || !IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Player is no longer avaiable!");

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client) && IsClientInTrading(Player))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Result = StringToInt(info);

			//Initialize:
			SetSelectedItem(Client, Result);

			//Show Menu:
			DrawItemTradingAmountMenu(Client);
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");
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

public void DrawItemTradingAmountMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleItemTradingAmountMenu);

	//Declare:
	char title[256];
	char FormatMenu[64];
	int ItemId = GetSelectedItem(Client);

	//Format:
	Format(title, sizeof(title), "how many would you like to trade?\n\n%s", GetItemName(ItemId));

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "1x - %s", GetItemCost(ItemId));

	//Menu Button:
	menu.AddItem("1", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "2x - %s", GetItemCost(ItemId) * 2);

	//Menu Button:
	menu.AddItem("2", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "5x - %s", GetItemCost(ItemId) * 5);

	//Menu Button:
	menu.AddItem("5", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "10x - %s", GetItemCost(ItemId) * 10);

	//Menu Button:
	menu.AddItem("10", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "25x - %s", GetItemCost(ItemId) * 25);

	//Menu Button:
	menu.AddItem("25", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "50x - %s", GetItemCost(ItemId) * 50);

	//Menu Button:
	menu.AddItem("50", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "100x - %s", GetItemCost(ItemId) * 100);

	//Menu Button:
	menu.AddItem("100", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "200x - %s", GetItemCost(ItemId) * 200);

	//Menu Button:
	menu.AddItem("200", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "500x - %s", GetItemCost(ItemId) * 500);

	//Menu Button:
	menu.AddItem("500", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "1000x - %s", GetItemCost(ItemId) * 1000);

	//Menu Button:
	menu.AddItem("1000", FormatMenu);

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleItemTradingAmountMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

		//Declare:
		int Player = GetTargetPlayer(Client);

		//Check:
		if(!IsClientConnected(Player) || !IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Player is no longer avaiable!");

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client) && IsClientInTrading(Player))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Amount = StringToInt(info);
			int ItemId = GetSelectedItem(Client);

			if(GetItemAmount(Player, ItemId) - Amount >= 0)
			{

				//Initulize:
				SetMenuTarget(Client, Amount);

				//Show Menu:
				DrawItemTradingOfferMenu(Client);
			}

			//Override
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have %ix of \x0732CD32%s\x07FFFFFF!", Player, Amount, GetItemName(ItemId));
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");
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

public void DrawItemTradingOfferMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleItemTradingOfferMenu);

	//Declare:
	char title[256];
	char FormatMenu[64];
	int ItemId = GetSelectedItem(Client);

	//Format:
	Format(title, sizeof(title), "how many would you like to Offer for?\n\n%ix - %s", GetMenuTarget(Client), GetItemName(ItemId));

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(25));

	//Menu Button:
	menu.AddItem("25", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(50));

	//Menu Button:
	menu.AddItem("50", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(100));

	//Menu Button:
	menu.AddItem("100", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(200));

	//Menu Button:
	menu.AddItem("200", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(500));

	//Menu Button:
	menu.AddItem("500", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(1000));

	//Menu Button:
	menu.AddItem("1000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(2000));

	//Menu Button:
	menu.AddItem("2000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(5000));

	//Menu Button:
	menu.AddItem("5000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(10000));

	//Menu Button:
	menu.AddItem("10000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(15000));

	//Menu Button:
	menu.AddItem("15000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(20000));

	//Menu Button:
	menu.AddItem("20000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(30000));

	//Menu Button:
	menu.AddItem("30000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(40000));

	//Menu Button:
	menu.AddItem("40000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(50000));

	//Menu Button:
	menu.AddItem("50000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(75000));

	//Menu Button:
	menu.AddItem("75000", FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "%s", IntToMoney(100000));

	//Menu Button:
	menu.AddItem("100000", FormatMenu);

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Item Handle:
public int HandleItemTradingOfferMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

		//Declare:
		int Player = GetTargetPlayer(Client);

		//Check:
		if(!IsClientConnected(Player) || !IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Player is no longer avaiable!");

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client) && IsClientInTrading(Player))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Result = StringToInt(info);
			int ItemId = GetSelectedItem(Client);
			int Amount = GetMenuTarget(Client);

			if(GetBank(Client) - Result >= 0)
			{

				//Initulize:
				SetMenuTarget(Client, Result);

				OnClientTradeOffer(Client, Player, ItemId, Amount, Result);
			}

			//Override
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have %ix of \x0732CD32%s\x07FFFFFF!", Player, Amount, GetItemName(ItemId));
			}
		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");
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

public void OnClientTradeOffer(int Client, int Player, int ItemId, int Amount, int Offer)
{

	//Handle:
	Menu menu = CreateMenu(HandleItemTradingOffer);

	//Declare:
	char title[256];
	char FormatMenu[64];
	char FormatMenu2[64];

	//Format:
	Format(title, sizeof(title), "%N would like to trade\n%ix - %s\nfor %s", Client, Amount, GetItemName(ItemId), IntToMoney(Offer));

	//Menu Title:
	menu.SetTitle(title);

	//Format:
	Format(FormatMenu2, sizeof(FormatMenu2), "%i", Offer);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "Yes");

	//Menu Button:
	menu.AddItem(FormatMenu2, FormatMenu);

	//Format:
	Format(FormatMenu, sizeof(FormatMenu), "No");

	//Menu Button:
	menu.AddItem("0", FormatMenu);

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Initulize:
	SetTargetPlayer(Player, Client);
}

//Item Handle:
public int HandleItemTradingOffer(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

		//Declare:
		int Player = GetTargetPlayer(Client);

		//Check:
		if(!IsClientConnected(Player) || !IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Player is no longer avaiable!");

			//Return:
			return true;
		}

		//Check:
		if(IsClientInTrading(Client) && IsClientInTrading(Player))
		{

			//Declare:
			char info[64];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Initialize:
			int Offer = StringToInt(info);

			//Accept:
			if(Offer != 0)
			{

				//Check:
				if(GetBank(Player) - Offer >= 0)
				{

					//Initialize:
					int ItemId = GetSelectedItem(Player);
					int Amount = GetMenuTarget(Player);

					//Check:
					if(GetItemAmount(Client, ItemId) - Amount >= 0)
					{

						//Initialize:
						SetBank(Client, (GetBank(Client) + Offer));
						SetBank(Player, (GetBank(Player) - Offer));

						SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - Amount));
						SaveItem(Player, ItemId, (GetItemAmount(Player, ItemId) + Amount));

						//Print:
						CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has accepted your offer %ix of \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Client, Amount, GetItemName(ItemId), IntToMoney(Offer));
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have accepted \x0732CD32%N\x07FFFFFF offer %ix of \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF!", Player, Amount, GetItemName(ItemId), IntToMoney(Offer));
					}

					//Override
					else
					{

						//Print:
						CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have %ix of \x0732CD32%s\x07FFFFFF!", Player, Amount, GetItemName(ItemId));

						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have have %ix of \x0732CD32%s\x07FFFFFF!", Amount, GetItemName(ItemId));
					}
				}

				//Override
				else
				{

					//Print:
					CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - You doesn't have \x0732CD32%s\x07FFFFFF for the trade offer!", IntToMoney(Offer));

					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have \x0732CD32%s\x07FFFFFF for the trade offer!", Player, IntToMoney(Offer));
				}
			}

			//Override
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have declined \x0732CD32%N\x07FFFFFF trade offer", Player);

				CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has declined your trade offer", Client);
			}

		}

		//Override
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - You both need to be in the trading zone to use this action!");
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

public Action Command_LocateTrading(int Client, int Args)
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
	if(InTrading[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already in the Trading Zone!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);
	Position[2] += 25.0;
	Origin = TradingZones[1];
	Origin[2] += 25.0;

	//Declare:
	int BeamColor[4] = {255, 255, 255, 225};

	TE_SetupBeamPoints(Position, Origin, Laser(), 0, 0, 66, 1.0, 1.0, 1.0, 0, 0.0, BeamColor, 0);

	TE_SendToClient(Client);

	//Return:
	return Plugin_Handled;
}