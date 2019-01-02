//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorcars_included_
  #endinput
#endif
#define _rp_vendorcars_included_

//Defines:
#define MAXCARSPAWNS		10

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

float CarSpawns[MAXCARSPAWNS + 1][3];
int PlayerVehicle[MAXPLAYERS + 1] = {-1,...};
float VehicleFuel[MAXPLAYERS + 1] = {0.0,...};
int VehicleMetal[MAXPLAYERS + 1] = {0,...};

public void initVendorVehicle()
{

	//Commands
	RegAdminCmd("sm_createvendorcarspawn", CommandCreateVendorCarSpawn, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removevendorcarspawn", CommandRemoveVendorCarSpawn, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listvendorcarspawns", CommandListVendorCarSpawns, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipecarspawns", Command_WipeCarSpawns, ADMFLAG_ROOT, "");

	RegConsoleCmd("sm_locatecars", Command_LocateCars);

	//Timers:
	CreateTimer(0.2, CreateSQLdbVendorCarSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXCARSPAWNS; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		CarSpawns[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbVendorCarSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `CarSpawns`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadVendorCarSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXCARSPAWNS; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		CarSpawns[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM CarSpawns WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVendorCarSpawns, query);
}

public void T_DBLoadVendorCarSpawns(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVendorCarSpawns: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vendor Car Spawns Found in DB!");

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
			CarSpawns[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Random Vendor Car Spawns Found!");
	}
}

public void T_DBPrintVendorCarSpawns(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVendorCarSpawns: Query failed! %s", error);
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
public Action CommandCreateVendorCarSpawn(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createvendorcarspawn <id>");

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
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createvendorcarspawn <0-10>");

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
	if(CarSpawns[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE CarSpawns SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO CarSpawns (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	CarSpawns[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created vendor car spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action CommandRemoveVendorCarSpawn(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removevendorcarspawn <id>");

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
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removevendorcarspawn <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(CarSpawns[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	CarSpawns[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM CarSpawns WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Random vendor car spawn (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListVendorCarSpawns(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Vendor Car Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXCARSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM CarSpawns WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintVendorCarSpawns, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeCarSpawns(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Vendor Car Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXCARSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM CarSpawns WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void VendorVehicles(int Client, int VendorId, int Entity)
{

	//Declare:
	char FormatTitle[50];

	//Format:
	Format(FormatTitle, 50, "buy a vehicle or \nspawn your own");

	//Handle:
	Menu menu = CreateMenu(HandleVendorVehicles);

	//Menu Title:
	menu.SetTitle(FormatTitle);

	//Add Menu Item:
	menu.AddItem("0", "Buy Vehicles");

	menu.AddItem("1", "View your Inventory");

	menu.AddItem("2", "Sell Vehicles");

	//Check:
	if(IsValidEdict(PlayerVehicle[Client]))
	{

		//Health:
		int Health = GetEntProp(PlayerVehicle[Client], Prop_Data, "m_iHealth");

		int MaxHealth = GetEntProp(PlayerVehicle[Client], Prop_Data, "m_iMaxHealth");

		if(Health > 0 && VehicleFuel[Client] < 100.0)
		{

			//Add Menu Item:
			menu.AddItem("6", "€1k Refuel Car");
		}

		//Check:
		if(Health == 0)
		{

			//Add Menu Item:
			menu.AddItem("3", "€5k Repair Vehicle");
		}

		//Check:
		else if(Health < MaxHealth)
		{

			//Add Menu Item:
			menu.AddItem("4", "€1k Repair Vehicle");
		}

		//Override:
		else
		{

			//Add Menu Item:
			menu.AddItem("5", "Put Back In Garage");
		}
	}

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Initulize:
	SetMenuTarget(Client, VendorId);

	//Initulize:
	SetTargetPlayer(Client, Entity);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//BankMenu Handle:
public int HandleVendorVehicles(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

		//Check:
		if(IsValidEdict(InVehicle))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't access this vendor whilst in a vehicle!");

			//Return:
			return true;
		}

		//Declare:
		int Entity = GetTargetPlayer(Client);

		//Too Far Away:
		if(!IsInDistance(Client, Entity))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are too far away from the vendor to talk!");

			//Return:
			return true;
		}

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Show Menu:
			VendorBuyVehicles(Client);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Show Menu:
			VendorVehiclesInventory(Client);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			VendorSellVehicles(Client);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Check:
			if(IsValidEdict(PlayerVehicle[Client]))
			{

				//Declare:
				int Amount = 5000;

				//Check:
				if(GetBank(Client) - Amount > 0)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Amount));

					//Accept:
					AcceptEntityInput(PlayerVehicle[Client], "kill");

					//Remove From DB:
					RemoveSpawnedItem(1, 32, 1);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - your vehicle was taken away for repairs!");

					//Initulize:
					PlayerVehicle[Client] = -1;
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough money to repair your vehicle!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have a vehicle spawned");
			}
		}

		//Button Selected:
		if(Result == 4)
		{

			//Check:
			if(IsValidEdict(PlayerVehicle[Client]))
			{

				//Declare:
				int Amount = 1000;

				//Check:
				if(GetBank(Client) - Amount > 0)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Amount));

					//Respawn Vehicle:
					RespawnVehicle(Client, PlayerVehicle[Client]);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have repaired your damaged vehicle!");
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough money to repair the damages of your vehicle!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have a vehicle spawned");
			}
		}

		//Button Selected:
		if(Result == 5)
		{

			//Check:
			if(IsValidEdict(PlayerVehicle[Client]))
			{

				//Accept:
				AcceptEntityInput(PlayerVehicle[Client], "kill");

				//Remove From DB:
				RemoveSpawnedItem(1, 32, 1);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have put your vehicle back into the garage");
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have any vehicles currently spawned");
			}
		}

		//Button Selected:
		if(Result == 6)
		{

			//Check:
			if(IsValidEdict(PlayerVehicle[Client]))
			{

				//Declare:
				float Position[3];
				float VehiclePosition[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Position);

				GetEntPropVector(PlayerVehicle[Client], Prop_Send, "m_vecOrigin", VehiclePosition);

				//Declare:
				float Dist = GetVectorDistance(Position, VehiclePosition);

				//Too Far Away:
				if(Dist <= 550)
				{

					//Initulize:
					if(VehicleFuel[Client] < 100.0)
					{

						//Declare:
						int Amount = 1000;

						//Check:
						if(GetBank(Client) - Amount > 0)
						{

							//Initulize:
							SetBank(Client, (GetBank(Client) - Amount));

							//Initulize:
							VehicleFuel[Client] = 100.0;

							//Respawn Vehicle:
							RespawnVehicle(Client, PlayerVehicle[Client]);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have just refuled your car for %s", IntToMoney(Amount));
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough money to refuel your vehicle!");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your vehicle has already been refueled");
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your vehicle is too faw away to be refuled");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have a vehicle spawned");
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

public void RespawnVehicle(int Client, int Vehicle)
{

	//Check:
	if(!IsValidEdict(Vehicle))
	{

		//Return:
		return;
	}

	//Declare:
	char Message[64];
	float Position[3];
	float Ang[3];

	//Format:
	Format(Message, sizeof(Message), "%s", GetVehicleTypeFromModel(Vehicle));

	//Get Prop Data:
	GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", Position);
	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", Ang);

	//Health:
	int Health = GetEntProp(Vehicle, Prop_Data, "m_iHealth");

	int MaxHealth = GetEntProp(Vehicle, Prop_Data, "m_iMaxHealth");

	int VehicleLocked = GetEntProp(Vehicle, Prop_Data, "m_bLocked");

	//Accept:
	AcceptEntityInput(Vehicle, "Kill");

	//Forward Function:
	CreateVehicleFromString(Client, true, Message, -1, Position, Ang, Health, VehicleLocked, VehicleFuel[Client], 0);

	//MaxHealth:
	SetEntProp(PlayerVehicle[Client], Prop_Data, "m_iMaxHealth", MaxHealth);
}

//Job Experience Menu:
public void VendorBuyVehicles(int Client)
{

	//Declare:
	char FormatTitle[50];
	bool MenuDisplay = false;

	//Format:
	Format(FormatTitle, 50, "What vehicle would you\nlike to buy?");

	//Handle:
	Menu menu = CreateMenu(HandleVendorBuyVehicles);

	//Loop:
	for(int X = 0; X < GetMaxItems(); X++)
	{

		//Old Items
		if(GetItemGroup(X) == 16)
		{

			//Has Items:
			if(GetItemAmount(Client, X) == 0)
			{

				//Initialize:
				MenuDisplay = true;

				//Declare:
				char ActionItemId[12];
				char MenuFormat[255];

				//Format:
				Format(ActionItemId, sizeof(ActionItemId), "%i", X);

				//Format:
				Format(MenuFormat, sizeof(MenuFormat), "[€%i] %s", GetItemCost(X), GetItemName(X));

				//Add Menu Item:
				menu.AddItem(ActionItemId, MenuFormat);
			}
		}
	}

	//Show:
	if(MenuDisplay == true)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already purchased every vehicle avaiable!");

		//Close:
		delete menu;
	}
}

//BankMenu Handle:
public int HandleVendorBuyVehicles(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int X = StringToInt(info);

		//Has Enoug Money
		if(GetBank(Client) >= GetItemCost(X) && GetBank(Client) != 0)
		{

			//Initialize:
			SetBank(Client, (GetBank(Client) - GetItemCost(X)));

			// Dynamic Economy!
			AddServerSafeMoneyAll(GetItemCost(X));

			//Initialize:
			SetItemAmount(Client, X, (GetItemAmount(Client, X) + 1));

			//Save:
			SaveItem(Client, X, GetItemAmount(Client, X));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF.", GetItemName(X), IntToMoney(GetItemCost(X)));
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough for this vehicle");
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

//Job Experience Menu:
public void VendorVehiclesInventory(int Client)
{

	//Declare:
	char FormatTitle[50];
	bool MenuDisplay = false;

	//Format:
	Format(FormatTitle, 50, "Spawn Vehicles in From\nInventory");

	//Handle:
	Menu menu = CreateMenu(HandleVendorInventoryVehicles);

	//Menu Title:
	menu.SetTitle(FormatTitle);

	//Loop:
	for(int X = 0; X < GetMaxItems(); X++)
	{

		//Old Items
		if(GetItemGroup(X) == 16)
		{

			//Has Items:
			if(GetItemAmount(Client, X) > 0)
			{


				//Initialize:
				MenuDisplay = true;

				//Add Menu Item:
				menu.AddItem(GetItemName(X), GetItemName(X));
			}
		}
	}

	//Show:
	if(MenuDisplay == true)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have any cars in your inventory");

		//Close:
		delete menu;
	}
}

//BankMenu Handle:
public int HandleVendorInventoryVehicles(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int VendorId = GetMenuTarget(Client);
		float EyeAng[3] = {0.0, 0.0, 0.0};

		//Invalid Spawn Check:
		if(CarSpawns[VendorId][0] != 69.0)
		{

			//Check:
			if(!IsValidEdict(PlayerVehicle[Client]))
			{

				//Declare:
				int Health = 0;

				//Check:
				if(StrContains(info, "AirBoat", false) != -1)
				{

					//Initulize:
					Health = 1000;

					//Forward Function:
					CreateVehicleFromString(Client, false, info, VendorId, CarSpawns[VendorId], EyeAng, Health, 1, 0.1, 0);
				}

				//Check:
				if(StrContains(info, "Jeep", false) != -1)
				{

					//Initulize:
					Health = 1000;

					//Forward Function:
					CreateVehicleFromString(Client, false, info, VendorId, CarSpawns[VendorId], EyeAng, Health, 1, 0.1, 0);
				}

				//Check:
				if(StrContains(info, "Golf GTI", false) != -1)
				{

					//Initulize:
					Health = 1000;

					//Forward Function:
					CreateVehicleFromString(Client, false, info, VendorId, CarSpawns[VendorId], EyeAng, Health, 1, 0.1, 0);
				}

				//Check:
				if(StrContains(info, "APC", false) != -1)
				{

					//Initulize:
					Health = 4000;

					//Forward Function:
					CreateVehicleFromString(Client, false, info, VendorId, CarSpawns[VendorId], EyeAng, Health, 1, 0.1, 0);
				}

				//Check:
				if(StrContains(info, "Ferrari GT250", false) != -1)
				{

					//Initulize:
					Health = 1000;

					//Forward Function:
					CreateVehicleFromString(Client, false, info, VendorId, CarSpawns[VendorId], EyeAng, Health, 1, 0.1, 0);
				}

				//Check:
				if(StrContains(info, "Corvette", false) != -1)
				{

					//Initulize:
					Health = 1000;

					//Forward Function:
					CreateVehicleFromString(Client, false, info, VendorId, CarSpawns[VendorId], EyeAng, Health, 1, 0.1, 0);
				}

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - we have spawned your %s at point %i!", info, VendorId);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already spawned a vehicle!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Vendor Vehicle Spawn point!");
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

public void CreateVehicleFromString(int Client, bool Connecting, char info[64], int VendorId, float Origin[3], float EyeAng[3], int Health, int VehicleLocked, float Fuel, int VehMetal)
{

	//Check:
	if(IsValidEdict(PlayerVehicle[Client]))
	{

		//Remove:
		RemovePlayerCar(Client);
	}

	//Check
	if(Health == 0)
	{

		//Declare:
		char Model[128];

		//Format:
		Format(Model, sizeof(Model), "%s", GetVehicleModelFromInfo(info));

		//Declare:
		int Entity = CreateProp(Origin, EyeAng, Model, true, false);

		//Initulize:
		SetEntityRenderMode(Entity, RENDER_GLOW);

		SetEntityRenderColor(Entity, 40, 40, 40, 255);

		//Set do default classname
		SetEntityClassName(Entity, "prop_vehicle_damaged");

		//Set Health:
		SetEntProp(Entity, Prop_Data, "m_iHealth", Health);

		//Invincible:
		SetEntProp(Entity, Prop_Data, "m_takedamage", 0, 1);

		//Debris:
		int Collision = GetEntSendPropOffs(Entity, "m_CollisionGroup");
		SetEntData(Entity, Collision, 1, 1, true);

		//Initulize:
		PlayerVehicle[Client] = Entity;

		VehicleMetal[Client] = VehMetal;

		//Health:
		SetEntProp(Entity, Prop_Data, "m_iHealth", 0);

		//Invincible:
		SetEntProp(Entity, Prop_Data, "m_takedamage", 2, 1);

		//Damage Hook:
		SDKHook(Entity, SDKHook_OnTakeDamage, OnVehicleDamagedTakeDamage);
	}

	//Override:
	else
	{

		//Check:
		if(StrContains(info, "AirBoat", false) != -1)
		{

			//Spawn:
			PlayerVehicle[Client] = CreateAirBoat(Client, Origin, EyeAng, Health, VehicleLocked);
		}

		//Check:
		if(StrContains(info, "Jeep", false) != -1)
		{

			//Spawn Buggy:
			PlayerVehicle[Client] = CreateJeep(Client, Origin, EyeAng, Health, VehicleLocked);
		}

		//Check:
		if(StrContains(info, "Golf GTI", false) != -1)
		{

			//Spawn Golf:
			PlayerVehicle[Client] = CreateCustomCar(Client, Origin, EyeAng, "models/golf/golf.mdl", "scripts/vehicles/golf.txt", Health, VehicleLocked);
		}

		//Check:
		if(StrContains(info, "APC", false) != -1)
		{

			//Spawn Apc:
			PlayerVehicle[Client] = CreateAPC(Client, Origin, EyeAng, Health, VehicleLocked);
		}

		//Check:
		if(StrContains(info, "Ferrari GT250", false) != -1)
		{

			//Spawn GT250:
			PlayerVehicle[Client] = CreateCustomCar(Client, Origin, EyeAng, "models/tdmcars/ferrari250gt.mdl", "scripts/vehicles/gt250.txt", Health, VehicleLocked);
		}

		//Check:
		if(StrContains(info, "Corvette", false) != -1)
		{

			//Spawn GT250:
			PlayerVehicle[Client] = CreateCustomCar(Client, Origin, EyeAng, "models/corvette/corvette.mdl", "scripts/vehicles/corvette.txt", Health, VehicleLocked);
		}

		//Turn off car player has no fuel:
		if(Fuel == 0.0)
		{

			//Accept:
			AcceptEntityInput(PlayerVehicle[Client], "TurnOff", Client);
		}

		//Initulize:
		VehicleFuel[Client] = Fuel;

		VehicleMetal[Client] = 0;

		//Check:
		if(Connecting == false)
		{

			//Check:
			if(!IsSpawnedItemSaved(Client, 32, 1))
			{

				//Declare:
				char AddedData[64];

				//Format:
				Format(AddedData, sizeof(AddedData), "%s^%f", info, Fuel);

				//Add Spawned Item to DB:
				InsertSpawnedItem(Client, 32, 1, Health, VehicleLocked, 0, AddedData, CarSpawns[VendorId], EyeAng);
			}
		}
	}
}

//Job Experience Menu:
public void VendorSellVehicles(int Client)
{

	//Declare:
	char FormatTitle[50];
	bool MenuDisplay = false;

	//Format:
	Format(FormatTitle, 50, "Spawn Vehicles in From\nInventory");

	//Handle:
	Menu menu = CreateMenu(HandleVendorInventorySellVehicle);

	//Menu Title:
	menu.SetTitle(FormatTitle);

	//Loop:
	for(int X = 0; X < GetMaxItems(); X++)
	{

		//Old Items
		if(GetItemGroup(X) == 16)
		{

			//Has Items:
			if(GetItemAmount(Client, X) > 0)
			{

				//Initialize:
				MenuDisplay = true;

				//Declare:
				char ActionItemId[12];
				char MenuFormat[255];

				//Format:
				Format(ActionItemId, sizeof(ActionItemId), "%i", X);

				int Amount = RoundFloat(float(GetItemCost(X)) / 1.1);

				//Format:
				Format(MenuFormat, sizeof(MenuFormat), "[€%i] %s", Amount, GetItemName(X));

				//Add Menu Item:
				menu.AddItem(ActionItemId, MenuFormat);
			}
		}
	}

	//Show:
	if(MenuDisplay == true)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have any cars in your inventory");

		//Close:
		delete menu;
	}
}

//BankMenu Handle:
public int HandleVendorInventorySellVehicle(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int X = StringToInt(info);
		int Amount = RoundFloat(float(GetItemCost(X)) / 1.1);

		//Has Enoug Money
		if(GetItemAmount(Client, X) > 0)
		{

			//Initialize:
			SetBank(Client, (GetBank(Client) + Amount));

			// Dynamic Economy!
			TakeServerSafeMoneyAll(Amount);

			//Initialize:
			SetItemAmount(Client, X, (GetItemAmount(Client, X) - 1));

			//Save:(780
			SaveItem(Client, X, GetItemAmount(Client, X));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You Sold \x0732CD32%s\x07FFFFFF for \x0732CD32%s\x07FFFFFF.", GetItemName(X), IntToMoney(Amount));
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You dont have this vehicle anymore");
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

public int GetPlayerVehicle(int Client)
{

	//Return:
	return PlayerVehicle[Client];
}

public void SetPlayerVehicle(int Client, int VehicleEnt)
{

	//Initulize:
	PlayerVehicle[Client] = VehicleEnt;
}

public float GetVehicleFuel(int Client)
{

	//Return:
	return view_as<float>(VehicleFuel[Client]);
}

public void SetVehicleFuel(int Client, float Result)
{

	//Initulize:
	VehicleFuel[Client] = Result;
}

public int GetVehicleMetal(int Client)
{

	//Return:
	return view_as<int>(VehicleMetal[Client]);
}

public void SetVehicleMetal(int Client, int Result)
{

	//Initulize:
	VehicleMetal[Client] = Result;
}


public void RemovePlayerCar(int Client)
{

	//Check:
	if(IsValidEdict(PlayerVehicle[Client]))
	{

		//Accept:
		AcceptEntityInput(PlayerVehicle[Client], "kill");

		//Initulize:
		PlayerVehicle[Client] = -1;
	}
}

public int GetOwnerOfVehicle(int Ent)
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Check:
			if(PlayerVehicle[Client] == Ent)
			{

				//Return:
				return view_as<int>(Client);
			} 
		}
	}

	//Return:
	return view_as<int>(-1);
}

public float GetPlayerVehicleFuel(int Ent)
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Check:
			if(PlayerVehicle[Client] == Ent)
			{

				//Return:
				return view_as<float>(VehicleFuel[Client]);
			} 
		}
	}

	//Return:
	return view_as<float>(0.0);
}

public float GetPlayerVehicleMetal(int Ent)
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Check:
			if(PlayerVehicle[Client] == Ent)
			{

				//Return:
				return view_as<float>(VehicleMetal[Client]);
			} 
		}
	}

	//Return:
	return view_as<float>(0.0);
}

char GetVehicleTypeFromModel(int Ent)
{

	//Declare:
	char Result[32] = "null";

	//Check:
	if(IsValidEdict(Ent))
	{

		//Declare:
		char Model[128];

		//Initulize:
		GetEntPropString(Ent, Prop_Data, "m_ModelName", Model, sizeof(Model));

		//Check:
		if(StrContains(Model, "models/airboat.mdl", false) != -1)
		{


			//Initulize:
			Result = "AirBoat";
		}

		//Check:
		if(StrContains(Model, "models/blodia/buggy.mdl", false) != -1)
		{

			//Initulize:
			Result = "Jeep";
		}

		//Check:
		if(StrContains(Model, "models/golf/golf.mdl", false) != -1)
		{

			//Initulize:
			Result = "Golf GTI";
		}

		//Check:
		if(StrContains(Model, "models/combine_apc.mdl", false) != -1)
		{

			//Initulize:
			Result = "APC";
		}

		//Check:
		if(StrContains(Model, "models/tdmcars/ferrari250gt.mdl", false) != -1)
		{

			//Initulize:
			Result = "Ferrari GT250";
		}

		//Check:
		if(StrContains(Model, "models/corvette/corvette.mdl", false) != -1)
		{

			//Initulize:
			Result = "Corvette";
		}
	}

	//Return:
	return view_as<char>(Result);
}

char GetVehicleModelFromInfo(char info[64])
{

	//Declare:
	char Result[32] = "null";

	//Check:
	if(StrContains(info, "AirBoat", false) != -1)
	{

		//Initulize:
		Result = "models/airboat.mdl";
	}

	//Check:
	if(StrContains(info, "Jeep", false) != -1)
	{

		//Initulize:
		Result = "models/blodia/buggy.mdl";
	}

	//Check:
	if(StrContains(info, "Golf GTI", false) != -1)
	{

		//Initulize:
		Result = "models/golf/golf.mdl";
	}

	//Check:
	if(StrContains(info, "APC", false) != -1)
	{

		//Initulize:
		Result = "models/combine_apc.mdl";
	}

	//Check:
	if(StrContains(info, "Ferrari GT250", false) != -1)
	{

		//Initulize:
		Result = "models/tdmcars/ferrari250gt.mdl";
	}

	//Check:
	if(StrContains(info, "Corvette", false) != -1)
	{

		//Initulize:
		Result = "models/corvette/corvette.mdl";
	}

	//Return:
	return view_as<char>(Result);
}

public void initCarModThink()
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Declare:
			int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

			//Check:
			if(IsValidEdict(InVehicle))
			{

				//Declare:
				int Owner = GetOwnerOfVehicle(InVehicle);

				//Check:
				if(Owner > 0 && VehicleFuel[Owner] != 0.0)
				{

					int Speed = GetEntProp(InVehicle, Prop_Send, "m_nSpeed");
					float Throttle = GetEntPropFloat(InVehicle, Prop_Send, "m_flThrottle");

					float FuelUsed = GetRandomFloat(0.001, 0.005);

					//Declare:
					int Buttons = GetClientButtons(Client);

					//E Key:
					if(Buttons & IN_USE)
					{

						//Initulize:
						FuelUsed += (float(Speed) / 1500);

						//Check:
						if(Throttle > 0.0)
						{

							//Initulize:
							FuelUsed += (float(Speed) / 2000);
						}
					}

					//Initulize:
					FuelUsed += (float(Speed) / 3000);

					//Check:
					if(Throttle > 0.0)
					{

						//Initulize:
						FuelUsed += (float(Speed) / 2000);
					}

					//Check:
					if(VehicleFuel[Owner] - FuelUsed > 0.000000)
					{

						//Initulize:
						VehicleFuel[Owner] = VehicleFuel[Owner] - FuelUsed;
					}

					//Override:
					else
					{

						//Accept:
						AcceptEntityInput(InVehicle, "TurnOff", Client);

						SetEntProp(InVehicle, Prop_Send, "m_nSpeed", 0);

						SetEntPropFloat(InVehicle, Prop_Send, "m_flThrottle", 0.0);

						//Initulize:
						VehicleFuel[Owner] = 0.0;

						//Print:
						CPrintToChat(Owner, "\x07FF4040|RP|\x07FFFFFF - Your vehicle has ran out of fuel!");

						if(Client != Owner) CPrintToChat(Owner, "\x07FF4040|RP|\x07FFFFFF - The vehicle has ran out of fuel!");
					}
				}
			}
		}
	}
}

public Action Command_LocateCars(int Client, int Args)
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
	while ((Props = FindEntityByClassname(Props, "npc_Vendor_Cars")) != -1)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no Cars vendor currently spawned on the map");

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