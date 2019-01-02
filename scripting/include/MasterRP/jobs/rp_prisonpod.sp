//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_prisonpods_included_
  #endinput
#endif
#define _rp_prisonpods_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXPRISONPODS	10

int PrisonPodEnt[MAXPRISONPODS + 1] = -1;
float PrisonPodSpawn[MAXPRISONPODS + 1][3];

public void initPrisonPod()
{

	//Commands:
	RegAdminCmd("sm_createprisonpod", Command_CreatePrisonPod, ADMFLAG_ROOT, "<id> - Creates a prop");

	RegAdminCmd("sm_saveprisonPod", Command_SavePrisonPod, ADMFLAG_ROOT, "<id> - Save a computer for hacking");

	RegAdminCmd("sm_removeprisonpod", Command_RemovePrisonPod, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listprisonpods", Command_ListPrisonPodSpawn, ADMFLAG_SLAY, "- Lists all the Spawns in the database");

	//Beta
	RegAdminCmd("sm_wipeprisonpods", Command_WipePrisonPods, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbPrisonPodSpawn);

	//Loop:
	for(int Z = 0; Z <= MAXPRISONPODS; Z++)
	{

		//Initulize:
		PrisonPodEnt[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			PrisonPodSpawn[Z][i] = 69.0;
		}
	}
}

//Create Database:
public Action CreateSQLdbPrisonPodSpawn(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PrisonPodSpawn`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL, `Angles` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadPrisonPodSpawn(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= MAXPRISONPODS; Z++)
	{

		//Initulize:
		PrisonPodEnt[Z] = -1;

		//Loop:
		for(int i = 0; i < 3; i++)
		{

			//Initulize:
			PrisonPodSpawn[Z][i] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM PrisonPodSpawn WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadPrisonPodSpawn, query);
}

public void T_DBLoadPrisonPodSpawn(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadPrisonPodSpawn: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Prison Pods Zones Found in DB!");

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
			float EyeAng[3];

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
				EyeAng[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			PrisonPodSpawn[X] = Position;

			PrisonPodEnt[X] = CreatePrisonerPod(0, PrisonPodSpawn[X], EyeAng, 500, 1);

			//Accept:
			AcceptEntityInput(PrisonPodEnt[X], "disablemotion", PrisonPodEnt[X]);

			//Set Move:
			SetEntityMoveType(PrisonPodEnt[X], MOVETYPE_CUSTOM);
		}

		//Print:
		PrintToServer("|RP| - Prison Pods Found!");
	}
}

public void T_DBPrintPrisonPodSpawn(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintPrisonPodSpawn: Query failed! %s", error);
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

public void CheckOnPrisonPodDestroyed(int Entity)
{

	//Check:
	if(IsValidPrisonPod(Entity))
	{

		int X = GetPrisonPodIndex(Entity);

		//Timers:
		CreateTimer(300.0, RespawnVehiclePrisonPod, X);
	}
}

//Create Database:
public Action RespawnVehiclePrisonPod(Handle Timer, any Data)
{

	//Declare:
	int X = Data;

	//Check:
	if(IsPrisonPodIndexFree(X))
	{

		//Declare:
		float EyeAng[3] = {0.0,0.0,0.0};

		PrisonPodEnt[X] = CreatePrisonerPod(0, PrisonPodSpawn[X], EyeAng, 500, 1);

		//Accept:
		AcceptEntityInput(PrisonPodEnt[X], "disablemotion", PrisonPodEnt[X]);

		//Set Move:
		SetEntityMoveType(PrisonPodEnt[X], MOVETYPE_CUSTOM);
	}
}

public Action OnVehiclePrisonPodShift(int Client, int Vehicle)
{

	//Declare:
	int Driver = GetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer");

	//Check:
	if(Driver == -1)
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
		CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF You can't lock the vehicle whilst someone is inside");
	}
}

//Create Garbage Zone:
public Action Command_CreatePrisonPod(int Client, int Args)
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

	//Spawn Prop:
	CreatePrisonerPod(Client, Origin, EyeAngles, 500, 1);

	//Return:
	return Plugin_Handled;
}

//Save Prison Pod:
public Action Command_SavePrisonPod(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_saveprisonpod <id>");

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

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Prop Door:
	if(!StrEqual(ClassName, "prop_vehicle_prisoner_pod"))
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
	if(StringToInt(SpawnId) < 0 || StringToInt(SpawnId) > MAXPRISONPODS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_saveprisonpod <0-%i>", MAXPRISONPODS);

		//Return:
		return Plugin_Handled;
	}

	//Spawn Already Created:
	if(IsValidEdict(PrisonPodEnt[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a Prison Pod index into the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

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
	Format(query, sizeof(query), "INSERT INTO PrisonPodSpawn (`Map`,`ZoneId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(SpawnId), Position, Ang);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initulize:
	PrisonPodEnt[StringToInt(SpawnId)] = Ent;

	//Accept:
	AcceptEntityInput(Ent, "disablemotion", Ent);

	//Set Move:
	SetEntityMoveType(Ent, MOVETYPE_CUSTOM);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Saved Prison Pod \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemovePrisonPod(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeanlionspawn <0-%i>", MAXPRISONPODS);

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(PrisonPodSpawn[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	PrisonPodSpawn[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM PrisonPodSpawn WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed PrisonPod Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListPrisonPodSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "PrisonPod Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXPRISONPODS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM PrisonPodSpawn WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintPrisonPodSpawn, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipePrisonPods(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "PrisonPod Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXPRISONPODS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM PrisonPodSpawn WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public bool IsValidPrisonPod(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXPRISONPODS; X++)
	{

		//Check:
		if(PrisonPodEnt[X] == Ent)
		{

			//Return:
			return view_as<bool>(true);
		}
	}

	//Return:
	return view_as<bool>(false);
}

public int GetPrisonPodIndex(int Ent)
{

	//Loop:
	for(int X = 0; X <= MAXPRISONPODS; X++)
	{

		//Check:
		if(PrisonPodEnt[X] == Ent)
		{

			//Return:
			return view_as<int>(X);
		}
	}

	//Return:
	return view_as<int>(-1);
}
public bool IsPrisonPodIndexFree(int X)
{

	//Check:
	if(!IsValidEdict(PrisonPodEnt[X]))
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public int GetPrisonPodsOnMap()
{

	//Declare:
	int Vehicles = 0;

	//Loop:
	for(int X = 0; X <= MAXPRISONPODS; X++)
	{

		//Check:
		if(IsValidEdict(PrisonPodEnt[X]))
		{

			//Initulize:
			Vehicles += 1;
		}
	}

	//Return:
	return view_as<int>(Vehicles);
}
