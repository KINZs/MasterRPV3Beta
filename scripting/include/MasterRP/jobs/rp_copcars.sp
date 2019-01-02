//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_copcar_included_
  #endinput
#endif
#define _rp_copcar_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXPOLICECARS	10

int CopCar[MAXPOLICECARS + 1] = -1;
float CopCarSpawn[MAXPOLICECARS + 1][3];

public void initCopCar()
{

	//Commands:
	RegAdminCmd("sm_createcopcarspawn", Command_CreateCopCarZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removecopcarspawn", Command_RemoveCopCarZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listcopcarpawns", Command_ListCopCarSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipecopcarspawn", Command_WipeCopCarZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testcopcarspawn", Command_TestCopCarZone, ADMFLAG_ROOT, "<id> - Test CopCar Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbCopCarSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXPOLICECARS; Z++)
	{

		//Initulize:
		CopCar[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			CopCarSpawn[Z][i] = 69.0;
		}
	}
}

//Create Database:
public Action CreateSQLdbCopCarSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `CopCarSpawn`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadCopCarSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXPOLICECARS; Z++)
	{

		//Initulize:
		CopCar[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			CopCarSpawn[Z][i] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM CopCarSpawn WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadCopCarSpawn, query);
}

public void T_DBLoadCopCarSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadCopCarSpawn: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No CopCar Zones Found in DB!");

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
			float EyeAng[3] = {0.0,0.0,0.0};

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
			CopCarSpawn[X] = Position;

			CopCar[X] = CreateAPC(0, CopCarSpawn[X], EyeAng, 4000, 1);

			//Set do default classname
			SetEntityClassName(CopCar[X], "prop_vehicle_apc_cop");
		}

		//Print:
		PrintToServer("|RP| - Cop Car Zones Found!");
	}
}

public void T_DBPrintCopCarSpawn(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintCopCarSpawn: Query failed! %s", error);
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

public void CheckOnCopCarDestroyed(int Entity)
{

	//Check:
	if(IsValidCopCar(Entity))
	{

		int X = GetCopCarIndex(Entity);

		//Timers:
		CreateTimer(300.0, RespawnCopVehicle, X);
	}
}

//Create Database:
public Action RespawnCopVehicle(Handle Timer, any Data)
{

	//Declare:
	int X = Data;

	//Check:
	if(IsCarIndexFree(X))
	{

		//Declare:
		float EyeAng[3] = {0.0,0.0,0.0};

		CopCar[X] = CreateAPC(0, CopCarSpawn[X], EyeAng, 4000, 1);

		//Set do default classname
		SetEntityClassName(CopCar[X], "prop_vehicle_apc_cop");
	}
}

public Action OnCopVehicleShift(int Client, int Vehicle)
{

	//Declare:
	int Driver = GetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer");

	//Check:
	if(Driver == -1)
	{

		//Declare:
		int Speed = GetEntProp(Vehicle, Prop_Data, "m_nSpeed");

		//Check:
		if(Speed == 0)
		{

			//Declare:
			int VehicleLocked = GetEntProp(Vehicle, Prop_Data, "m_bLocked");

			//Check:
			if(VehicleLocked == 1)
			{

				//Send:
				SetEntProp(Vehicle, Prop_Data, "m_bLocked", 0);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have unlocked this vehicle");
			}

			//Override:
			else
			{

				//Send:
				SetEntProp(Vehicle, Prop_Data, "m_bLocked", 1);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you have locked this vehicle");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF you can't lock the vehicle whilst it is moving");
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF You can't lock the vehicle whilst someone is inside");
	}
}

public void RespawnCopVehicleOnPlayerExit(int Vehicle)
{

	//Check:
	if(!IsValidEdict(Vehicle))
	{

		//Return:
		return;
	}

	//Declare:
	float Position[3];
	float Ang[3];

	//Get Prop Data:
	GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", Position);
	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", Ang);

	//Health:
	int Health = GetEntProp(Vehicle, Prop_Data, "m_iHealth");

	int MaxHealth = GetEntProp(Vehicle, Prop_Data, "m_iMaxHealth");

	int VehicleLocked = GetEntProp(Vehicle, Prop_Data, "m_bLocked");

	//Request:
	RequestFrame(OnNextFrameKill, Vehicle);

	//Declare:
	int X = GetCopCarIndex(Vehicle);

	//Spawn:
	CopCar[X] = CreateAPC(0, Position, Ang, Health, VehicleLocked);

	//Set do default classname
	SetEntityClassName(CopCar[X], "prop_vehicle_apc_cop");

	//MaxHealth:
	SetEntProp(CopCar[X], Prop_Data, "m_iMaxHealth", MaxHealth);
}


public Action Command_CreateCopCarZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createcopcarspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createcopcarspawn <0-%i>", MAXPOLICECARS);

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
	if(CopCarSpawn[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE CopCarSpawn SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO CopCarSpawn (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	CopCarSpawn[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created CopCar npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveCopCarZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeanlionspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeanlionspawn <0-%i>", MAXPOLICECARS);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(CopCarSpawn[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	CopCarSpawn[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM CopCarSpawn WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed CopCar npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListCopCarSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "CopCar Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXPOLICECARS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM CopCarSpawn WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintCopCarSpawn, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeCopCarZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "CopCar Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXPOLICECARS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM CopCarSpawn WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestCopCarZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testcopcarspawn <id>");

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
	if(Id < 0 || Id > MAXPOLICECARS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testcopcarspawn <0-%i>", MAXPOLICECARS);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(IsValidEdict(CopCar[Id]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - unable to spawn due to another vehicle already index");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float EyeAng[3] = {0.0,0.0,0.0};

	//Id
	CopCar[Id] = CreateAPC(0, CopCarSpawn[Id], EyeAng, 4000, 1);

	//Set do default classname
	SetEntityClassName(CopCar[Id], "prop_vehicle_apc_Cop");

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, CopCarSpawn[Id][0], CopCarSpawn[Id][1], CopCarSpawn[Id][2]);

	//Return:
	return Plugin_Handled;
}

public void OnCopCarNPCDestroyedCheck(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXPOLICECARS; X++)
	{

		//Check:
		if(CopCar[X] == Entity)
		{

			//Initulize:
			CopCar[X] = -1;
		}
	}
}

public bool IsValidCopCar(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXPOLICECARS; X++)
	{

		//Check:
		if(CopCar[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public int GetCopCarIndex(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXPOLICECARS; X++)
	{

		//Check:
		if(CopCar[X] == Ent)
		{

			//Return:
			return view_as<int>(X);
		}
	}

	//Return:
	return view_as<int>(-1);
}
public bool IsCarIndexFree(int X)
{

	//Check:
	if(!IsValidEdict(CopCar[X]))
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public int GetCopCarsOnMap()
{

	//Declare:
	int Vehicles = 0;

	//Loop:
	for(int X = 0; X <= MAXPOLICECARS; X++)
	{

		//Check:
		if(IsValidEdict(CopCar[X]))
		{

			//Initulize:
			Vehicles += 1;
		}
	}

	//Return:
	return view_as<int>(Vehicles);
}
