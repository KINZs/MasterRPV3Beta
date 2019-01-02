//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_pdcomputer_included_
  #endinput
#endif
#define _rp_pdcomputer_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXPDCOMPUTERS			5

//Definitions:
int PdComputer[MAXPDCOMPUTERS + 1] = {-1,...};

public void initPdComputer()
{

	//Commands:
	RegAdminCmd("sm_createpdcomputer", Command_CreatePdComputer, ADMFLAG_ROOT, "<id> - Create a computer for hacking");

	RegAdminCmd("sm_savepdcomputer", Command_SavePdComputer, ADMFLAG_ROOT, "<id> - Save a computer for hacking");

	RegAdminCmd("sm_removepdcomputer", Command_RemovePdComputer, ADMFLAG_ROOT, "<id> - Removes a computer from the db");

	RegAdminCmd("sm_listpdcomputers", Command_ListPdComputers, ADMFLAG_SLAY, "- Lists all the computers in the database");

	//Beta
	RegAdminCmd("sm_wipepdcomputer", Command_WipePdComputers, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbPdComputers);
}

//Create Database:
public Action CreateSQLdbPdComputers(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PdComputer`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ComputerId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL, `angles` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadPdComputers(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM PdComputer WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadPdComputers, query);
}

//Create Garbage Zone:
public Action Command_CreatePdComputer(int Client, int Args)
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
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Spawn Prop
	int Ent = CreateProp(Origin, EyeAngles, "models/props_lab/servers.mdl", false, false);

	//Set ClassName:
	SetEntityClassName(Ent, "prop_Pd_Computer");

	//Return:
	return Plugin_Handled;
}

//Save Computer:
public Action Command_SavePdComputer(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_savepdcomputers <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Prop Garbage Can:
	if(!IsValidPdComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Check:
	if(StringToInt(SpawnId) < 0 || StringToInt(SpawnId) > MAXPDCOMPUTERS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_savepdcomputers <0-%i>", MAXPDCOMPUTERS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn Already Created:
	if(IsValidEdict(PdComputer[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a pd computer index into the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];
	float Angles[3]; 

	//Initluze:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Declare:
	char query[512];
	char Position[128];
	char Ang[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Format:
	Format(query, sizeof(query), "INSERT INTO PdComputer (`Map`,`ComputerId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(SpawnId), Position, Ang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	PdComputer[StringToInt(SpawnId)] = Ent;

	//Set Health:
	SetEntProp(Ent, Prop_Data, "m_iHealth", 500);

	//MaxHealth:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", 500);

	//Invincible:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnPdComputerTakeDamage);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Saved Pd Computer \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Computer:
public Action Command_RemovePdComputer(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removepdcomputer <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Spawn Already Created:
	if(!IsValidEdict(PdComputer[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM PdComputer WHERE ComputerId = %i AND Map = '%s';", StringToInt(SpawnId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Pd Computer (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListPdComputers(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Pd Computer List: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXPDCOMPUTERS + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM PdComputer WHERE Map = '%s' AND ComputerId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintPdComputers, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipePdComputers(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Pd Computer List Wiped: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXPDCOMPUTERS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM PdComputer WHERE ComputerId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBLoadPdComputers(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBPdLoadComputers: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Pd Computers Found in DB!");

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
			float Angles[3];

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

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Create Computer:
			int Ent = CreateProp(Position, Angles, "models/props_lab/servers.mdl", false, true);

			//Set Health:
			SetEntProp(Ent, Prop_Data, "m_iHealth", 500);

			//MaxHealth:
			SetEntProp(Ent, Prop_Data, "m_iMaxHealth", 500);

			//Invincible:
			SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

			//Damage Hook:
			SDKHook(Ent, SDKHook_OnTakeDamage, OnPdComputerTakeDamage);

			//Initulize:
			PdComputer[X] = Ent;

			//Set ClassName:
			SetEntityClassName(Ent, "prop_Pd_Computer");
		}

		//Print:
		PrintToServer("|RP| - Pd Computers Found!");
	}
}

public void T_DBLoadPdComputerDestroyed(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBPdLoadComputerDestroyed: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Pd Computer Found in DB!");

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
			float Angles[3];

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

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Create Computer:
			int Ent = CreateProp(Position, Angles, "models/props_lab/servers.mdl", false, true);

			//Set Health:
			SetEntProp(Ent, Prop_Data, "m_iHealth", 0);

			//MaxHealth:
			SetEntProp(Ent, Prop_Data, "m_iMaxHealth", 500);

			//Invincible:
			SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

			SetEntityRenderMode(Ent, RENDER_GLOW);

			SetEntityRenderColor(Ent, 40, 40, 40, 255);

			//Declare:
			float Offset[3] = {0.0, 0.0, 20.0};

			//Create Fire Effect!
			CreateInfoParticleSystemOther(Ent, "null", "Fire_Large_01", 0.2, Offset, Angles);

			//Damage Hook:
			SDKHook(Ent, SDKHook_OnTakeDamage, OnPdComputerTakeDamage);

			//Initulize:
			PdComputer[X] = Ent;

			//Set ClassName:
			SetEntityClassName(Ent, "prop_Pd_Computer");
		}
	}
}

