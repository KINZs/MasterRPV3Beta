//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_computer_included_
  #endinput
#endif
#define _rp_computer_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXCOMPUTERS			10

//Misc:
float ComputerHackingOrigin[MAXPLAYERS + 1][3];
int HasBeenHacked[MAXCOMPUTERS + 1] = {0,...};
int OwnerCooldown[MAXCOMPUTERS + 1] = {0,...};
int Computer[MAXCOMPUTERS + 1] = {-1,...};
int ComputerMoney[MAXCOMPUTERS + 1] = {0,...};
int ComputerHacking[MAXPLAYERS + 1] = {0,...};
int OwnsComputer[MAXPLAYERS + 1] = {-1,...};

// models/props_lab/servers.mdl

public void initComputerHacking()
{

	//Commands:
	RegAdminCmd("sm_createcomputer", Command_CreateComputer, ADMFLAG_ROOT, "<id> - Create a computer for hacking");

	RegAdminCmd("sm_savecomputer", Command_SaveComputer, ADMFLAG_ROOT, "<id> - Save a computer for hacking");

	RegAdminCmd("sm_removecomputer", Command_RemoveComputer, ADMFLAG_ROOT, "<id> - Removes a computer from the db");

	RegAdminCmd("sm_listcomputers", Command_ListComputers, ADMFLAG_SLAY, "- Lists all the computers in the database");

	//Beta
	RegAdminCmd("sm_wipecomputer", Command_WipeComputers, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbComputers);

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS; X++)
	{

		//Initulize:
		HasBeenHacked[X] = 0;

		Computer[X] = -1;

		OwnerCooldown[X] = 0;

		ComputerMoney[X] = 0;
	}
}

public void initComputer()
{

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS; X++)
	{

		//Is Valid:
		if(HasBeenHacked[X] > 0)
		{

			//Initulize:
			HasBeenHacked[X] -= 1;
		}

		//Check:
		if(OwnerCooldown[X] > 0)
		{

			//Initulize:
			OwnerCooldown[X] -= 1;
		}
	}
}

public void initComputerMoney()
{

	//Declare:
	int Random;

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS; X++)
	{

		//Check:
		if(ComputerMoney[X] < 1000)
		{

			//Initulize:
			Random = GetRandomInt(50, 100);

			//Check:
			if(OwnsComputer[X] != -1)
			{

				//Initulize:
				Random = (Random * 2);
			}

			//Check:
			if(Random + ComputerMoney[X] > 1000)
			{

				//Initulize:
				ComputerMoney[X] = 1000;
			}

			//Override:
			else
			{
				//Initulize:
				ComputerMoney[X] = ComputerMoney[X] + Random;
			}
		}

		//Check:
		if(OwnsComputer[X] != -1)
		{

			//Initulize:
			Random = GetRandomInt(1, 10);

			if(Random == 1 && OwnsComputer[X] != -1)
			{

				//Loop:
				for(int Client = 1; Client <= GetMaxClients(); Client++)
				{

					//Connected:
					if(IsClientConnected(Client) && IsClientInGame(Client))
					{

						//Check:
						if(OwnsComputer[X] == SteamIdToInt(Client))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - the combine has taken back control over the computer systems!");
						}
					}
				}

				//Initulize:
				OwnsComputer[X] = -1;
			}
		}
	}
}