public void T_DBPrintPdComputers(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintPdComputers: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", SpawnId, Buffer);
		}
	}
}

//Handle Use Forward:
public void OnPdComputerUse(int Client, int Ent)
{

	//Check:
	if(!StrEqual(GetJob(Client), "Hacker") && !IsAdmin(Client) && !StrEqual(GetJob(Client), "Crime Lord") && !IsCop(Client))
	{

		//Return:
		return;
	}

	//Draw Menu:
	DrawPlayerPdComputerMenu(Client, Ent);

	//Initulize:
	SetLastPressedE(Client, 0.0);
}

public bool IsValidPdComputer(int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Door:
	if(StrEqual(ClassName, "prop_Pd_Computer"))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public Action DrawPlayerPdComputerMenu(int Client, int Ent)
{

	//Initulize:
	SetMenuTarget(Client, Ent);

	//Handle:
	Menu menu = CreateMenu(HandlePlayerPdComputerMenu);

	//Declare:
	char title[256];

	//Format:
	Format(title, sizeof(title), "Choose an option: %N", Client);

	//Menu Title:
	menu.SetTitle(title);

	//Health:
	int Health = GetEntProp(Ent, Prop_Data, "m_iHealth");

	//Max Health:
	int MaxHealth = GetEntProp(Ent, Prop_Data, "m_iMaxHealth");

	//Check:
	if(Health == 0)
	{

		//Menu Button:
		menu.AddItem("3", "Repair Computer");
	}

	//Check:
	else if(Health < MaxHealth)
	{

		//Menu Button:
		menu.AddItem("3", "Repair Computer");

		//Menu Button:
		menu.AddItem("0", "Use Bank Software");

		//Menu Button:
		menu.AddItem("1", "Use Vendor Software");
	}

	//Check:
	else if(Health == MaxHealth)
	{

		//Menu Button:
		menu.AddItem("0", "Use Bank Software");

		//Menu Button:
		menu.AddItem("1", "Use Vendor Software");
	}

	//Check:
	else if(GetBitCoin(Client) > 0.000000)
	{

		//Menu Button:
		menu.AddItem("2", "Trade BitCoin");
	}


	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Action|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandlePlayerPdComputerMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//In Distance:
		if(!IsInDistance(Client, Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Initulize:
			SetMenuTarget(Client, Ent);

			//Loop:
			for(int X = 0; X <= MAXPDCOMPUTERS; X++)
			{

				//Ready:
				if(PdComputer[X] == Ent)
				{

					//Draw Menu:
					DrawBankMenu(Client, Ent);
				}
			}
		}

		//Button Selected:
		else if(Result == 1)
		{

			//Initulize:
			SetMenuTarget(Client, Ent);

			//Handle:
			menu = CreateMenu(HandlePlayerPdComputerVendorMenu);

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

		//Button Selected:
		else if(Result == 2)
		{

			//Declare:
			char AllBTC[32];
			char bAllBTC[32];

			//Format:
			Format(AllBTC, 32, "All (%0.7fBTC)", GetBitCoin(Client));

			Format(bAllBTC, 32, "%f", GetBitCoin(Client));

			//Handle:
			menu = CreateMenu(HandlePdComputerTradeBitcoinMenu);

			//Menu Title:
			menu.SetTitle("How Much to Trade:");

			//Menu Button:
			menu.AddItem(bAllBTC, AllBTC);

			menu.AddItem("0.1", "0.1");

			menu.AddItem("0.2", "0.2");

			menu.AddItem("0.5", "0.5");

			menu.AddItem("1.0", "1.0");

			menu.AddItem("2.0", "2.0");

			menu.AddItem("5.0", "5.0");

			menu.AddItem("10.0", "10.0");

			menu.AddItem("20.0", "20.0");

			menu.AddItem("50.0", "50.0");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 20);
		}

		//Button Selected: fix computer from broken
		else if(Result == 3)
		{

			//Health:
			int Health = GetEntProp(Ent, Prop_Data, "m_iHealth");

			//Check:
			if(Health < 500)
			{

				//Health:
				SetEntProp(Ent, Prop_Data, "m_iHealth", 500);

				//Invincible:
				SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);

				SetEntityRenderMode(Ent, RENDER_GLOW);

				SetEntityRenderColor(Ent, 255, 255, 255, 255);

				//Declare:
				int Amount = 0;

				//Loop:
				while(Health < 500)
				{

					//Initulize:
					Health += 1;

					Amount += 1;
				}

				Amount = (Amount * 2);

				//SetBank:
				SetBank(Client, (GetBank(Client) + Amount));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have earned \x0732CD32%s\x07FFFFFF for repairing this computer!", IntToMoney(Amount));
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This computer already has full health");
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
	return view_as<bool>(true);
}

//PlayerMenu Handle:
public int HandlePlayerPdComputerVendorMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//In Distance:
		if(!IsInDistance(Client, Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Show Vendor Buy Menu
		VendorMenuBuy(Client, Result, Ent);
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

public int HandlePdComputerTradeBitcoinMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		int Ent = GetMenuTarget(Client);

		//In Distance:
		if(!IsInDistance(Client, Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");

			//Return:
			return view_as<bool>(true);
		}

		//Declare:
		char info[64];

		//Get Menu Info::
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		float Amount = StringToFloat(info);

		//Is Valid:
		if((GetBitCoin(Client) - Amount > 0.000000000) && GetBitCoin(Client) != 0)
		{

			//Initialize:
			float TradedBTC = (Amount * 5000.0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have traded \x0732CD32%0.7f\x07FFFFFFBTC for \x0732CD32%s", Amount , IntToMoney(RoundFloat(TradedBTC)));

			//Initialize:
			SetBank(Client, (GetBank(Client) + RoundFloat(TradedBTC)));

			//Check:
			if(GetBitCoin(Client) == Amount)
			{

				//Initialize:
				SetBitCoin(Client, 0.000000000);
			}

			//Override:
			else
			{

				//Initialize:
				SetBitCoin(Client, (GetBitCoin(Client) - Amount));
			}

			//Set Menu State:
			BankState(Client, RoundFloat(TradedBTC));

			//Play Sound:
			EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much BTC.");
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

//Event Damage:
public Action OnPdComputerTakeDamage(int Entity, int &Attacker, int &Inflictor, float &Damage, int &DamageType)
{

	//Health:
	int Health = GetEntProp(Entity, Prop_Data, "m_iHealth");

	//Check:
	if(Attacker > 0 && Attacker <= GetMaxClients())
	{

		//Declare:
		char WeaponName[32];

		//Initulize;
		GetClientWeapon(Attacker, WeaponName, sizeof(WeaponName));

		//Is Stun Stick:
		if(StrEqual(WeaponName, GetArrestWeapon(), false) || StrEqual(WeaponName, GetRepairWeapon(), false))
		{

			//Declare:
			float Origin[3];
			float Position[3];

			//Get Prop Data:
			GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Position);

			GetClientAbsOrigin(Attacker, Origin);

			//Declare:
			float Dist = GetVectorDistance(Position, Origin);

			//In Distance:	
			if(Dist <= 150)
			{

				//Declare:
				int Amount = RoundFloat(Damage);

				//Check:
				if(Health - Amount < 0)
				{

					//Initulize:
					SetMetal(Attacker, (GetMetal(Attacker) + (Health / 2)));
					SetResources(Attacker, (GetResources(Attacker) + (Health / 2)));
				}

				//Override:
				else
				{

					//Initulize:
					SetMetal(Attacker, (GetMetal(Attacker) + (Amount / 2)));
					SetResources(Attacker, (GetResources(Attacker) + (Amount / 2)));
				}
			}
		}

		//Is Cop:
		if(IsCop(Attacker))
		{

			//Initulize:
			Damage = 0.0;

			//Return:
			return Plugin_Changed;
		}

		//Override:
		else
		{

			//Initulize:
			SetCrime(Attacker, (GetCrime(Attacker) + RoundFloat(Damage * 2)));
		}
	}

	//Check:
	if(Health - RoundFloat(Damage) <= 0)
	{

		//Forward:
		OnPdComputerExplode(Entity);
	}

	//Return:
	return Plugin_Continue;
}

public void OnPdComputerExplode(int Entity)
{

	//Declare:
	float Origin[3];
	float Angles[3];
	float Offset[3] = {0.0,0.0,20.0};

	//Initulize:
	GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Origin);
	GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angles);

	//TE Setup:
	TE_SetupDynamicLight(Origin, 255, 100, 10, 8, 150.0, 0.4, 50.0);

	//Send:
	TE_SendToAll();

	//Emit Sound:
	EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

	//Temp Ent:
	TE_SetupExplosion(Origin, Smoke(), 10.0, 1, 0, 100, 5000);

	//Send:
	TE_SendToAll();

	//Temp Ent:
	TE_SetupExplosion(Origin, Explode(), 5.0, 1, 0, 600, 5000);

	//Send:
	TE_SendToAll();

	//CreateDamage:
	ExplosionDamage(Entity, Entity, Origin, DMG_BURN);

	//Create Fire Effect!
	CreateInfoParticleSystemOther(Entity, "null", "Fire_Large_01", 0.2, Offset, Angles);

	//Loop:
	for(int X = 0; X <= MAXPDCOMPUTERS; X++)
	{

		//Ready:
		if(PdComputer[X] == Entity)
		{

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM PdComputer WHERE Map = '%s' AND ComputerId = %i;", ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBLoadPdComputerDestroyed, query);
		}
	}
}

public void PdComputerHud(int Client, int Entity, float NoticeInterval)
{

	//Health:
	int Health = GetEntProp(Entity, Prop_Data, "m_iHealth");

	//Declare:
	char FormatMessage[256];

	//Check:
	if(Health == 0)
	{

		//Format:
		Format(FormatMessage, sizeof(FormatMessage), "Pd Computer:\nBroken");
	}

	//Override:
	else
	{

		//Format:
		Format(FormatMessage, sizeof(FormatMessage), "Pd Computer:\nHealth: %i", Health);
	}

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