public Action BeginComputerHack(int Client, int Ent)
{

	//Is Valid:
	if(!IsAdmin(Client) && !StrEqual(GetJob(Client), "Crime Lord") && !StrEqual(GetJob(Client), "Hacker"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You dont have the required job to hack this computer!");

		//Return:
		return Plugin_Continue;
	}

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to Start Hacking the Computer!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());

		//Return:
		return Plugin_Continue;
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are cuffed you can't start hacking!");

		//Return:
		return Plugin_Continue;
	}

	//In Critical:
	else if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - you are in Critical Health!");

		//Return:
		return Plugin_Continue;
	}

	//Is Hacking:
	else if(ComputerHacking[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You are already hacking!");

		//Return:
		return Plugin_Continue;
	}

	//Is Hacking:
	else if(GetEnergy(Client) < 15)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You don't have enough energy to Hack this \x0732CD32%s\x07FFFFFF!", "Computer");

		//Return:
		return Plugin_Continue;
	}

	//Is Cop:
	if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return Plugin_Continue;
	}

	//Override:
	else
	{

		//Declare:
		bool ValidComputer = false;

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Initialize:
				ValidComputer = true;

				//Check:
				if(HasBeenHacked[X] > 0)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - This \x0732CD32%s\x07FFFFFF has been Hacked too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", "Computer", HasBeenHacked[X]);

					//Return:
					return Plugin_Continue;
				}
			}
		}

		//Check:
		if(!ValidComputer)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - This Computer doesn't have an index slot");

			//Return:
			return Plugin_Continue;
		}

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 15));

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 4));

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Hacking a \x0732CD32%s\x07FFFFFF!", Client, "Computer");

		//Declare:
		float Origin[3];

		//Initialize:
		GetClientAbsOrigin(Client, Origin);

		//Initialize:
		ComputerHackingOrigin[Client] = Origin;

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Save:
				HasBeenHacked[X] = GetHackComputerAmount();
			}
		}

		//Start:
		ComputerHacking[Client] = 60;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Timer:
		CreateTimer(1.0, BeginHackingComputer, Client, TIMER_REPEAT);
	}

	//Return:
	return Plugin_Continue;
}

public Action BeginHackingComputer(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client))
	{

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Cleared:
	if(ComputerHacking[Client] < 0 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped Hacking an NPC!", Client);

		//Initulize::
		ComputerHacking[Client] = 0;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	float Dist = GetVectorDistance(ComputerHackingOrigin[Client], ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		ComputerHacking[Client] = 0;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(ComputerHacking[Client] == 40)
	{

		//Declare:
		int Random = GetRandomInt(150, 250);

		//Initlulize:
		SetCash(Client, (GetCash(Client) + Random));

		//Dynamic Computer Robbing:
		BeginRobbingVendorToSafe(Client, Random);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have hacked \x0732CD32%s\x07FFFFFF out of this computer!", IntToMoney(Random));
	}

	//Check:
	if(ComputerHacking[Client] == 30)
	{

		//Declare:
		int R = GetRandomInt(457, 462);

		//Save
		SaveItem(Client, R, (GetItemAmount(Client, R) + 1));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Found %s on this computer!", GetItemName(R));
	}

	//Check:
	if(ComputerHacking[Client] == 20)
	{

		//Declare:
		int Random = GetRandomInt(150, 250);

		//Initlulize:
		SetCash(Client, (GetCash(Client) + Random));

		//Dynamic Computer Robbing:
		BeginRobbingVendorToSafe(Client, Random);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have hacked \x0732CD32%s\x07FFFFFF out of this computer!", IntToMoney(Random));
	}

	//Check:
	if(ComputerHacking[Client] == 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		ComputerHacking[Client] = 0;

		//Declare:
		int R = GetRandomInt(457, 462);

		//Save
		SaveItem(Client, R, (GetItemAmount(Client, R) + 1));

		//Print
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Found %s on this computer!", GetItemName(R));

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	ComputerHacking[Client] -= 1;

	//Initialize:
	SetCrime(Client, (GetCrime(Client) + 5));

	//Return:
	return Plugin_Handled;
}

public bool IsClientHackingCashFromComputer(int Client)
{

	//Check:
	if(ComputerHacking[Client] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

//Create Database:
public Action CreateSQLdbComputers(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Computer`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ComputerId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL, `angles` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadComputers(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Computer WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadComputers, query);
}

//Create Garbage Zone:
public Action Command_CreateComputer(int Client, int Args)
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
	SetEntityClassName(Ent, "prop_Computer");

	//Return:
	return Plugin_Handled;
}

//Save Computer:
public Action Command_SaveComputer(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_savecomputers <id>");

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
	if(!IsValidComputer(Ent))
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
	if(StringToInt(SpawnId) < 0 || StringToInt(SpawnId) > MAXCOMPUTERS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_savecomputers <0-%i>", MAXCOMPUTERS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn Already Created:
	if(IsValidEdict(Computer[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a computer index into the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

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
	Format(query, sizeof(query), "INSERT INTO Computer (`Map`,`ComputerId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(SpawnId), Position, Ang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	Computer[StringToInt(SpawnId)] = Ent;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Saved Computer \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Computer:
public Action Command_RemoveComputer(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removecomputer <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Spawn Already Created:
	if(!IsValidEdict(Computer[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM Computer WHERE ComputerId = %i AND Map = '%s';", StringToInt(SpawnId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Computer (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListComputers(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Computer List: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM Computer WHERE Map = '%s' AND ComputerId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintComputers, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeComputers(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Computer List Wiped: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXCOMPUTERS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM Computer WHERE ComputerId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBLoadComputers(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadComputers: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Computers Found in DB!");

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

			//Initulize:
			Computer[X] = Ent;

			//Set ClassName:
			SetEntityClassName(Ent, "prop_Computer");
		}

		//Print:
		PrintToServer("|RP| - Computers Found!");
	}
}

public void T_DBPrintComputers(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintComputers: Query failed! %s", error);
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
public void OnComputerUse(int Client, int Ent)
{

	//Check:
	if(!StrEqual(GetJob(Client), "Hacker") && !IsAdmin(Client) && !StrEqual(GetJob(Client), "Crime Lord"))
	{

		//Return:
		return;
	}

	//Draw Menu:
	DrawPlayerComputerHackMenu(Client, Ent);

	//Initulize:
	SetLastPressedE(Client, 0.0);
}

public Action DrawPlayerComputerHackMenu(int Client, int Ent)
{

	//Initulize:
	SetMenuTarget(Client, Ent);

	//Handle:
	Menu menu = CreateMenu(HandlePlayerComputerHackMenu);

	//Declare:
	char title[256];

	//Format:
	Format(title, sizeof(title), "Choose an option: %N", Client);

	//Menu Title:
	menu.SetTitle(title);

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS; X++)
	{

		//Ready:
		if(Computer[X] == Ent)
		{

			//Initulize:
			if(OwnsComputer[X] == SteamIdToInt(Client))
			{

				//Declare:
				char FormatMenu[64];

				//Format:
				Format(FormatMenu, sizeof(FormatMenu), "Collect (%s)", IntToMoney(ComputerMoney[X]));

				//Menu Button:
				menu.AddItem("3", FormatMenu);
			}

			//Override:
			else
			{

				//Menu Button:
				menu.AddItem("0", "Attempt to take over matchine");
			}
		}
	}

	//Check:
	if(GetItemAmount(Client, 458) > 0)
	{

		//Menu Button:
		menu.AddItem("1", "Use Bank Hacking Software");
	}

	//Check:
	if(GetItemAmount(Client, 460) > 0)
	{

		//Menu Button:
		menu.AddItem("2", "Use No Crime Software");
	}

	//Check:
	if(GetItemAmount(Client, 459) > 0)
	{

		//Menu Button:
		menu.AddItem("4", "Use Vendor Software");
	}

	//Check:
	if(GetItemAmount(Client, 462) > 0)
	{

		//Menu Button:
		menu.AddItem("5", "Use Hacking Software");
	}

	//Check:
	if(GetItemAmount(Client, 461) > 0)
	{

		//Menu Button:
		menu.AddItem("6", "Use Bank Software");
	}

	//Check:
	if(GetBitCoin(Client) > 0.000000)
	{

		//Menu Button:
		menu.AddItem("7", "Trade BitCoin");
	}


	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Action|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandlePlayerComputerHackMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

			//Loop:
			for(int X = 0; X <= MAXCOMPUTERS; X++)
			{

				//Ready:
				if(Computer[X] == Ent)
				{

					//Check:
					if(OwnerCooldown[X] == 0)
					{

						//Initulize:
						if(GetItemAmount(Client, 457) > 0)
						{

							//Declare:
							int Random = GetRandomInt(500, 1000);

							//Crime:
							SetCrime(Client, (GetCrime(Client) + Random));

							//Set Item
							SaveItem(Client, 457, (GetItemAmount(Client, 457) - 1));

							//Declare:
							Random = GetRandomInt(1, 10);

							//Check:
							if(Random > 5)
							{

								//Initulize:
								OwnsComputer[X] = SteamIdToInt(Client);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have managed to hack into this computer system");
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have failed to hack this computer");
							}

							//Initulize:
							OwnerCooldown[X] = 30;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough computer software to hack this computer");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait %i seconds for cooldown", OwnerCooldown[X]);
					}
				}
			}
		}

		//Button Selected:
		else if(Result == 1)
		{

			//Check:
			if(GetItemAmount(Client, 458) > 0)
			{

				//Loop:
				for(int X = 0; X <= MAXCOMPUTERS; X++)
				{

					//Ready:
					if(Computer[X] == Ent)
					{

						//Check:
						if(OwnerCooldown[X] == 0)
						{

							//Declare:
							int Random = GetRandomInt(150, 300);

							//Initlulize:
							SetCash(Client, (GetCash(Client) + Random));

							//Dynamic Computer Robbing:
							BeginRobbingVendorToSafe(Client, Random);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have used a \x0732CD32%s\x07FFFFFF and got \x0732CD32%s\x07FFFFFF out of this computer!", GetItemName(458), IntToMoney(Random));

							//Crime:
							SetCrime(Client, (GetCrime(Client) + (Random * 2)));

							//Set Item
							SaveItem(Client, 458, (GetItemAmount(Client, 458) - 1));

							//Initulize:
							OwnerCooldown[X] = 30;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait \x0732CD32%i\x07FFFFFF seconds for cooldown", OwnerCooldown[X]);
						}

					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You dont have \x0732CD32%s\x07FFFFFF", GetItemName(458));
			}
		}

		//Button Selected:
		else if(Result == 2)
		{

			//Check:
			if(GetItemAmount(Client, 458) > 0)
			{

				//Loop:
				for(int X = 0; X <= MAXCOMPUTERS; X++)
				{

					//Ready:
					if(Computer[X] == Ent)
					{

						//Check:
						if(OwnerCooldown[X] == 0)
						{

							//Initulize:
							int Random = GetRandomInt(1, 10);

							//Check:
							if(Random > 6)
							{

								//Initulize:
								Random = GetRandomInt(750, 1250);

								//Check
								if(GetCrime(Client) - Random > 0)
								{

									//Crime:
									SetCrime(Client, (GetCrime(Client) - Random));
								}

								//Override:
								else
								{

									//Crime:
									SetCrime(Client, 0);
								}

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have taken \x0732CD32%i\x07FFFFFF away by hacking this computer", Random);
							}

							//Override:
							else
							{

								//Initulize:
								Random = GetRandomInt(750, 1250);

								//Crime:
								SetCrime(Client, (GetCrime(Client) + Random));

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - The combine has traced your hacking software!", Random);
							}

							//Initulize:
							OwnerCooldown[X] = 20;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait \x0732CD32%i\x07FFFFFF seconds for cooldown", OwnerCooldown[X]);
						}
					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You dont have \x0732CD32%s\x07FFFFFF", GetItemName(458));
			}
		}

		//Button Selected:
		else if(Result == 3)
		{

			//Loop:
			for(int X = 0; X <= MAXCOMPUTERS; X++)
			{

				//Ready:
				if(Computer[X] == Ent)
				{

					//Check:
					if(OwnsComputer[X] == SteamIdToInt(Client))
					{

						//Check:
						if(ComputerMoney[X] > 0)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have collected \x0732CD32%s\x07FFFFFF from this computer!", IntToMoney(ComputerMoney[X]));

							//Initulize:
							SetCash(Client, (GetCash(Client) + ComputerMoney[X]));

							//Crime:
							SetCrime(Client, (GetCrime(Client) + (ComputerMoney[X] * 2)));

							//Initulize:
							ComputerMoney[X] = 0;

							//Initulize:
							int Random = GetRandomInt(1, 10);

							//Check:
							if(Random == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - the combine has taken back control over the computer systems!");

								//Initulize:
								OwnsComputer[X] = -1;
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - this computer hasn't generated any money yet!");
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You can't collect any money as you dont own this computer");
					}
				}
			}
		}

		//Button Selected:
		else if(Result == 4)
		{

			//Initulize:
			SetMenuTarget(Client, Ent);

			//Handle:
			menu = CreateMenu(HandlePlayerComputerVendorMenu);

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
		if(Result == 5)
		{

			//Loop:
			for(int X = 0; X <= MAXCOMPUTERS; X++)
			{

				//Ready:
				if(Computer[X] == Ent)
				{

					//Initulize:
					if(GetItemAmount(Client, 462) > 0)
					{

						//Check:
						if(OwnerCooldown[X] == 0)
						{

							//Initulize:
							OwnerCooldown[X] = 15;

							//Declare:
							int Random1 = GetRandomInt(457, 461);

							//Declare:
							int Random2 = GetRandomInt(457, 461);

							//Set Item
							SaveItem(Client, 462, (GetItemAmount(Client, 462) - 1));

							//Set Item
							SaveItem(Client, Random1, (GetItemAmount(Client, Random1) + 1));

							//Set Item
							SaveItem(Client, Random2, (GetItemAmount(Client, Random2) + 1));

							//Initulize:
							int Random = GetRandomInt(250, 500);

							//Crime:
							SetCrime(Client, (GetCrime(Client) + Random));

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have managed to Steal 1x of %s and 1x of %s", GetItemName(Random1), GetItemName(Random2));
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait \x0732CD32%i\x07FFFFFF seconds for cooldown", OwnerCooldown[X]);
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough Hacking Software");
					}
				}
			}
		}

		//Button Selected:
		if(Result == 6)
		{

			//Initulize:
			SetMenuTarget(Client, Ent);

			//Loop:
			for(int X = 0; X <= MAXCOMPUTERS; X++)
			{

				//Ready:
				if(Computer[X] == Ent)
				{

					//Initulize:
					if(GetItemAmount(Client, 461) > 0)
					{

						//Set Item
						SaveItem(Client, 461, (GetItemAmount(Client, 461) - 1));

						//Draw Menu:
						DrawBankMenu(Client, Ent);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough Bank software");
					}
				}
			}
		}

		//Button Selected:
		else if(Result == 7)
		{

			//Declare:
			char AllBTC[32];
			char bAllBTC[32];

			//Format:
			Format(AllBTC, 32, "All (%0.7fBTC)", GetBitCoin(Client));

			Format(bAllBTC, 32, "%f", GetBitCoin(Client));

			//Handle:
			menu = CreateMenu(HandleComputerTradeBitcoinMenu);

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
public int HandlePlayerComputerVendorMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
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

public int HandleComputerTradeBitcoinMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

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

public void OnItemsUseHackComputer(int Client, int ItemId)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return;
	}

	//Prop Garbage Can:
	if(!IsValidComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return;
	}

	//In Distance:
	if(!IsInDistance(Client, Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");
	}

	//Initulize:
	if(GetItemAmount(Client, ItemId) > 0)
	{

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Check:
				if(OwnerCooldown[X] == 0)
				{

					//Declare:
					int Random = GetRandomInt(1, 10);

					//Check:
					if(Random > 5)
					{

						//Initulize:
						OwnsComputer[X] = SteamIdToInt(Client);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have managed to hack into this computer system");
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have failed to hack this computer");
					}

					//Declare:
					Random = GetRandomInt(500, 1000);

					//Crime:
					SetCrime(Client, (GetCrime(Client) + Random));

					//Set Item
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					OwnerCooldown[X] = 30;
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait %i seconds for cooldown", OwnerCooldown[X]);
				}
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough computer software to hack this computer");
	}

	//Return:
	return;
}

public void OnItemsUseBankHackSoftware(int Client, int ItemId)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return;
	}

	//Prop Garbage Can:
	if(!IsValidComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return;
	}

	//In Distance:
	if(!IsInDistance(Client, Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");
	}

	//Initulize:
	if(GetItemAmount(Client, ItemId) > 0)
	{

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Check:
				if(OwnerCooldown[X] == 0)
				{

					//Declare:
					int Random = GetRandomInt(150, 300);

					//Initlulize:
					SetCash(Client, (GetCash(Client) + Random));

					//Dynamic Computer Robbing:
					BeginRobbingComputerToSafe(Client, Random);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have used a \x0732CD32%s\x07FFFFFF and got \x0732CD32%s\x07FFFFFF out of this computer!", GetItemName(ItemId), IntToMoney(Random));

					//Crime:
					SetCrime(Client, (GetCrime(Client) + (Random * 2)));

					//Set Item
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					OwnerCooldown[X] = 30;
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait %i seconds for cooldown", OwnerCooldown[X]);
				}
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough computer software to hack this computer");
	}

	//Return:
	return;
}

public void OnItemsUseVendorSoftware(int Client, int ItemId)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return;
	}

	//Prop Garbage Can:
	if(!IsValidComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return;
	}

	//In Distance:
	if(!IsInDistance(Client, Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");
	}

	//Initulize:
	SetMenuTarget(Client, Ent);

	//Handle:
	Menu menu = CreateMenu(HandlePlayerComputerVendorMenu);

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

	//Return:
	return;
}

public void OnItemsUseNoCrimeSoftware(int Client, int ItemId)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return;
	}

	//Prop Garbage Can:
	if(!IsValidComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return;
	}

	//In Distance:
	if(!IsInDistance(Client, Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");
	}

	//Initulize:
	if(GetItemAmount(Client, ItemId) > 0)
	{

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Check:
				if(OwnerCooldown[X] == 0)
				{

					//Initulize:
					int Random = GetRandomInt(1, 10);

					//Check:
					if(Random > 6)
					{

						//Set Item
						SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

						//Initulize:
						Random = GetRandomInt(750, 1250);

						//Check
						if(GetCrime(Client) - Random > 0)
						{

							//Crime:
							SetCrime(Client, (GetCrime(Client) - Random));
						}

						//Override:
						else
						{

							//Crime:
							SetCrime(Client, 0);
						}

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have taken \x0732CD32%i\x07FFFFFF away by hacking this computer", Random);
					}

					//Override:
					else
					{

						//Initulize:
						Random = GetRandomInt(750, 1250);

						//Crime:
						SetCrime(Client, (GetCrime(Client) + Random));

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - The combine has traced your hacking software!", Random);
					}

					//Initulize:
					OwnerCooldown[X] = 20;
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait \x0732CD32%i\x07FFFFFF seconds for cooldown", OwnerCooldown[X]);
				}
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough computer software to hack this computer");
	}

	//Return:
	return;
}

public void OnItemsUseHackingSoftware(int Client, int ItemId)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return;
	}

	//Prop Garbage Can:
	if(!IsValidComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return;
	}

	//In Distance:
	if(!IsInDistance(Client, Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");
	}

	//Initulize:
	if(GetItemAmount(Client, ItemId) > 0)
	{

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Check:
				if(OwnerCooldown[X] == 0)
				{

					//Declare:
					int Random1 = GetRandomInt(457, 461);

					//Declare:
					int Random2 = GetRandomInt(457, 461);

					//Set Item
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Set Item
					SaveItem(Client, Random1, (GetItemAmount(Client, Random1) + 1));

					//Set Item
					SaveItem(Client, Random2, (GetItemAmount(Client, Random2) + 1));

					//Initulize:
					int Random = GetRandomInt(250, 500);

					//Crime:
					SetCrime(Client, (GetCrime(Client) + Random));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have managed to Steal 1x of %s and 1x of %s", GetItemName(Random1), GetItemName(Random2));

					//Initulize:
					OwnerCooldown[X] = 15;
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - please wait \x0732CD32%i\x07FFFFFF seconds for cooldown", OwnerCooldown[X]);
				}
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough computer software to hack this computer");
	}

	//Return:
	return;
}

public void OnItemsUseBankSoftware(int Client, int ItemId)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return;
	}

	//Prop Garbage Can:
	if(!IsValidComputer(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return;
	}

	//In Distance:
	if(!IsInDistance(Client, Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't access this computer because your too far away!");
	}

	//Initulize:
	if(GetItemAmount(Client, ItemId) > 0)
	{

		//Loop:
		for(int X = 0; X <= MAXCOMPUTERS; X++)
		{

			//Ready:
			if(Computer[X] == Ent)
			{

				//Set Item
				SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

				//Draw Menu:
				DrawBankMenu(Client, Ent);
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Hack|\x07FFFFFF - You have enough computer software to hack this computer");
	}

	//Return:
	return;
}

public void ComputerHud(int Client, int Ent, float NoticeInterval)
{

	//Check:
	if(!StrEqual(GetJob(Client), "Hacker") && !IsAdmin(Client) && !StrEqual(GetJob(Client), "Crime Lord"))
	{

		//Return:
		return;
	}

	//Declare:
	int Id = GetComputerIndexId(Ent);
	char FormatMessage[256];

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "Computer:\nHas %s worth of hackable files", IntToMoney(ComputerMoney[Id]));

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

public int GetComputerIndexId(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS; X++)
	{

		//Check:
		if(Computer[X] == Entity)
		{

			//Return:
			return X;
		}
	}

	//Return:
	return -1;
}

public bool IsValidComputer(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXCOMPUTERS; X++)
	{

		//Check:
		if(Computer[X] == Entity)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}
